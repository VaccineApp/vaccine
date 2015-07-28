using Vaccine.Collections;

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

        public ItemStore<Post> replies { get; private set; }

        public PostListRow (Post post) {
            Object (post: post);
            replies = get_all_replies ();

            content.margin = 15; // glade erases this so just set in code

            post_name.label = post.name;
            post_time.label = FourChan.get_post_time (post.time);
            post_no.label = @"No. $(post.no)";

            if (post.filename == null) {
                post_thumbnail.destroy ();
            } else {
                cancel = FourChan.get_thumbnail (post, buf => {
                    cancel = null;
                    post_thumbnail.pixbuf = buf;
                });
            }

            post_text.label = FourChan.get_post_text (post.com);

            var nreplies = replies.length;
            if (nreplies == 0) {
                responses_button.destroy ();
            } else {
                responses_amount.label = nreplies > 99 ? "99+" : nreplies.to_string ();
                responses_amount.get_style_context ().remove_class ("label");
            }
            Stylizer.set_widget_css (this, "/vaccine/post-list-row.css");
        }

        ~PostListRow () {
            if (cancel != null)
                cancel.cancel ();
        }

        private ItemStore<Post> get_all_replies () {
            return post.thread.filtered (_p => {
                var p = _p as Post;
                if (p == null || p.com == null) return false;
                return ((!) p).com.contains (@"&gt;&gt;$(post.no)");
            });
        }

        [GtkCallback] private void show_responses () {
            var panelView = get_ancestor (typeof (PanelView)) as PanelView;
            var tpane = get_ancestor (typeof (ThreadPane)) as ThreadPane;
            var children = panelView.get_children ();
            int position = children.index (tpane);
            Gtk.Widget? next;
            if ((next = children.nth_data (position + 1)) != null)
                panelView.remove (next);
            panelView.add (new ThreadPane (replies, @"Replies to No. $(post.no)"));
        }
    }
}
