[GtkTemplate (ui = "/org/vaccine/app/media-view.ui")]
public class Vaccine.MediaView : Gtk.Window {
    [GtkChild] private Gtk.HeaderBar headerbar;

    // headerbar buttons
    [GtkChild] private Gtk.Button btn_prev;
    [GtkChild] private Gtk.Button btn_next;
    [GtkChild] private Gtk.ToggleButton btn_gallery;
    [GtkChild] private Gtk.Button btn_download;
    [GtkChild] private Gtk.Button btn_present;

    // view and containers
    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.Alignment loading_view;
    [GtkChild] private Gtk.Box gallery_view;
    [GtkChild] private Gtk.IconView gallery_icons;
    [GtkChild] private Gtk.DrawingArea image_view;

    // custom data
    public Thread thread { construct; get; }
    public int current_post { private set; get; default = 0; }
    private Cancellable? loading_cancellable = null;

    public MediaView (Gtk.ApplicationWindow window, Post post) {
        Object (thread: post.thread);
        current_post = post.thread.index_of (post);
        var store = new Gtk.ListStore (2, typeof (Gdk.Pixbuf), typeof (string));
        gallery_icons.pixbuf_column = 0;
        gallery_icons.text_column = 1;
        post.thread.foreach (post => {
            if (post.filename != null)
                store.insert_with_values (null, -1, 0, post.pixbuf, 1, post.filename + post.ext, -1);
            return true;
        });

        gallery_icons.model = store;
        stack.visible_child = image_view;

        set_transient_for (window);

        bind_property ("current_post", headerbar, "title", BindingFlags.SYNC_CREATE,
        (binding, src, ref target) => {
            Post p = thread [(int) src];
            target = p.filename + p.ext;
            debug (@"target = $(target.get_string ())");
            return true;
        });
    }

    public override void destroy () {
        base.destroy ();
    }

    [GtkCallback] private bool render_image (Cairo.Context ctx) {
        Post p = thread [current_post];
        if (p.full_pixbuf == null && loading_cancellable == null) {
            loading_cancellable = p.get_full_image (pixbuf => {
                if (loading_cancellable != null)
                    loading_cancellable = null;
            });
            debug (@"downloading $(p.filename)$(p.ext)");
            return true;
        } else if (p.full_pixbuf.width <= 0 || p.full_pixbuf.height <= 0)
            return true;
        double i_ratio = (double) p.full_pixbuf.width / p.full_pixbuf.height;
        int w_width, w_height;  // widget dimensions
        w_width = image_view.get_allocated_width ();
        w_height = image_view.get_allocated_height ();
        double w_ratio = (double) w_width / w_height;
        int r_width, r_height;  // rendered image
        double r_padding_x, r_padding_y;
        if (w_ratio >= i_ratio) {
            r_height = w_height;
            r_width = (int) Math.round (r_height * i_ratio);
            r_padding_x = (double)(w_width - r_width) / 2;
            r_padding_y = 0;
        } else {
            r_width = w_width;
            r_height = (int) Math.round (r_width / i_ratio);
            r_padding_x = 0;
            r_padding_y = (double)(w_height - r_height) / 2;
        }
        debug (@"dim = $(r_width)x$r_height");
        debug (@"pixbuf_dim = $(p.full_pixbuf.width)x$(p.full_pixbuf.height)");

        double scale_x = (double) r_width / p.full_pixbuf.width;
        double scale_y = (double) r_height / p.full_pixbuf.height;
        debug (@"scale = {$scale_x, $scale_y");
        ctx.translate (r_padding_x, r_padding_y);
        ctx.scale (scale_x, scale_y);
        Gdk.cairo_set_source_pixbuf (ctx, p.full_pixbuf, 0, 0);
        ctx.rectangle (0, 0, p.full_pixbuf.width, p.full_pixbuf.height);
        ctx.fill ();
        return true;
    }

    [GtkCallback] private void toggle_gallery () {
        if (btn_gallery.active)
            stack.visible_child = gallery_view;
        else
            stack.visible_child = image_view;
    }
}
