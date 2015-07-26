namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/post-list-row.ui")]
    public class PostListRow : Gtk.ListBoxRow {
        [GtkChild] private Gtk.Box content;

        [GtkChild] private Gtk.Label post_name;
        [GtkChild] private Gtk.Label post_time;
        [GtkChild] private Gtk.Label post_no;

        [GtkChild] private Gtk.Label post_text;
        [GtkChild] private Gtk.Image post_thumbnail;
        [GtkChild] private Gtk.Button responses_button;
        [GtkChild] private Gtk.Label responses_amount;

        private Cancellable? cancel = null;

        public Post post { get; construct; }
        public Thread replies { get; private set; }

        public PostListRow (Post t) {
            Object (post: t);
            replies = get_all_replies ();

            content.margin = 15; // glade erases this so just set in code

            post_name.label = t.name;
            post_time.label = FourChan.get_post_time (t.time);
            post_no.label = @"No. $(t.no)";

            if (t.filename == null) {
                post_thumbnail.destroy ();
            } else {
                cancel = FourChan.get_thumbnail (t, buf => {
                    cancel = null;
                    post_thumbnail.pixbuf = buf;
                });
            }

            post_text.label = FourChan.get_post_text (t.com);

            if (replies.posts.size == 0)
                responses_button.destroy ();
            else {
                responses_amount.label = replies.posts.size > 99 ? "99+" : @"$(replies.posts.size)";
                responses_amount.get_style_context ().remove_class ("label");
            }
            Util.Stylizer.set_widget_css (this, "/vaccine/post-list-row.css");
        }

        ~PostListRow () {
            if (cancel != null)
                cancel.cancel ();
        }

        private Thread get_all_replies () {
            return post.thread.filter ((p) => p.com != null && p.com.contains ("&gt;&gt;"+post.no.to_string ()));
        }

        [GtkCallback] private void show_responses () {
            var panelView = get_ancestor (typeof (PanelView)) as PanelView;
            var tpane = get_ancestor (typeof (ThreadPane)) as ThreadPane;
            var children = panelView.get_children ();
            int position = children.index (tpane);
            Gtk.Widget next;
            if ((next = children.nth_data (position + 1)) != null)
                panelView.remove (next);
            panelView.add (new ThreadPane (replies, true, @"Replies to #$(post.no)"));
        }
    }
}
