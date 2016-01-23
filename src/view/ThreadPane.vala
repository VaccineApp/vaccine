[GtkTemplate (ui = "/org/vaccine/app/thread-pane.ui")]
public class Vaccine.ThreadPane : Gtk.Box {
    [GtkChild] private Gtk.ListBox list;
    [GtkChild] private Gtk.Box heading_box;
    [GtkChild] private Gtk.Label heading;
    [GtkChild] private Gtk.Button closebutton;

    // we already have it from the catalog
    public Gdk.Pixbuf? op_thumb { private get; construct; }

    // UI is prioritized, call set_model later when you have data
    public void set_model (ListModel model) {
        list.bind_model (model, item => {
            var post = item as Post;
            return new PostListRow (post, post.isOP ? op_thumb : null);
        });
    }

    public ThreadPane (Gdk.Pixbuf? op_thumb = null) {
        Object (op_thumb: op_thumb);
    }

    public ThreadPane.with_title (string title) {
        this ();
        // OP could theoretically guess the post number
        // assert (!model.get_item (0).isOP);
        heading_box.visible = true;
        heading.label = "<span size=\"large\">" + title + "</span>";
    }
}
