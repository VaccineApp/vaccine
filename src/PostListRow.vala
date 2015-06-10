[GtkTemplate (ui = "/bloop/post-list-row.ui")]
public class PostListRow : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label name;
    [GtkChild] private Gtk.Label time;
    [GtkChild] private Gtk.Label post_no;

    [GtkChild] private Gtk.Image image;
    [GtkChild] private Gtk.Label comment;

    public PostListRow (ThreadInfo ti) {
        name.label = ti.name;
        time.label = ti.now;
        post_no.label = ti.no.to_string ();
        comment.label = ti.com;
    }
}
