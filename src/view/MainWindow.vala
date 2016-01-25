[GtkTemplate (ui = "/org/vaccine/app/main-window.ui")]
public class Vaccine.MainWindow : Gtk.ApplicationWindow {
    [GtkChild] private Gtk.HeaderBar headerbar;
    [GtkChild] private Gtk.SearchEntry searchentry;
    [GtkChild] private Gtk.Button choose_board_button;
    [GtkChild] private Gtk.ToggleButton show_search_bar_button;
    [GtkChild] private Gtk.Button open_in_browser_button;

    [GtkChild] private Gtk.SearchBar searchbar;
    [GtkChild] private Gtk.Notebook notebook;

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

        listbox.set_filter_func (row => (row.get_child () as Gtk.Label).name.contains (board_search.text));
        board_search.changed.connect (listbox.invalidate_filter);

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

        FourChan.get_boards.begin ((obj, res) => {
            var boards = FourChan.get_boards.end (res);
            foreach (Board b in boards) {
                var row = new Gtk.Label ("/%s/ - %s".printf (b.board, b.title));
                row.name = b.board;
                row.margin = 6;
                row.halign = Gtk.Align.START;
                listbox.add (row);
            }
            listbox.show_all ();
        });

        listbox.row_selected.connect (row => {
            if (row != null) { // why is it null?
                var child = row.get_child () as Gtk.Label;
                FourChan.board = child.name;
                open_in_browser_button.sensitive = false;
                choose_board_button.label = child.label;

                popover.visible = false;
                board_search.text = "";

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
        });

        this.show_all ();
    }

    public void show_thread (int64 no, Gdk.Pixbuf op_thumbnail) {
        var panelview = new PanelView ();
        var threadpane = new ThreadPane (FourChan.board, no, op_thumbnail);

        FourChan.get_thread.begin (FourChan.board, no, (obj, res) => {
            Thread thread = FourChan.get_thread.end (res);
            threadpane.set_model (thread);

            panelview.name = thread.get_title ();
        });

        panelview.name = "Loading…";
        panelview.add (threadpane);
        add_page (panelview);
    }

    private void add_page (NotebookPage page, bool closeable = true, bool reorderable = true) {
        var tab = new Tab (notebook, page, closeable);
        int i = notebook.append_page (page, tab);
        notebook.child_set (page, "reorderable", reorderable);
        notebook.set_current_page (i);
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
