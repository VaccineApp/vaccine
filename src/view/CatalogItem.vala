[GtkTemplate (ui = "/org/vaccine/app/catalog-item.ui")]
public class Vaccine.CatalogItem : Gtk.Button {
    // TODO: show # of replies (and make it look good)
    private weak MainWindow main_window;

    [GtkChild] private Gtk.Stack image_stack;

    [GtkChild] private Gtk.DrawingArea post_image;
    [GtkChild] public Gtk.Label post_subject;
    [GtkChild] public Gtk.Label post_comment;
    [GtkChild] public Gtk.Label post_n_replies;

    private Cancellable? cancel = null;

    public ThreadOP op { get; construct; }

    public CatalogItem (MainWindow win, ThreadOP t) {
        Object (op: t);
        this.main_window = win;

        post_image.draw.connect (cr => {
            if (op.pixbuf == null)
                return false;

            Gtk.Allocation alloc;
            post_image.get_allocation (out alloc);

            double scale_x = (double) alloc.width / op.pixbuf.width;
            double scale_y = (double) alloc.height / op.pixbuf.height;

            if (scale_x * op.pixbuf.height >= alloc.height) {
                double offset = (alloc.height - op.pixbuf.height * scale_x) / 2;
                cr.translate (0, offset);
                cr.scale (scale_x, scale_x);
            } else if (scale_y * op.pixbuf.width >= alloc.width) {
                double offset = (alloc.width - op.pixbuf.width * scale_y) / 2;
                cr.translate (offset, 0);
                cr.scale (scale_y, scale_y);
            } else {
                assert_not_reached ();
            }

            Gdk.cairo_set_source_pixbuf (cr, op.pixbuf, 0, 0);
            cr.paint ();
            return Gdk.EVENT_STOP;
        });

        if (t.filename != null) { // deleted files
            cancel = t.get_thumbnail (buf => {
                cancel = null;
                image_stack.set_visible_child (post_image);
            });
        }
        if (t.com != null) {
            this.post_comment.label = PostTransformer.transform_post (t.com);
        }
        this.post_n_replies.label = @"$(t.replies) replies";
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
        main_window.show_thread (op.no, op.pixbuf);
    }
}
