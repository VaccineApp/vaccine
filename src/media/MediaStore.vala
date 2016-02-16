public class Vaccine.MediaStore : Object, Gtk.TreeModel {
    public Thread thread { construct; get; }
    public List<MediaPreview> previews = new List<MediaPreview> ();
    private int stamp = 0;

    public MediaStore (Thread t) {
        Object (thread: t);

        t.posts.foreach (post => {
            if (post.filename != null) {
                var media = MediaPreview.from_post (this, post);
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
        // cancel all downloads
        foreach (var preview in previews)
            preview.cancel_thumbnail_download.cancel ();
    }

    private void update (uint position, uint removed, uint added) {
        unowned List<MediaPreview> current = previews.first ();

        for (uint p = 0; p < thread.posts.size; ++p)
            if (thread.posts [(int)p].filename != null && MediaPreview.is_supported (thread.posts [(int)p].ext)) {
                if (current != null && thread.posts [(int)p].no == current.data.id)
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
                    var media = MediaPreview.from_post (this, thread.posts [(int)p]);
                    current.append (media);
                    ++stamp;
                    current = current.next;
                    var iter = Gtk.TreeIter () {
                        stamp = this.stamp,
                        user_data = current
                    };
                    var path = get_path (iter);
                    this.row_inserted (path, iter);
                }
            }
    }

    /**
     * Get property type by index:
     * 0 = id (int64)
     * 1 = thumbnail (Gdk.Pixbuf)
     * 2 = filename (string)
     */
    public Type get_column_type (int index) {
        switch (index) {
        case 0:
            return typeof (int64);
        case 1:
            return typeof (Gdk.Pixbuf);
        case 2:
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

        MediaPreview preview = ((List<MediaPreview>) iter.user_data).data;

        switch (column) {
        case 0: // id
            val = Value (typeof (int64));
            val.set_int64 (preview.id);
            break;
        case 1: // pixbuf
            val = Value (typeof (Gdk.Pixbuf));
            val.set_object (preview.thumbnail);
            break;
        case 2: // filename
            val = Value (typeof (string));
            val.set_string (preview.filename);
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

    public int get_n_columns () { return 3; }

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

    public bool get_path_and_iter (MediaPreview preview, out Gtk.TreePath path, out Gtk.TreeIter iter) {
        for (unowned List<MediaPreview> link = previews.first ();
            link != null; link = link.next) {
            if (link.data == preview) {
                iter = Gtk.TreeIter () {
                    stamp = this.stamp,
                    user_data = link
                };
                path = this.get_path (iter);
                return true;
            }
        }
        invalid_iter (out iter);
        path = null;
        return false;
    }
}
