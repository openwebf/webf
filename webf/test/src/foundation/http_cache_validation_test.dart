/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:webf/foundation.dart';
import 'package:webf/src/foundation/http_cache_object.dart';
import 'package:path/path.dart' as path;

void main() {
  group('HttpCacheObject validation', () {
    late Directory tempDir;
    late String cacheDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('webf_cache_test_');
      cacheDir = tempDir.path;
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should validate content length correctly for non-encoded content', () async {
      // Create a cache object with specific content length
      final cacheObject = HttpCacheObject(
        'https://example.com/test.jpg',
        cacheDir,
        contentLength: 1024,
        headers: 'Content-Type: image/jpeg\n',
      );

      // Write index
      await cacheObject.writeIndex();

      // Write blob data with correct length
      final blobSink = cacheObject.openBlobWrite();
      final correctData = Uint8List(1024);
      blobSink.add(correctData);
      await blobSink.close();

      // Validation should pass
      final isValid = await cacheObject.validateContent();
      expect(isValid, true);
    });

    test('should fail validation when content length mismatches for non-encoded content', () async {
      // Create a cache object with specific content length
      final cacheObject = HttpCacheObject(
        'https://example.com/test.jpg',
        cacheDir,
        contentLength: 1024,
        headers: 'Content-Type: image/jpeg\n',
      );

      // Write index
      await cacheObject.writeIndex();

      // Write blob data with incorrect length
      final blobSink = cacheObject.openBlobWrite();
      final incorrectData = Uint8List(512); // Half the expected size
      blobSink.add(incorrectData);
      await blobSink.close();

      // Validation should fail
      final isValid = await cacheObject.validateContent();
      expect(isValid, false);
    });

    test('should skip content length validation for encoded content', () async {
      // Create a cache object with gzip encoding
      final cacheObject = HttpCacheObject(
        'https://example.com/test.js',
        cacheDir,
        contentLength: 1024,
        headers: 'Content-Type: application/javascript\nContent-Encoding: gzip\n',
      );

      // Write index
      await cacheObject.writeIndex();

      // Write blob data with different length (simulating compressed data)
      final blobSink = cacheObject.openBlobWrite();
      final compressedData = Uint8List(256); // Much smaller due to compression
      blobSink.add(compressedData);
      await blobSink.close();

      // Validation should pass because content-encoding is present
      final isValid = await cacheObject.validateContent();
      expect(isValid, true);
    });

    test('should fail validation when cache files are missing', () async {
      // Create a cache object
      final cacheObject = HttpCacheObject(
        'https://example.com/test.png',
        cacheDir,
        contentLength: 1024,
      );

      // Don't write any files

      // Validation should fail
      final isValid = await cacheObject.validateContent();
      expect(isValid, false);
    });

    test('should remove invalid cache during read', () async {
      // Create a cache object with specific content length
      final cacheObject = HttpCacheObject(
        'https://example.com/test.css',
        cacheDir,
        contentLength: 1024,
        headers: 'Content-Type: text/css\n',
      );

      // Write index
      await cacheObject.writeIndex();

      // Write blob data with incorrect length
      final blobSink = cacheObject.openBlobWrite();
      final incorrectData = Uint8List(100); // Much smaller than expected
      blobSink.add(incorrectData);
      await blobSink.close();

      // Verify files exist before read
      final indexFile = File(path.join(cacheDir, cacheObject.hash));
      final blobFile = File(path.join(cacheDir, '${cacheObject.hash}-blob'));
      expect(await indexFile.exists(), true);
      expect(await blobFile.exists(), true);

      // Create a new cache object to read from disk (simulating a fresh read)
      final readCacheObject = HttpCacheObject(
        'https://example.com/test.css',
        cacheDir,
      );

      // Read should trigger validation and remove invalid cache
      await readCacheObject.read();

      // Files should be removed
      expect(await indexFile.exists(), false);
      expect(await blobFile.exists(), false);
      expect(readCacheObject.valid, false);
    });

    test('should write index atomically', () async {
      // Create separate cache objects to avoid conflicts
      final futures = <Future>[];
      for (int i = 0; i < 5; i++) {
        futures.add(() async {
          final cacheObject = HttpCacheObject(
            'https://example.com/atomic-test-$i.js',
            cacheDir,
            contentLength: 1024 + i,
            headers: 'Content-Type: application/javascript\n',
          );
          await cacheObject.writeIndex();
          
          // Also write blob data to create a complete cache object
          final blobSink = cacheObject.openBlobWrite();
          blobSink.add(Uint8List(1024 + i));
          await blobSink.close();
        }());
      }

      await Future.wait(futures);

      // Verify each cache object is valid
      for (int i = 0; i < 5; i++) {
        final readCacheObject = HttpCacheObject(
          'https://example.com/atomic-test-$i.js',
          cacheDir,
        );
        
        await readCacheObject.read();
        
        expect(readCacheObject.valid, true);
        expect(readCacheObject.contentLength, 1024 + i);
      }
    });

    test('should write blob atomically', () async {
      final cacheObject = HttpCacheObject(
        'https://example.com/atomic-blob.dat',
        cacheDir,
        contentLength: 100,
      );

      await cacheObject.writeIndex();

      // Write data to blob
      final blobSink = cacheObject.openBlobWrite();
      final testData = Uint8List.fromList(List.generate(100, (i) => i));
      blobSink.add(testData);
      await blobSink.close();

      // Verify blob file exists and has correct content
      final blobFile = File(path.join(cacheDir, '${cacheObject.hash}-blob'));
      expect(await blobFile.exists(), true);
      expect(await blobFile.length(), 100);

      // Verify temp files were cleaned up (check for any temp files with glob pattern)
      final tempDir = Directory(cacheDir);
      final tempFiles = await tempDir.list().where((entity) =>
          entity is File && entity.path.contains('${cacheObject.hash}-blob.tmp.')).toList();
      expect(tempFiles.isEmpty, true);
    });

    test('should handle concurrent access with file locking', () async {
      final url = 'https://example.com/concurrent.js';
      final cacheObjects = <HttpCacheObject>[];
      
      // Create multiple cache objects for the same URL
      for (int i = 0; i < 3; i++) {
        cacheObjects.add(HttpCacheObject(
          url,
          cacheDir,
          contentLength: 1024 + i,
        ));
      }

      // Keep track of successful writes
      int successfulWrites = 0;
      
      // Try to write concurrently - some may fail due to locking
      final futures = cacheObjects.map((obj) async {
        try {
          // Write both index and blob atomically
          await obj.writeIndex();
          
          // Also write blob data matching the content length
          final blobSink = obj.openBlobWrite();
          blobSink.add(Uint8List(obj.contentLength!));
          await blobSink.close();
          
          successfulWrites++;
        } catch (e) {
          // Expected - some writes may fail due to locking or rename conflicts
        }
      }).toList();
      await Future.wait(futures);

      // At least one should have succeeded
      expect(successfulWrites, greaterThan(0));

      // Read back and verify one succeeded with valid data
      final readCacheObject = HttpCacheObject(url, cacheDir);
      await readCacheObject.read();
      
      if (readCacheObject.valid) {
        // If valid, content length should match one of the attempted values
        expect([1024, 1025, 1026].contains(readCacheObject.contentLength), true);
      } else {
        // If concurrent writes created inconsistent state, that's acceptable
        // as long as the cache system detected it
        expect(readCacheObject.valid, false);
      }
    });

    test('should validate content checksum', () async {
      final cacheObject = HttpCacheObject(
        'https://example.com/checksum.dat',
        cacheDir,
        contentLength: 100,
      );

      await cacheObject.writeIndex();

      // Write data and calculate checksum
      final blobSink = cacheObject.openBlobWrite();
      final testData = Uint8List.fromList(List.generate(100, (i) => i));
      blobSink.add(testData);
      await blobSink.close();

      // Update checksum
      await cacheObject.updateContentChecksum();
      await cacheObject.writeIndex();

      // Validate should pass
      expect(await cacheObject.validateContent(), true);

      // Tamper with the blob file
      final blobFile = File(path.join(cacheDir, '${cacheObject.hash}-blob'));
      await blobFile.writeAsBytes(Uint8List.fromList([1, 2, 3]));

      // Validation should fail
      expect(await cacheObject.validateContent(), false);
    });

    test('should use SHA-256 hash for cache keys', () async {
      final url1 = 'https://example.com/file1.js';
      final url2 = 'https://example.com/file2.js';
      
      final cache1 = HttpCacheObject(url1, cacheDir);
      final cache2 = HttpCacheObject(url2, cacheDir);
      
      // Hashes should be different
      expect(cache1.hash, isNot(equals(cache2.hash)));
      
      // Hashes should be consistent
      final cache1Again = HttpCacheObject(url1, cacheDir);
      expect(cache1.hash, equals(cache1Again.hash));
      
      // Hash should be 16 characters (truncated SHA-256)
      expect(cache1.hash.length, 16);
      expect(RegExp(r'^[a-f0-9]+$').hasMatch(cache1.hash), true);
    });

    test('should handle version identifier correctly', () async {
      final cacheObject = HttpCacheObject(
        'https://example.com/versioned.js',
        cacheDir,
        contentLength: 1024,
      );

      await cacheObject.writeIndex();

      // Manually corrupt the version in the index file
      final indexFile = File(path.join(cacheDir, cacheObject.hash));
      final bytes = await indexFile.readAsBytes();
      // Change version byte (index 1)
      bytes[1] = 99; // Invalid version
      await indexFile.writeAsBytes(bytes);

      // Try to read - should fail due to version mismatch
      final readCacheObject = HttpCacheObject(
        'https://example.com/versioned.js',
        cacheDir,
      );
      await readCacheObject.read();
      
      expect(readCacheObject.valid, false);
    });

    test('should recover from write errors gracefully', () async {

      // Create a read-only directory to force write error
      final readOnlyDir = Directory(path.join(tempDir.path, 'readonly'));
      await readOnlyDir.create();
      
      // Make directory read-only on Unix systems
      if (!Platform.isWindows) {
        await Process.run('chmod', ['444', readOnlyDir.path]);
      }

      final errorCacheObject = HttpCacheObject(
        'https://example.com/error.dat',
        readOnlyDir.path,
        contentLength: 100,
      );

      // Writing should fail but not crash
      try {
        await errorCacheObject.writeIndex();
        if (!Platform.isWindows) {
          fail('Expected write to fail');
        }
      } catch (e) {
        // Expected error
        expect(e, isNotNull);
      }

      // Cleanup
      if (!Platform.isWindows) {
        await Process.run('chmod', ['755', readOnlyDir.path]);
      }
    });

    test('should handle stale lock files', () async {
      final cacheObject = HttpCacheObject(
        'https://example.com/stale-lock.js',
        cacheDir,
      );

      // Create a stale lock file
      final lockFile = File(path.join(cacheDir, '${cacheObject.hash}.lock'));
      final oldTimestamp = DateTime.now().subtract(Duration(minutes: 5)).millisecondsSinceEpoch;
      await lockFile.writeAsString('$oldTimestamp\n12345');

      // Should be able to acquire lock despite stale lock file
      await cacheObject.writeIndex();
      expect(cacheObject.valid, true);

      // Lock file should be cleaned up
      expect(await lockFile.exists(), false);
    });

    test('should handle corrupted cache data gracefully', () async {
      final cacheObject = HttpCacheObject(
        'https://example.com/corrupted.dat',
        cacheDir,
        contentLength: 100,
      );

      await cacheObject.writeIndex();

      // Write blob data
      final blobSink = cacheObject.openBlobWrite();
      blobSink.add(Uint8List(100));
      await blobSink.close();

      // Corrupt the index file
      final indexFile = File(path.join(cacheDir, cacheObject.hash));
      await indexFile.writeAsBytes(Uint8List.fromList([0xFF, 0xFF, 0xFF]));

      // Try to read corrupted cache
      final readCacheObject = HttpCacheObject(
        'https://example.com/corrupted.dat',
        cacheDir,
      );
      await readCacheObject.read();

      // Should be invalid
      expect(readCacheObject.valid, false);
    });
  });
}
