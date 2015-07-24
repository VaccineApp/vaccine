namespace Vaccine {
    public class App : Gtk.Application {
        public FourChan chan = new FourChan ();

        public App () {
            Object (application_id: "vaccine.Vaccine",
                    flags: ApplicationFlags.FLAGS_NONE);
        }

        private MainWindow main_window;

        const ActionEntry[] actions = {
            { "about", show_about },
        };

        void show_about () {
            debug ("about");
        }

        protected override void startup () {
            base.startup ();
            main_window = new MainWindow (this);

            add_action_entries (actions, this);

            var builder = new Gtk.Builder.from_resource ("/vaccine/menu.xml");
            var menu = builder.get_object ("menu") as MenuModel;
            set_app_menu (menu);
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
