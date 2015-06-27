namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/thread-widget.ui")]
    public class ThreadWidget : Gtk.ScrolledWindow {
        [GtkChild] private Gtk.ListBox list;

        public ThreadWidget (Thread thread) {
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
