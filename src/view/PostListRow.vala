namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/post-list-row.ui")]
    public class PostListRow : Gtk.ListBoxRow {
        [GtkChild] private Gtk.Label post_text;
        [GtkChild] private Gtk.Image post_thumbnail;
        [GtkChild] private Gtk.Button image_button;

        private Cancellable? cancel = null;

        public PostListRow (Post t) {
            if (t.filename == null) {
                image_button.destroy ();
            } else {
                cancel = FourChan.get_thumbnail (t, buf => {
                    cancel = null;
                    post_thumbnail.pixbuf = buf;
                });
            }

            post_text.label = FourChan.get_post_text (t.com);
        }

        ~PostListRow () {
            if (cancel != null)
                cancel.cancel ();
        }
    }
}
