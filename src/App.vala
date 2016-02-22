namespace Vaccine {
    public const string PROGRAM_VERSION = "0.0.1";

    public class App : Gtk.Application {
        public static Settings settings;
        public FourChan chan = new FourChan ();
        public Bayes.Classifier code_classifier = new Bayes.Classifier ();
        PreferencesView? prefs = null;

        public App () {
            Object (application_id: "org.vaccine.app",
                    flags: ApplicationFlags.FLAGS_NONE);
            try {
                var istream = GLib.resources_open_stream ("/org/vaccine/app/code-training-set.json", GLib.ResourceLookupFlags.NONE);
                code_classifier.storage = new Bayes.StorageMemory.from_stream (istream);
                debug ("loaded source code training file");
            } catch (Error e) {
                debug ("failed to load training set: %s", e.message);
                code_classifier.storage = new Bayes.StorageMemory ();
            }
        }

        public MainWindow main_window { get; private set; }

        const ActionEntry[] actions = {
            { "preferences", show_preferences },
            { "about", show_about },
            { "quit", quit }
        };

        void show_preferences () {
            if (prefs != null)
                return;

            prefs = new PreferencesView ();
            prefs.transient_for = main_window;
            prefs.delete_event.connect (() => {
                prefs = null;
                return Gdk.EVENT_PROPAGATE;
            });
            prefs.present ();
        }

        void show_about () {
            string[] authors = {"benwaffle", "Prince781"};
            Gtk.show_about_dialog (get_active_window (),
                program_name: "Vaccine",
                copyright: "Copyright © 2016 - Vaccine Developers",
                authors: authors,
                website: "https://github.com/VaccineApp/vaccine",
                website_label: "GitHub",
                license_type: Gtk.License.GPL_3_0,
                comments: "A GTK3 imageboard client",
                logo_icon_name: "applications-internet");
        }

        protected override void startup () {
            base.startup ();
            add_action_entries (actions, this);

            settings = new Settings (application_id);
            settings.bind ("use-dark-theme",
                Gtk.Settings.get_default (), "gtk-application-prefer-dark-theme",
                SettingsBindFlags.DEFAULT);

            main_window = new MainWindow (this);

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource (resource_base_path + "/style.css");
            Gtk.StyleContext.add_provider_for_screen (main_window.get_screen (),
                provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        protected override void activate () {
            base.activate ();
            main_window.present ();
        }
    }
}

int main (string[] args) {
    var app = new Vaccine.App ();
    Gst.init (ref args);
    int res = app.run (args);
    Gst.deinit ();
    return res;
}
