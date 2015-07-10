// strips XML tags, not clothes

namespace Vaccine {
    class Stripper : Object {
        private const string TOP_LEVEL_TAG = "_top_level"; // no one will ever use this

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
            var post = PostTransformer.common_clean (com).replace ("\n", " ");
            try {
                xfm.ctx.parse (@"<$TOP_LEVEL_TAG>$post</$TOP_LEVEL_TAG>", -1); // requires a top-level element
            } catch (MarkupError e) {
                debug (e.message);
                return null;
            }
            // print (@"\n\x1b[35m==========================================\x1b[0m\n$com\n\t\t\t\t\x1b[44mv\x1b[0m\n$(xfm.dest)\n\n");
            return xfm.dest;
        }
    }
}
