[GtkTemplate (ui = "/org/vaccine/app/board-list-row.ui")]
public class BoardListRow : Gtk.ListBoxRow {
    [GtkChild] Gtk.Label board_label;
    [GtkChild] Gtk.Image star_image;

    public BoardListRow (string label) {
        board_label.label = label;
    }
}
