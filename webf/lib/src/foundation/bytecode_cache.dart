/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:quiver/collection.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';

enum ByteCodeCacheMode {
  /// Default cache usage mode: If the JavaScript source has a corresponding bytecode file,
  /// we will use the cached bytecode instead of the JavaScript code string to reduce the parsing time.
  DEFAULT,

  /// Don't use the cache, use the javascript string.
  NO_CACHE,
}

class QuickJSByteCodeCacheObject {
  static ByteCodeCacheMode cacheMode = ByteCodeCacheMode.DEFAULT;

  String hash;

  // The directory to store cache file.
  final String cacheDirectory;

  // The index file.
  final File _file;

  bool get valid => bytes != null;

  Uint8List? bytes;

  QuickJSByteCodeCacheObject(this.hash, this.cacheDirectory, { this.bytes }):
        _file = File(path.join(cacheDirectory, hash));

  /// Read the index file.
  Future<void> read() async {
    // Make sure file exists, or causing io exception.
    if (!await _file.exists()) {
      return;
    }

    // If read before, ignoring to read again.
    if (valid) return;

    try {
      bytes = await _file.readAsBytes();
    } catch (message, stackTrace) {
      print('Error while reading cache object for $hash');
      print('\n$message');
      print('\n$stackTrace');

      // Remove index file while invalid.
      await remove();
    }
  }

  Future<void> write() async {
    if (bytes != null) {
      await _file.writeAsBytes(bytes!);
    }
  }

  // Remove all the cached files.
  Future<void> remove() async {
    if (await _file.exists()) {
      await _file.delete();
    }
  }
}

/// This is a bytecode cache class that caches bytecodes generated during JavaScript parsing.
/// Use bytecode instead of JavaScript code string can result in a 58.1% reduction in loading time,
/// particularly for larger JavaScript files (>= 1MB).
class QuickJSByteCodeCache {
  // Memory cache.
  //   [String cacheKey] -> [QuickJSByteCodeCache object]
  // A splay tree is a good choice for data that is stored and accessed frequently.
  static final LinkedLruHashMap<String, QuickJSByteCodeCacheObject> _caches = LinkedLruHashMap(maximumSize: 25);

  static Directory? _cacheDirectory;
  static Future<Directory> getCacheDirectory() async {
    if (_cacheDirectory != null) {
      return _cacheDirectory!;
    }

    final String appTemporaryPath = await getWebFTemporaryPath();
    final Directory cacheDirectory = Directory(path.join(appTemporaryPath, 'ByteCodeCaches'));
    bool isThere = await cacheDirectory.exists();
    if (!isThere) {
      await cacheDirectory.create(recursive: true);
    }
    return _cacheDirectory = cacheDirectory;
  }

  static String _getCacheHash(String code) {
    WebFInfo webFInfo = getWebFInfo();
    // Uri uriWithoutFragment = uri;
    // return uriWithoutFragment.toString();
    return '%${code.hashCode}_${webFInfo.appRevision}%';
  }

  // Get the CacheObject by uri, no validation needed here.
  static Future<QuickJSByteCodeCacheObject> getCacheObject(String code) async {
    QuickJSByteCodeCacheObject cacheObject;

    // L2 cache in memory.
    final String hash = _getCacheHash(code);
    if (_caches.containsKey(hash)) {
      cacheObject = _caches[hash]!;
    } else {
      // Get cache in disk.
      final Directory cacheDirectory = await getCacheDirectory();
      cacheObject = QuickJSByteCodeCacheObject(hash, cacheDirectory.path);
    }

    await cacheObject.read();

    return cacheObject;
  }

  // Add or update the httpCacheObject to memory cache.
  static void putObject(String code, Uint8List bytes) async {
    final String key = _getCacheHash(code);

    final Directory cacheDirectory = await getCacheDirectory();
    QuickJSByteCodeCacheObject cacheObject = QuickJSByteCodeCacheObject(key, cacheDirectory.path, bytes: bytes);

    _caches.update(key, (value) => cacheObject, ifAbsent: () => cacheObject);
    await cacheObject.write();
  }

  static void removeObject(String code) {
    final String key = _getCacheHash(code);
    _caches.remove(key);
  }

  static bool isCodeNeedCache(String source) {
    return QuickJSByteCodeCacheObject.cacheMode == ByteCodeCacheMode.DEFAULT && source.length > 1024 * 10; // >= 50 KB
  }
}
