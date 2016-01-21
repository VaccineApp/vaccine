// pango markup
public class Vaccine.PostTransformer : Object {
    private const MarkupParser parser = {
        visit_start,
        visit_end,
        visit_text,
        visit_passthrough,
        error
    };

    private uint a_tag_level = 0; // handles nested <a> tags...thanks mods

    private MarkupParseContext ctx;

    private string dest = "";

    public PostTransformer () {
        ctx = new MarkupParseContext(parser, 0, this, null);
    }

    void visit_text (MarkupParseContext context, string text, size_t text_len) throws MarkupError {
        if (a_tag_level == 0) { // we are not inside an <a> tag, so wrap links
            string link;
            try {
                link = /(\w+:\/\/\S*)/.replace(text, -1, 0, "<a href=\"\\1\">\\1</a>");
            } catch (RegexError e) {
                debug (e.message);
                link = text;
            }
            dest += link;
        } else {
            dest += text;
        }
    }

    void visit_start (MarkupParseContext context, string elem, string[] attrs, string[] vals) throws MarkupError {
        if (elem == "a") a_tag_level++;

        // <tt> is Pango's monospace element
        // should we check for class="prettyprint"?
        else if (elem == "pre") elem = "tt";

        // our dummy top-level XML element
        else if (elem == "_top_level") return;

        // 4chan oddly puts <font class="unkfunc"></font> around some quotelinks
        // I think this was used for greentext in the past and the ancient stickies have never been change
        else if (elem == "font") return;

        dest += "<" + elem;
        for (int i = 0; i < attrs.length; ++i) {
            if (attrs[i] == "target") {
                ;
            } else if (attrs[i] == "class") {
                if (vals[i] == "quote")
                    dest += " foreground=\"#789922\"";
            } else {
                dest += " %s=\"%s\"".printf (attrs[i], vals[i]);
            }
        }
        dest += ">";
    }

    void visit_end (MarkupParseContext context, string elem) throws MarkupError {
        if (elem == "a") a_tag_level--;
        else if (elem == "pre") elem = "tt";
        else if (elem == "_top_level") return;
        else if (elem == "font") return;

        dest += "</" + elem + ">";
    }

    void visit_passthrough (MarkupParseContext context, string passthrough_text, size_t text_len) throws MarkupError {
        debug (@"visit_passthrough: $passthrough_text\n");
    }

    void error (MarkupParseContext context, Error error)  {
        debug (@"error: $(error.message)\n");
    }

    public static string transform_post (string com) throws MarkupError {
        var xfm = new PostTransformer ();
        var post = common_clean (com).replace ("&", "&amp;");
        xfm.ctx.parse ("<_top_level>" + post + "</_top_level>", -1); // requires a top-level element
        // TODO: remove when it all works
        // print (@"\n\x1b[35m==========================================\x1b[0m\n$com\n\t\t\t\t\x1b[44mv\x1b[0m\n$(xfm.dest)\n\n");
        return xfm.dest;
    }

    public static string common_clean (string com) {
        return com
            .compress ()
            .replace ("\n", "\\n") // in code tags
            .replace ("\t", "\\t")
            .replace ("<br></br>", "\n")
            .replace ("<br>",      "\n") // unclosed tag
            .replace ("<br />",    "\n")
            .replace ("<wbr>",     "");
    }
}
