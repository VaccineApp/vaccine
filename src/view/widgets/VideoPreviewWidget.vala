[GtkTemplate (ui = "/org/vaccine/app/video-preview-widget.ui")]
public class Vaccine.VideoPreviewWidget : Gtk.Overlay {
    [GtkChild] private unowned Gtk.Box sink_holder;

    // control holder
    [GtkChild] private unowned Gtk.Revealer controls_revealer;

    // controls
    [GtkChild] public unowned Gtk.Button btn_play;
    [GtkChild] public unowned Gtk.Image btn_play_img;
    [GtkChild] public unowned Gtk.Scale progress_scale;
    [GtkChild] public unowned Gtk.ToggleButton toggle_repeat;

    // info
    [GtkChild] public unowned Gtk.Label progress_text_start;
    [GtkChild] public unowned Gtk.Label progress_text_end;

    // gtksink element
    public dynamic Gst.Element video_sink { private set; get; }
    private Gtk.Widget? area;

    public VideoPreviewWidget () {
        // init gst stuff
        dynamic Gst.Element? gtk_sink = Gst.ElementFactory.make ("gtksink", "video_sink");
        if (gtk_sink == null) {
            gtk_sink = Gst.ElementFactory.make ("gtksink", "video_sink");
            if (gtk_sink == null)
                error("Failed to created gtksink.");
        }
        video_sink = (!) gtk_sink;
        area = gtk_sink.widget;
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
