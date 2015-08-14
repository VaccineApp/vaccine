namespace Vaccine {
    public const string PROGRAM_VERSION = "0.0.1";

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
            load_settings ();

            main_window = new MainWindow (this);

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource(@"$resource_base_path/style.css");
            Gtk.StyleContext.add_provider_for_screen (main_window.get_screen (),
                provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        protected override void activate () {
            base.activate ();
            add_action_entries (actions, this);
            main_window.present ();
        }

        public Settings settings { get; private set; }

        private void load_settings () {
#if DEBUG
            try {
                SettingsSchemaSource sss = new SettingsSchemaSource.from_directory ("schemas/", null, true);
                SettingsSchema schema = sss.lookup (application_id, false);
                this.settings = new Settings.full (schema, null, null);
            } catch (Error e) {
                debug (e.message);
                this.settings = new Settings (application_id);
            }
#else
            this.settings = new Settings (application_id);
#endif

            this.settings.bind ("use-dark-theme",
                        Gtk.Settings.get_default (), "gtk-application-prefer-dark-theme",
                        SettingsBindFlags.DEFAULT);
        }
    }
}

int main (string[] args) {
    var app = new Vaccine.App ();
    return app.run (args);
}
