namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/post-list-row.ui")]
    public class PostListRow : Gtk.ListBoxRow {
        [GtkChild] private Gtk.Label post_text;
        [GtkChild] private Gtk.Image post_thumbnail;
        [GtkChild] private Gtk.Button image_button;

        public PostListRow (Post t) {
            if (t.filename == null) {
                image_button.destroy ();
            } else {
                FourChan.get_thumbnail.begin (t, (obj, res) =>
                    post_thumbnail.pixbuf = FourChan.get_thumbnail.end (res));
            }

            post_text.label = FourChan.get_post_text (t.com);
        }
    }
}
