namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/catalog-item.ui")]
    public class CatalogItem : Gtk.Button {
        private unowned MainWindow main_window;

        [GtkChild] private Gtk.Image post_image;
        [GtkChild] private Gtk.Label post_comment;

        private int64 post_no = -1;

        public CatalogItem (MainWindow win, ThreadOP t) {
            this.main_window = win;
            this.post_no = t.no;

            if (t.filename != null) { // deleted files
                FourChan.get_thumbnail.begin (FourChan.board, t, (obj, res) => {
                    if (post_image != null) // I think it is null when being finalized
                        post_image.pixbuf = FourChan.get_thumbnail.end (res);
                });
            }
            this.post_comment.label = FourChan.get_post_text (t.com);
        }

        public override void clicked () {
            main_window.show_thread(post_no);
        }
    }
}
