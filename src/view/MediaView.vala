[GtkTemplate (ui = "/org/vaccine/app/media-view.ui")]
public class Vaccine.MediaView : Gtk.Window {
    // [GtkChild] private unowned Gtk.HeaderBar headerbar;

    // headerbar buttons
    // [GtkChild] private unowned Gtk.Button btn_prev;
    // [GtkChild] private unowned Gtk.Button btn_next;
    [GtkChild] private unowned Gtk.ToggleButton btn_gallery;
    // [GtkChild] private unowned Gtk.Button btn_download;
    [GtkChild] private unowned Gtk.Button btn_present;
    [GtkChild] private unowned Gtk.Button btn_reverse_search;

    // view and containers
    [GtkChild] private unowned Gtk.Stack stack;
    [GtkChild] private unowned Gtk.Alignment loading_view;
    [GtkChild] private unowned Gtk.ProgressBar download_progress;
    [GtkChild] private unowned Gtk.Box gallery_view;
    [GtkChild] private unowned Gtk.IconView gallery_icons;

    // usable widget
    [GtkChild] private unowned Gtk.DrawingArea image_view;

    // must be filled with VideoPreviewWidget
    [GtkChild] private unowned Gtk.Box video_holder;
    private VideoPreviewWidget video_view;

    // custom data
    private Gtk.ApplicationWindow parent_window;
    public Thread thread { construct; get; }
    private MediaStore store;
    private unowned List<MediaPreview> current_media;
    private unowned Gtk.Widget last_widget;

    private bool is_fullscreen = false;

    private uint? pulse_id = null;
    private uint? media_onready_id = null;

    public MediaView (Gtk.ApplicationWindow window, Post post) {
        Object (thread: post.thread);
        assert (post.filename != null);

        parent_window = window;

        gallery_icons.pixbuf_column = 1;
        gallery_icons.text_column = 2;

        store = new MediaStore ((!) (post.thread));
        gallery_icons.model = store;
        gallery_icons.item_activated.connect (path => {
            Gtk.TreeIter iter;
            if (store.get_iter (out iter, path)) {
                if (stack.visible_child == gallery_view)
                    btn_gallery.active = false;
                show_media ((List<MediaPreview>) iter.user_data);
            }
        });

        // add VideoPreviewWidget to box
        video_view = new VideoPreviewWidget ();
        video_holder.pack_start (video_view);
        video_holder.show_all ();

        current_media = store.previews.first ();
        while (current_media.next != null && current_media.data.id != post.no)
            current_media = current_media.next;
        last_widget = loading_view;
        title = current_media.data.filename;
        show_media (current_media, true);
        set_transient_for (window);
    }

    ~MediaView () {
        if (current_media != null)
            current_media.data.stop_with_widget ();
        if (pulse_id != null)
            Source.remove ((!) pulse_id);
        if (media_onready_id != null)
            Source.remove ((!) media_onready_id);
        debug ("MediaView dtor");
    }

    private void show_media (List<MediaPreview> next_media, bool initial = false) {
        if (!initial)
            current_media.data.stop_with_widget ();
        current_media = next_media;
        btn_reverse_search.sensitive = current_media.data is ImagePreview;
        if (!current_media.data.loaded)
            stack.visible_child = loading_view;
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
        title = "%s (%d of %u)".printf (current_media.data.filename, store.previews.position (current_media) + 1, store.previews.length ());
        if (current_media.data is ImagePreview)
            current_media.data.init_with_widget (image_view);
        else if (current_media.data is VideoPreview)
            current_media.data.init_with_widget (video_view);
        media_onready_id = Idle.add (() => {
            if (!current_media.data.loaded)
                return Source.CONTINUE;
            // stop loading
            Source.remove (pulse_id);
            pulse_id = null;
            download_progress.set_fraction (1);
            media_onready_id = null;

            if (current_media.data is ImagePreview)
                last_widget = image_view;
            else if (current_media.data is VideoPreview) {
                last_widget = video_holder;
            } else
                error ("failed !!!");
            if (stack.visible_child != gallery_view)
                stack.visible_child = last_widget;
            return Source.REMOVE;
        });
    }

    [GtkCallback]
    private void show_prev_media () {
        if (current_media.prev == null)
            show_media (store.previews.last ());
        else
            show_media (current_media.prev);
    }

    [GtkCallback]
    private void show_next_media () {
        if (current_media.next == null)
            show_media (store.previews.first ());
        else
            show_media (current_media.next);
    }

    [GtkCallback]
    private void download_file () {
        var chooser = new Gtk.FileChooserDialog ("Save File", this,
            Gtk.FileChooserAction.SAVE,
            "_Cancel", Gtk.ResponseType.CANCEL,
            "_Save", Gtk.ResponseType.ACCEPT);
        chooser.set_current_name (current_media.data.filename);
        var filter = new Gtk.FileFilter ();
        filter.set_filter_name (current_media.data.extension);
        filter.add_pattern ("*" + current_media.data.extension);
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

    [GtkCallback]
    private void toggle_gallery () {
        if (btn_gallery.active)
            stack.visible_child = gallery_view;
        else
            stack.visible_child = last_widget;
    }

    [GtkCallback]
    private void reverse_image_search () {
        MediaPreview preview = current_media.data;
        AppInfo.launch_default_for_uri ("https://www.google.com/searchbyimage?&image_url=%s".printf (preview.url), null);
    }

    [GtkCallback]
    private void toggle_fullscreen () {
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
