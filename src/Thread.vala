using Gee;
using Vaccine.Collections;

namespace Vaccine {
    public class Thread : ItemStore<Post> {
        ArrayList<Post> posts = new ArrayList<Post> ();
        public string board { get; construct; }

        public ThreadOP op {
            get {
                ThreadOP *op = posts[0] as ThreadOP;
                return op;
            }
        }

        public override uint length { get { return (uint) posts.size; } }

        public Thread (string board) {
            Object(board: board);
        }

        // why must return type be "Post" and not "Post?"?
        public override Post @get (int i) {
            if (i >= posts.size)
                return (!) null;    // -__-
            return posts [i];
        }

        public override void @set (int i, Post p) {
            posts [i] = p;
            base.@set (i, p);
        }

        public override void append (Post post) {
            posts.add (post);
            base.append (post);
        }

        public override void remove (uint pos) {
            posts.remove_at ((int) pos);
            base.remove (pos);
        }

        public override void remove_all () {
            posts.clear ();
        }

        public override ItemStore<Post> filtered (owned Predicate<Post> func) {
            return new FilteredItemStore<Post> (this, func);
        }

        public override Iterator<Post> iterator () {
            return posts.iterator ();
        }

        public string get_tab_title () {
            var title = @"/$board/ - ";
            title += op.sub ?? Stripper.transform_post(op.com) ?? op.no.to_string ();
            return title;
        }
    }
}
