namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/catalog-item.ui")]
    public class CatalogItem : Gtk.Button {
        private unowned MainWindow main_window;

        [GtkChild] private Gtk.Image post_image;
        [GtkChild] private Gtk.Label post_subject;
        [GtkChild] private Gtk.Label post_comment;

        private Cancellable? cancel = null;

        private int64 post_no = -1;

        public CatalogItem (MainWindow win, ThreadOP t) {
            this.main_window = win;
            this.post_no = t.no;

            if (t.filename != null) { // deleted files
                cancel = FourChan.get_thumbnail (t, buf => {
                    cancel = null;
                    post_image.pixbuf = buf;
                });
            }
            this.post_comment.label = FourChan.get_post_text (t.com);
            if (t.sub != null)
                this.post_subject.label = @"<b>$(t.sub)</b>";
            else
                post_subject.destroy ();
        }

        ~CatalogItem () {
            if (cancel != null)
                cancel.cancel ();
        }

        public override void clicked () {
            main_window.show_thread(post_no);
        }
    }
}
