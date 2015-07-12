using Gtk;

namespace Vaccine {
    public class PanelView : Container {
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
            // misc
            max_visible = maximum_visible;
        }

        public override void add (Widget widget) {
            widget.set_parent (this);
        }

        public override void remove (Widget widget) {
            widget.unparent ();
            if (get_visible () && widget.get_visible ())
                queue_resize_no_redraw ();
        }

        public override SizeRequestMode get_request_mode () {
            return SizeRequestMode.WIDTH_FOR_HEIGHT;
        }

        public override void size_allocate (Allocation allocation) {
            uint border_width = get_border_width ();
            Allocation child_allocation = Allocation ();
            child_allocation.x = (int) border_width;
            child_allocation.y = (int) border_width;
            child_allocation.width = (allocation.width - 2*(int) border_width) / (int) max_visible;
            child_allocation.height = allocation.height - 2*(int) border_width;
            uint nthchild = 0;
            get_children ().foreach ((widget) => {
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
            unowned List<weak Widget> list = get_children ().nth (current);
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
        }

        public override bool draw (Cairo.Context cr) {
            base.draw (cr);
            return false;
        }
    }
}
