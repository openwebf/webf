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
  static Future<PersistCookieJar> get _loadCookieJarFuture async {
    if (_cookieJar != null) return _cookieJar!;
    await loadCookieFromStorage();
    return _cookieJar!;
  }

  CookieJar(this.url);

  static Future<void> loadCookieFromStorage() async {
    assert(_cookieJar == null);
    String appTemporaryPath = await getWebFTemporaryPath();
    _cookieJar = PersistCookieJar(storage: FileStorage(path.join(appTemporaryPath, 'cookies')));
  }

  void setCookie(String value) {
    if (value.isEmpty) {
      return;
    }
    Cookie cookie = Cookie.fromSetCookieValue(value);
    Uri uri = Uri.parse(url);
    List<String> pathSegements = uri.pathSegments;

    cookie.path ??= '/' + pathSegements.sublist(0, pathSegements.length - 1).join('/');
    cookie.domain ??= uri.host;

    if (uri.host.isNotEmpty && _cookieJar != null) {
      _cookieJar!.saveFromAPISync(uri, [cookie]);
    }
  }

  void deleteCookies() {
    Uri uri = Uri.parse(url);
    if (uri.host.isNotEmpty && _cookieJar != null) {
      _cookieJar!.delete(uri);
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
    cookieStr?.forEach((element) {
      list.add(Cookie.fromSetCookieValue(element));
    });
    await _cookieJar!.saveFromResponse(uri, list);
  }

  static Future<void> loadForRequest(Uri uri, List<Cookie> requestCookies) async {
    if (_cookieJar == null) {
      Completer completer = Completer();
      _loadCookieJarFuture.whenComplete(() async {
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
