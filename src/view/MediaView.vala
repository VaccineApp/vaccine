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

    // image view
    Gdk.PixbufAnimationIter gif_iter = null;

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

        show_image (current_post);
    }

    public override void destroy () {
        base.destroy ();
    }

    private void show_image (int num) {
        gif_iter = null;
        current_post = num;
        stack.visible_child = image_view;
    }

    private bool update_animated_image () {
        if (gif_iter != null) {
            gif_iter.advance (null);
            image_view.queue_draw ();
            return Source.CONTINUE;
        }
        return Source.REMOVE;
    }

    [GtkCallback] private bool render_image (Cairo.Context ctx) {
        Post p = thread [current_post];
        Gdk.Pixbuf? frame = null;
        if (gif_iter != null)
            frame = gif_iter.get_pixbuf ();
        else if (p.full_pixbuf != null)
            frame = p.full_pixbuf.get_static_image ();
        if (frame == null && loading_cancellable == null) {
            loading_cancellable = p.get_full_image (pixbuf => {
                if (!pixbuf.is_static_image ()) {
                    gif_iter = pixbuf.get_iter (null);
                    Gdk.threads_add_timeout (gif_iter.get_delay_time (), update_animated_image);
                }
                if (loading_cancellable != null)
                    loading_cancellable = null;
            });
            debug (@"downloading $(p.filename)$(p.ext)");
            return true;
        } else if (frame.width <= 0 || frame.height <= 0)
            return true;
        double i_ratio = (double) p.full_pixbuf.get_width () / p.full_pixbuf.get_height ();
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
        double scale_x = (double) r_width / frame.width;
        double scale_y = (double) r_height / frame.height;
        ctx.translate (r_padding_x, r_padding_y);
        ctx.scale (scale_x, scale_y);
        Gdk.cairo_set_source_pixbuf (ctx, frame, 0, 0);
        ctx.rectangle (0, 0, frame.width, frame.height);
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
