// Copyright & License
// This open source project authorized by https://flutterchina.club , and the license is MIT.

import 'dart:io';

/// This class is a wrapper for `Cookie` class.
/// Because the `Cookie` class doesn't  support Json serialization,
/// for the sake of persistence, we use this class instead of it.
class SerializableCookie {
  SerializableCookie(this.cookie) {
    createTimeStamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
  }

  /// Create a instance form Json string.

  SerializableCookie.fromJson(String value) {
    final t = value.split(';_crt=');
    cookie = Cookie.fromSetCookieValue(t[0]);
    createTimeStamp = int.parse(t[1]);
  }

  /// Test the  whether this cookie is expired.

  bool isExpired() {
    final t = DateTime.now();
    return (cookie.maxAge != null && cookie.maxAge! < 1) ||
        (cookie.maxAge != null &&
            (t.millisecondsSinceEpoch ~/ 1000).toInt() - createTimeStamp >=
                cookie.maxAge!) ||
        (cookie.expires != null && !cookie.expires!.isAfter(t));
  }

  /// Serialize the Json string.

  String toJson() => toString();
  late Cookie cookie;

  int createTimeStamp = 0;

  @override
  String toString() {
    return cookie.toString() + ';_crt=$createTimeStamp';
  }
}
