[GtkTemplate (ui = "/vaccine/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {
    [GtkChild] private Gtk.ComboBoxText board_chooser;
    [GtkChild] private Gtk.ListBox post_list;

    public MainWindow (Gtk.Application app) {
        Object (application: app);

        var ch = FourChan.get ();
        assert (ch != null);
        ch.get_boards.begin ((obj, res) => {
            var boards = ch.get_boards.end (res);
            foreach (Board b in boards)
                board_chooser.append_text (@"/$(b.board)/ - $(b.title)");
        });

        ch.cur_board = "g";
        ch.catalog_updated.connect ((o, catalog) => {
            foreach (Page p in catalog)
                foreach (ThreadOP t in p.threads)
                    post_list.add (new PostListRow (t));
        });
        ch.refresh_catalog ();

        this.show_all ();
    }
}
