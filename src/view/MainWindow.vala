[GtkTemplate (ui = "/vaccine/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {
    [GtkChild] private Gtk.ComboBoxText board_chooser;

    [GtkCallback] private void board_changed (Gtk.ComboBox widget) {
        var box = widget as Gtk.ComboBoxText;
        FourChan.get ().cur_board = box.get_active_text ().split ("/")[1];
    }

    public MainWindow (Gtk.Application app) {
        Object (application: app);

        FourChan.get ().get_boards.begin ((obj, res) => {
            var boards = FourChan.get ().get_boards.end (res);
            foreach (Board b in boards)
                board_chooser.append_text (@"/$(b.board)/ - $(b.title)");
        });

        var c = new CatalogWidget ();
        this.add (c);

        FourChan.get ().catalog_updated.connect ((o, catalog) => {
            c.clear ();
            foreach (Page p in catalog)
                foreach (ThreadOP t in p.threads)
                    c.add (t);
        });
        FourChan.get ().refresh_catalog.begin ();

        this.show_all ();
    }
}
