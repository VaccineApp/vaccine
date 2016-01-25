[GtkTemplate (ui = "/org/vaccine/app/catalog-widget.ui")]
public class Vaccine.CatalogWidget : Gtk.Box, NotebookPage {
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

    public void open_in_browser () {
        try {
            AppInfo.launch_default_for_uri ("https://boards.4chan.org/%s/".printf (FourChan.board), null);
        } catch (Error e) {
            warning (e.message);
        }
    }

    public void filter (string text) {
        if (text == "")
            layout.set_filter_func (null);
        else
            layout.set_filter_func (child => {
                var item = child.get_child () as CatalogItem;
                string query = Markup.escape_text (text.down ());
                string subject = item.post_subject.label.down ();
                string comment = item.post_comment.label.down ();
                return subject.contains (query) || comment.contains (query);
            });
    }

    public void refresh () {
        FourChan.catalog.download.begin (FourChan.board);
    }
}
