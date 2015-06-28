namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/main-window.ui")]
    public class MainWindow : Gtk.ApplicationWindow {
        [GtkChild] private Gtk.HeaderBar headerbar;
        [GtkChild] private Gtk.Notebook notebook;

        [GtkChild] private Gtk.ListBox listbox;
        [GtkChild] private Gtk.SearchEntry searchentry;

        public MainWindow (Gtk.Application app) {
            Object (application: app);

            listbox.set_filter_func (row => (row.get_child () as Gtk.Label).label.down ().contains (searchentry.text.down ()));
            searchentry.changed.connect (listbox.invalidate_filter);

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

            listbox.row_selected.connect (row => FourChan.board = row.get_child ().name);

            var catalog = new CatalogWidget ();
            add_page (catalog, null, false);

            FourChan.catalog.downloaded.connect ((o, data) => {
                catalog.clear ();
                foreach (Page p in data)
                    foreach (ThreadOP t in p.threads)
                        catalog.add (this, t);
            });

            this.show_all ();
        }

        public void show_thread (int64 no) {
            FourChan.get_thread.begin (FourChan.board, no, (obj, res) => {
                Thread thread = FourChan.get_thread.end (res);
                var widget = new ThreadWidget (thread);
                add_page (widget, FourChan.get_tab_title (thread), true);
            });
        }

        private void add_page (Gtk.Widget w, string? name, bool c) {
            int i = notebook.append_page (w, new Tab (notebook, w, name, c));
            notebook.set_current_page (i);
        }
    }
}
