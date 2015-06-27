namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/thread-pane-view.ui")]
    public class ThreadPaneView : Gtk.Box {
        public ThreadPaneView (Thread thread) {
            add_pane(new ThreadWidget (thread));
            this.show_all();
        }

        public void add_pane (Gtk.Widget w) {
            var revealer = new Gtk.Revealer ();
            revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_LEFT);
            revealer.set_transition_duration (4000);
            revealer.add (w);
            this.pack_start (revealer, true, true, 0);
            revealer.set_reveal_child (true);
            // TODO: call revealer after tab is visible
        }
    }
}
