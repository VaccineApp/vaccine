namespace Vaccine {
    public class App : Gtk.Application {
        public FourChan chan = new FourChan ();

        public App () {
            Object (application_id: "popcnt.Vaccine",
                    flags: ApplicationFlags.FLAGS_NONE);
        }

        private MainWindow main_window;

        protected override void startup () {
            base.startup ();
            main_window = new MainWindow (this);
        }

        protected override void activate () {
            base.activate ();
            main_window.present ();
        }
    }
}

int main (string[] args) {
    var app = new Vaccine.App ();
    return app.run (args);
}
