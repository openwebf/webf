/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';

enum ByteCodeCacheMode {
  /// Default cache usage mode: If the JavaScript source has a corresponding bytecode file,
  /// we will use the cached bytecode instead of the JavaScript code string to reduce the parsing time.
  DEFAULT,

  /// Don't use the cache, use the javascript string.
  NO_CACHE,
}

Future<void> deleteFile(File file) async {
  if (await file.exists()) {
    await file.delete();
  }
}

class QuickJSByteCodeCacheObject {
  static ByteCodeCacheMode cacheMode = ByteCodeCacheMode.DEFAULT;

  String hash;

  // The directory to store cache file.
  final String cacheDirectory;

  // The index file.
  final String _diskPath;
  final File _checksum;

  bool get valid => bytes != null;

  Uint8List? bytes;

  QuickJSByteCodeCacheObject(this.hash, this.cacheDirectory, {this.bytes})
      : _diskPath = path.join(cacheDirectory, hash),
        _checksum = File(path.join(cacheDirectory, '$hash.checksum'));

  /// Read the index file.
  Future<void> read() async {
    File cacheFile = File(_diskPath);
    // Make sure file exists, or causing io exception.
    if (!await cacheFile.exists()) {
      return;
    }

    // If read before, ignoring to read again.
    if (valid) return;

    try {
      bytes = await cacheFile.readAsBytes();
      int fileCheckSum = getCrc32(bytes!.toList());

      bool isCheckSumExist = await _checksum.exists();

      if (isCheckSumExist) {
        int savedChecksum = int.parse(await _checksum.readAsStringSync());
        if (fileCheckSum != savedChecksum) {
          throw FlutterError(
              'read bytecode cache failed, reason: checksum failed');
        }
      } else {
        // the cache files are created by older WebF versions, which doesn't contains the checksum files.
        // remove the cached file and rollback to init stage.
        await cacheFile.delete();
      }
    } catch (message, stackTrace) {
      print('Error while reading cache object for $hash');
      print('\n$message');
      print('\n$stackTrace');

      bytes = null;
      // Remove index file while invalid.
      await remove();
    }
  }

  Future<void> write() async {
    if (bytes != null) {
      int fileSum = getCrc32(bytes!.toList());
      File tmp = File(path.join(cacheDirectory, '$hash.tmp'));

      await Future.wait([
        _checksum.writeAsString(fileSum.toString()),
        tmp.writeAsBytes(bytes!)
      ]);
      await tmp.rename(_diskPath);
    }
  }

  // Remove all the cached files.
  Future<void> remove() async {
    File cacheFile = File(_diskPath);
    File tmp = File(path.join(cacheDirectory, '$hash.tmp'));
    await Future.wait(
        [deleteFile(cacheFile), deleteFile(tmp), deleteFile(_checksum)]);
  }
}

/// This is a bytecode cache class that caches bytecodes generated during JavaScript parsing.
/// Use bytecode instead of JavaScript code string can result in a 58.1% reduction in loading time,
/// particularly for larger JavaScript files (>= 1MB).
class QuickJSByteCodeCache {
  // Memory cache.
  //   [String cacheKey] -> [QuickJSByteCodeCache object]
  // A splay tree is a good choice for data that is stored and accessed frequently.
  static final LinkedLruHashMap<String, QuickJSByteCodeCacheObject> _caches =
      LinkedLruHashMap(maximumSize: 25);

  static Directory? _cacheDirectory;
  static Future<Directory> getCacheDirectory() async {
    if (_cacheDirectory != null) {
      return _cacheDirectory!;
    }

    final String appTemporaryPath = await getWebFTemporaryPath();
    final Directory cacheDirectory =
        Directory(path.join(appTemporaryPath, 'ByteCodeCaches'));
    bool isThere = await cacheDirectory.exists();
    if (!isThere) {
      await cacheDirectory.create(recursive: true);
    }
    return _cacheDirectory = cacheDirectory;
  }

  static String _getCacheHash(Uint8List code) {
    WebFInfo webFInfo = getWebFInfo();
    // Uri uriWithoutFragment = uri;
    // return uriWithoutFragment.toString();
    return '%${hashObjects(code)}_${webFInfo.appRevision}%';
  }

  // Get the CacheObject by uri, no validation needed here.
  static Future<QuickJSByteCodeCacheObject> getCacheObject(Uint8List codeBytes) async {
    QuickJSByteCodeCacheObject cacheObject;

    // L2 cache in memory.
    final String hash = _getCacheHash(codeBytes);
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
  static void putObject(Uint8List codeBytes, Uint8List bytes) async {
    final String key = _getCacheHash(codeBytes);

    final Directory cacheDirectory = await getCacheDirectory();
    QuickJSByteCodeCacheObject cacheObject =
        QuickJSByteCodeCacheObject(key, cacheDirectory.path, bytes: bytes);

    _caches.update(key, (value) => cacheObject, ifAbsent: () => cacheObject);
    await cacheObject.write();
  }

  static void removeObject(Uint8List code) {
    final String key = _getCacheHash(code);
    _caches.remove(key);
  }

  static bool isCodeNeedCache(Uint8List codeBytes) {
    return QuickJSByteCodeCacheObject.cacheMode == ByteCodeCacheMode.DEFAULT &&
        codeBytes.length > 1024 * 10; // >= 50 KB
  }
}
