using Gee;

namespace Vaccine {
    public class Thread : Object, ListModel {
        public ArrayList<Post> posts = new ArrayList<Post> ();
        public string board { get; construct; }

        public ThreadOP op {
            get {
                ThreadOP *op = posts[0] as ThreadOP;
                return op;
            }
        }

        public Thread (string board) {
            Object(board: board);
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

        public FilterListModel filter (FilterListModel.FilterFunc filter) {
            return new FilterListModel (this, filter);
        }

        public string get_tab_title () {
            var title = @"/$board/ - ";
            title += op.sub ?? Stripper.transform_post(op.com) ?? op.no.to_string ();
            return title;
        }
    }
}
