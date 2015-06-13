using Gee;

public class Thread : Object, Json.Serializable {
    public ArrayList<Post> posts { get; set; }

    public ThreadOP op {
        get {
            ThreadOP *p = posts[0] as ThreadOP;
            p->unref();
            print ("%u\n", p->ref_count);
            return p;
        }
    }

    public bool deserialize_property (string property_name, out Value val, ParamSpec pspec, Json.Node property_node) {
        if (property_name != "posts") {
            val = Value (pspec.value_type);
            return default_deserialize_property (property_name, &val, pspec, property_node);
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

    public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec) {
        error ("serialization not supported");
    }
}

public class Post : Object {
    public int no              { get; set; }
    public string now          { get; set; }
    public string name         { get; set; }
    public string com          { get; set; }

    // image stuff
    public string filename     { get; set; }
    public string ext          { get; set; }
    public int w               { get; set; }
    public int h               { get; set; }
    public int tn_w            { get; set; }
    public int tn_h            { get; set; }
    public int tim             { get; set; }
    public string md5          { get; set; }
    public int fsize           { get; set; }

    public int time            { get; set; }
    // no of OP
    public int resto           { get; set; }
    public string capcode      { get; set; }
    public string trip         { get; set; }

    public bool isOP { get { return resto == 0; } }
}

public class ThreadOP : Post {
    public int sticky          { get; set; }
    public int closed          { get; set; }
    public string sub          { get; set; }
    public string semantic_url { get; set; }
    public int replies         { get; set; }
    public int images          { get; set; }
    public int bumplimit       { get; set; }
    public int imagelimit      { get; set; }
    public int unique_ips      { get; set; }
}
