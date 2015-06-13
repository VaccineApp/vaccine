[GtkTemplate (ui = "/vaccine/post-list-row.ui")]
public class PostListRow : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label name;
    [GtkChild] private Gtk.Label time;
    [GtkChild] private Gtk.Label post_no;

    [GtkChild] private Gtk.Image image;
    [GtkChild] private Gtk.Label comment;

    public PostListRow (ThreadOP t) {
        name.label = t.name;
        time.label = t.now;
        post_no.label = t.no.to_string ();
        comment.label = t.com;
    }
}
