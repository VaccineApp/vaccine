using Gee;

[GtkTemplate (ui = "/vaccine/thread-widget.ui")]
public class ThreadWidget : Gtk.ScrolledWindow {
    [GtkChild] private Gtk.ListBox list;

    public ThreadWidget (Thread t) {

    }
}
