using Gtk;

public class Vaccine.PanelView : Container {
    private List<Widget> _children;

    private uint _current = 0;
    public uint current {
        get { return _current; }
        set {
            _current = value;
            queue_resize_no_redraw ();
        }
    }

    private uint _max_visible;
    public uint max_visible {
        get { return _max_visible; }
        set {
            _max_visible = value;
            queue_resize_no_redraw ();
        }
    }

    public PanelView (uint maximum_visible = 2) {
        // Container
        base.set_has_window (false);
        base.set_can_focus (true);
        base.set_redraw_on_allocate (false);
        // Widget
        this.set_visible (true);
        // misc
        max_visible = maximum_visible;
        _children = new List<Widget> ();
    }

    public PanelView.with_name (string name, uint maximum_visible = 2) {
        this (maximum_visible);
        this.name = name;
    }

    ~PanelView () {
        debug ("PanelView dtor");
        _children.foreach (w => w.destroy ());
    }

    public override void add (Widget widget) {
        _children.append (widget);
        widget.set_parent (this);
        if (get_visible () && widget.get_visible ()) {
            queue_resize_no_redraw ();
            uint len = _children.length ();
            if (len - current > max_visible)
                current = len - max_visible;
        }
    }

    public override void remove (Widget widget) {
        unowned List<Widget> elem = _children.find (widget);
        int position = _children.position (elem);
        if (elem.next != null)
            remove (elem.next.data);
        _children.remove (widget);
        if (current >= position)
            current = position >= max_visible ? position - max_visible : position - 1;
        else if (position - (int)current < max_visible)
            current = current > 0 ? current - 1 : current;
        widget.unparent ();
        if (get_visible () && widget.get_visible ())
            queue_resize_no_redraw ();
    }

    public override void forall_internal (bool include_internal, Gtk.Callback callback) {
        _children.foreach (w => callback (w));
    }

    public override SizeRequestMode get_request_mode () {
        return SizeRequestMode.WIDTH_FOR_HEIGHT;
    }

    public override Type child_type () {
        return typeof (ThreadPane);
    }

    public override void size_allocate (Allocation allocation) {
        uint length = _children.length ();
        int border_width = (int) get_border_width ();
        Allocation child_allocation = Allocation ();
        child_allocation.x = allocation.x + border_width;
        child_allocation.y = allocation.y + border_width;
        child_allocation.width = (allocation.width - 2*border_width) / (int) uint.min(max_visible, length);
        child_allocation.height = allocation.height - 2*border_width;
        uint nthchild = 0;
        _children.foreach (widget => {
            Allocation widget_allocation = Allocation() {
                x = child_allocation.x +
                    (nthchild <= current ? 0 : (int)(nthchild - current)*child_allocation.width),
                y = child_allocation.y,
                width = child_allocation.width,
                height = child_allocation.height
            };
            widget.size_allocate (widget_allocation);
            if (widget.get_realized ())
                widget.show ();
            ++nthchild;
        });
        base.size_allocate (allocation);
    }

    public new void get_preferred_size (out Requisition minimum_size, out Requisition natural_size) {
        unowned List<Widget> list = _children.nth (current);
        minimum_size = { 0, 0 };
        natural_size = { 0, 0 };

        int i = 0;
        for (unowned List<Widget> obj = list; obj.next != null && i < max_visible; obj = obj.next, ++i) {
            Widget child = obj.data;
            Requisition child_minsize, child_natsize;
            child.get_preferred_size (out child_minsize, out child_natsize);
            minimum_size.width += child_minsize.width;
            minimum_size.height += child_minsize.height;
            natural_size.width += child_natsize.width;
            natural_size.height += child_natsize.height;
        }
    }

    // What is the point of this method?
    public override bool draw (Cairo.Context cr) {
        base.draw (cr);
        return false;
    }
}
