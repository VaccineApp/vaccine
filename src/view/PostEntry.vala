[GtkTemplate (ui = "/org/vaccine/app/ui/post-entry.ui")]
public class Vaccine.PostEntry : Gtk.Frame {
    public Post post { get; set; }

    [GtkChild] private Gtk.Revealer post_content_revealer;
    [GtkChild] private Gtk.Label post_name;
    [GtkChild] private Gtk.Label post_time;
    [GtkChild] private Gtk.Label post_no;
    [GtkChild] private Gtk.TextView post_textview;

    [GtkChild] private Gtk.Revealer img_revealer;
    [GtkChild] private Gtk.Image post_thumbnail;
    [GtkChild] private Gtk.Label post_filename;

    [GtkChild] private Gtk.MenuButton post_btn_replies;
    [GtkChild] private Gtk.Label post_nreplies;

    [GtkChild] private Gtk.ToggleToolButton post_btn_hide;

    [GtkChild] private Gtk.Revealer post_img_btns_revealer;

    private Cancellable? cancel = null;

    static Gtk.TextTagTable tags = new Gtk.TextTagTable ();

    static construct {
        var greentext = new Gtk.TextTag ("greentext");
        greentext.foreground = "#789922";
        tags.add (greentext);

        var link = new Gtk.TextTag ("link");
        link.foreground = "#2a76c6";
        link.underline = Pango.Underline.SINGLE;
        link.event.connect ((obj, event, iter) => {
            switch (event.type) {
            case Gdk.EventType.BUTTON_RELEASE:  // click
                Gtk.TextIter select_start, select_end;
                Gtk.TextView textview = obj as Gtk.TextView;

                textview.buffer.get_selection_bounds (out select_start, out select_end);
                // if text is selected, don't open any links
                if (select_start.get_offset () != select_end.get_offset ())
                    return false;
                var iter_begin = iter;
                var iter_end = iter;
                if (iter_begin.backward_to_tag_toggle (null)
                 && iter_end.forward_to_tag_toggle (null)) {
                    string url = iter_begin.get_text (iter_end);
                    try {
                        // try open
                        AppInfo.launch_default_for_uri (url, null);
                    } catch (Error e) {
                        warning (url + ": " + e.message);
                    }
                }
                break;
            default:
                return false;
            }
            return false;
        });
        tags.add (link);

        var code = new Gtk.TextTag ("code");
        code.font = "monospace";
        tags.add (code);

        var bold = new Gtk.TextTag ("bold");
        bold.weight = Pango.Weight.BOLD;
        tags.add (bold);

        var underline = new Gtk.TextTag ("underline");
        underline.underline = Pango.Underline.SINGLE;
        tags.add (underline);

        // TODO spoiler

        // TODO math
        var math = new Gtk.TextTag ("math");
        math.font = "serif";
        tags.add (math);
    }

    private Gdk.Cursor cursor_text;
    private Gdk.Cursor cursor_pointer;

    private PostReplies reply_list;

    private Menu menu;

    public PostEntry (Post post, Gdk.Pixbuf? thumbnail = null) {
        Object (post: post);

        reply_list = new PostReplies (post);
        menu = new Menu ();
        post.bind_property ("visible", this, "visible", BindingFlags.DEFAULT);
        post.bind_property ("hidden", post_btn_hide, "active", BindingFlags.INVERT_BOOLEAN);
        post_content_revealer.bind_property ("reveal-child", post_btn_hide,
            "active", BindingFlags.INVERT_BOOLEAN | BindingFlags.BIDIRECTIONAL);
        App.settings.bind ("show-trips", post_name, "visible", SettingsBindFlags.GET);

        string name = post.name;
        if (post.capcode != null)
            name += " ## " + post.capcode[0].toupper().to_string () + post.capcode.substring (1);

        post_name.label = "<b>%s</b> <span color=\"#aaa\">%s</span>".printf (name, post.trip ?? "");
        post_time.label = FourChan.get_post_time (post.time);
        post_no.label = "No. %lld".printf (post.no);

        if (post.filename == null) {
            assert (!post.isOP);
            // img_revealer.reveal_child = false;
            img_revealer.destroy ();
        } else if (thumbnail != null) {
            post_thumbnail.pixbuf = thumbnail;
        } else {
            cancel = post.get_thumbnail (buf => {
                cancel = null;
                post_thumbnail.pixbuf = buf;
            });
        }

        if (post.filename != null) {
            post_filename.label = post.filename + post.ext;
        }

        post_textview.buffer = new Gtk.TextBuffer (tags);
        if (post.com != null) {
            try {
                new PostTextBuffer (post.com).fill_text_buffer (post_textview.buffer, post_textview);
            } catch (Error e) {
                debug (e.message);
            }
        }

        cursor_text = new Gdk.Cursor.from_name (post_textview.get_display (), "text");
        cursor_pointer = new Gdk.Cursor.from_name (post_textview.get_display (), "pointer");

        post_textview.motion_notify_event.connect (event => {
            int x, y;
            post_textview.window_to_buffer_coords (Gtk.TextWindowType.WIDGET, (int) event.x, (int) event.y, out x, out y);

            Gtk.TextIter mouse;
            post_textview.get_iter_at_location (out mouse, x, y);

            var cursor = cursor_text;
            foreach (var tag in mouse.get_tags ()) {
                if (tag.name == "link") {
                    cursor = cursor_pointer;
                    break;
                }
            }
            post_textview.get_window (Gtk.TextWindowType.TEXT).cursor = cursor;
            return false;
        });

        post.bind_property ("nreplies", post_nreplies, "label", BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
        (obj, src, ref target) => {
            uint val = src.get_uint ();
            target = val > 99 ? "99+" : val.to_string ();
            return true;
        });

        reply_list.reply_added.connect (reply => menu.append ("#%lld".printf (reply.no), null));

        post_btn_replies.menu_model = menu;
    }

    ~PostEntry () {
        if (cancel != null)
            cancel.cancel ();
    }

    [GtkCallback]
    private bool image_controls_enter (Gdk.EventCrossing event) {
        post_img_btns_revealer.reveal_child = true;
        return Gdk.EVENT_STOP;
    }

    [GtkCallback]
    private bool image_controls_leave (Gdk.EventCrossing event) {
        post_img_btns_revealer.reveal_child = false;
        return Gdk.EVENT_PROPAGATE;
    }
}
