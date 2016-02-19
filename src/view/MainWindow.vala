[GtkTemplate (ui = "/org/vaccine/app/main-window.ui")]
public class Vaccine.MainWindow : Gtk.ApplicationWindow {
    [GtkChild] private Gtk.HeaderBar headerbar;
    [GtkChild] private Gtk.SearchEntry searchentry;
    [GtkChild] private Gtk.Button choose_board_button;
    [GtkChild] private Gtk.ToggleButton show_search_bar_button;
    [GtkChild] private Gtk.Button open_in_browser_button;
    [GtkChild] private Gtk.Button refresh_button;

    [GtkChild] private Gtk.SearchBar searchbar;
    [GtkChild] private Gtk.Stack content_stack;
    [GtkChild] private Gtk.Notebook notebook;
    [GtkChild] private Gtk.Alignment no_content;
    [GtkChild] private Gtk.Label no_content_description;

    // board chooser
    [GtkChild] private Gtk.Popover popover;
    [GtkChild] private Gtk.ListBox listbox;
    [GtkChild] private Gtk.SearchEntry board_search;

    private CatalogWidget catalog;

    const ActionEntry[] shortcuts = {
        { "close_tab", close_tab },
        { "catalog_find", catalog_find },
        { "next_tab", next_tab },
        { "prev_tab", prev_tab }
    };

    void close_tab () {
        var page = notebook.get_nth_page (notebook.page);
        if (page != catalog)
            page.destroy ();
    }

    // TODO: thread search
    void catalog_find () {
        if (!searchbar.search_mode_enabled) {
            searchbar.search_mode_enabled = true;
            searchentry.grab_focus_without_selecting ();
        } else {
            searchbar.search_mode_enabled = false;
        }
    }

    void next_tab () {
        notebook.page = (notebook.page+1) % notebook.get_n_pages ();
    }

    void prev_tab () {
        notebook.page = (notebook.page-1) % notebook.get_n_pages ();
    }

    public MainWindow (Gtk.Application app) {
        Object (application: app);

        add_action_entries (shortcuts, this);

        app.set_accels_for_action ("app.quit", {"<Primary>Q"});
        app.set_accels_for_action ("win.close_tab", {"<Primary>W"});
        app.set_accels_for_action ("win.catalog_find", {"<Primary>F"});
        app.set_accels_for_action ("win.next_tab", {"<Primary>Tab"});
        app.set_accels_for_action ("win.prev_tab", {"<Primary><Shift>Tab"});

        Variant geom = App.settings.get_value ("win-geom");
        int x, y, width, height;
        geom.get ("(iiii)", out x, out y, out width, out height);
        move (x, y);
        resize (width, height);


        // meme magic:
        const string[] no_content_texts = {
            "Select a board to begin",
            "Select a board to waste time on",
            "Select a board to shitpost about animu",
            "Start wasting time",
            "Get out of your mom's basement"
        };

        no_content_description.label = no_content_texts [Random.int_range (0, no_content_texts.length)];

        App.settings.changed["filter-nsfw-content"].connect (listbox.invalidate_filter);
        board_search.changed.connect (listbox.invalidate_filter);

        FourChan.get_boards.begin ((obj, res) => {
            var boards = FourChan.get_boards.end (res);
            listbox.foreach (w => w.destroy ());
            foreach (Board b in boards) {
                var row = new Gtk.Label ("/%s/ - %s".printf (b.board, b.title));
                row.name = b.board;
                row.margin = 6;
                row.halign = Gtk.Align.START;
                row.set_data ("nsfw", b.ws_board == 0);
                listbox.add (row);
            }
            listbox.show_all ();
        });

        listbox.set_filter_func (row => {
            var label = row.get_child () as Gtk.Label;
            if (App.settings.get_boolean ("filter-nsfw-content") && label.get_data ("nsfw"))
                return false;
            if (board_search.text.length == 0)
                return true;
            return label.name.contains (board_search.text);
        });

        notebook.page_added.connect ((w, p) =>
            notebook.show_tabs = (notebook.get_n_pages() > 1));
        notebook.page_removed.connect ((w, p) =>
            notebook.show_tabs = (notebook.get_n_pages() > 1));

        show_search_bar_button.bind_property ("active", searchbar, "search-mode-enabled", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        notebook.bind_property ("page", headerbar, "title", BindingFlags.DEFAULT, (bind, src, ref target) => {
            var page = notebook.get_nth_page ((int) src);
            assert (page != null);
            target = page.name;
            return true;
        });

        listbox.row_selected.connect (row => {
            if (row != null) { // why is it null?
                var child = row.get_child () as Gtk.Label;
                FourChan.board = child.name;
                open_in_browser_button.sensitive = false;
                refresh_button.sensitive = false;
                choose_board_button.label = child.label;

                popover.visible = false;
                board_search.text = "";

                content_stack.visible_child = notebook;
                notebook.page = notebook.page_num (catalog);
            }
        });

        catalog = new CatalogWidget ();
        add_page (catalog, false, false);

        FourChan.catalog.downloaded.connect ((o, board, threads) => {
            catalog.clear ();
            foreach (Page page in threads)
                foreach (ThreadOP t in page.threads)
                    catalog.add (this, t);
            open_in_browser_button.sensitive = true;
            refresh_button.sensitive = true;
        });

        this.show_all ();
    }

    public override bool delete_event (Gdk.EventAny ev) {
        int x, y, width, height;
        get_position (out x, out y);
        get_size (out width, out height);
        App.settings.set ("win-geom", "(iiii)", x, y, width, height);
        return false;
    }

    public void show_thread (int64 no, Gdk.Pixbuf op_thumbnail) {
        var panelview = new PanelView ();
        var threadpane = new ThreadPane (FourChan.board, no, op_thumbnail);
        var thread = new Thread (FourChan.board, no);
        threadpane.set_model (thread);

        panelview.name = "Loading…";
        FourChan.dl_thread.begin (thread, (obj, res) => {
            FourChan.dl_thread.end (res);
            panelview.name = thread.get_title ();
        });

        panelview.add (threadpane);
        add_page (panelview);
    }

    private void add_page (NotebookPage page, bool closeable = true, bool reorderable = true) {
        var tab = new Tab (notebook, page, closeable);
        int i = notebook.append_page (page, tab);
        notebook.child_set (page, "reorderable", reorderable);
        notebook.set_current_page (i);

        page.notify["name"].connect (() => {
            notebook.notify_property ("page");
        });
    }

    [GtkCallback]
    private void open_in_browser (Gtk.Button button) {
        var current = notebook.get_nth_page (notebook.page);
        assert (current is NotebookPage);
        ((NotebookPage) current).open_in_browser ();
    }

    [GtkCallback]
    private void search_entry_changed (Gtk.Editable entry) {
        var current = notebook.get_nth_page (notebook.page);
        var text = ((Gtk.Entry) entry).text;
        assert (current is NotebookPage);
        ((NotebookPage) current).filter (text);
    }

    [GtkCallback]
    private void refresh (Gtk.Button button) {
        var current = notebook.get_nth_page (notebook.page);
        assert (current is NotebookPage);
        ((NotebookPage) current).refresh ();
    }
}
