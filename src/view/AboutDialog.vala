[GtkTemplate (ui = "/org/vaccine/app/ui/about-dialog.ui")]
public class Vaccine.AboutDialog : Gtk.AboutDialog {
    public AboutDialog (Gtk.Window parent) { transient_for = parent; }
}
