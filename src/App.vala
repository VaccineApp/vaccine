namespace Vaccine {
    public class App : Gtk.Application {
        public FourChan chan = new FourChan ();

        public App () {
            Object (application_id: "org.vaccine.app", flags: ApplicationFlags.FLAGS_NONE);
        }

        private MainWindow main_window;

        private Settings settings;

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

            main_window = new MainWindow (this);

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource("/org/vaccine/app/style.css");
            Gtk.StyleContext.add_provider_for_screen (main_window.get_screen (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            load_settings ();
        }

        protected override void activate () {
            base.activate ();
            add_action_entries (actions, this);
            main_window.present ();
        }

        void load_settings () {
            // load settings from custom directory (for now)
            SettingsSchemaSource? sss;
            try {
                sss = new SettingsSchemaSource.from_directory ("schemas/", null, true);
            } catch (Error e) {
                error ("could not create SSS: "+e.message);
            }
            SettingsSchema? schema = ((!) sss).lookup ("org.vaccine.app", false);
            if (schema == null) {
                error ("could not look up schema");
            } else {
                settings = new Settings.full (schema, null, null);
                settings.bind ("use-dark-theme", Gtk.Settings.get_default (), "gtk-application-prefer-dark-theme", SettingsBindFlags.DEFAULT);
            }
        }
    }
    public const string PROGRAM_VERSION = "v0.1-alpha";
}

int main (string[] args) {
    var app = new Vaccine.App ();
    return app.run (args);
}
