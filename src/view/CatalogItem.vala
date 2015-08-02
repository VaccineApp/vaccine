namespace Vaccine {
    [GtkTemplate (ui = "/org/vaccine/app/catalog-item.ui")]
    public class CatalogItem : Gtk.Box {
        private unowned MainWindow main_window;

        [GtkChild] private Gtk.Stack image_stack;
        // [GtkChild] private Gtk.Overlay image_overlay;

        [GtkChild] private Gtk.Image post_image;
        [GtkChild] private Gtk.Label post_subject;
        [GtkChild] private Gtk.Label post_comment;

        private Cancellable? cancel = null;

        public ThreadOP op { get; construct; }

        public int64 post_no { get { return op.no; } }

        public CatalogItem (MainWindow win, ThreadOP t) {
            Object (op: t);
            this.main_window = win;

            if (t.filename != null) { // deleted files
                cancel = t.get_thumbnail (buf => {
                    cancel = null;
                    double ratio = (double) buf.width / buf.height;
                    int width, height;
                    if (buf.width > buf.height) {
                        width = 200;
                        height = (int) Math.round (width / ratio);
                    } else {
                        height = 200;
                        width = (int) Math.round (height * ratio);
                    }
                    post_image.pixbuf = buf.scale_simple (width, height, Gdk.InterpType.BILINEAR);
                    image_stack.set_visible_child (post_image);
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

        /* public override void clicked () {
            main_window.show_thread(post_no, op.pixbuf);
        } */
    }
}
