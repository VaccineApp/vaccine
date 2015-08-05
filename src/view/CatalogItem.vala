namespace Vaccine {
    [GtkTemplate (ui = "/org/vaccine/app/catalog-item.ui")]
    public class CatalogItem : Gtk.Button {
        // TODO: show # of replies (and make it look good)
        private weak MainWindow main_window;

        [GtkChild] private Gtk.Stack image_stack;

        [GtkChild] private Gtk.DrawingArea post_image;
        [GtkChild] public Gtk.Label post_subject;
        [GtkChild] public Gtk.Label post_comment;

        private Cancellable? cancel = null;

        public ThreadOP op { get; construct; }

        public CatalogItem (MainWindow win, ThreadOP t) {
            Object (op: t);
            this.main_window = win;

            post_image.draw.connect(cr => {
                if (op.pixbuf == null)
                    return false;
                op.get_thumbnail (pixbuf => {
                    var mat = cr.get_matrix ();

                    Gtk.Allocation alloc;
                    post_image.get_allocation (out alloc);

                    double scale_x = (double) alloc.width / pixbuf.width;
                    double scale_y = (double) alloc.height / pixbuf.height;

                    if (scale_x * pixbuf.height >= alloc.height) {
                        mat.scale (scale_x, scale_x);
                        double offset = (alloc.height - pixbuf.height * scale_x) / 2;
                        mat.translate (0, offset);
                    } else if (scale_y * pixbuf.width >= alloc.width) {
                        mat.scale (scale_y, scale_y);
                        double offset = (alloc.width - pixbuf.width * scale_y) / 2;
                        mat.translate (offset, 0);
                    } else {
                        assert_not_reached ();
                    }

                    cr.set_matrix (mat);
                    Gdk.cairo_set_source_pixbuf (cr, pixbuf, 0, 0);
                    cr.paint ();
                });
                return true;
            });

            if (t.filename != null) { // deleted files
                cancel = t.get_thumbnail (buf => {
                    cancel = null;
                    image_stack.set_visible_child (post_image);
                });
            }
            this.post_comment.label = FourChan.get_post_text (t.com);
            if (t.sub != null)
                this.post_subject.label = @"<span weight=\"bold\" size=\"larger\">$(t.sub)</span>";
            else
                post_subject.destroy ();
        }

        ~CatalogItem () {
            if (cancel != null)
                cancel.cancel ();
        }

        [GtkCallback]
        public void show_thread () {
            main_window.show_thread(op.no, op.pixbuf);
        }
    }
}
