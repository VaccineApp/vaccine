using Vaccine.Util;

namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/thread-pane.ui")]
    public class ThreadPane : Gtk.ScrolledWindow {
        [GtkChild] private Gtk.ListBox list;
        public Thread thread { get; construct; }

        private void add_separator (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
                if (before != null && row.get_header () == null)
                    row.set_header (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        }

        public ThreadPane (Thread thread) {
            Object (thread: thread);
            name = new StringModifier (thread.get_tab_title ()).replace (/\s/, "_").text;
            list.set_header_func (add_separator);
            list.bind_model (thread, item => new PostListRow (item as Post));
        }
    }
}
