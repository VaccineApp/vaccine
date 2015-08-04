namespace Vaccine {
    [GtkTemplate (ui = "/org/vaccine/app/catalog-item.ui")]
    public class CatalogItem : Gtk.Box {
        private weak MainWindow main_window;

        [GtkChild] private Gtk.Stack image_stack;

        [GtkChild] private Gtk.Image post_image;
        [GtkChild] public Gtk.Label post_subject;
        [GtkChild] public Gtk.Label post_comment;

        [GtkChild] private Gtk.Revealer post_stats;
        [GtkChild] private Gtk.Label num_posts;
        [GtkChild] private Gtk.Label num_images;

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
                Gdk.threads_add_timeout (1618, () => {
                    num_posts.label = @"<span size=\"small\"><b>R</b>: $(op.replies)</span>";
                    num_posts.tooltip_markup = @"<b>$(op.replies)</b> repl$(op.replies != 1 ? "ies" : "y")";
                    num_images.label = @"<span size=\"small\"><b>I</b>: $(op.images)</span>";
                    num_images.tooltip_markup = @"<b>$(op.images)</b> image$(op.images != 1 ? "s" : "")";
                    post_stats.reveal_child = true;
                    return false;
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

        public void show_thread () {
            main_window.show_thread(post_no, op.pixbuf);
        }
    }
}
