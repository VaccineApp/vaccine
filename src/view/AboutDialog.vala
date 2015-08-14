[GtkTemplate (ui = "/org/vaccine/app/about-dialog.ui")]
public class Vaccine.AboutDialog : Gtk.AboutDialog {
    public AboutDialog (Gtk.ApplicationWindow app_window) {
        version = PROGRAM_VERSION;
        set_transient_for (app_window);
    }
}
