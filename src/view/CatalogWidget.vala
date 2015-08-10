[GtkTemplate (ui = "/org/vaccine/app/catalog-widget.ui")]
public class Vaccine.CatalogWidget : Gtk.Box {
    [GtkChild] public Gtk.FlowBox layout;

    public CatalogWidget () {
        name = "Catalog";
    }

    public new void add (MainWindow win, ThreadOP t) {
        layout.add (new CatalogItem (win, t));
    }

    public void clear () {
        layout.foreach (w => w.destroy ());
    }
}
