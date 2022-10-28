import 'dart:io';

import 'package:webf/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:cookie_jar/cookie_jar.dart';

class CookieJar {
  final String url;
  final cookies = <Cookie>[];
  static final DefaultCookieJar domCookieJar = DefaultCookieJar();
  static final Future<PersistCookieJar> persistCookieJar = _cj;

  CookieJar(this.url);

  void setCookie(String value) {
    Cookie cookie = Cookie.fromSetCookieValue(value);
    cookies.add(cookie);
    Uri uri = Uri.parse(url);
    if (uri.host.isNotEmpty) {
      domCookieJar.saveFromResponse(uri, [cookie]);
    }
  }

  void deleteCookies() {
    cookies.clear();
    Uri uri = Uri.parse(url);
    if (uri.host.isNotEmpty) {
      domCookieJar.delete(uri);
    }
  }

  String cookie() {
    final cookiePairs = <String>[];
    Uri uri = Uri.parse(url);
    String scheme = uri.scheme;
    cookies.forEach((value) {
      SerializableCookie seCookie = SerializableCookie(value);
      bool isHttpOnly = seCookie.cookie.httpOnly;
      bool isInvalid = seCookie.isExpired();
      bool isSecure = seCookie.cookie.secure;
      if (!isHttpOnly || !isInvalid) {
        if (isSecure) {
          if (scheme == 'https') {
            cookiePairs.add('${value.name}=${value.value}');
          }
        } else {
          cookiePairs.add('${value.name}=${value.value}');
        }
      }
    });
    return cookiePairs.join('; ');
  }

  static Future<PersistCookieJar> get _cj async {
    String appTemporaryPath = await getWebFTemporaryPath();
    return PersistCookieJar(storage: FileStorage(path.join(appTemporaryPath, 'cookies')));
  }

  static Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {
    PersistCookieJar cj = await persistCookieJar;
    cj.saveFromResponse(uri, cookies);
  }

  static Future<void> saveFromResponseRaw(Uri uri, List<String>? cookieStr) async {
    PersistCookieJar cj = await persistCookieJar;
    final list = <Cookie>[];
    cookieStr?.forEach((element) {
      list.add(Cookie.fromSetCookieValue(element));
    });
    cj.saveFromResponse(uri, list);
  }

  static Future<void> loadForRequest(Uri uri, List<Cookie> requestCookies) async {
    List<Cookie> pageCookies = await domCookieJar.loadForRequest(uri);
    if (pageCookies.isNotEmpty) {
      requestCookies.addAll(pageCookies);
    }
    PersistCookieJar pCJ = await persistCookieJar;
    List<Cookie> cookies = await pCJ.loadForRequest(uri);
    if (cookies.isNotEmpty) {
      requestCookies.addAll(cookies);
    }
  }
}
