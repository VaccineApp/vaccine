namespace Vaccine {
    [GtkTemplate (ui = "/org/vaccine/app/main-window.ui")]
    public class MainWindow : Gtk.ApplicationWindow {
        /*unused*/ // [GtkChild] private Gtk.HeaderBar headerbar;
        [GtkChild] private Gtk.Notebook notebook;

        [GtkChild] private Gtk.Popover popover;
        [GtkChild] private Gtk.ListBox listbox;
        [GtkChild] private Gtk.SearchEntry searchentry;
        [GtkChild] private Gtk.Label buttonlabel;

        private CatalogWidget catalog;

        public MainWindow (Gtk.Application app) {
            Object (application: app);

            listbox.set_filter_func (row => (row.get_child () as Gtk.Label).name.contains (searchentry.text));
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

            listbox.row_selected.connect (row => {
                if (row != null) { // why is it null?
                    var child = row.get_child () as Gtk.Label;
                    FourChan.board = child.name;
                    buttonlabel.label = child.label;

                    popover.visible = false;
                    searchentry.text = "";

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
            key_press_event.connect (catalog.search_bar.handle_event);
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
    }
}
