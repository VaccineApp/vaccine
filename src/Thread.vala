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
        get {
            ThreadOP *op = posts[0] as ThreadOP;
            return op;
        }
    }

    public string board { get; construct; }

    public Thread (string board) {
        Object(board: board);
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

    /**
     * When we write the update_thread() method, we will simply emit the
     * items_changed signal
     */
}
