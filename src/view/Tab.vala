[GtkTemplate (ui = "/vaccine/tab.ui")]
public class Tab : Gtk.Box {
    [GtkChild] private Gtk.Label tablabel;
    [GtkChild] private Gtk.Button closebutton;

    public Tab (Gtk.Notebook notebook, Gtk.Widget child, string title, bool closeable) {
        tablabel.label = title;
        closebutton.visible = closeable;

        closebutton.clicked.connect(button => notebook.remove (child));
    }
}
