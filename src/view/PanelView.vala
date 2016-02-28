using Gtk;

public class Vaccine.PanelView : Container, NotebookPage {
    private SList<Widget> _children;

    private uint _current = 0;
    public uint current {
        get { return _current; }
        set {
            _current = value;
            queue_draw ();
        }
    }

    private uint _max_visible;
    public uint max_visible {
        get { return _max_visible; }
        set {
            _max_visible = value;
            queue_resize ();
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
        _children = new SList<Widget> ();
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
        unowned SList<Widget> elem = _children.find (widget);
        int position = _children.position (elem);
        if (elem.next != null)
            remove (elem.next.data);
        _children.remove (widget);
        widget.unparent ();
        if (current >= position)
            current = position >= max_visible ? position - max_visible : position - 1;
        else if (position - (int)current < max_visible)
            current = current > 0 ? current - 1 : current;
        if (get_visible ())
            queue_resize_no_redraw ();
    }

    public override void forall_internal (bool include_internal, Gtk.Callback callback) {
        _children.foreach (w => callback (w));
    }

    public override SizeRequestMode get_request_mode () {
        return SizeRequestMode.HEIGHT_FOR_WIDTH;
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

        int visible = (int) uint.min(max_visible, length);
        child_allocation.width = (allocation.width - 2*border_width) / visible;
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

    public override void get_preferred_width (out int minimum_width, out int natural_width) {
        base.get_preferred_width (out minimum_width, out natural_width);
        int visible = (int) uint.min(max_visible, _children.length ());
        Requisition child_minsize, child_natsize;
        if (visible > 0) {
            _children.nth_data (current).get_preferred_size (out child_minsize, out child_natsize);
            minimum_width = int.max(visible * child_minsize.width, minimum_width);
            natural_width = int.max(visible * child_natsize.width, natural_width);
        }
    }

    /* public new void get_preferred_size (out Requisition minimum_size, out Requisition natural_size) {
        unowned List<Widget> list = _children.nth (current);
        minimum_size = { 0, 0 };
        natural_size = { 0, 0 };

        int i = 0;
        for (unowned List<weak Widget> obj = list; obj.next != null && i < max_visible; obj = obj.next, ++i) {
            Widget child = obj.data;
            Requisition child_minsize, child_natsize;
            child.get_preferred_size (out child_minsize, out child_natsize);
            minimum_size.width += child_minsize.width;
            minimum_size.height += child_minsize.height;
            natural_size.width += child_natsize.width;
            natural_size.height += child_natsize.height;
        }
    } */

    // What is the point of this method?
    public override bool draw (Cairo.Context cr) {
        base.draw (cr);
        return false;
    }

    private NotebookPage threadpane () {
        return (NotebookPage) _children.data;
    }

    public string search_text {
        get { return threadpane ().search_text; }
        set { threadpane ().search_text = value; }
    }

    public void open_in_browser () {
        threadpane ().open_in_browser ();
    }

    public void refresh () {
        threadpane ().refresh ();
    }
}
