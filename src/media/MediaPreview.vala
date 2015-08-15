public abstract class Vaccine.MediaPreview : Object {
    public const string[] supported_images = { ".gif", ".png", ".jpg" };

    /**
     * Creates a new MediaPreview from a post, if the media is supported.
     * Otherwise returns null.
     */
    public static MediaPreview? from_post (Post post) {
        foreach (var ext in supported_images)
            if (post.ext == ext)
                return new ImagePreview (post);
        return null;    /* TODO: add support for more files */
    }

    /**
     * The remote filename.
     */
    public string url { get; construct; }

    /**
     * The local filename.
     */
    public string filename { get; construct; }

    /**
     * A file type (like "GIF images")
     */
    public abstract string filetype { owned get; }

    /**
     * The post containing the data for this preview.
     */
    public Post post { get; construct; }

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
