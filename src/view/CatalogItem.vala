[GtkTemplate (ui = "/vaccine/catalog-item.ui")]
public class CatalogItem : Gtk.Box {
    [GtkChild] private Gtk.Image image;
    [GtkChild] private Gtk.Label com;

    public CatalogItem (ThreadOP t) {
        if (t.filename != null) { // deleted files
            FourChan.get ().load_post_thumbnail.begin (t, (obj, res) => {
                var buf = FourChan.get ().load_post_thumbnail.end (res);
                assert (image != null);
                image.pixbuf = buf;
            });
        }
        com.label = t.com;
    }
}
