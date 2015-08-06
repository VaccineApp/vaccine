[GtkTemplate (ui = "/org/vaccine/app/preferences-view.ui")]
class Vaccine.PreferencesView : Gtk.Window {
    public PreferencesView (Gtk.ApplicationWindow window, Settings settings) {
        set_transient_for (window);
    }
}
