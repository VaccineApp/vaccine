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
                if (obj != null && filter ((!) obj))
                    ++f;
            }

            return data.get_item (i-1);
        }

        public Type get_item_type () {
            return data.get_item_type ();
        }

        public uint get_n_items () {
            uint count = 0;
            uint length = data.get_n_items ();
            for (uint i = 0; i < length; ++i)
                if (filter (data.get_item (i)))
                    ++count;
            return count;
        }
    }
}
