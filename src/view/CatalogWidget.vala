[GtkTemplate (ui = "/vaccine/catalog-widget.ui")]
public class CatalogWidget : Gtk.ScrolledWindow {
    [GtkChild] public Gtk.FlowBox layout;

    public void add (ThreadOP t) {
        layout.add (new CatalogItem (t));
    }

    public void clear () {
        layout.foreach(w => layout.remove (w));
    }
}
