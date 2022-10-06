import 'dart:io';

import 'package:webf/foundation.dart';
import 'package:path/path.dart' as path;

import 'cookie/file_storage.dart';
import 'cookie/persist_cookie_jar.dart';
import 'cookie/serializable_cookie.dart';

class CookieJar {

  CookieJar() {
  }

  final Map<String, SerializableCookie> _pairs = {};

  void setCookie(String value) {
    Cookie cookie = Cookie.fromSetCookieValue(value);
    SerializableCookie serializableCookie = SerializableCookie(cookie);
    _pairs[serializableCookie.cookie.name] = serializableCookie;
  }

  String cookie() {
    List<String> cookiePairs = List.generate(_pairs.length, (index) {
      String key = _pairs.keys.elementAt(index);
      SerializableCookie value = _pairs.values.elementAt(index);
      bool isHttpOnly = value.cookie.httpOnly;
      bool isInvalid = value.isExpired();
      if (!isHttpOnly || !isInvalid) {
        return '$key=${value.cookie.value}';
      } else {
        return '';
      }
    });
    return cookiePairs.join('; ');
  }

  static final Future<PersistCookieJar> _cookieJar = _cj;
  static Future<PersistCookieJar> get _cj async {
    String appTemporaryPath = await getWebFTemporaryPath();
    return PersistCookieJar(storage: FileStorage(path.join(appTemporaryPath, 'cookies')));
  }

  static Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {
    PersistCookieJar cj = await CookieJar._cookieJar;
    cj.saveFromResponse(uri, cookies);
  }

  static Future<List<Cookie>> loadForRequest(Uri uri) async {
    PersistCookieJar cj = await CookieJar._cookieJar;
    return cj.loadForRequest(uri);
  }
}
