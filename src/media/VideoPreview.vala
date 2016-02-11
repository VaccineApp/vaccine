public class Vaccine.VideoPreview : MediaPreview {
    private Gst.Element video_source;   // playbin

    private string src_plugin { set; public get; default = "playbin"; }

    private bool _loaded = false;
    public override bool loaded { get { return _loaded; } }

    public override string filetype {
        owned get { return "WebM video"; }
    }

    // hold reference to video preview widget
    private VideoPreviewWidget? preview_widget;

    private Gtk.Adjustment? adjustment;

    // time in ns
    private string convert_clocktime (uint64 time) {
        uint64 seconds = time / Gst.SECOND;
        uint64 min = seconds / 60;

        return @"%$(uint64.FORMAT):%02$(uint64.FORMAT)".printf (min, seconds % 60);
    }

    public VideoPreview (Post post)
        requires (post.filename != null && post.ext != null)
    {
         Object (url: @"https://i.4cdn.org/$(post.board)/$(post.tim)$(post.ext)",
            filename: @"$(post.filename)$(post.ext)",
            post: post);
        video_source = Gst.ElementFactory.make (src_plugin, "video_source");
        if (video_source == null) {
            error (@"could not create plugin $src_plugin");
        }
    }

    ~VideoPreview () {
        if (preview_widget != null)
            stop_with_widget ();
        debug ("VideoPreview dtor");
    }

    private weak Binding? bind_position;
    private weak Binding? bind_duration;
    private weak Binding? bind_is_playing;
    private weak Binding? bind_repeat;

    public override void init_with_widget (Gtk.Widget widget)
        requires (widget is VideoPreviewWidget)
    {
        preview_widget = widget as VideoPreviewWidget;

        terminate = false;
        // set the sink element
        video_source["video-sink"] = preview_widget.video_sink;
        // set the URI
        video_source["uri"] = url;

        // create adjustment
        adjustment = new Gtk.Adjustment (0, 0, duration, 1, 0, 0);
        preview_widget.progress_scale.adjustment = adjustment;

        // bind properties:
        bind_position = bind_property ("position", preview_widget.progress_text_start,
            "label", BindingFlags.DEFAULT, (binding, srcval, ref targetval) => {
                targetval.set_string (convert_clocktime (srcval.get_int64 ()));
                return true;
            });
        bind_duration = bind_property ("duration", preview_widget.progress_text_end,
            "label", BindingFlags.DEFAULT, (binding, srcval, ref targetval) => {
                targetval.set_string (convert_clocktime (srcval.get_uint64 ()));
                return true;
            });
        bind_property ("position", adjustment, "value", BindingFlags.BIDIRECTIONAL, null,
            (binding, srcval, ref targetval) => {   // adjustment.value -> position
                return video_source.seek_simple (Gst.Format.TIME,
                    Gst.SeekFlags.FLUSH | Gst.SeekFlags.ACCURATE,
                    (int64) srcval.get_double ());
            });
        bind_property ("duration", adjustment, "upper", BindingFlags.DEFAULT);
        bind_is_playing = bind_property ("playing", preview_widget.btn_play_img,
            "icon-name", BindingFlags.DEFAULT, (binding, srcval, ref targetval) => {
                if (srcval.get_boolean ())  // playing
                    targetval = "media-playback-pause-symbolic";
                else
                    targetval = "media-playback-start-symbolic";
                return true;
            });
        bind_repeat = bind_property ("repeat", preview_widget.toggle_repeat,
                                     "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        // start playing
        if (video_source.set_state (Gst.State.PLAYING) == Gst.StateChangeReturn.FAILURE)
            debug ("failed to start playing");

        // add callback
        preview_widget.btn_play.clicked.connect (toggle_play);

        // listen to the bus
        video_source.get_bus ().add_watch (Priority.DEFAULT, handle_message);

        // set up monitor
        Idle.add (monitor_bus);
    }

    public override void stop_with_widget ()
        requires (preview_widget != null)
    {
        terminate = true;
        video_source["video-sink"] = null;
        video_source.set_state (Gst.State.NULL);

        // unbind all properties
        bind_position.unbind ();
        bind_position = null;
        bind_duration.unbind ();
        bind_duration = null;
        bind_is_playing.unbind ();
        bind_is_playing = null;
        bind_repeat.unbind ();
        bind_repeat = null;

        adjustment = null;

        // disconnect widget event handlers
        preview_widget.btn_play.clicked.disconnect (toggle_play);

        // preview_widget.progress_scale.adjustment = null;
        preview_widget = null;
    }

    // if video is playing
    public bool playing { get; private set; }

    // if seeking is enabled
    private bool _seek_enabled = false;
    public bool seek_enabled { get { return _seek_enabled; } }

    // position in video
    public int64 position { get; set; default = -1; }

    // length of video
    public uint64 duration { get; private set; default = Gst.CLOCK_TIME_NONE; }

    public bool terminate { get; private set; }

    // if stream has ended
    public bool end_of_stream { get; private set; }

    // repeat the video
    public bool repeat { get; set; default = true; }

    // handle messages from the bus
    private bool handle_message (Gst.Bus bus, Gst.Message msg) {
        if (terminate)
            return Source.REMOVE;
        switch (msg.type) {
        case Gst.MessageType.ERROR:
            GLib.Error err;
            string debug_info;

            msg.parse_error (out err, out debug_info);
            stdout.printf ("Error received from element %s: %s\n", msg.src.name, err.message);
            stdout.printf ("Debugging information: %s\n", debug_info != null ? debug_info : "none");
            break;
        case Gst.MessageType.EOS:
            debug ("End-of-stream reached");
            end_of_stream = true;
            if (repeat) {
                if (video_source.seek_simple (Gst.Format.TIME,
                    Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT,
                    0))
                    end_of_stream = false;
                else
                    debug ("failed to seek to beginning");
            } else
                video_source.set_state (Gst.State.PAUSED);
            break;
        case Gst.MessageType.DURATION_CHANGED:
            duration = Gst.CLOCK_TIME_NONE;
            break;
        case Gst.MessageType.STATE_CHANGED:
            Gst.State old_state;
            Gst.State new_state;
            Gst.State pending_state;

            msg.parse_state_changed (out old_state, out new_state, out pending_state);
            if (msg.src == video_source) {
                debug ("Pipeline state changed from %s to %s",
                    Gst.Element.state_get_name (old_state),
                    Gst.Element.state_get_name (new_state));
                if (new_state == Gst.State.READY)
                    _loaded = true;
                playing = (new_state == Gst.State.PLAYING);

                if (playing) {
                    Gst.Query query = new Gst.Query.seeking (Gst.Format.TIME);
                    int64 start;
                    int64 end;

                    if (video_source.query (query)) {
                        query.parse_seeking (null, out _seek_enabled, out start, out end);
                        if (seek_enabled)
                            debug (@"seeking is enabled from $start to $end");
                        else
                            debug ("seeking is disabled");
                    } else
                        debug ("seeking query failed");
                    end_of_stream = false;
                }
            }
            break;
        default:
            // do nothing
            break;
        }
        return terminate ? Source.REMOVE : Source.CONTINUE;
    }

    // update information from the video
    private bool monitor_bus () {
        if (playing) {
            Gst.Format fmt = Gst.Format.TIME;
            int64 current = -1;
            Gst.ClockTime stream_length = Gst.CLOCK_TIME_NONE;

            // get position
            if (!video_source.query_position (fmt, out current))
                debug ("could not query media position");
            else
                position = current;

            // get stream duration
            if (duration == Gst.CLOCK_TIME_NONE) {
                if (!video_source.query_duration (fmt, out stream_length))
                    debug ("could not query media duration");
                else
                    duration = stream_length;
            }

        }
        return terminate ? Source.REMOVE : Source.CONTINUE;
    }

    private void toggle_play () {
        Gst.State new_state = playing ? Gst.State.PAUSED : Gst.State.PLAYING;

        if (new_state == Gst.State.PLAYING && end_of_stream) {
            if (!video_source.seek_simple (Gst.Format.TIME,
                Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, 0))
                debug ("failed to reset stream");
        }
        Gst.StateChangeReturn ret = video_source.set_state (new_state);
        if (ret == Gst.StateChangeReturn.FAILURE)
            debug ("Unable to change state");
    }
}
