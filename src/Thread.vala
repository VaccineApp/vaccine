using Gee;

public class Vaccine.Thread : Object, ListModel {
    private ArrayList<Post> posts = new ArrayList<Post> ();

    public string title {
        owned get {
            var sub = Stripper.transform_post (op.sub);
            var com = Stripper.transform_post (op.com);
            var no = op.no.to_string ();
            return @"/$board/ — $(sub ?? com ?? no)";
        }
    }

    public ThreadOP op {
        owned get {
            assert (posts.size > 0);
            return posts[0] as ThreadOP;
        }
    }

    public string board { get; construct; }

    private uint timeout_id = -1;

    /**
     * This function creates a SourceFunc that calls
     * update_thread without storing a strong reference
     * to the Thread.
     */
    private static SourceFunc create_nonowning_callback (Thread thread) {
        weak Thread weakref = thread;
        return () => {
            debug (@"updating thread $(weakref.op.no)");
            weakref.update_thread ();
            return Source.CONTINUE;
        };
    }

    public Thread (string board) {
        Object(board: board);
        // TODO make pref, min 10 sec per API rules
        timeout_id = Timeout.add_seconds (10, create_nonowning_callback (this));
    }

    ~Thread () {
        debug (@"thread dtor $(op.no)");
        stop_updating ();
    }

    public void stop_updating () {
        if (timeout_id != -1)
            Source.remove (timeout_id);
        timeout_id = -1;
    }

    public void append (Post p) {
        posts.add (p);
        items_changed (posts.size-1, 0, 1);
    }

    public void @foreach (ForallFunc<Post> func) {
        posts.foreach (func);
    }

    public Object? get_item (uint position) {
        return posts[(int) position] as Object;
    }

    public Type get_item_type () {
        return typeof (Post);
    }

    public uint get_n_items () {
        return posts.size;
    }

    public void update_thread () {
        FourChan.get_thread.begin (board, op.no, (obj, res) => {
            Thread newer = FourChan.get_thread.end (res);
            newer.stop_updating ();

            int old_n_posts = posts.size;
            for (int i = 0; i < newer.posts.size; ++i) {
                var new_post = newer.posts[i];
                if (i > this.posts.size-1) { // new post
                    this.posts.add (newer.posts[i]);
                } else if (this.posts[i].no != new_post.no) { // post deleted
                    this.posts.remove_at (i);
                    this.items_changed (i, 1, 0);
                    --i;
                }
            }
            if (old_n_posts > 0)
                this.items_changed (old_n_posts, 0, this.posts.size - old_n_posts);
        });
    }
}
