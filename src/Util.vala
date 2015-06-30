string ellipsize (string s, uint lim) {
    return s.length > lim ? s[0:lim] + "..." : s;
}

namespace Vaccine {
    namespace Util {
        public class RegexStream : Object {
            public string text { get; private set; }

            public RegexStream (string text) {
                this.text = text;
            }

            public RegexStream replace (Regex exp, string replacement, RegexMatchFlags flags = 0) {
                try {
                    text = exp.replace (text, -1, 0, replacement, flags);
                } catch (Error e) {
                    debug (e.message);
                }
                return this;
            }
        }
    }
}
