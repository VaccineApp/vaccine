[GtkTemplate (ui = "/org/vaccine/app/video-preview-widget.ui")]
public class Vaccine.VideoPreviewWidget : Gtk.Overlay {
    [GtkChild] protected Gtk.Box sink_holder;

    // controls
    [GtkChild] protected Gtk.Button btn_play;
    [GtkChild] protected Gtk.Scale progress_scale;
    [GtkChild] protected Gtk.ToggleButton toggle_repeat;

    // info
    [GtkChild] protected Gtk.Label progress_text_start;
    [GtkChild] protected Gtk.Label progress_text_end;

    private Gst.Pipeline pipeline;

    public VideoPreviewWidget (GtkGst.Widget sink, Gst.Pipeline pipeline) {
        this.pipeline = pipeline;
        sink_holder.pack_start (sink);
    }

    [GtkCallback] private void play_cb () {
        Gst.State current;

        if (pipeline.get_state (out current, null, Gst.CLOCK_TIME_NONE)
            != Gst.StateChangeReturn.SUCCESS) {
            debug ("gstreamer: could not video get state");
            return;
        }
        if (current == Gst.State.PAUSED) {
            if (pipeline.set_state (Gst.State.PLAYING) != Gst.StateChangeReturn.SUCCESS)
                debug ("gstreamer: could not play video");
        } else if (current == Gst.State.PLAYING) {
            if (pipeline.set_state (Gst.State.PAUSED) != Gst.StateChangeReturn.SUCCESS)
                debug ("gstreamer: could not pause video");
        }
    }
}
