// Copyright & License
// This open source project authorized by https://flutterchina.club , and the license is MIT.

import 'dart:convert';
import 'dart:io';
import 'default_cookie_jar.dart';
import 'serializable_cookie.dart';
import 'stroage.dart';
import 'file_storage.dart';

/// [PersistCookieJar] is a cookie manager which implements the standard
/// cookie policy declared in RFC. [PersistCookieJar]  persists the cookies in files,
/// so if the application exit, the cookies always exist unless call [delete] explicitly.
class PersistCookieJar extends DefaultCookieJar {
  ///
  /// [persistSession]: Whether persisting the cookies that without
  /// "expires" or "max-age" attribute;
  /// If false, the session cookies will be discarded;
  /// otherwise, the session cookies will be persisted.
  ///
  /// [ignoreExpires]: save/load even cookies that have expired.
  ///
  /// [storage]: Defaults to FileStorage

  PersistCookieJar(
      {this.persistSession = true,
      bool ignoreExpires = false,
      Storage? storage})
      : super(ignoreExpires: ignoreExpires) {
    this.storage = storage ?? FileStorage();
  }

  /// Whether persisting the cookies that without "expires" or "max-age" attribute;
  final bool persistSession;

  final IndexKey = '.index';
  final DomainsKey = '.domains';

  late Storage storage;

  late Set<String> _hostSet;
  bool _initialized = false;

  Future<void> forceInit() {
    return _checkInitialized(force: true);
  }

  Future<void> _checkInitialized({bool force = false}) async {
    if (force || !_initialized) {
      await storage.init(persistSession, ignoreExpires);
      // Load domain cookies
      var str = await storage.read(DomainsKey);
      if (str != null && str.isNotEmpty) {
        try {
          final Map<String, dynamic> jsonData = json.decode(str);

          final cookies = jsonData.map((String domain, _cookies) {
            final Map<String, dynamic> cookies =
                _cookies.cast<String, dynamic>();
            final domainCookies = cookies.map((String path, map) {
              final Map<String, String> cookieForPath =
                  map.cast<String, String>();
              final realCookies = cookieForPath.map(
                  (String cookieName, String cookie) =>
                      MapEntry<String, SerializableCookie>(
                          cookieName, SerializableCookie.fromJson(cookie)));
              return MapEntry<String, Map<String, SerializableCookie>>(
                  path, realCookies);
            });
            return MapEntry<String,
                    Map<String, Map<String, SerializableCookie>>>(
                domain, domainCookies);
          });
          domainCookies
            ..clear()
            ..addAll(cookies);
        } catch (e) {
          await storage.delete(DomainsKey);
        }
      }

      str = await storage.read(IndexKey);
      if ((str != null && str.isNotEmpty)) {
        try {
          final list = json.decode(str);
          _hostSet = Set<String>.from(list);
        } catch (e) {
          await storage.delete(IndexKey);
        }
      } else {
        _hostSet = <String>{};
      }
      _initialized = true;
    }
  }

  void _checkInitializedSync({bool force = false}) {
    if (force || !_initialized) {
      storage.initSync(persistSession, ignoreExpires);
      // Load domain cookies
      var str = storage.readSync(DomainsKey);
      if (str != null && str.isNotEmpty) {
        try {
          final Map<String, dynamic> jsonData = json.decode(str);

          final cookies = jsonData.map((String domain, _cookies) {
            final Map<String, dynamic> cookies =
            _cookies.cast<String, dynamic>();
            final domainCookies = cookies.map((String path, map) {
              final Map<String, String> cookieForPath =
              map.cast<String, String>();
              final realCookies = cookieForPath.map(
                      (String cookieName, String cookie) =>
                      MapEntry<String, SerializableCookie>(
                          cookieName, SerializableCookie.fromJson(cookie)));
              return MapEntry<String, Map<String, SerializableCookie>>(
                  path, realCookies);
            });
            return MapEntry<String,
                Map<String, Map<String, SerializableCookie>>>(
                domain, domainCookies);
          });
          domainCookies
            ..clear()
            ..addAll(cookies);
        } catch (e) {
          storage.deleteSync(DomainsKey);
        }
      }

      str = storage.readSync(IndexKey);
      if ((str != null && str.isNotEmpty)) {
        try {
          final list = json.decode(str);
          _hostSet = Set<String>.from(list);
        } catch (e) {
          storage.deleteSync(IndexKey);
        }
      } else {
        _hostSet = <String>{};
      }
      _initialized = true;
    }
  }

  @override
  Future<List<Cookie>> loadForRequest(Uri uri) async {
    await _checkInitialized();
    await _load(uri);
    return super.loadForRequest(uri);
  }

  List<Cookie> loadForCurrentURISync(Uri uri) {
    _checkInitializedSync();
    _loadSync(uri);
    return loadFromUri(uri);
  }

  @override
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {
    await _checkInitialized();
    if (cookies.isNotEmpty) {
      await super.saveFromResponse(uri, cookies);
      if (cookies.every((Cookie e) => e.domain == null)) {
        await _save(uri);
      } else {
        await _save(uri, true);
      }
    }
  }

