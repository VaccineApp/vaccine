[GtkTemplate (ui = "/org/vaccine/app/post-list-row.ui")]
public class Vaccine.PostListRow : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label post_name;
    [GtkChild] private Gtk.Label post_time;
    [GtkChild] private Gtk.Label post_no;

    [GtkChild] private Gtk.TextView post_textview;
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

        post_name.label = @"<b>$(post.name)</b> <span color=\"#aaa\">$(post.trip ?? "")</span>";
        post_time.label = FourChan.get_post_time (post.time);
        post_no.label = @"No. $(post.no)";

        if (post.filename == null) {
            assert (!post.isOP);
            post_thumbnail.destroy ();
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
                new PostTextBuffer (post.com).fill_text_buffer (post_textview.buffer);
            } catch (Error e) {
                debug (e.message);
            }
        }

        cursor_text = new Gdk.Cursor.for_display (post_textview.get_display (), Gdk.CursorType.XTERM);
        cursor_pointer = new Gdk.Cursor.for_display (post_textview.get_display (), Gdk.CursorType.HAND2);

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

    [GtkCallback] private void show_responses () {
        var panelView = get_ancestor (typeof (PanelView)) as PanelView;
        var tpane = get_ancestor (typeof (ThreadPane)) as ThreadPane;
        var children = panelView.get_children ();
        int position = children.index (tpane);
        Gtk.Widget? next;
        if ((next = children.nth_data (position + 1)) != null)
            panelView.remove (next);
        var threadpane = new ThreadPane.with_title (@"Replies to No. $(post.no)");
        panelView.add (threadpane);
        threadpane.set_model (new PostReplies (post));
    }
}
