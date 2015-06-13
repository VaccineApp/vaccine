using Gee;

public class Page : Object, Json.Serializable {
    public int page                    { get; set; }
    public ArrayList<ThreadOP> threads { get; set; }

    public bool deserialize_property (string property_name, out Value val, ParamSpec pspec, Json.Node property_node) {
        if (property_name != "threads") {
            val = Value (pspec.value_type);
            return default_deserialize_property (property_name, &val, pspec, property_node);
        }

        var list = new ArrayList<ThreadOP> ();
        property_node.get_array ().foreach_element ((arr, index, node) => {
            debug (node.type_name() + "\n");
            var o = Json.gobject_deserialize (typeof (ThreadOP), node) as ThreadOP;
            assert (o != null);
            list.add (o);
        });

        debug (@"got $property_name: $(list.size)\n");
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

