import 'dart:async';
import 'dart:io';

import 'package:webf/foundation.dart';
import 'package:path/path.dart' as path;

import 'cookie_jar/persist_cookie_jar.dart';
import 'cookie_jar/file_storage.dart';
import 'cookie_jar/serializable_cookie.dart';

class CookieJar {
  final String url;
  static PersistCookieJar? _cookieJar;
  static Future<PersistCookieJar>? _cookieJarFuture;

  final List<Cookie>? initialCookies;
  CookieJar(this.url, { this.initialCookies }) {
    if (_cookieJar == null) {
      _cookieJarFuture = initCookieFromStorage().then((cookieJar) {
        return afterCookieJarLoaded(cookieJar, uri: Uri.parse(url), initialCookies: initialCookies);
      });
    } else {
      afterCookieJarLoaded(_cookieJar!, uri: Uri.parse(url), initialCookies: initialCookies);
    }
  }

  static Future<PersistCookieJar> afterCookieJarLoaded(PersistCookieJar cookieJar, { Uri? uri, List<Cookie>? initialCookies }) async {
    if (initialCookies != null && uri != null) {
      cookieJar.saveFromAPISync(uri, initialCookies);
    }
    _cookieJar = cookieJar;
    return cookieJar;
  }

  static Future<PersistCookieJar> initCookieFromStorage() async {
    assert(_cookieJar == null);
    String appTemporaryPath = await getWebFTemporaryPath();
    return PersistCookieJar(storage: FileStorage(path.join(appTemporaryPath, 'cookies')));
  }

  void setCookieString(String value) {
    if (value.isEmpty) {
      return;
    }
    Cookie cookie = Cookie.fromSetCookieValue(value);
    Uri uri = Uri.parse(url);
    List<String> pathSegements = uri.pathSegments;

    if (pathSegements.isNotEmpty) {
      cookie.path ??= '/' + pathSegements.sublist(0, pathSegements.length - 1).join('/');
    }

    cookie.domain ??= uri.host;

    if (uri.host.isNotEmpty && _cookieJar != null) {
      _cookieJar!.saveFromAPISync(uri, [cookie]);
    }
  }

  void setCookie(List<Cookie> cookies, [Uri? uri]) {
    if (_cookieJar != null) {
      uri = uri ?? Uri.parse(url);
      _cookieJar!.saveFromAPISync(uri, cookies);
    }
  }

  void clearCookie() {
    Uri uri = Uri.parse(url);
    if (uri.host.isNotEmpty && _cookieJar != null) {
      _cookieJar!.delete(uri, true);
    }
  }

  void clearAllCookies() {
    if (_cookieJar != null) {
      _cookieJar!.deleteAllSync();
    }
  }

  String cookie() {
    final cookiePairs = <String>[];
    Uri uri = Uri.parse(url);
    String scheme = uri.scheme;
    List<Cookie> cookies = _cookieJar!.loadForCurrentURISync(uri);
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

  static Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {
    await _cookieJar!.saveFromResponse(uri, cookies);
  }

  static Future<void> saveFromResponseRaw(Uri uri, List<String>? cookieStr) async {
    final list = <Cookie>[];
    cookieStr?.forEach((str) {
      Cookie cookie = Cookie.fromSetCookieValue(str);
      cookie.domain ??= uri.host;
      list.add(cookie);
    });
    await _cookieJar!.saveFromResponse(uri, list);
  }

  static Future<void> loadForRequest(Uri uri, List<Cookie> requestCookies) async {
    if (_cookieJar == null) {
      Completer completer = Completer();
      _cookieJarFuture ??= initCookieFromStorage().then(afterCookieJarLoaded);
      _cookieJarFuture!.whenComplete(() async {
        await loadForRequest(uri, requestCookies);
        completer.complete();
      });
      return await (completer.future);
    }

    List<Cookie> cookies = await _cookieJar!.loadForRequest(uri);
    if (cookies.isNotEmpty) {
      requestCookies.addAll(cookies);
    }
  }
}
