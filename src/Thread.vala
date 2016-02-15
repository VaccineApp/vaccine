using Gee;

public class Vaccine.Thread : Object, ListModel {
    public ArrayList<Post>? posts = null;

    public string get_title () {
        string? sub = Stripper.transform_post (op.sub);
        if (sub != null)
            return "/%s/ — %s".printf (board, sub);

        string? com = Stripper.transform_post (op.com);
        if (com != null)
            return "/%s/ — %s".printf (board, com);

        string no = op.no.to_string ();
        return "/%s/ — %s".printf (board, no);
    }

    public ThreadOP op {
        owned get {
            assert (posts.size > 0);
            return posts[0] as ThreadOP;
        }
    }

    public string board { get; construct; }
    public int64 no { get; construct; }

    private uint timeout_id = -1;

    public Thread (string board, int64 no) {
        Object (board: board, no: no);
        // TODO make pref, min 10 sec per API rules
        unowned SourceFunc update_cb = () => {
            this.update_thread ();
            return Source.CONTINUE;
        };
        timeout_id = Timeout.add_seconds (10, update_cb);
    }

    ~Thread () {
        stop_updating ();
    }

    public void stop_updating () {
        if (timeout_id != -1) {
            Source.remove (timeout_id);
            timeout_id = -1;
        }
    }

    public void append (Post p) {
        posts.add (p);
        items_changed (posts.size-1, 0, 1);
    }

    public Object? get_item (uint position) {
        return posts[(int) position] as Object;
    }

    public Type get_item_type () {
        return typeof (Post);
    }

    public uint get_n_items () {
        return posts == null ? 0 : posts.size;
    }

    public void update_thread () {
        debug ("updating thread %lld".printf (no));
        FourChan.dl_thread.begin (this);
    }
}
