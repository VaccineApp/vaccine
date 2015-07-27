using Gee;

namespace Vaccine {
    public class FilterListModel : Object, ListModel {
        public delegate bool FilterFunc (Object o);

        FilterFunc filter;
        ListModel data;

        public FilterListModel (ListModel data, FilterFunc filter) {
            this.filter = filter;
            this.data = data;
        }

        public Object? get_item (uint pos) {
            uint i = 0, f = 0;
            for (; f <= pos && i < data.get_n_items (); ++i) {
                Object? obj = data.get_item (i);
                if (obj != null && filter ((!) obj) == true)
                    ++f;
            }

            return data.get_item (i-1);
        }

        public Type get_item_type () {
            return data.get_item_type ();
        }

        public uint get_n_items () {
            var objs = new ArrayList<weak Object> ();
            for (int i = 0; i < data.get_n_items (); ++i)
                objs.add (data.get_item (i));
            uint count = 0;
            foreach (var obj in objs)
                if (filter (obj))
                    ++count;
            return count;
        }
    }
}
