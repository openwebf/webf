import 'dart:async';
import 'dart:io';

import 'package:webf/foundation.dart';
import 'package:path/path.dart' as path;

import 'cookie_jar/persist_cookie_jar.dart';
import 'cookie_jar/file_storage.dart';
import 'cookie_jar/serializable_cookie.dart';

class CookieManager {
  static PersistCookieJar? _cookieJar;
  static Future<PersistCookieJar>? _cookieJarFuture;

  CookieManager();

  static Future<PersistCookieJar> afterCookieJarLoaded(PersistCookieJar cookieJar, {Uri? uri, List<Cookie>? initialCookies}) async {
    if (initialCookies != null && uri != null) {
      cookieJar.saveFromAPI(uri, initialCookies);
    }
    _cookieJar = cookieJar;
    return cookieJar;
  }

  static Future<PersistCookieJar> initCookieFromStorage() async {
    assert(_cookieJar == null);
    String appTemporaryPath = await getWebFTemporaryPath();
    return PersistCookieJar(storage: FileStorage(path.join(appTemporaryPath, 'cookies')));
  }

  /// Set cookie for a specific URL
  void setCookie(String url, Cookie cookie) {
    if (url.isEmpty) {
      return;
    }
    Uri uri = Uri.parse(url);
    List<String> pathSegments = uri.pathSegments;

    if (pathSegments.isNotEmpty) {
      cookie.path ??= '/' + pathSegments.sublist(0, pathSegments.length - 1).join('/');
    }

    cookie.domain ??= uri.host;

    if (uri.host.isNotEmpty && _cookieJar != null) {
      _cookieJar!.saveFromAPI(uri, [cookie]);
    }
  }

  /// Set cookie for a specific URL from a set-cookie string
  void setCookieString(String url, String value) {
    if (value.isEmpty) {
      return;
    }
    Cookie cookie = Cookie.fromSetCookieValue(value);
    setCookie(url, cookie);
  }

  /// Set multiple cookies for a URL
  void setCookies(String url, List<Cookie> cookies) {
    if (_cookieJar != null) {
      Uri uri = Uri.parse(url);
      _cookieJar!.saveFromAPI(uri, cookies);
    }
  }

  /// Get all cookies as string for a URL
  String getCookieString(String url) {
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

  /// Get all cookies for a URL
  List<Cookie> getCookies(String url) {
    Uri uri = Uri.parse(url);
    return _cookieJar!.loadForCurrentURISync(uri);
  }

  /// Clear all cookies for a specific URL
  void clearCookie(String url) {
    Uri uri = Uri.parse(url);
    if (uri.host.isNotEmpty && _cookieJar != null) {
      _cookieJar!.delete(uri, true);
    }
  }

  /// Clear all cookies in storage
  void clearAllCookies() {
    if (_cookieJar != null) {
      _cookieJar!.deleteAllSync();
    }
  }

  /// Initialize cookie jar with initial cookies if needed
  Future<void> initialize({String? url, List<Cookie>? initialCookies}) async {
    if (_cookieJar == null) {
      _cookieJarFuture = initCookieFromStorage().then((cookieJar) {
        return afterCookieJarLoaded(cookieJar,
          uri: url != null ? Uri.parse(url) : null,
          initialCookies: initialCookies);
      });
      await _cookieJarFuture;
    } else if (url != null && initialCookies != null) {
      afterCookieJarLoaded(_cookieJar!, uri: Uri.parse(url), initialCookies: initialCookies);
    }
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
