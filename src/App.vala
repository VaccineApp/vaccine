namespace Vaccine {
    public const string PROGRAM_VERSION = "v0.1-alpha";

    public class App : Gtk.Application {
        public FourChan chan = new FourChan ();
        public string progpath { get; construct; }
        public string progdir { get; construct; }

        public App (string path) {
            Object (application_id: "org.vaccine.app",
                    flags: ApplicationFlags.FLAGS_NONE,
                    progpath: path, progdir: Path.get_dirname (path));
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

        Settings load_settings () {
            Settings prefs;

            if (progdir == "/usr/bin")
                return new Settings (application_id);
            string dir = Environment.get_current_dir ();
            // load settings from custom directory (for now)
            try {
                SettingsSchemaSource sss = new SettingsSchemaSource.from_directory (@"$(dir)/schemas/", null, true);
                SettingsSchema schema = sss.lookup (application_id, false);
                prefs = new Settings.full (schema, null, null);
                prefs.bind ("use-dark-theme", Gtk.Settings.get_default (),
                               "gtk-application-prefer-dark-theme", SettingsBindFlags.DEFAULT);
            } catch (Error e) {
                debug (e.message);
                return new Settings (application_id);
            }
            return prefs;
        }
    }
}

int main (string[] args) {
    var app = new Vaccine.App (args [0]);
    return app.run (args);
}
