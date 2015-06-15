using Gee;

public class Thread : Object, ListModel {
    private ArrayList<Post> posts = new ArrayList<Post> ();


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


    public void add (Post post) {
        posts.insert (0, post);
    }

    public ThreadOP op {
        get {
            ThreadOP *p = posts[0] as ThreadOP;
            p->unref();
            print ("%u\n", p->ref_count);
            return p;
        }
    }

    public async void update () {

    }
/*
    // Json.Serializable
    public bool deserialize_property (string prop_name, out Value val, ParamSpec pspec, Json.Node property_node) {
        if (prop_name != "posts") {
            val = Value (pspec.value_type);
            return default_deserialize_property (prop_name, &val, pspec, property_node);
        }

        var list = new ArrayList<Post> ();
        var op = property_node.get_array ().get_element (0);
        list.add (Json.gobject_deserialize (typeof (ThreadOP), op) as ThreadOP);
        property_node.get_array ().foreach_element ((arr, index, node) => {
            if (index != 0)
                list.add (Json.gobject_deserialize (typeof (Post), node) as Post);
        });
        val = Value (list.get_type ());
        val.set_object (list);
        return true;
    }

    public unowned ParamSpec find_property (string name) {
        return this.get_class ().find_property (name);
    }

    public Json.Node serialize_property (string prop_name, Value val, ParamSpec pspec) {
        error ("serialization not supported");
    }
*/
}

