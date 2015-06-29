namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/thread-pane.ui")]
    public class ThreadPane : Gtk.ScrolledWindow {
        [GtkChild] private Gtk.ListBox list;

        public ThreadPane (Thread thread) {
            this.name = thread.name;
            this.list.set_header_func ((row, before) =>
                row.set_header (before != null ?
                    row.get_header () ?? new Gtk.Separator (Gtk.Orientation.HORIZONTAL) :
                    new Gtk.Separator (Gtk.Orientation.HORIZONTAL))
            );
            this.list.bind_model (thread, item => {
                var p = item as Post;
                if (p.filename != null)
                    return new ImagePostListRow (p);
                else
                    return new PostListRow (p);
            });
        }
    }
}
