[GtkTemplate (ui = "/vaccine/tab.ui")]
public class Tab : Gtk.Box {
    [GtkChild] private Gtk.Label tablabel;
    [GtkChild] private Gtk.Button closebutton;

    public Tab (string title, bool closeable) {
        tablabel.label = title;
        closebutton.visible = closeable;
    }
}
