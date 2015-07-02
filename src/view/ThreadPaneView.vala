namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/thread-pane-view.ui")]
    public class ThreadPaneView : Gtk.Box {
        public ThreadPaneView (Thread thread) {
            add_pane(new ThreadPane (thread));
            this.show_all ();
        }

        public void add_pane (Gtk.Widget w) {
            /*
            var revealer = new Gtk.Revealer ();
            revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_LEFT);
            revealer.set_transition_duration (700);
            revealer.add (w);
            revealer.visible = false; */
            this.pack_start (w, true, true, 0);
            /*
            GLib.Timeout.add (1000, () => {
                revealer.set_reveal_child (true);
                return false;
            }); */
        }
    }
}
