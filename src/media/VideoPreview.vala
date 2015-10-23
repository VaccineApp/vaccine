public class Vaccine.VideoPreview : MediaPreview {
    private Gst.Pipeline? video_pipeline;
    private Gst.Element? video_source;
    private Gst.Element? video_convert;
    private Gst.Element? video_sink;

    private string src_plugin { set; public get; default = "uridecodebin"; }
    private string conv_plugin { set; public get; default = "videoconvert"; }
    private string sink_plugin { set; public get; default = "gtksink"; }

    private bool _loaded = false;
    public override bool loaded { get { return _loaded; } }

    public override string filetype {
        owned get { return "WebM video"; }
    }

    // widget info
    private Gtk.Box? box;
    private VideoPreviewWidget preview_area;
    private Gtk.Widget area;

    private int? width = null;
    private int? height = null;
    public float ratio { get; set; }
    private Gst.Structure video_info;

    public VideoPreview (Post post)
        requires (post.filename != null && post.ext != null)
    {
         Object (url: @"https://i.4cdn.org/$(post.board)/$(post.tim)$(post.ext)",
            filename: @"$(post.filename)$(post.ext)",
            post: post);
        video_source = Gst.ElementFactory.make (src_plugin, "video_source");
        video_convert = Gst.ElementFactory.make (conv_plugin, "video_convert");
        video_sink = Gst.ElementFactory.make (sink_plugin, "video_sink");
        video_pipeline = new Gst.Pipeline ("video_pipeline");
        if (video_source == null || video_convert == null
         || video_sink == null || video_pipeline == null) {
            debug ("gstreamer: could not create all elements:");
            if (video_source == null)
                debug (@"\tcould not create plugin $src_plugin");
            if (video_convert == null)
                debug (@"\tcould not create plugin $conv_plugin");
            if (video_sink == null)
                debug (@"\tcould not create plugin $sink_plugin");
            if (video_pipeline == null)
                debug ("\tcould not create video pipeline");
            return;
        }
        if (!(video_sink is Gst.Base.Sink)) {
            debug (@"gstreamer: video_sink ($sink_plugin) is not a sink element");
        }
        video_sink.get ("widget", out area);
        preview_area = new VideoPreviewWidget (this, area, video_pipeline);
    }

    ~VideoPreview () {
        if (box != null)
            stop_with_widget ();
        debug ("VideoPreview dtor");
    }

    public override void init_with_widget (Gtk.Widget widget)
        requires (widget is Gtk.Box)
    {
        box = widget as Gtk.Box;
        box.pack_start (preview_area);
        box.show_all ();

        if (!loaded) {
            video_pipeline.add_many (video_source, video_convert, video_sink);
            if (!video_convert.link (video_sink)) {
                debug ("gstreamer: failed to link convert -> sink");
                return;
            }
            video_source.set ("uri", url);
            debug (@"downloading from $url");
            video_source.pad_added.connect (pad_added_handler);
        }

        if (video_pipeline.set_state (Gst.State.PLAYING) == Gst.StateChangeReturn.FAILURE) {
            debug ("gstreamer: failed to set state to playing");
        } else
            debug ("gstreamer: set video to playing");
    }

    public override void stop_with_widget ()
        requires (box != null)
    {
        if (video_pipeline.set_state (Gst.State.NULL) == Gst.StateChangeReturn.FAILURE)
            debug ("gstreamer: failed to stop video");
        else
            debug ("gstreamer: stopped video");
        box.remove (preview_area);
        box = null;
        video_source.pad_added.disconnect (pad_added_handler);
    }

    /* connects the video_source's src pad to the video_convert's sink pad
     * shamefully taken from valadoc's tutorial on Gst.Element
     */
    private void pad_added_handler (Gst.Element src, Gst.Pad new_pad) {
        Gst.Pad sink_pad = video_convert.get_static_pad ("sink");
        debug (@"received new pad $(new_pad.name) from $(src.name)");

        if (sink_pad.is_linked ())
            return;

        // check new pad's type
        Gst.Caps new_pad_caps = new_pad.query_caps (null);
        unowned Gst.Structure new_pad_struct = new_pad_caps.get_structure (0);
        string new_pad_type = new_pad_struct.get_name ();
        video_info = new_pad_struct.copy ();
        // FIXME: (possibly use Gst.Query?)
        video_info.fixate ();
        if (!video_info.get_int ("width", out width))
            debug ("failed to get width");
        if (!video_info.get_int ("height", out height))
            debug ("failed to get height");
        if (width != null && height != null) {
            ratio = (float) width / height;
            debug (@"width = $width, height = $height, ratio is $ratio");
        }

        // attempt the link
        if (new_pad.link (sink_pad) != Gst.PadLinkReturn.OK)
            debug (@"link failed with type $new_pad_type");
        else {
            debug (@"successfully linked with type $new_pad_type");
            _loaded = true;
        }
    }
}
