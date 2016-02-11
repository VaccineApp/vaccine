public class Vaccine.MediaStore : Object, Gtk.TreeModel {
    public Thread thread { construct; get; }
    public List<MediaPreview> previews = new List<MediaPreview> ();
    private int stamp = 0;

    public MediaStore (Thread t) {
        Object (thread: t);

        t.foreach (post => {
            if (post.filename != null) {
                var media = MediaPreview.from_post (post);
                if (media != null) {
                    previews.append (media);
                    ++stamp;
                }
            }
            return true;
        });

        t.items_changed.connect (update);
    }

    ~MediaStore () {
        debug ("MediaStore dtor");
    }

    private void update (uint position, uint removed, uint added) {
        unowned List<MediaPreview> current = previews.first ();

        for (uint p = 0; p < thread.posts.size; ++p)
            if (thread.posts [(int)p].filename != null && MediaPreview.is_supported (thread.posts [(int)p].ext)) {
                if (current != null && thread.posts [(int)p] == current.data.post)
                    current = current.next;
                else {
                    if (current != null) {  // remove
                        current = current.prev;
                        previews.remove_link (current.next);
                        --stamp;
                        var iter = Gtk.TreeIter () {
                            stamp = this.stamp,
                            user_data = current.next
                        };
                        var path = get_path (iter);
                        this.row_deleted (path);
                    } else
                        current = previews.last (); // insert at front
                    var media = MediaPreview.from_post (thread.posts [(int)p]);
                    current.append (media);
                    ++stamp;
                    var iter = Gtk.TreeIter () {
                        stamp = this.stamp,
                        user_data = current.next
                    };
                    var path = get_path (iter);
                    this.row_inserted (path, iter);
                    current = current.next;

                    /* Signal.connect (media.post, "pixbuf", () => {
                        MediaPreview preview = (owned) media;
                        Gtk.TreeIter iter2;

                        if (!iter_nth_child (out iter2, null, previews.position (preview)))
                            debug (@"failed to get iter for $(preview.post.filename + preview.post.ext)");
                        else {
                            Gtk.TreePath path2 = get_path (iter2);
                            row_changed (path2, iter2);
                        }
                    }, media); */
                }
            }
    }

    /**
     * Get property type by index:
     * 0 = thumbnail (Gdk.Pixbuf)
     * 1 = filename (string)
     */
    public Type get_column_type (int index) {
        switch (index) {
        case 0:
            return typeof (Gdk.Pixbuf);
        case 1:
            return typeof (string);
        default:
            return Type.INVALID;
        }
    }

    public Gtk.TreeModelFlags get_flags () {
        return 0;
    }

    // return an invalid iter
    private bool invalid_iter (out Gtk.TreeIter iter) {
        iter = Gtk.TreeIter () { stamp = -1 };
        return false;
    }

    public void get_value (Gtk.TreeIter iter, int column, out Value val) {
        assert (iter.stamp == stamp);

        Post post = ((List<MediaPreview>) iter.user_data).data.post;

        switch (column) {
        case 0: // pixbuf
            val = Value (typeof (Gdk.Pixbuf));
            val.set_object (post.pixbuf);
            break;
        case 1: // filename
            val = Value (typeof (string));
            val.set_string (post.filename + post.ext);
            break;
        default:
            val = Value (Type.INVALID);
            break;
        }
    }

    public bool get_iter (out Gtk.TreeIter iter, Gtk.TreePath path) {
        // (path depth of 1 = flat tree)
        if (path.get_depth () != 1 || thread.posts.size == 0)
            return invalid_iter (out iter);

        iter = Gtk.TreeIter () {
            stamp = this.stamp,
            user_data = previews.nth (path.get_indices ()[0])   // save List<G> link
        };
        return true;
    }

    public int get_n_columns () { return 2; }

    public Gtk.TreePath? get_path (Gtk.TreeIter iter) {
        assert (iter.stamp == stamp);

        Gtk.TreePath path = new Gtk.TreePath ();
        path.append_index (previews.position ((List<MediaPreview>) iter.user_data));
        return path;
    }

    public int iter_n_children (Gtk.TreeIter? iter) {
        assert (iter == null || iter.stamp == stamp);
        // iter == null (points to start of list)
        // iter != null (iter points to node with 0 child nodes)
        return iter == null ? thread.posts.size : 0;
    }

    public bool iter_next (ref Gtk.TreeIter iter) {
        assert (iter.stamp == stamp);

        unowned List<MediaPreview> link = (List<MediaPreview>) iter.user_data;
        if (link.next == null)
            return false;

        iter.user_data = link.next;
        return true;
    }

    public bool iter_previous (ref Gtk.TreeIter iter) {
        assert (iter.stamp == stamp);

        unowned List<MediaPreview> link = (List<MediaPreview>) iter.user_data;
        if (link.prev == null)
            return false;

        iter.user_data = link.prev;
        return true;
    }

    /*
     * Set iter to point to the nth child
     * parent should be null (if not, then we do nothing, since this is not a tree)
     */
    public bool iter_nth_child (out Gtk.TreeIter iter, Gtk.TreeIter? parent, int n) {
        assert (parent == null || parent.stamp == stamp);

        // set iter to nth child in list
        if (parent == null && n < previews.length ()) {
            iter = Gtk.TreeIter () {
                stamp = this.stamp,
                user_data = previews.nth (n)    // save link
            };
            return true;
        }

        // otherwise, return invalid iter
        return invalid_iter (out iter);
    }

    public bool iter_children (out Gtk.TreeIter iter, Gtk.TreeIter? parent) {
        assert (parent == null || parent.stamp == stamp);
        return invalid_iter (out iter); // not a tree
    }

    public bool iter_has_child (Gtk.TreeIter iter) {
        assert (iter.stamp == stamp);
        return false;   // not a tree
    }

    public bool iter_parent (out Gtk.TreeIter iter, Gtk.TreeIter child) {
        assert (child.stamp == stamp);
        return invalid_iter (out iter); // not a tree
    }
} 
