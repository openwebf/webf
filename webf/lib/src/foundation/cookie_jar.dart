// Legacy implements.
// TODO: should read cookie values from http requests.
class CookieJar {
  final Map<String, String> _pairs = {};
  void setCookie(String value) {
    value = value.trim();

    RegExp pattern = RegExp(r'^[^=]*=([^;]*)');

    if (!value.contains('=')) {
      _pairs[''] = value;
    } else {
      int idx = value.indexOf('=');
      String key = value.substring(0, idx);
      // Only allow to set a single cookie at a time
      // Find first cookie value if multiple cookie set
      RegExpMatch? match = pattern.firstMatch(value);

      if (match != null && match[1] != null) {
        value = match[1]!;

        if (key.isEmpty && value.isEmpty) {
          return;
        }
      }
      _pairs[key] = value;
    }
  }

  String cookie() {
    List<String> cookiePairs = List.generate(_pairs.length, (index) {
      String key = _pairs.keys.elementAt(index);
      String value = _pairs.values.elementAt(index);
      return '$key=$value';
    });
    return cookiePairs.join('; ');
  }
}
