public class Vaccine.PostReplies : Object {
    public Post post { get; set; }

    public HashTable<int64?,Post> replies = new HashTable<int64?,Post> (int64_hash, int64_equal);

    private string to_ref;

    private uint timeout_id = -1;

    public PostReplies (Post post) {
        Object (post: post);
        to_ref = "&gt;&gt;%lld".printf (post.no);

        unowned SourceFunc callback = () => {
            foreach (var p in post.thread.posts)
                if (p.com != null && p.com.contains (to_ref)) {
                    replies.insert (p.no, p);
                    ++post.nreplies;
                    reply_added (p);
                }
            timeout_id = -1;
            return Source.REMOVE;
        };
        timeout_id = Idle.add (callback);

        post.thread.post_added.connect (p => {
            if (p.com != null && p.com.contains (to_ref)) {
                replies.insert (p.no, p);
                ++post.nreplies;
                reply_added (p);
            }
        });

        post.thread.post_removed.connect (p => {
            if (replies.contains (p.no)) {
                replies.remove (p.no);
                --post.nreplies;
                reply_removed (p);
            }
        });
    }

    ~PostReplies () {
        if (timeout_id != -1) {
            Source.remove (timeout_id);
            timeout_id = -1;
        }
    }

    public signal void reply_added (Post p);
    public signal void reply_removed (Post p);
}
