[GtkTemplate (ui = "/org/vaccine/app/video-preview-widget.ui")]
public class Vaccine.VideoPreviewWidget : Gtk.Overlay {
    [GtkChild] private Gtk.Box sink_holder;

    // control holder
    [GtkChild] private Gtk.Revealer controls_revealer;

    // controls
    [GtkChild] public Gtk.Button btn_play;
    [GtkChild] public Gtk.Image btn_play_img;
    [GtkChild] public Gtk.Scale progress_scale;
    [GtkChild] public Gtk.ToggleButton toggle_repeat;

    // info
    [GtkChild] public Gtk.Label progress_text_start;
    [GtkChild] public Gtk.Label progress_text_end;

    // gtksink element
    public Gst.Element video_sink { private set; get; }
    private Gtk.Widget? area;

    public VideoPreviewWidget () {
        // init gst stuff
        video_sink = Gst.ElementFactory.make ("gtksink", "video_sink");
        video_sink.@get ("widget", out area);

        sink_holder.pack_start (area);

        sink_holder.show_all ();
        add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
    }

    [GtkCallback]
    private bool mouse_enter_cb (Gdk.EventCrossing event) {
        controls_revealer.reveal_child = true;
        return true;
    }

    [GtkCallback]
    private bool mouse_leave_cb (Gdk.EventCrossing event) {
        // don't hide if our mouse "leaves" into a descendant widget
        if (event.detail != Gdk.NotifyType.INFERIOR)
            controls_revealer.reveal_child = false;
        return true;
    }
}
