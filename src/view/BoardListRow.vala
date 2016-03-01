[GtkTemplate (ui = "/org/vaccine/app/board-list-row.ui")]
public class BoardListRow : Gtk.ListBoxRow {
    [GtkChild] Gtk.Label board_label;
    [GtkChild] Gtk.Image star_image;

    public BoardListRow (string label) {
        board_label.label = label;
    }

    [GtkCallback]
    private bool row_enter (Gdk.EventCrossing ev) {
        if (ev.detail != Gdk.NotifyType.INFERIOR)
            star_image.show ();
        return true;
    }

    [GtkCallback]
    private bool row_leave (Gdk.EventCrossing ev) {
        if (ev.detail != Gdk.NotifyType.INFERIOR)
            star_image.hide ();
        return true;
    }
}
