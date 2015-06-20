[GtkTemplate (ui = "/vaccine/post-list-row.ui")]
public class PostListRow : Gtk.ListBoxRow {
    [GtkChild] private new Gtk.Label name; // TODO: rename
    [GtkChild] private Gtk.Label time;
    [GtkChild] private Gtk.Label post_no;

    [GtkChild] private Gtk.Image image;
    [GtkChild] private Gtk.Label comment;

    public PostListRow (ThreadOP t) {
        name.label = t.name;
        time.label = t.now;
        post_no.label = t.no.to_string ();
        comment.label = t.com;

        if (t.filename != null)
            FourChan.get ().load_post_thumbnail.begin (t, (obj, res) => {
                image.pixbuf = FourChan.get ().load_post_thumbnail.end (res);
            });
    }
}
