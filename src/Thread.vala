using Gee;

namespace Vaccine {
    public class Thread : Object, ListModel {
        private ArrayList<Post> realposts;
        private ArrayList<Post>? _filtered_posts;
        public ArrayList<Post> posts {
            get { return _filtered_posts ?? realposts; }
        }
        public string board { get; construct; }

        public delegate bool FilterFunc(Post p);

        public ThreadOP op {
            get {
                assert (posts.size > 0);
                ThreadOP *p = posts[0] as ThreadOP;
                p->unref(); // TODO: is this truly necessary?
                return p;
            }
        }

        public Thread (string board_name) {
            Object(board: board_name);
            realposts = new ArrayList<Post> ();
        }

        public Thread filter (FilterFunc func) {
            Thread t = new Thread (board);
            t.realposts = realposts;
            t._filtered_posts = new ArrayList<Post> ();
            foreach (var post in t.realposts)
                if (func (post))
                    t._filtered_posts.add (post);
            return t;
        }

        public Object? get_item (uint pos)
            requires(0 <= pos < posts.size)
        {
            return posts[(int)pos];
        }

        public Type get_item_type () {
            return typeof (Post);
        }

        public uint get_n_items () {
            return posts.size;
        }

        public static string get_tab_title (Thread thread) {
            var title = @"/$board/ - ";
            title += thread.op.sub ?? Stripper.transform_post(thread.op.com) ?? thread.op.no.to_string ();
            return Util.ellipsize(title, 32);
        }
    }
}
