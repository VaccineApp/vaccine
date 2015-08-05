namespace Vaccine {
    [GtkTemplate (ui = "/org/vaccine/app/catalog-widget.ui")]
    public class CatalogWidget : Gtk.Box {
        [GtkChild] public Gtk.FlowBox layout;
        [GtkChild] public Gtk.SearchBar search_bar;
        [GtkChild] public Gtk.SearchEntry search_entry;

        public CatalogWidget () {
            name = "Catalog";
            search_entry.changed.connect (() => {
                if (search_entry.text == "")
                    layout.set_filter_func (null);
                else
                    layout.set_filter_func (child => {
                        var item = child.get_child () as CatalogItem;
                        string query = search_entry.text.down ();
                        string subject = item.post_subject.label.down ();
                        string comment = item.post_comment.label.down ();
                        return subject.contains (query) || comment.contains (query);
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
