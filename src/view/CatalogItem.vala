[GtkTemplate (ui = "/vaccine/catalog-item.ui")]
public class CatalogItem : Gtk.Box {
    [GtkChild] private Gtk.Image image;
    [GtkChild] private Gtk.Label com;

    public CatalogItem (ThreadOP t) {
        FourChan.get ().load_post_thumbnail.begin (t, (obj, res) => {
            image.pixbuf = FourChan.get ().load_post_thumbnail.end (res);
        });
        com.label = t.com;
    }
}
