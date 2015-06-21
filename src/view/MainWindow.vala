[GtkTemplate (ui = "/vaccine/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {
    [GtkChild] private Gtk.ComboBoxText board_chooser;
    [GtkChild] private Gtk.Stack stack;

    [GtkCallback] private void board_changed (Gtk.ComboBox widget) {
        FourChan.board = board_chooser.get_active_id ();
    }

    public MainWindow (Vaccine app) {
        Object (application: app);

        FourChan.get_boards.begin ((obj, res) => {
            var boards = FourChan.get_boards.end (res);
            foreach (Board b in boards)
                board_chooser.append (b.board, @"/$(b.board)/ - $(b.title)");
        });

        var catalog = new CatalogWidget ();
        stack.add_titled(catalog, "catalog", "Catalog");

        FourChan.catalog.downloaded.connect ((o, data) => {
            catalog.clear ();
            foreach (Page p in data)
                foreach (ThreadOP t in p.threads)
                    catalog.add (this, t);
        });

        this.show_all ();
    }

    public void show_thread (int64 no) {
        FourChan.get_thread.begin (no, (obj, res) => {
            var thread = FourChan.get_thread.end (res);
            var widget = new ThreadWidget (thread);
            stack.add_titled (widget, @"thread $no", @"/$(FourChan.board)/$no");
            stack.set_visible_child (widget);
        });
    }
}
