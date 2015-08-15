[GtkTemplate (ui = "/org/vaccine/app/media-view.ui")]
public class Vaccine.MediaView : Gtk.Window {
    [GtkChild] private Gtk.HeaderBar headerbar;

    // headerbar buttons
    [GtkChild] private Gtk.Button btn_prev;
    [GtkChild] private Gtk.Button btn_next;
    [GtkChild] private Gtk.ToggleButton btn_gallery;
    [GtkChild] private Gtk.Button btn_download;
    [GtkChild] private Gtk.Button btn_present;

    // view and containers
    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.Alignment loading_view;
    [GtkChild] private Gtk.Box gallery_view;
    [GtkChild] private Gtk.IconView gallery_icons;
    [GtkChild] private Gtk.DrawingArea image_view;

    // custom data
    public Thread thread { construct; get; }
    private List<MediaPreview> media;
    private unowned List<MediaPreview> current_media;

    public MediaView (Gtk.ApplicationWindow window, Post post) {
        Object (thread: post.thread);
        var store = new Gtk.ListStore (3, typeof (Gdk.Pixbuf), typeof (string), typeof (MediaPreview));
        gallery_icons.pixbuf_column = 0;
        gallery_icons.text_column = 1;
        media = new List<MediaPreview> ();
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
        current_media.data.init_with_widget (image_view);
        stack.visible_child = image_view;
    }

    ~MediaView () {
        if (current_media != null)
            current_media.data.stop_with_widget ();
    }

    private void show_image (int num) {
        current_media.data.stop_with_widget ();
        current_media = media.nth (num);
        current_media.data.init_with_widget (image_view);
        stack.visible_child = image_view;
    }

    [GtkCallback] private void toggle_gallery () {
        if (btn_gallery.active)
            stack.visible_child = gallery_view;
        else
            stack.visible_child = image_view;
    }
}
