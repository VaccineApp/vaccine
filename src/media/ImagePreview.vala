public class Vaccine.ImagePreview : MediaPreview {
    private Gdk.PixbufAnimation? image_data;
    private Gdk.PixbufAnimationIter? frame_iter;
    private Cancellable? image_data_load_cancel;

    public bool is_animated { get { return !image_data.is_static_image (); } }

    private weak Gdk.Pixbuf? frame {
        get {
            return frame_iter != null ? frame_iter.get_pixbuf () : null;
        }
    }

    uint? timeout_id = null;

    // holds reference to single DrawingArea
    private Gtk.DrawingArea? canvas;

    public override bool loaded { get { return image_data != null; } }

    public ImagePreview (MediaStore media_store, Post post)
        requires (post.filename != null && post.ext != null)
    {
        base (media_store, post);
        image_data_load_cancel = new Cancellable ();
    }

    public override void cancel_everything () {
        if (image_data_load_cancel != null)
            image_data_load_cancel.cancel ();
        base.cancel_everything ();
    }

    ~ImagePreview () {
        if (canvas != null)
            stop_with_widget ();
        debug ("ImagePreview dtor");
    }

    public override void init_with_widget (Gtk.Widget widget)
        requires (canvas == null)
        requires (widget is Gtk.DrawingArea)
    {
        canvas = widget as Gtk.DrawingArea;
        if (loaded) { // reset frame_iter on init
            frame_iter = image_data.get_iter (null);
            if (image_data.is_static_image ())
                canvas.queue_draw ();
            else
                timeout_id = Timeout.add (frame_iter.get_delay_time (), update_animated_image);
        } else {  // download image if not loaded
            FourChan.download_image.begin (url, image_data_load_cancel, (obj, res) => {
                image_data = FourChan.download_image.end (res);
                image_data_load_cancel = null;
                frame_iter = image_data.get_iter (null);
                if (image_data.is_static_image ())
                    canvas.queue_draw ();
                else
                    timeout_id = Timeout.add (frame_iter.get_delay_time (), update_animated_image);
            });
        }
        canvas.draw.connect (draw_image);
    }

    public override void stop_with_widget ()
        requires (canvas != null)
    {
        canvas.draw.disconnect (draw_image);
        if (timeout_id != null) {
            Source.remove ((!) timeout_id);
            timeout_id = null;
        }
        frame_iter = null;
        canvas = null;
    }

    private bool update_animated_image () {
        if (frame_iter.advance (null))
            canvas.queue_draw ();
        return Source.CONTINUE;
    }

    private bool draw_image (Cairo.Context ctx) {
        if (!loaded)
            return false;
        double i_ratio = (double) image_data.get_width () / image_data.get_height ();
        int w_width, w_height;  // widget dimensions
        w_width = canvas.get_allocated_width ();
        w_height = canvas.get_allocated_height ();
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
}