  void saveFromAPISync(Uri uri, List<Cookie> cookies) {
    _checkInitializedSync();
    if (cookies.isNotEmpty) {
      saveCookiesToMemory(uri, cookies);
      if (cookies.every((Cookie e) => e.domain == null)) {
        _saveSync(uri);
      } else {
        _saveSync(uri, true);
      }
    }
  }

  Map<String, Map<String, SerializableCookie>> _filter(
    Map<String, Map<String, SerializableCookie>> domain,
  ) {
    return domain
        .cast<String, Map<String, dynamic>>()
        .map((String path, Map<String, dynamic> _cookies) {
      final cookies = _cookies.map((String cookieName, cookie) {
        if (((cookie.cookie.expires == null && cookie.cookie.maxAge == null) &&
                persistSession) ||
            (persistSession && !cookie.isExpired())) {
          return MapEntry<String, SerializableCookie>(cookieName, cookie);
        } else {
          // key = null, and remove after
          return MapEntry<String?, SerializableCookie>(null, cookie);
        }
      })
        ..removeWhere((String? k, SerializableCookie v) => k == null);

      return MapEntry<String, Map<String, SerializableCookie>>(
        path,
        cookies.cast<String, SerializableCookie>(),
      );
    });
  }

  /// Delete cookies for specified [uri].
  /// This API will delete all cookies for the `uri.host`, it will ignored the `uri.path`.
  ///
  /// [withDomainSharedCookie] `true` will delete the domain-shared cookies.
  @override
  Future<void> delete(Uri uri, [bool withDomainSharedCookie = false]) async {
    await _checkInitialized();
    await super.delete(uri, withDomainSharedCookie);
    final host = uri.host;
    if (_hostSet.remove(host)) {
      await storage.write(IndexKey, json.encode(_hostSet.toList()));
    }

    await storage.delete(host);

    if (withDomainSharedCookie) {
      await storage.write(DomainsKey, json.encode(domainCookies));
    }
  }

  /// Delete all cookies files under [dir] directory and clear them out from RAM
  @override
  Future<void> deleteAll() async {
    await _checkInitialized();
    await super.deleteAll();
    var keys = _hostSet.toList(growable: true)..addAll([IndexKey, DomainsKey]);
    await storage.deleteAll(keys);
    _hostSet.clear();
  }

  @override
  void deleteAllSync() {
    _checkInitializedSync();
    super.deleteAllSync();
    var keys = _hostSet.toList(growable: true)..addAll([IndexKey, DomainsKey]);
    storage.deleteAllSync(keys);
    _hostSet.clear();
  }

  Future<void> _save(Uri uri, [bool withDomainSharedCookie = false]) async {
    final host = uri.host;

    if (!_hostSet.contains(host)) {
      _hostSet.add(host);
      await storage.write(IndexKey, json.encode(_hostSet.toList()));
    }
    final cookies = hostCookies[host];

    if (cookies != null) {
      await storage.write(host, json.encode(_filter(cookies)));
    }

    if (withDomainSharedCookie) {
      var filterDomainCookies =
          domainCookies.map((key, value) => MapEntry(key, _filter(value)));
      await storage.write(DomainsKey, json.encode(filterDomainCookies));
    }
  }

  void _saveSync(Uri uri, [bool withDomainSharedCookie = false]) {
    final host = uri.host;

    if (!_hostSet.contains(host)) {
      _hostSet.add(host);
      storage.writeSync(IndexKey, json.encode(_hostSet.toList()));
    }
    final cookies = hostCookies[host];

    if (cookies != null) {
      storage.writeSync(host, json.encode(_filter(cookies)));
    }

    if (withDomainSharedCookie) {
      var filterDomainCookies =
      domainCookies.map((key, value) => MapEntry(key, _filter(value)));
      storage.writeSync(DomainsKey, json.encode(filterDomainCookies));
    }
  }

  Future<void> _load(Uri uri) async {
    final host = uri.host;
    if (_hostSet.contains(host) && hostCookies[host] == null) {
      var str = await storage.read(host);

      if (str != null && str.isNotEmpty) {
        Map<String, Map<String, dynamic>>? cookies;
        try {
          cookies = json.decode(str).cast<String, Map<String, dynamic>>();

          cookies!.forEach((String path, Map<String, dynamic> map) {
            map.forEach((String k, v) {
              map[k] = SerializableCookie.fromJson(v);
            });
          });

          hostCookies[host] =
              cookies.cast<String, Map<String, SerializableCookie>>();
        } catch (e) {
          await storage.delete(host);
        }
      }
    }
  }

  void _loadSync(Uri uri) {
    final host = uri.host;
    if (_hostSet.contains(host) && hostCookies[host] == null) {
      var str = storage.readSync(host);

      if (str != null && str.isNotEmpty) {
        Map<String, Map<String, dynamic>>? cookies;
        try {
          cookies = json.decode(str).cast<String, Map<String, dynamic>>();

          cookies!.forEach((String path, Map<String, dynamic> map) {
            map.forEach((String k, v) {
              map[k] = SerializableCookie.fromJson(v);
            });
          });

          hostCookies[host] =
              cookies.cast<String, Map<String, SerializableCookie>>();
        } catch (e) {
          storage.deleteSync(host);
        }
      }
    }
  }
}
