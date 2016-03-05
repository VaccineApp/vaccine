[GtkTemplate (ui = "/org/vaccine/app/ui/preferences-view.ui")]
class Vaccine.PreferencesView : Gtk.Window {
    [GtkChild] Gtk.Switch show_trips;
    [GtkChild] Gtk.Switch filter_nsfw_content;
    [GtkChild] Gtk.SpinButton image_cache_size_mb;
    [GtkChild] Gtk.Switch use_dark_theme;

    public PreferencesView () {
        App.settings.bind ("show-trips", show_trips, "active", SettingsBindFlags.DEFAULT);
        App.settings.bind ("filter-nsfw-content", filter_nsfw_content, "active", SettingsBindFlags.DEFAULT);
        App.settings.bind ("image-cache-size-mb", image_cache_size_mb, "value", SettingsBindFlags.DEFAULT);
        App.settings.bind ("use-dark-theme", use_dark_theme, "active", SettingsBindFlags.DEFAULT);
    }
}
