[GtkTemplate (ui = "/org/vaccine/app/error-dialog.ui")]
class Vaccine.ErrorDialog : Gtk.Dialog {
    [GtkChild] Gtk.Label label;

    public ErrorDialog (string message) {
        Object (use_header_bar: 1);
        var header = this.get_header_bar () as Gtk.HeaderBar;
        header.title = "Error";
        header.subtitle = "oh shit son";
        label.label = message;

        this.set_transient_for ((Application.get_default () as Gtk.Application).active_window);
        this.show_all ();
        this.run ();
    }
}
