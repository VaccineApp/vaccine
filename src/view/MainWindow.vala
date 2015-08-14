[GtkTemplate (ui = "/org/vaccine/app/main-window.ui")]
public class Vaccine.MainWindow : Gtk.ApplicationWindow {
    /*unused*/ // [GtkChild] private Gtk.HeaderBar headerbar;
    [GtkChild] private Gtk.Label window_title;
    [GtkChild] private Gtk.SearchEntry window_searchentry;
    [GtkChild] private Gtk.Stack headerbar_stack;

    [GtkChild] private Gtk.Notebook notebook;

    [GtkChild] private Gtk.Button choose_board_button;
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

    public int dialogs = 0;

    void close_tab () {
        if (notebook.get_nth_page (notebook.page) != catalog)
            notebook.remove_page (notebook.page);
    }

    void catalog_find () {
        window_searchentry.grab_focus_without_selecting ();
        headerbar_stack.set_visible_child (window_searchentry);
        notebook.page = notebook.page_num (catalog); // TODO: thread search
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

        app.set_accels_for_action ("win.close_tab", {"<Control>W"});
        app.set_accels_for_action ("win.catalog_find", {"<Control>F"});
        app.set_accels_for_action ("win.next_tab", {"<Control>Tab"});
        app.set_accels_for_action ("win.prev_tab", {"<Control><Shift>Tab"});

        listbox.set_filter_func (row => (row.get_child () as Gtk.Label).name.contains (board_search.text));
        board_search.changed.connect (listbox.invalidate_filter);

        notebook.page_added.connect ((w, p) =>
            notebook.show_tabs = (notebook.get_n_pages() > 1));
        notebook.page_removed.connect ((w, p) =>
            notebook.show_tabs = (notebook.get_n_pages() > 1));

        window_title.bind_property ("label", this, "title", BindingFlags.SYNC_CREATE, (bind, src, ref target) => {
            target = @"$(src.get_string ()) \u2015 Vaccine";
            return true;
        });

        notebook.bind_property ("page", window_title, "label", BindingFlags.DEFAULT, (bind, src, ref target) => {
            var page = notebook.get_nth_page ((int) src);
            assert (page != null);
            target = @"$(page.name)";
            return true;
        });

        FourChan.get_boards.begin ((obj, res) => {
            var boards = FourChan.get_boards.end (res);
            foreach (Board b in boards) {
                var row = new Gtk.Label (@"/$(b.board)/ - $(b.title)");
                row.name = b.board;
                row.margin = 6;
                row.halign = Gtk.Align.START;
                listbox.add (row);
            }
            listbox.show_all ();
        });

        window_title.event.connect (event => {
            catalog_find ();
            return true;
        });

        window_searchentry.changed.connect (() => {
            // TODO: thread search
            if (window_searchentry.text == "")
                catalog.layout.set_filter_func (null);
            else
                catalog.layout.set_filter_func (child => {
                    var item = child.get_child () as CatalogItem;
                    string query = Markup.escape_text (window_searchentry.text.down ());
                    string subject = item.post_subject.label.down ();
                    string comment = item.post_comment.label.down ();
                    return subject.contains (query) || comment.contains (query);
                });
        });

        listbox.row_selected.connect (row => {
            if (row != null) { // why is it null?
                var child = row.get_child () as Gtk.Label;
                FourChan.board = child.name;
                choose_board_button.label = child.label;

                popover.visible = false;
                board_search.text = "";

                notebook.set_current_page (0);
            }
        });

        catalog = new CatalogWidget ();
        add_page (catalog, false, false);

        FourChan.catalog.downloaded.connect ((o, board, threads) => {
            catalog.clear ();
            foreach (Page page in threads)
                foreach (ThreadOP t in page.threads)
                    catalog.add (this, t);
        });

        // set up events
        key_press_event.connect (key => {
            if (notebook.page == 0) {
                headerbar_stack.set_visible_child (window_searchentry);
                window_searchentry.grab_focus_without_selecting ();
                return window_searchentry.handle_event (key);
            } else // TODO: ThreadPane search
                return false;
        });

        window_searchentry.focus_out_event.connect (event => {
            headerbar_stack.set_visible_child (window_title);
            return false;
        });

        this.show_all ();
    }

    public void show_thread (int64 no, Gdk.Pixbuf op_thumbnail) {
        FourChan.get_thread.begin (FourChan.board, no, (obj, res) => {
            Thread thread = FourChan.get_thread.end (res);
            var widget = new PanelView.with_name (thread.title);
            widget.add (new ThreadPane (thread, op_thumbnail));
            add_page (widget);
        });
    }

    private void add_page (Gtk.Widget w, bool closeable = true, bool reorderable = true) {
        var tab = new Tab (notebook, w, closeable);
        int i = notebook.append_page (w, tab);
        notebook.set_tab_reorderable (tab, reorderable);
        notebook.child_set (w, "reorderable", reorderable);
        notebook.set_current_page (i);
    }
}
