public class Vaccine.PostTextBuffer : Object {
    private const string TOP_LEVEL_TAG = "_top_level"; // no one will ever use this
    private const MarkupParser parser = {
        visit_start,
        visit_end,
        visit_text,
        visit_passthrough,
        error
    };

    private uint a_tag_level = 0; // handles nested <a> tags...thanks mods
    private MarkupParseContext ctx;
    private string src;
    private Gtk.TextBuffer buffer;
    private Gtk.TextIter iter;

    private string current_tag = null;
    private string current_text = "";

    void visit_start (MarkupParseContext context, string elem, string[] attrs, string[] vals) throws MarkupError {
        if (elem == "a") a_tag_level++;
        else if (elem == "pre") current_tag = "code";
        else if (elem == TOP_LEVEL_TAG) return; // our dummy top-level XML element
        // 4chan oddly puts <font class="unkfunc"></font> around some quotelinks
        // I think this was used for greentext in the past and the ancient stickies have never been change
        else if (elem == "font") return;

        else {
            for (int i = 0; i < attrs.length; ++i) {
                if (attrs[i] == "class" && vals[i] == "quote") {
                    current_tag = "greentext";
                } else if (attrs[i] == "class" && vals[i] == "quotelink") {
                    current_tag = "link";
                }
            }
        }
    }

    void visit_text (MarkupParseContext context, string text, size_t text_len) throws MarkupError {
        debug (@"visit_text, text=$text");
        //if (a_tag_level == 0) { // we are not inside an <a> tag, so wrap links
            //current_text = /(\w+:\/\/\S*)/.replace(text, -1, 0, "<a href=\"\\1\">\\1</a>");
        //} else {
            current_text = text;
        //}
    }

    void visit_end (MarkupParseContext context, string elem) throws MarkupError {
        if (elem == "a") a_tag_level--;

        if (current_tag != null) {
            buffer.insert_with_tags_by_name (ref iter, current_text, -1, current_tag);
        } else {
            buffer.insert (ref iter, current_text, -1);
        }
        current_tag = null;
        current_text = "";
    }

    void visit_passthrough (MarkupParseContext context, string passthrough_text, size_t text_len) throws MarkupError {
        debug (@"visit_passthrough: $passthrough_text\n");
    }

    void error (MarkupParseContext context, Error error)  {
        debug (@"error: $(error.message)\n");
    }

    public PostTextBuffer (string com) {
        this.src = com;
        ctx = new MarkupParseContext(parser, 0, this, null);
    }

    public void fill_text_buffer (Gtk.TextBuffer buffer) throws MarkupError {
        this.buffer = buffer;
        buffer.get_iter_at_offset (out this.iter, 0);
        var post = common_clean (src);
        this.ctx.parse (@"<$TOP_LEVEL_TAG>$post</$TOP_LEVEL_TAG>", -1); // requires a top-level element
        print (@"\n\x1b[35m==========================================\x1b[0m\n$post\n\t\t\t\t\x1b[44mv\x1b[0m\n$(buffer.text)\n\n");
    }

    string common_clean (string com) {
        return com
            .compress ()
            .replace ("\n", "\\n") // in code tags
            .replace ("\t", "\\t")
            .replace ("<br>", "\n") // unclosed tag
            .replace ("<wbr>", "") // suggested break location
            .replace ("&gt;", ">")
            .replace ("&quot;", "\"")
            .replace ("&", "&amp;");
    }
}
