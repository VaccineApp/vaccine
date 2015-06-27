namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/image-post-list-row.ui")]
    public class ImagePostListRow : Gtk.ListBoxRow {
        [GtkChild] private new Gtk.Label name; // TODO: rename
        [GtkChild] private Gtk.Label time;
        [GtkChild] private Gtk.Label post_no;

        [GtkChild] private Gtk.Image image;
        [GtkChild] private Gtk.Label comment;

        public ImagePostListRow (Post t) {
            this.name.label = t.name;
            this.time.label = t.now;
            this.post_no.label = t.no.to_string ();
            this.comment.label = t.com;

            if (t.filename != null) {
                FourChan.get_thumbnail.begin (t, (obj, res) => {
                    image.pixbuf = FourChan.get_thumbnail.end (res);
                });
            }
        }
    }
}
