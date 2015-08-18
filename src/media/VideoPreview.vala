public class Vaccine.VideoPreview : MediaPreview {
    private Gst.Pipeline? video_pipeline;
    private Gst.Element? video_source;
    private Gst.Element? video_sink;

    public override bool loaded { get { return false; /* TODO */ } }

    public override string filetype {
        owned get { return "WebM video"; }
    }

    // widget info
    private Gtk.Box? box = null;
    // private GtkGst.Widget? area;

    public VideoPreview (Post post)
        requires (post.filename != null && post.ext != null)
    {
         Object (url: @"https://i.4cdn.org/$(post.board)/$(post.tim)$(post.ext)",
            filename: @"$(post.filename)$(post.ext)",
            post: post);
        video_source = Gst.ElementFactory.make ("souphttpsrc", "video_source");
        video_sink = Gst.ElementFactory.make ("gtkglsink", "video_sink");
        video_pipeline = new Gst.Pipeline ("video_pipeline");
        if (video_source == null || video_sink == null || video_pipeline == null) {
            debug ("gstreamer: could not create all elements");
            return;
        }
        video_pipeline.add_many (video_source, video_sink);
        video_source.set ("location", url);
        video_source.link (video_sink);
    }

    public override void init_with_widget (Gtk.Widget widget)
        requires (widget is Gtk.Box)
        requires (box == null)
    {
        box = widget as Gtk.Box;
    }

    public override void stop_with_widget ()
        requires (box != null)
    {

    }
}
