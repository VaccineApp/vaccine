[GtkTemplate (ui = "/org/vaccine/app/post-list-row.ui")]
public class Vaccine.PostListRow : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label post_name;
    [GtkChild] private Gtk.Label post_time;
    [GtkChild] private Gtk.Label post_no;

    [GtkChild] private Gtk.TextView post_textview;
    [GtkChild] private Gtk.Button image_button;
    [GtkChild] private Gtk.Image post_thumbnail;
    [GtkChild] private Gtk.Button responses_button;
    [GtkChild] private Gtk.Label responses_amount;

    private Cancellable? cancel = null;

    public Post post { get; construct; }

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
    }

    private Gdk.Cursor cursor_text;
    private Gdk.Cursor cursor_pointer;

    public PostListRow (Post post, Gdk.Pixbuf? thumbnail = null) {
        Object (post: post);

        post.bind_property ("visible", this, "visible", BindingFlags.DEFAULT);

        App.settings.bind ("show-trips", post_name, "visible", SettingsBindFlags.GET);

        string name = post.name;
        if (post.capcode != null)
            name += " ## " + post.capcode[0].toupper().to_string () + post.capcode.substring (1);

        post_name.label = "<b>%s</b> <span color=\"#aaa\">%s</span>".printf (name, post.trip ?? "");
        post_time.label = FourChan.get_post_time (post.time);
        post_no.label = "No. %lld".printf (post.no);

        if (post.filename == null) {
            assert (!post.isOP);
            image_button.destroy ();
        } else if (thumbnail != null) {
            post_thumbnail.pixbuf = thumbnail;
        } else {
            cancel = post.get_thumbnail (buf => {
                cancel = null;
                post_thumbnail.pixbuf = buf;
            });
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

        // TODO property binding for thread updates
        var nreplies = post.nreplies;
        if (nreplies == 0) {
            responses_button.destroy ();
        } else {
            responses_amount.label = nreplies > 99 ? "99+" : nreplies.to_string ();
            responses_amount.get_style_context ().remove_class ("label");
        }
    }

    ~PostListRow () {
        if (cancel != null)
            cancel.cancel ();
    }

    [GtkCallback]
    private void show_responses () {
        var panelView = get_ancestor (typeof (PanelView)) as PanelView;
        var tpane = get_ancestor (typeof (ThreadPane)) as ThreadPane;
        var children = panelView.get_children ();
        int position = children.index (tpane);
        Gtk.Widget? next;
        if ((next = children.nth_data (position + 1)) != null)
            panelView.remove (next);
        var threadpane = new ThreadPane.with_title ("Replies to No. %lld".printf (post.no));
        panelView.add (threadpane);
        threadpane.set_model (new PostReplies (post));
    }

    [GtkCallback]
    private void show_media_view () {
        var win = (Application.get_default () as App).main_window;
        new MediaView (win, post).present ();
    }
}
