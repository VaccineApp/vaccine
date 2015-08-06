namespace Vaccine {
    [GtkTemplate (ui = "/org/vaccine/app/main-window.ui")]
    public class MainWindow : Gtk.ApplicationWindow {
        /*unused*/ // [GtkChild] private Gtk.HeaderBar headerbar;
        [GtkChild] private Gtk.Notebook notebook;

        [GtkChild] private Gtk.Popover popover;
        [GtkChild] private Gtk.ListBox listbox;
        [GtkChild] private Gtk.SearchEntry board_search;
        [GtkChild] private Gtk.Label buttonlabel;

        private CatalogWidget catalog;

        const ActionEntry[] shortcuts = {
            { "close_tab", close_tab },
            { "catalog_find", catalog_find },
            { "next_tab", next_tab },
            { "prev_tab", prev_tab },
        };

        void close_tab () {
            if (notebook.page != 0)
                notebook.remove_page (notebook.page);
        }

        void catalog_find () {
            notebook.page = 0; // TODO: thread search
            catalog.search_bar.set_search_mode (true);
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

            listbox.row_selected.connect (row => {
                if (row != null) { // why is it null?
                    var child = row.get_child () as Gtk.Label;
                    FourChan.board = child.name;
                    buttonlabel.label = child.label;

                    popover.visible = false;
                    board_search.text = "";

                    notebook.set_current_page (0);
                }
            });

            catalog = new CatalogWidget ();
            add_page (catalog, false);

            FourChan.catalog.downloaded.connect ((o, board, threads) => {
                catalog.clear ();
                foreach (Page page in threads)
                    foreach (ThreadOP t in page.threads)
                        catalog.add (this, t);
            });

            // set up events
            key_press_event.connect (search);
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

        private void add_page (Gtk.Widget w, bool closeable = true) {
            int i = notebook.append_page (w, new Tab (notebook, w, closeable));
            notebook.set_current_page (i);
        }

        private bool search (Gdk.EventKey key) {
            if (catalog.get_visible ())
                return catalog.search_bar.handle_event (key);
            else    // TODO: ThreadPane search
                return false;
        }
    }
}
