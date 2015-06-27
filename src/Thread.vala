using Gee;

namespace Vaccine {
    public class Thread : Object, ListModel {
        public ArrayList<Post> posts = new ArrayList<Post> ();

        public ThreadOP op {
            get {
                assert (posts.size > 0);
                ThreadOP *p = posts[0] as ThreadOP;
                p->unref();
                return p;
            }
        }


        public Object? get_item (uint pos)
            requires(0 <= pos && pos < posts.size)
        {
            return posts[(int)pos];
        }

        public Type get_item_type () {
            return typeof (Post);
        }

        public uint get_n_items () {
            return posts.size;
        }
    }
}
