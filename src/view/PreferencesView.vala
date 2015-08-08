[GtkTemplate (ui = "/org/gnome/vaccine/preferences-view.ui")]
class Vaccine.PreferencesView : Gtk.Window {
    private MainWindow parent_win;

    [GtkChild] Gtk.Switch show_trips;
    [GtkChild] Gtk.Switch filter_nsfw_content;
    [GtkChild] Gtk.SpinButton image_cache_size_mb;
    [GtkChild] Gtk.Switch use_dark_theme;

    private Settings settings;

    public PreferencesView (Gtk.ApplicationWindow window, Settings settings) {
        this.settings = settings;
        set_transient_for (window);
        settings.bind ("show-trips", show_trips, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("filter-nsfw-content", filter_nsfw_content, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("image-cache-size-mb", image_cache_size_mb, "value", SettingsBindFlags.DEFAULT);
        settings.bind ("use-dark-theme", use_dark_theme, "active", SettingsBindFlags.DEFAULT);
        parent_win = window as MainWindow;
        ++parent_win.dialogs;
    }

    public override void destroy () {
        --parent_win.dialogs;
    }
}
