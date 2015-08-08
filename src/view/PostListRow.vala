[GtkTemplate (ui = "/org/gnome/vaccine/post-list-row.ui")]
public class Vaccine.PostListRow : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label post_name;
    [GtkChild] private Gtk.Label post_time;
    [GtkChild] private Gtk.Label post_no;

    [GtkChild] private Gtk.Label post_text;
    [GtkChild] private Gtk.Image post_thumbnail;
    [GtkChild] private Gtk.Button responses_button;
    [GtkChild] private Gtk.Label responses_amount;

    private Cancellable? cancel = null;

    public Post post { get; construct; }

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

        post_text.label = FourChan.get_post_text (post.com);

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
        panelView.add (new ThreadPane.with_replies (new PostReplies (post), @"Replies to No. $(post.no)"));
    }
}
