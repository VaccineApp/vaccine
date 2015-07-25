using Gee;

namespace Vaccine {
    public class Thread : Object, ListModel {
        private ArrayList<Post> realposts;
        private ArrayList<Post>? filtered_posts;
        public ArrayList<Post> posts {
            get { return filtered_posts ?? realposts; }
        }
        public string board { get; construct; }

        public delegate bool FilterFunc (Post p);

        private ThreadOP? _op;
        public ThreadOP op {
            get { return _op == null ? (_op = posts[0] as ThreadOP) : _op; }
            private set { _op = value; }
        }

        public Thread (string board_name) {
            Object(board: board_name);
            realposts = new ArrayList<Post> ();
        }

        public Thread filter (FilterFunc func) {
            Thread t = new Thread (board);
            t.op = op;
            t.realposts = realposts;
            t.filtered_posts = new ArrayList<Post> ();
            foreach (var post in t.realposts)
                if (func (post))
                    t.filtered_posts.add (post);
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

        public string get_tab_title () {
            var title = @"/$board/ - ";
            title += op.sub ?? Stripper.transform_post(op.com) ?? op.no.to_string ();
            return title;
        }
    }
}
