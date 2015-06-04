public class Page : Object, Json.Serializable {
    public int page { get; set; }

    public class ThreadInfo : Object {
        public int no            { get; set; }
        public int last_modified { get; set; }

        public string to_string() {
            return @"Thread [no=$no, last_modified=$last_modified]";
        }
    }

    public Array<ThreadInfo> threads { get; set; }

    public string to_string() {
        var str = @"Page #$page ";
        for (int i = 0; i < threads.length; ++i) {
            str += "\n\t" + threads.index(i).to_string();
        }
        return str;
    }

    public bool deserialize_property(string property_name,
                                     out Value val,
                                     ParamSpec pspec,
                                     Json.Node property_node) {
        if (property_name != "threads") {
            val = Value(pspec.value_type);
            return default_deserialize_property(property_name, &val, pspec, property_node);
        }

        var array = new Array<ThreadInfo>();
        property_node.get_array().foreach_element((arr, index, node) => {
            array.append_val(Json.gobject_deserialize(typeof(ThreadInfo), node) as ThreadInfo);
        });
        val = Value(typeof(Array));
        val.set_boxed(array);
        return true;
    }

    public unowned ParamSpec find_property(string name) {
        return this.get_class().find_property(name);
    }

    public Json.Node serialize_property(string property_name, Value value, ParamSpec pspec) {
        return new Json.Node(Json.NodeType.NULL);
    }
}
