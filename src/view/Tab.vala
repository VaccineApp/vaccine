[GtkTemplate (ui = "/org/vaccine/app/tab.ui")]
public class Vaccine.Tab : Gtk.Box {
    [GtkChild] private Gtk.Label tablabel;
    [GtkChild] private Gtk.Button closebutton;

    private Gtk.Widget pane;

    public Tab (Gtk.Notebook notebook, Gtk.Widget child, bool closeable) {
        this.pane = child; // needed to avoid mem leaks
        child.bind_property ("name", tablabel, "label", BindingFlags.SYNC_CREATE);
        closebutton.visible = closeable;
        closebutton.clicked.connect (button => this.pane.destroy ());
    }
}
