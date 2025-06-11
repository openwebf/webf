/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/foundation/http_cache.dart';
import 'package:webf/src/foundation/http_cache_object.dart';

import '../../webf_test.dart';

void main() {
  Directory? tempDirectory;
  setUp(() {
    tempDirectory = setupTest();
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  group('HttpCache integration', () {
    late HttpCacheController cacheController;

    setUp(() async {
      cacheController = HttpCacheController.instance('https://example.com');
    });

    test('should handle cache key generation correctly', () {
      final uri1 = Uri.parse('https://example.com/file.js');
      final uri2 = Uri.parse('https://example.com/file.js#fragment');
      final uri3 = Uri.parse('https://example.com/other.js');

      // Fragments should be ignored
      expect(
        HttpCacheController.getCacheKey(uri1),
        HttpCacheController.getCacheKey(uri2),
      );

      // Different paths should have different keys
      expect(
        HttpCacheController.getCacheKey(uri1),
        isNot(HttpCacheController.getCacheKey(uri3)),
      );
    });

    test('should handle concurrent cache operations', () async {
      final futures = <Future>[];

      // Create multiple concurrent cache operations
      for (int i = 0; i < 5; i++) {
        final uri = Uri.parse('https://example.com/concurrent-$i.js');
        futures.add(() async {
          final cacheObject = HttpCacheObject(
            HttpCacheController.getCacheKey(uri),
            (await HttpCacheController.getCacheDirectory()).path,
            contentLength: 100 + i,
          );

          await cacheObject.writeIndex();

          final blobSink = cacheObject.openBlobWrite();
          blobSink.add(Uint8List(100 + i));
          await blobSink.close();

          cacheController.putObject(uri, cacheObject);
        }());
      }

      await Future.wait(futures);

      // Verify all objects were cached
      for (int i = 0; i < 5; i++) {
        final uri = Uri.parse('https://example.com/concurrent-$i.js');
        final cacheObject = await cacheController.getCacheObject(uri);
        expect(cacheObject.valid, true);
        expect(cacheObject.contentLength, 100 + i);
      }
    });

    test('should store and retrieve cache objects', () async {
      final uri = Uri.parse('https://example.com/test.js');
      final cacheKey = HttpCacheController.getCacheKey(uri);
      final cacheDir = (await HttpCacheController.getCacheDirectory()).path;

      // Create and store a cache object
      final cacheObject = HttpCacheObject(
        cacheKey,
        cacheDir,
        contentLength: 1024,
        headers: 'Content-Type: application/javascript\n',
        eTag: '"123abc"',
      );

      await cacheObject.writeIndex();

      final blobSink = cacheObject.openBlobWrite();
      blobSink.add(Uint8List(1024));
      await blobSink.close();

      cacheController.putObject(uri, cacheObject);

      // Retrieve from cache
      final retrievedObject = await cacheController.getCacheObject(uri);
      expect(retrievedObject.valid, true);
      expect(retrievedObject.contentLength, 1024);
      expect(retrievedObject.eTag, '"123abc"');
    });

    test('should handle cache removal', () async {
      final uri = Uri.parse('https://example.com/removable.js');
      final cacheKey = HttpCacheController.getCacheKey(uri);
      final cacheDir = (await HttpCacheController.getCacheDirectory()).path;

      // Create and store a cache object
      final cacheObject = HttpCacheObject(
        cacheKey,
        cacheDir,
        contentLength: 512,
      );

      await cacheObject.writeIndex();

      final blobSink = cacheObject.openBlobWrite();
      blobSink.add(Uint8List(512));
      await blobSink.close();

      cacheController.putObject(uri, cacheObject);

      // Remove from cache
      cacheController.removeObject(uri);

      // Try to get from memory cache (should create new object from disk)
      final retrievedObject = await cacheController.getCacheObject(uri);
      // It will still be valid because it reads from disk
      expect(retrievedObject.valid, true);

      // Remove the actual files
      await retrievedObject.remove();

      // Now it should be invalid
      final removedObject = await cacheController.getCacheObject(uri);
      expect(removedObject.valid, false);
    });
  });
}
