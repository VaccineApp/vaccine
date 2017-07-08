public abstract class Vaccine.MediaPreview : Object {
    public const string[] supported_images = { ".gif", ".png", ".jpg" };
    public const string[] supported_videos = { ".webm" };

    public static bool is_supported (string ext) {
        return ext in supported_images || ext in supported_videos;
    }

    /**
     * Creates a new MediaPreview from a post, if the media is supported.
     * Otherwise returns null.
     */
    public static MediaPreview? from_post (MediaStore media_store, Post post) {
        if (post.ext in supported_images)
            return new ImagePreview (media_store, post);
        if (post.ext in supported_videos)
            return new VideoPreview (media_store, post);
        return null; /* TODO: add support for more files */
    }

    public weak MediaStore store { get; construct; }

    /**
     * The post number
     */
    public int64 id { get; construct; }

    /**
     * The remote filename.
     */
    public string url { get; construct; }

    /**
     * The local filename.
     */
    public string filename { get; construct; }

    /**
     * file extension
     */
    public string extension { get; construct; }

    /**
     * The thumbnail URL
     */
    public string thumbnail_url { get; construct; }

    /**
     * The thumbnail
     */
    public Gdk.Pixbuf? thumbnail { get; private set; }

    protected MediaPreview (MediaStore media_store, Post post) {
        Object (store: media_store,
                id: post.no,
                url: @"https://i.4cdn.org/$(post.board)/$(post.tim)$(post.ext)",
                filename: @"$(post.filename)$(post.ext)",
                extension: post.ext,
                thumbnail_url: @"https://i.4cdn.org/$(post.board)/$(post.tim)s.jpg");
    }

    public Cancellable? cancel_thumbnail_download;

    public virtual void cancel_everything () {
        if (cancel_thumbnail_download != null)
            cancel_thumbnail_download.cancel ();
    }

    construct {
        cancel_thumbnail_download = new Cancellable ();
        FourChan.download_image.begin (thumbnail_url, cancel_thumbnail_download, (obj, res) => {
            var anim = FourChan.download_image.end (res);
            if (cancel_thumbnail_download.is_cancelled ())
                return;
            int width = 128;
            Gdk.Pixbuf image = anim.get_static_image ();
            if (image.width > width)
                thumbnail = image.scale_simple (width, (int)(image.height * ((double)width/image.width)), Gdk.InterpType.BILINEAR);
            else
                thumbnail = image;
            Gtk.TreePath path;
            Gtk.TreeIter iter;
            if (store.get_path_and_iter (this, out path, out iter))
                store.row_changed (path, iter);
            cancel_thumbnail_download = null;
        });
    }

    ~MediaPreview () {
        cancel_everything ();
        debug ("Cancelling all pending operations");
    }

    /**
     * If the file has been loaded.
     */
    public abstract bool loaded { get; }

    /**
     * Renders the preview onto the widget or onto a new widget created as a
     * child of the given widget.
     */
    public abstract void init_with_widget (Gtk.Widget widget);

    /**
     * Stops all operations and pending operations with the previous widget.
     */
    public abstract void stop_with_widget ();

    /**
     * Self-explanatory. Downloads and saves the media to a file.
     * @throws Error if file is not yet loaded
     */
    public async bool save_as (string path) throws Error {
        var message = new Soup.Message ("GET", this.url);
        var istream = yield FourChan.soup.send_async (message, null);
        var fstream = yield File.new_for_path (path).create_readwrite_async (FileCreateFlags.NONE);
        var os = fstream.output_stream as FileOutputStream;
        os.splice (istream, OutputStreamSpliceFlags.CLOSE_SOURCE);
        return yield fstream.close_async ();
    }
}
