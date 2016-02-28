/**
 * Shows an image such that it fills its container, like
 * background-size: cover;
 * background-position: center;
 */
public class Vaccine.CoverImage : Gtk.Widget {
    private Cairo.ImageSurface image;

    construct {
        this.set_has_window (false);
    }

    public CoverImage (Gdk.Pixbuf pixbuf) {
        this.image = (Cairo.ImageSurface) Gdk.cairo_surface_create_from_pixbuf (pixbuf, 1, null);
        this.visible = true;
    }

    public override void get_preferred_width (out int min, out int nat) {
        min = nat = image.get_width ();
    }

    public override void get_preferred_height (out int min, out int nat) {
        min = nat = image.get_height ();
    }

    public override bool draw (Cairo.Context cr) {
        Gtk.Allocation alloc;
        get_allocation (out alloc);

        int image_width = image.get_width ();
        int image_height = image.get_height ();

        double scale_x = (double) alloc.width / image_width;
        double scale_y = (double) alloc.height / image_height;

        if (scale_x * image_height >= alloc.height) {
            double offset = (alloc.height - image_height * scale_x) / 2;
            cr.translate (0, offset);
            cr.scale (scale_x, scale_x);
        } else if (scale_y * image_width >= alloc.width) {
            double offset = (alloc.width - image_width * scale_y) / 2;
            cr.translate (offset, 0);
            cr.scale (scale_y, scale_y);
        } else {
            assert_not_reached ();
        }

        cr.set_source_surface (image, 0, 0);
        cr.paint ();
        return Gdk.EVENT_STOP;
    }
}
