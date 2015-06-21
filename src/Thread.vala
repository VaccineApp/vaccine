using Gee;

public class Thread : Object, ListModel {
    public ArrayList<Post> posts = new ArrayList<Post> ();


    public Object? get_item (uint pos) {
        assert (pos >= 0);
        assert (pos < posts.size);
        return posts[(int)pos];
    }

    public Type get_item_type () {
        return typeof (Post);
    }

    public uint get_n_items () {
        return posts.size;
    }


    public ThreadOP op {
        get {
            assert (posts.size > 0);
            ThreadOP *p = posts[0] as ThreadOP;
            print ("%u\n", p->ref_count);
            return p;
        }
    }


    public string to_string () {
        return @"Thread $(op.no) with $(posts.size) posts";
    }
}

