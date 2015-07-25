using Vaccine.Util;

namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/thread-pane.ui")]
    public class ThreadPane : Gtk.ScrolledWindow {
        [GtkChild] private Gtk.ListBox list;
        [GtkChild] private Gtk.Box heading_box;
        [GtkChild] private Gtk.Label heading;

        public Thread thread { get; construct; }
        public bool is_reply { get; construct; }

        private void add_separator (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
                if (before != null && row.get_header () == null)
                    row.set_header (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        }

        public ThreadPane (Thread thread, bool reply = false, string title = "") {
            Object (thread: thread, is_reply: reply);
            name = new StringModifier (thread.get_tab_title ()).replace (/\s/, "_").text;
            list.set_header_func (add_separator);
            list.bind_model (thread, item => new PostListRow (item as Post));

            if (reply) {
                heading.label = @"<span size=\"large\">$title</span>";
                var provider = new Gtk.CssProvider ();
                provider.load_from_resource ("/vaccine/thread-pane.css");
                Gtk.StyleContext.add_provider_for_screen (
                    get_screen (),
                    provider,
                    0
                );
            } else
                heading_box.destroy ();
        }

        [GtkCallback] public void close () {
            this.destroy ();
        }
    }
}
