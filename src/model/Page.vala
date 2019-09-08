using Gee;

public class Vaccine.Page : Object, Json.Serializable {
    public string? board               { get; set; }

    /**
     * The page number
     */
    public uint? page                    { get; set; }

    /**
     * The threads on this page
     */
    public ArrayList<ThreadOP> threads { get; set; }

    public bool deserialize_property (string prop_name, out Value val, ParamSpec pspec, Json.Node property_node) {
        if (prop_name != "threads") {
            val = Value (pspec.value_type);
            return default_deserialize_property (prop_name, out val, pspec, property_node);
        }

        var list = new ArrayList<ThreadOP> ();
        property_node.get_array ().foreach_element ((arr, index, node) => {
            var o = Json.gobject_deserialize (typeof (ThreadOP), node) as ThreadOP;
            assert (o != null);
            o.board = board;
            o.bump_order = index;
            list.add ((!) o);
        });

        val = Value (list.get_type ());
        val.set_object (list);
        return true;
    }
}
