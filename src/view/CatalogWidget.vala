[GtkTemplate (ui = "/org/vaccine/app/catalog-widget.ui")]
public class Vaccine.CatalogWidget : Gtk.Box, NotebookPage {
    [GtkChild] public Gtk.FlowBox layout;

    public string search_text { get; set; }

    public CatalogWidget () {
        name = "Catalog";
        layout.set_filter_func (child => {
            if (search_text == null)
                return true;
            var item = child.get_child () as CatalogItem;
            string query = Markup.escape_text (search_text.down ());
            string subject = item.post_subject.label.down ();
            string comment = item.post_comment.label.down ();
            return subject.contains (query) || comment.contains (query);
        });
        notify["search-text"].connect (layout.invalidate_filter);
    }

    public new void add (MainWindow win, ThreadOP t) {
        layout.add (new CatalogItem (win, t));
    }

    public void clear () {
        layout.foreach (w => w.destroy ());
    }

    public void open_in_browser () {
        try {
            AppInfo.launch_default_for_uri ("https://boards.4chan.org/%s/".printf (FourChan.board), null);
        } catch (Error e) {
            warning (e.message);
        }
    }

    public void refresh () {
        FourChan.catalog.download.begin (FourChan.board);
    }
}
