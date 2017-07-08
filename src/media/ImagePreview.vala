public class Vaccine.ImagePreview : MediaPreview {
    private Gdk.Pixbuf? image_data;
    private Gdk.PixbufAnimation? gif_data;
    private Cancellable? image_data_load_cancel;

    // holds reference to single DrawingArea
    private Gtk.ImageView? imageview;

    public override bool loaded { get { return image_data != null || gif_data != null; } }

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
        debug ("ImagePreview dtor");
    }

    public override void init_with_widget (Gtk.Widget widget)
        requires (imageview == null)
        requires (widget is Gtk.ImageView)
    {
        imageview = widget as Gtk.ImageView;
        imageview.fit_allocation = true;

        imageview.notify["scale"].connect ((obj, prop) => {
            Gtk.Allocation alloc;
            imageview.get_allocation (out alloc);
            print ("scale = %f, %dx%d\n", imageview.scale, alloc.width, alloc.height);
        });

        if (loaded) { // reset frame_iter on init
            if (image_data != null)
                imageview.set_pixbuf (image_data, 1);
            else
                imageview.set_animation (gif_data, 1);
        } else {  // download image if not loaded
            FourChan.download_image.begin (url, image_data_load_cancel, (obj, res) => {
                var img = FourChan.download_image.end (res);
                if (img.is_static_image()) {
                    image_data = img.get_static_image();
                    imageview.set_pixbuf (image_data, 1);
                } else {
                    gif_data = img;
                    imageview.set_animation (gif_data, 1);
                }

                image_data_load_cancel = null;
            });
        }
    }

    public override void stop_with_widget() {}
}
