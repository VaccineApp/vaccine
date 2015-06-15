[GtkTemplate (ui = "/vaccine/post-list-row.ui")]
public class PostListRow : Gtk.ListBoxRow {
    [GtkChild] private new Gtk.Label name; // TODO: rename
    [GtkChild] private Gtk.Label time;
    [GtkChild] private Gtk.Label post_no;

    [GtkChild] private Gtk.Image image;
    [GtkChild] private Gtk.Label comment;

    public PostListRow (ThreadOP t, string board) {
        assert (t != null);

        name.label = t.name;
        time.label = t.now;
        post_no.label = t.no.to_string ();
        comment.label = t.com;

        if (t.filename != null) {
            var url = @"https://i.4cdn.org/$board/$(t.tim)s.jpg";
            load_image.begin (url);
        }
    }

    private async void load_image(string url) {
        var soup = new Soup.Session ();
        var msg = new Soup.Message ("GET", url);
        var stream = yield soup.send_async (msg);
        image.pixbuf = yield new Gdk.Pixbuf.from_stream_async (stream, null);
    }
}
