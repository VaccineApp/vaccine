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

        Settings prefs = (Application.get_default () as App).settings;

        post_name.visible = prefs.get_boolean ("show-trips");
        prefs.bind ("show-trips", post_name, "visible", SettingsBindFlags.GET);

        post_name.label = "<b>%s</b> <span color=\"#aaa\">%s</span>".printf (post.name, post.trip ?? "");
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
                string src;
                if (post is ThreadOP && ((ThreadOP) post).sticky == 1)
                    src = PostTransformer.common_clean (post.com, true);
                else
                    src = PostTransformer.common_clean (post.com, false);
                new PostTextBuffer (src).fill_text_buffer (post_textview.buffer);
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

        /**
         * The example in gtk3-demo creates link tags on the fly and does g_object_set_data (tag, url).
         * Should we be doing this? check memory & performance
         */
        post_textview.event_after.connect (event => {
            // if left button up
            if (event.type == Gdk.EventType.BUTTON_RELEASE && event.button.button == Gdk.BUTTON_PRIMARY) {
                Gtk.TextIter select_start, select_end;
                post_textview.buffer.get_selection_bounds (out select_start, out select_end);
                // if text is selected, don't open any links
                if (select_start.get_offset () != select_end.get_offset ())
                    return;

                // get buffer coords
                int x, y;
                post_textview.window_to_buffer_coords (Gtk.TextWindowType.WIDGET, (int) event.button.x, (int) event.button.y, out x, out y);

                // get TextIter
                Gtk.TextIter link;
                post_textview.get_iter_at_location (out link, x, y);
                foreach (var tag in link.get_tags ()) {
                    // find 'link' tag
                    if (tag.name == "link") {
                        // go to start of link
                        link.backward_to_tag_toggle (tags.lookup ("link"));
                        // go to end of link
                        Gtk.TextIter link_end = link;
                        link_end.forward_to_tag_toggle (tags.lookup ("link"));
                        // text between TextIters
                        var url = link.get_text (link_end);
                        // TODO handle quote links (>>1234)
                        try {
                            // try open
                            AppInfo.launch_default_for_uri (url, null);
                        } catch (Error e) {
                            warning (url + ": " + e.message);
                        }
                        break;
                    }
                }
            }
            // TODO handle touch up event
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
