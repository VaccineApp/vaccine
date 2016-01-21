public class Vaccine.CoverImage : Gtk.Widget {
    public Gdk.Pixbuf image { get; construct; }

    construct {
        this.set_has_window (false);
    }

    public CoverImage (Gdk.Pixbuf image) {
        Object (image: image);
        this.visible = true;
    }

    public override void get_preferred_width (out int min, out int nat) {
        min = nat = image.width;
    }

    public override void get_preferred_height (out int min, out int nat) {
        min = nat = image.height;
    }

    public override bool draw (Cairo.Context cr) {
        Gtk.Allocation alloc;
        get_allocation (out alloc);

        double scale_x = (double) alloc.width / image.width;
        double scale_y = (double) alloc.height / image.height;

        if (scale_x * image.height >= alloc.height) {
            double offset = (alloc.height - image.height * scale_x) / 2;
            cr.translate (0, offset);
            cr.scale (scale_x, scale_x);
        } else if (scale_y * image.width >= alloc.width) {
            double offset = (alloc.width - image.width * scale_y) / 2;
            cr.translate (offset, 0);
            cr.scale (scale_y, scale_y);
        } else {
            assert_not_reached ();
        }

        Gdk.cairo_set_source_pixbuf (cr, image, 0, 0);
        cr.paint ();
        return Gdk.EVENT_PROPAGATE;
    }
}
