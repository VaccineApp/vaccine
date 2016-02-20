using Gee;

public class Vaccine.Thread : Object, ListModel {
    public ArrayList<Post>? posts = null;

    public string get_title () {
        var op = posts[0] as ThreadOP;

        if (op.sub != null) {
            string? sub = Stripper.transform_post (op.sub);
            return "/%s/ — %s".printf (board, sub);
        }

        if (op.com != null) {
            string? com = Stripper.transform_post (op.com);
            return "/%s/ — %s".printf (board, com);
        }

        return "/%s/ — %lld".printf (board, no);
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

    public void set_filter (string text) {
        foreach (Post p in posts)
            p.visible = (p.com != null && text in p.com);
    }

    public void update_thread () {
        debug ("updating thread %lld".printf (no));
        FourChan.dl_thread.begin (this);
    }
}
