using Gee;

namespace Vaccine {
    public class Page : Object, Json.Serializable {
        public string? board               { get; set; }

        /**
         * The page number
         */
        public int page                    { get; set; }

        /**
         * The threads on this page
         */
        public ArrayList<ThreadOP> threads { get; set; }

        public bool deserialize_property (string prop_name, out Value val, ParamSpec pspec, Json.Node property_node) {
            if (prop_name != "threads") {
                val = Value (pspec.value_type);
                return default_deserialize_property (prop_name, &val, pspec, property_node);
            }

            var list = new ArrayList<ThreadOP> ();
            property_node.get_array ().foreach_element ((arr, index, node) => {
                var o = Json.gobject_deserialize (typeof (ThreadOP), node) as ThreadOP;
                o.board = board;
                list.add (o);
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
    }
}
