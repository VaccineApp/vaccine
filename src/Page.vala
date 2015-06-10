using Gee;

public class ThreadInfo : Object {
    public int no              { get; set; }
    public int sticky          { get; set; }
    public int closed          { get; set; }
    public string now          { get; set; }
    public string name         { get; set; }
    public string sub          { get; set; default = ""; }

    private string _com;
    public string com {
        get { return _com; }
        set {
            _com = value.compress ()
                .replace ("target=\"_blank\"", "")
                .replace ("span=\"quote\"", "")
                .replace ("<br>", "\n")
                .replace ("<wbr>", ""); // suggested position for word break if needed
        }
    }

    public string filename     { get; set; }
    public string ext          { get; set; }
    public int w               { get; set; }
    public int h               { get; set; }
    public int tn_w            { get; set; }
    public int tn_h            { get; set; }
    public int tim             { get; set; }
    public int time            { get; set; }
    public string md5          { get; set; }
    public int fsize           { get; set; }
    public int resto           { get; set; }
    public string capcode      { get; set; }
    public string semantic_url { get; set; }
    public int replies         { get; set; }
    public int images          { get; set; }
    public int last_modified   { get; set; }

    public string to_string () {
        return @"$no - $sub";
    }
}

public class Page : Object, Json.Serializable {
    public int page { get; set; }
    public Gee.List<ThreadInfo> threads { get; set; }

    public bool deserialize_property (string property_name, out Value val, ParamSpec pspec, Json.Node property_node) {
        if (property_name != "threads") {
            val = Value (pspec.value_type);
            return default_deserialize_property (property_name, &val, pspec, property_node);
        }

        var list = new ArrayList<ThreadInfo> ();
        property_node.get_array().foreach_element ((arr, index, node) => {
            list.add (Json.gobject_deserialize (typeof (ThreadInfo), node) as ThreadInfo);
        });
        val = Value (list.get_type ());
        val.set_object (list);
        return true;
    }

    public unowned ParamSpec find_property (string name) {
        return this.get_class ().find_property (name);
    }

    public Json.Node serialize_property (string property_name, Value value, ParamSpec pspec) {
        error ("Page serialization not supported");
    }
}
