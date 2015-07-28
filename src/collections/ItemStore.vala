using Gee;

namespace Vaccine.Collections {
    [GenericAccessors]
    public abstract class ItemStore<G> : Object, ListModel, Iterable<G>, Traversable<G> {
        protected bool mutable = true;

        public new abstract G @get (int i);

        public new virtual void @set (int i, G item)
            requires (mutable)
        {
            items_changed (i, 0, 1);
        }

        public abstract uint length { get; }

        public virtual void append (G item)
            requires (mutable)
        {
            items_changed (length-1, 0, 1);
        }

        public virtual void remove (uint position)
            requires (mutable)
        {
            items_changed (position, 1, 0);
        }

        public abstract void remove_all () requires (mutable);

        public abstract ItemStore<G> filtered (Predicate<G> func);

        public abstract Iterator<G> iterator ();

        public bool @foreach (ForallFunc<G> f) {
            foreach (var obj in this)
                if (!f (obj))
                    return false;
            return true;
        }

        public Iterator<G> filter (owned Predicate<G> pred) {
            return iterator ().filter (pred);
        }

        public Type get_item_type () {
            return typeof (G);
        }

        public uint get_n_items () {
            return length;
        }

        public Object? get_item (uint position) {
            if (position >= get_n_items ())
                return null;
            return this [(int)position] as Object;
        }
    }
}
