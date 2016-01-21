using Gee;

public class Vaccine.PostReplies : Object, ListModel {
    public Post post { get; set; }
    private ArrayList<Post> replies = new ArrayList<Post> ();

    public PostReplies (Post post) {
        Object (post: post);
        post.thread.items_changed.connect (update_replies);
        update_replies (-1, -1, -1);
    }

    private void update_replies (uint pos, uint rem, uint add) {
        var quote = "&gt;&gt;%lld".printf (post.no);
        replies.clear ();
        post.thread.foreach (p => {
            if (p.com.contains (quote))
                replies.add (p);
            return true;
        });
    }

    public Object? get_item (uint position) {
        return replies[(int) position] as Object;
    }

    public Type get_item_type () {
        return typeof (Post);
    }

    public uint get_n_items () {
        return replies.size;
    }
}
