[GtkTemplate (ui = "/vaccine/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {
    [GtkChild] private Gtk.ComboBoxText board_chooser;
    [GtkChild] private Gtk.ListBox post_list;

    public MainWindow (Gtk.Application app) {
        Object (application: app);
        FourChan.foreach_board.begin (b => {
            board_chooser.append_text (@"/$(b.board)/ - $(b.title)");
        });
        FourChan.foreach_catalog.begin (ti => {
            post_list.add (new PostListRow (ti));
        });

        this.show_all ();
    }
}
