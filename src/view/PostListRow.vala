namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/post-list-row.ui")]
    public class PostListRow : Gtk.ListBoxRow {
        [GtkChild] private Gtk.Label post_time;
        [GtkChild] private Gtk.Label post_number;
        [GtkChild] private Gtk.Label post_text;
        [GtkChild] private Gtk.Image post_thumbnail;

        public PostListRow (Post t) {
            post_time.label = FourChan.get_post_time (t.time);
            post_number.label = @"#$(t.no)";
            post_text.label = FourChan.get_post_text (t.com);

            if (t.filename == null) {
                post_thumbnail.destroy ();
            } else {
                FourChan.get_thumbnail.begin (t, (obj, res) => {
                    post_thumbnail.pixbuf = FourChan.get_thumbnail.end (res);
                });
            }
        }
    }
}
