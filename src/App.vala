namespace Vaccine {
    public class App : Gtk.Application {
        public FourChan chan = new FourChan ();

        public App () {
            Object (application_id: "org.vaccine.app", flags: ApplicationFlags.FLAGS_NONE);
        }

        private MainWindow main_window;

        private Settings settings;

        const ActionEntry[] actions = {
            { "about", show_about },
            { "quit", quit }
        };

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

            // load settings
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
                settings = new Settings.full ((!) schema, null, null);
                bool use_dark_theme = settings.get_boolean ("use-dark-theme");
                stdout.printf (@"use_dark_theme = $use_dark_theme\n");
            }
        }

        protected override void activate () {
            base.activate ();
            main_window.present ();
        }
    }
    public const string PROGRAM_VERSION = "v0.1-alpha";
}

int main (string[] args) {
    var app = new Vaccine.App ();
    return app.run (args);
}
