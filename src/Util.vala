string ellipsize (string s, uint lim) {
    return s.length > lim ? s[0:lim] + "..." : s;
}
