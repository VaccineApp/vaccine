namespace Vaccine {
    [GtkTemplate (ui = "/org/vaccine/app/catalog-widget.ui")]
    public class CatalogWidget : Gtk.ScrolledWindow {
        [GtkChild] public Gtk.FlowBox layout;

        public CatalogWidget () {
            name = "Catalog";
            layout.child_activated.connect (child => {
                if (!child.is_selected ())
                    (child.get_child () as CatalogItem).show_thread ();
            });
        }

        public new void add (MainWindow win, ThreadOP t) {
            layout.add (new CatalogItem (win, t));
        }

        public void clear () {
            layout.foreach (w => w.destroy ());
        }
    }
}
