namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/thread-pane.ui")]
    public class ThreadPane : Gtk.ScrolledWindow {
        [GtkChild] private Gtk.ListBox list;
        [GtkChild] private Gtk.Box heading_box;
        [GtkChild] private Gtk.Label heading;

        public ListModel model { get; construct; }

        private void add_separator (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
            if (before != null && row.get_header () == null)
                row.set_header (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        }

        public ThreadPane (Thread thread, ListModel? model = null, Gdk.Pixbuf? op_thumb = null) {
            Object (model: model);
            list.set_header_func (add_separator);
            list.bind_model (model ?? thread, item => {
                var post = item as Post;
                return new PostListRow (post, post.isOP ? op_thumb : null);
            });
        }

        public ThreadPane.with_title (Thread thread, ListModel model, string title) {
            this (thread, model);
            name = new StringModifier (thread.title).replace (/\s/, "_").window (0, 32).text;
            if (model != null && !(model.get_item (0) as Post).isOP) {
                heading_box.visible = true;
                heading.label = @"<span size=\"large\">$title</span>";
                Stylizer.set_widget_css (this, "/vaccine/thread-pane.css");
            }
        }

        [GtkCallback] public void close () {
            this.destroy ();
        }
    }
}
