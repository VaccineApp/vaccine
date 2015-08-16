[GtkTemplate (ui = "/org/vaccine/app/media-view.ui")]
public class Vaccine.MediaView : Gtk.Window {
    // [GtkChild] private Gtk.HeaderBar headerbar;

    // headerbar buttons
    // [GtkChild] private Gtk.Button btn_prev;
    // [GtkChild] private Gtk.Button btn_next;
    [GtkChild] private Gtk.ToggleButton btn_gallery;
    // [GtkChild] private Gtk.Button btn_download;
    [GtkChild] private Gtk.Button btn_present;

    // view and containers
    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.Alignment loading_view;
    [GtkChild] private Gtk.ProgressBar download_progress;
    [GtkChild] private Gtk.Box gallery_view;
    [GtkChild] private Gtk.IconView gallery_icons;
    [GtkChild] private Gtk.DrawingArea image_view;

    // custom data
    private Gtk.ApplicationWindow parent_window;
    public Thread thread { construct; get; }
    private List<MediaPreview> media = new List<MediaPreview> ();
    private unowned List<MediaPreview> current_media;

    private bool is_fullscreen = false;

    private uint? pulse_id = null;
    private uint? media_onready_id = null;

    public MediaView (Gtk.ApplicationWindow window, Post post) {
        Object (thread: post.thread);
        parent_window = window;
        var store = new Gtk.ListStore (3, typeof (Gdk.Pixbuf), typeof (string), typeof (MediaPreview));
        gallery_icons.pixbuf_column = 0;
        gallery_icons.text_column = 1;
        post.thread.foreach (p => {
            if (p.filename != null) {
                var item = MediaPreview.from_post (p);
                if (item == null) {
                    debug (@"file extension \"$(p.ext)\" unsupported");
                    return true;
                }
                store.insert_with_values (null, -1,
                    0, p.pixbuf,
                    1, p.filename + p.ext,
                    2, item,
                    -1);
                media.append (item);
            }
            return true;
        });

        gallery_icons.model = store;

        set_transient_for (window);

        current_media = media.first ();
        while (current_media.next != null && current_media.data.post != post)
            current_media = current_media.next;
        show_media (current_media);
    }

    ~MediaView () {
        if (current_media != null)
            current_media.data.stop_with_widget ();
        if (pulse_id != null)
            Source.remove ((!) pulse_id);
        if (media_onready_id != null)
            Source.remove ((!) media_onready_id);
    }

    private void show_media (List<MediaPreview> next_media, bool initial = false) {
        if (!initial)
            current_media.data.stop_with_widget ();
        if (!current_media.data.loaded)
            stack.visible_child = loading_view;
        current_media = next_media;
        if (pulse_id != null) {
            Source.remove ((!) pulse_id);
            pulse_id = null;
        }
        if (media_onready_id != null) {
            Source.remove ((!) media_onready_id);
            media_onready_id = null;
        }
        pulse_id = Timeout.add (300, () => {
            download_progress.pulse ();
            return Source.CONTINUE;
        });
        current_media.data.init_with_widget (image_view);
        media_onready_id = Idle.add (() => {
            if (!current_media.data.loaded)
                return Source.CONTINUE;
            Source.remove (pulse_id);
            pulse_id = null;
            download_progress.set_fraction (1);
            stack.visible_child = image_view;
            media_onready_id = null;
            return Source.REMOVE;
        });
    }

    [GtkCallback] private void show_prev_media () {
        if (current_media.prev == null)
            show_media (media.last ());
        else
            show_media (current_media.prev);
    }

    [GtkCallback] private void show_next_media () {
        if (current_media.next == null)
            show_media (media.first ());
        else
            show_media (current_media.next);
    }

    [GtkCallback] private void download_file () {
        var chooser = new Gtk.FileChooserDialog ("Save As...", this,
            Gtk.FileChooserAction.SAVE,
            "_Cancel", Gtk.ResponseType.CANCEL,
            "_Save As", Gtk.ResponseType.ACCEPT);
        var filter = new Gtk.FileFilter ();
        filter.set_filter_name (current_media.data.filetype);
        filter.add_pattern ("*" + current_media.data.post.ext);
        chooser.add_filter (filter);
        if (chooser.run () == Gtk.ResponseType.ACCEPT) {
            string fname = chooser.get_filename ();
            current_media.data.save_as.begin (fname, (obj, res) => {
                Notification notif;
                try {
                    current_media.data.save_as.end (res);
                    notif = new Notification ("Finished downloading");
                    notif.set_body (@"Saved file to $fname");
                } catch (Error e) {
                    debug (@"error: $(e.message)");
                    notif = new Notification ("Error saving file");
                    notif.set_body (e.message);
                }
                Application.get_default ().send_notification (null, notif);
            });
        }
        chooser.destroy ();
    }

    [GtkCallback] private void toggle_gallery () {
        if (btn_gallery.active)
            stack.visible_child = gallery_view;
        else
            stack.visible_child = image_view;
    }

    [GtkCallback] private void toggle_fullscreen () {
        if (is_fullscreen) {
            this.unfullscreen ();
            this.modal = true;
        } else {
            this.modal = false;
            this.fullscreen ();
        }
        is_fullscreen = !is_fullscreen;
    }
}
