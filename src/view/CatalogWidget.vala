namespace Vaccine {
    [GtkTemplate (ui = "/org/vaccine/app/catalog-widget.ui")]
    public class CatalogWidget : Gtk.Box {
        [GtkChild] public Gtk.FlowBox layout;
        [GtkChild] public Gtk.SearchBar search_bar;
        [GtkChild] public Gtk.SearchEntry search_entry;

        public CatalogWidget () {
            name = "Catalog";
            layout.child_activated.connect (child => {
                if (!child.is_selected ())
                    (child.get_child () as CatalogItem).show_thread ();
            });
            search_entry.changed.connect (() => {
                if (search_entry.text == "")
                    layout.set_filter_func (null);
                else
                    layout.set_filter_func (child => {
                        string query = search_entry.text;
                        var item = child.get_child () as CatalogItem;
                        string? subject = item.op.sub;
                        string comment = Stripper.transform_post (item.op.com ?? "") ?? item.op.com;
                        return (subject != null && query.match_string (subject, true)) || query.match_string (comment, true);
                    });
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
