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

        public ThreadPane (Thread thread, ListModel? model = null, string title = "") {
            Object (model: model);
            name = new StringModifier (thread.title).replace (/\s/, "_").window (0, 32).text;
            list.set_header_func (add_separator);
            list.bind_model (model ?? thread, item => new PostListRow (item as Post));

            if (model != null && !(model.get_item (0) as Post).isOP) {
                heading.label = @"<span size=\"large\">$title</span>";
                Stylizer.set_widget_css (this, "/vaccine/thread-pane.css");
            } else
                heading_box.destroy ();
        }

        [GtkCallback] public void close () {
            this.destroy ();
        }
    }
}
