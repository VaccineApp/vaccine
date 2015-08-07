namespace Vaccine {
    public const string PROGRAM_VERSION = "v0.1-alpha";

    public class App : Gtk.Application {
        public FourChan chan = new FourChan ();

        public App () {
            Object (application_id: "org.vaccine.app",
                    flags: ApplicationFlags.FLAGS_NONE);
        }

        private MainWindow main_window;


        const ActionEntry[] actions = {
            { "preferences", show_preferences },
            { "about", show_about },
            { "quit", quit }
        };

        void show_preferences () {
            new PreferencesView (main_window, settings).present ();
        }

        void show_about () {
            new AboutDialog (main_window).present ();
        }

        protected override void startup () {
            base.startup ();
            add_action_entries (actions, this);
            settings = load_settings ();

            main_window = new MainWindow (this);

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource("/org/vaccine/app/style.css");
            Gtk.StyleContext.add_provider_for_screen (main_window.get_screen (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        protected override void activate () {
            base.activate ();
            add_action_entries (actions, this);
            main_window.present ();
        }

        public Settings settings { get; private set; }

        Settings load_settings () {
            Settings prefs;

            // load settings from custom directory (for now)
            try {
                SettingsSchemaSource sss = new SettingsSchemaSource.from_directory ("schemas/", null, true);
                SettingsSchema schema = sss.lookup ("org.vaccine.app", false);
                prefs = new Settings.full (schema, null, null);
                prefs.bind ("use-dark-theme", Gtk.Settings.get_default (),
                               "gtk-application-prefer-dark-theme", SettingsBindFlags.DEFAULT);
            } catch (Error e) {
                debug (e.message);
                return new Settings ("org.vaccine.app");
            }
            return prefs;
        }
    }
}

int main (string[] args) {
    var app = new Vaccine.App ();
    return app.run (args);
}
