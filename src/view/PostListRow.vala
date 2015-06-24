[GtkTemplate (ui = "/vaccine/post-list-row.ui")]
public class PostListRow : Gtk.ListBoxRow {
    [GtkChild] private new Gtk.Label name; // TODO: rename
    [GtkChild] private Gtk.Label time;
    [GtkChild] private Gtk.Label post_no;

    [GtkChild] private Gtk.Label comment;

    public PostListRow (Post t) {
        this.name.label = t.name;
        this.time.label = t.now;
        this.post_no.label = t.no.to_string ();
        this.comment.label = t.com;
    }
}
