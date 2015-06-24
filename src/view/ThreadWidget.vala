using Gee;

[GtkTemplate (ui = "/vaccine/thread-widget.ui")]
public class ThreadWidget : Gtk.ScrolledWindow {
    [GtkChild] private Gtk.ListBox list;

    public ThreadWidget (Thread thread) {
        this.name = thread.name;
        this.list.bind_model (thread, item => new PostListRow (item as Post));
    }
}
