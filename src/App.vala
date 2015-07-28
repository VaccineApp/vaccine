namespace Vaccine {
    public class App : Gtk.Application {
        public FourChan chan = new FourChan ();

        public App () {
            Object (application_id: "org.vaccine.app", flags: ApplicationFlags.FLAGS_NONE);
        }

        private MainWindow main_window;

        const ActionEntry[] actions = {
            { "about", show_about },
            { "quit", quit }
        };

        void show_about () {
            debug ("about");
        }

        protected override void startup () {
            base.startup ();
            main_window = new MainWindow (this);
        }

        protected override void activate () {
            base.activate ();
            add_action_entries (actions, this);
            main_window.present ();
        }
    }
}

int main (string[] args) {
    var app = new Vaccine.App ();
    return app.run (args);
}
