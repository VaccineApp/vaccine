using Gee;

namespace Vaccine.Collections {
    public class FilteredItemStore<G> : ItemStore<G> {
        ItemStore<G> store;
        ArrayList<G> list;
        Predicate<G> filterFunc;

        public FilteredItemStore (ItemStore<G> store, owned Predicate<G> filter) {
            this.store = store;
            filterFunc = filter;
            mutable = false;
            list = new ArrayList<G> ();
            store.items_changed.connect (update);
            update (0, 0, 0);
        }

        public override uint length { get { return list.size; } }

        private void update (uint pos, uint rm, uint add) {
            list.clear ();
            store.filter (obj => filterFunc(obj)).foreach (obj => list.add(obj));
            items_changed (0, 0, list.size);
        }

        public override G @get (int i) {
            return list [i];
        }

        public override void remove_all () {}

        public override ItemStore<G> filtered (owned Predicate<G> func) {
            return new FilteredItemStore<G> (this, func);
        }

        public override Iterator<G> iterator () {
            return list.iterator ();
        }
    }
}
