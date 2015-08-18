public class Vaccine.VideoPreview : MediaPreview {
    private Gst.Pipeline? video_pipeline;
    private Gst.Element? video_source;
    private Gst.Element? video_convert;
    private Gst.Element? video_sink;

    private string src_plugin { set; public get; default = "uridecodebin"; }
    private string conv_plugin { set; public get; default = "videoconvert"; }
    private string sink_plugin { set; public get; default = "gtksink"; }

    public override bool loaded { get { return true; /* TODO */ } }

    public override string filetype {
        owned get { return "WebM video"; }
    }

    // widget info
    private Gtk.Box? box = null;
    private GtkGst.Widget? area;

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
        if (video_source == null || video_sink == null || video_pipeline == null) {
            debug ("gstreamer: could not create all elements");
            return;
        }
        if (!(video_sink is Gst.Base.Sink)) {
            debug (@"gstreamer: video_sink ($sink_plugin) is not a sink element");
        }
    }

    public override void init_with_widget (Gtk.Widget widget)
        requires (widget is Gtk.Box)
        requires (box == null)
        ensures (area != null && area is GtkGst.Widget)
    {
        box = widget as Gtk.Box;

        video_sink.get ("widget", out area);
        box.pack_start (area);
        box.show_all ();

        video_pipeline.add_many (video_source, video_convert, video_sink);
        if (!video_convert.link (video_sink)) {
            debug ("gstreamer: failed to link convert -> sink");
            return;
        }
        video_source.set ("uri", url);
        // video_source.set ("is-live", true);
        video_source.pad_added.connect (pad_added_handler);

        debug (@"downloading from $url");

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
        video_source.pad_added.disconnect (pad_added_handler);
        box = null;
    }

    // shamefully taken from valadoc's tutorial on Gst.Element
    private void pad_added_handler (Gst.Element src, Gst.Pad new_pad) {
        Gst.Pad sink_pad = video_convert.get_static_pad ("sink");
        debug (@"received new pad $(new_pad.name) from $(src.name)");

        if (sink_pad.is_linked ())
            return;

        // check new pad's type
        Gst.Caps new_pad_caps = new_pad.query_caps (null);
        weak Gst.Structure new_pad_struct = new_pad_caps.get_structure (0);
        string new_pad_type = new_pad_struct.get_name ();

        // attempt the link
        if (new_pad.link (sink_pad) != Gst.PadLinkReturn.OK)
            debug (@"link failed with type $new_pad_type");
        else
            debug (@"successfully linked with type $new_pad_type");
    }
}
