[GtkTemplate (ui = "/org/vaccine/app/tab.ui")]
public class Vaccine.Tab : Gtk.Box {
    [GtkChild] private Gtk.Label tablabel;
    [GtkChild] private Gtk.Button closebutton;

    public Tab (Gtk.Notebook notebook, Gtk.Widget child, bool closeable) {
        child.bind_property ("name", tablabel, "label", BindingFlags.SYNC_CREATE);
        closebutton.visible = closeable;
        closebutton.clicked.connect(button => child.destroy ());
    }
}
