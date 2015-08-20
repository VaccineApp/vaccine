[GtkTemplate (ui = "/org/vaccine/app/video-preview-widget.ui")]
public class Vaccine.VideoPreviewWidget : Gtk.Overlay {
    [GtkChild] private Gtk.Box sink_holder;
    private Gtk.AspectFrame frame;

    // controls
    [GtkChild] private Gtk.Button btn_play;
    [GtkChild] private Gtk.Scale progress_scale;
    [GtkChild] private Gtk.ToggleButton toggle_repeat;

    // info
    [GtkChild] private Gtk.Label progress_text_start;
    [GtkChild] private Gtk.Label progress_text_end;

    private Gst.Pipeline pipeline;

    public bool repeat { set; get; }

    private VideoPreview preview;

    public VideoPreviewWidget (VideoPreview preview, Gtk.Widget sink, Gst.Pipeline pipeline) {
        this.preview = preview;
        this.pipeline = pipeline;

        frame = new Gtk.AspectFrame (null, 0.5f, 0.5f, 1, false);
        frame.set_shadow_type (Gtk.ShadowType.NONE);
        frame.add (sink);
        sink_holder.add (frame);
        toggle_repeat.bind_property ("active", this, "repeat", BindingFlags.BIDIRECTIONAL);

        preview.bind_property ("ratio", frame, "ratio");
    }

    [GtkCallback] private void play_cb () {
        Gst.State current;

        if (pipeline.get_state (out current, null, Gst.CLOCK_TIME_NONE)
            != Gst.StateChangeReturn.SUCCESS) {
            debug ("gstreamer: could not get video state");
            return;
        }
        if (current == Gst.State.PAUSED) {
            if (pipeline.set_state (Gst.State.PLAYING) != Gst.StateChangeReturn.SUCCESS)
                debug ("gstreamer: could not play video");
            else debug ("gstreamer: playing video");
        } else if (current == Gst.State.PLAYING) {
            if (pipeline.set_state (Gst.State.PAUSED) != Gst.StateChangeReturn.SUCCESS)
                debug ("gstreamer: could not pause video");
            else debug ("gstreamer: paused video");
        }
    }
}
