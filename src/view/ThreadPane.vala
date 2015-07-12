namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/thread-pane.ui")]
    public class ThreadPane : Gtk.ScrolledWindow {
        [GtkChild] private Gtk.ListBox list;

        private void add_separator (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
                if (before != null && row.get_header () == null)
                    row.set_header (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        }

        public ThreadPane (Thread thread) {
            this.name = thread.get_tab_title ();
            this.list.set_header_func (add_separator);
            this.list.bind_model (thread, item => new PostListRow (item as Post));
        }
    }
}
