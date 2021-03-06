// strips XML tags, not clothes

public class Vaccine.Stripper : Object {
    private const MarkupParser parser = { null, null, visit_text, null, null };

    private MarkupParseContext ctx;

    private string dest = "";

    public Stripper () {
        ctx = new MarkupParseContext(parser, 0, this, null);
    }

    void visit_text (MarkupParseContext context, string text, size_t text_len) throws MarkupError {
        dest += text;
    }

    public static string? transform_post (string com) {
        var xfm = new Stripper ();
        var post = PostTransformer.common_clean (com)
            .split ("\n")[0]
            .replace ("\r", "")
            .replace ("&gt;", ">")
            .replace ("&#039;", "'")
            .replace ("&", "&amp;");
        try {
            xfm.ctx.parse ("<_top_level>" + post + "</_top_level>", -1); // requires a top-level element
        } catch (MarkupError e) {
            debug (e.message);
            return null;
        }
        // print (@"\n\x1b[35m==========================================\x1b[0m\n$com\n\t\t\t\t\x1b[44mv\x1b[0m\n$(xfm.dest)\n\n");
        return xfm.dest;
    }
}
