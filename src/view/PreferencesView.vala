[GtkTemplate (ui = "/org/vaccine/app/preferences-view.ui")]
class Vaccine.PreferencesView : Gtk.Window {
    [GtkChild] Gtk.Switch show_names;
    [GtkChild] Gtk.Switch show_tripcodes;
    [GtkChild] Gtk.Switch filter_nsfw_content;
    [GtkChild] Gtk.SpinButton image_cache_size_mb;
    [GtkChild] Gtk.Switch use_dark_theme;

    public PreferencesView (Gtk.ApplicationWindow window, Settings settings) {
        set_transient_for (window);
        settings.bind ("show-names", show_names, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("show-tripcodes", show_tripcodes, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("filter-nsfw-content", filter_nsfw_content, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("image-cache-size-mb", image_cache_size_mb, "value", SettingsBindFlags.DEFAULT);
        settings.bind ("use-dark-theme", use_dark_theme, "active", SettingsBindFlags.DEFAULT);
    }
}
