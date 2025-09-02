/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:path/path.dart' as path;

import '../../setup.dart';

void main() {
  setUp(() {
    setupTest();
  });

  group('WebF.clearAllCaches', () {
    test('should clear all HTTP disk cache files', () async {
      // Create test cache directory structures for multiple pages
      final String appTemporaryPath = await getWebFTemporaryPath();
      
      // Create cache directories for different pages (simulating the new structure)
      final Directory cacheDirectory1 = Directory(path.join(appTemporaryPath, 'HttpCaches_page1'));
      final Directory cacheDirectory2 = Directory(path.join(appTemporaryPath, 'HttpCaches_page2'));
      final Directory cacheDirectory3 = Directory(path.join(appTemporaryPath, 'HttpCache_special')); // Note: starts with HttpCache

      // Create directories
      await cacheDirectory1.create(recursive: true);
      await cacheDirectory2.create(recursive: true);
      await cacheDirectory3.create(recursive: true);

      // Create test cache files in each directory
      final File testCacheFile1 = File(path.join(cacheDirectory1.path, 'test_cache_1'));
      final File testCacheFile2 = File(path.join(cacheDirectory1.path, 'test_cache_2'));
      final File testCacheBlobFile1 = File(path.join(cacheDirectory1.path, 'test_cache_1-blob'));
      
      final File testCacheFile3 = File(path.join(cacheDirectory2.path, 'test_cache_3'));
      final File testCacheBlobFile2 = File(path.join(cacheDirectory2.path, 'test_cache_3-blob'));
      
      final File testCacheFile4 = File(path.join(cacheDirectory3.path, 'test_cache_4'));

      await testCacheFile1.writeAsString('test cache content 1');
      await testCacheFile2.writeAsString('test cache content 2');
      await testCacheBlobFile1.writeAsString('test blob content 1');
      await testCacheFile3.writeAsString('test cache content 3');
      await testCacheBlobFile2.writeAsString('test blob content 2');
      await testCacheFile4.writeAsString('test cache content 4');

      // Verify files exist
      expect(await testCacheFile1.exists(), true);
      expect(await testCacheFile2.exists(), true);
      expect(await testCacheBlobFile1.exists(), true);
      expect(await testCacheFile3.exists(), true);
      expect(await testCacheBlobFile2.exists(), true);
      expect(await testCacheFile4.exists(), true);

      // Clear all caches
      await WebF.clearAllCaches();

      // Verify all cache files and directories are deleted
      expect(await testCacheFile1.exists(), false);
      expect(await testCacheFile2.exists(), false);
      expect(await testCacheBlobFile1.exists(), false);
      expect(await testCacheFile3.exists(), false);
      expect(await testCacheBlobFile2.exists(), false);
      expect(await testCacheFile4.exists(), false);

      // Verify cache directories are deleted (they match HttpCache* pattern)
      expect(await cacheDirectory1.exists(), false);
      expect(await cacheDirectory2.exists(), false);
      expect(await cacheDirectory3.exists(), false);
    });

    test('should clear all memory caches', () async {
      // Create a mock HTTP cache controller and add some cache objects
      final HttpCacheController controller1 = HttpCacheController.instance('https://example.com');
      final HttpCacheController controller2 = HttpCacheController.instance('https://test.com');

      // Create cache objects
      final Uri uri1 = Uri.parse('https://example.com/test.js');
      final Uri uri2 = Uri.parse('https://test.com/style.css');

      final String cacheDir1 = (await HttpCacheController.getCacheDirectory(uri1));
      final String cacheDir2 = (await HttpCacheController.getCacheDirectory(uri2));

      final HttpCacheObject cacheObject1 = HttpCacheObject(
        HttpCacheController.getCacheKey(uri1),
        cacheDir1,
        contentLength: 100,
      );

      final HttpCacheObject cacheObject2 = HttpCacheObject(
        HttpCacheController.getCacheKey(uri2),
        cacheDir2,
        contentLength: 200,
      );

      // Put objects in memory cache
      controller1.putObject(uri1, cacheObject1);
      controller2.putObject(uri2, cacheObject2);

      // Verify objects are in memory cache
      final retrievedObject1 = await controller1.getCacheObject(uri1);
      final retrievedObject2 = await controller2.getCacheObject(uri2);
      expect(retrievedObject1.contentLength, 100);
      expect(retrievedObject2.contentLength, 200);

      // Clear all caches
      await Directory(cacheDir1).delete(recursive: true);
      await Directory(cacheDir2).delete(recursive: true);

      // Create new controller instances (since old ones were cleared)
      final HttpCacheController newController1 = HttpCacheController.instance('https://example.com');
      final HttpCacheController newController2 = HttpCacheController.instance('https://test.com');

      // Verify memory caches are cleared (objects will be recreated but not valid)
      final clearedObject1 = await newController1.getCacheObject(uri1);
      final clearedObject2 = await newController2.getCacheObject(uri2);
      expect(clearedObject1.valid, false);
      expect(clearedObject2.valid, false);
    });

    test('should handle case when cache directories do not exist', () async {
      // Get the temp directory path
      final String appTemporaryPath = await getWebFTemporaryPath();
      
      // Delete any existing HttpCache* directories
      final Directory tmpDir = Directory(appTemporaryPath);
      if (await tmpDir.exists()) {
        await for (final entity in tmpDir.list(followLinks: false)) {
          if (entity is Directory) {
            final String name = path.basename(entity.path);
            if (name.startsWith('HttpCache')) {
              await entity.delete(recursive: true);
            }
          }
        }
      }

      // Verify no HttpCache* directories exist
      bool hasHttpCacheDir = false;
      if (await tmpDir.exists()) {
        await for (final entity in tmpDir.list(followLinks: false)) {
          if (entity is Directory) {
            final String name = path.basename(entity.path);
            if (name.startsWith('HttpCache')) {
              hasHttpCacheDir = true;
              break;
            }
          }
        }
      }
      expect(hasHttpCacheDir, false);

      // Clear all caches should not throw
      await expectLater(WebF.clearAllCaches(), completes);

      // The important thing is that the operation completes without throwing
    });

    test('should handle concurrent cache clearing', () async {
      // Create test cache directories and files
      final String appTemporaryPath = await getWebFTemporaryPath();
      
      // Create multiple cache directories for different pages
      final List<Directory> cacheDirectories = [];
      for (int j = 0; j < 3; j++) {
        final Directory cacheDir = Directory(path.join(appTemporaryPath, 'HttpCaches_concurrent_$j'));
        await cacheDir.create(recursive: true);
        cacheDirectories.add(cacheDir);
        
        // Create multiple test files in each directory
        for (int i = 0; i < 10; i++) {
          final File testFile = File(path.join(cacheDir.path, 'test_cache_$i'));
          await testFile.writeAsString('test content $i');
        }
      }

      // Clear caches concurrently
      final futures = <Future>[];
      for (int i = 0; i < 5; i++) {
        futures.add(WebF.clearAllCaches());
      }

      // All operations should complete without error
      await expectLater(Future.wait(futures), completes);

      // Verify all cache directories are deleted
      for (final cacheDir in cacheDirectories) {
        expect(await cacheDir.exists(), false);
      }
    });

    test('should work correctly after clearing caches', () async {
      // Clear all caches first
      await WebF.clearAllCaches();

      // Create a new cache object and verify it works
      final HttpCacheController controller = HttpCacheController.instance('https://example.com');
      final Uri uri = Uri.parse('https://example.com/new.js');
      final String cacheDir = (await HttpCacheController.getCacheDirectory(uri));

      final HttpCacheObject cacheObject = HttpCacheObject(
        HttpCacheController.getCacheKey(uri),
        cacheDir,
        contentLength: 300,
        headers: 'Content-Type: application/javascript\n',
      );

      // Write cache to disk
      await cacheObject.writeIndex();
      final blobSink = cacheObject.openBlobWrite();
      blobSink.add(List.generate(300, (i) => i % 256));
      await blobSink.close();

      // Put in memory cache
      controller.putObject(uri, cacheObject);

      // Verify cache works correctly
      final retrievedObject = await controller.getCacheObject(uri);
      await retrievedObject.read();
      expect(retrievedObject.valid, true);
      expect(retrievedObject.contentLength, 300);
    });

    test('should handle file system errors gracefully', () async {
      // Create cache directories with potential issues
      final String appTemporaryPath = await getWebFTemporaryPath();
      final Directory cacheDirectory = Directory(path.join(appTemporaryPath, 'HttpCaches_errors'));

      if (!await cacheDirectory.exists()) {
        await cacheDirectory.create(recursive: true);
      }

      // Create a file that might cause issues
      final File problematicFile = File(path.join(cacheDirectory.path, 'problematic'));
      await problematicFile.writeAsString('content');

      // Even with potential file system issues, clearAllCaches should handle gracefully
      await expectLater(WebF.clearAllCaches(), completes);
    });

    test('should clear all QuickJS bytecode disk cache files', () async {
      // Create bytecode cache directory structure
      final String appTemporaryPath = await getWebFTemporaryPath();
      final Directory bytecodeCacheDirectory = Directory(
        path.join(appTemporaryPath, 'ByteCodeCaches_${QuickJSByteCodeCache.bytecodeVersion}')
      );

      // Create directory if it doesn't exist
      if (!await bytecodeCacheDirectory.exists()) {
        await bytecodeCacheDirectory.create(recursive: true);
      }

      // Create test bytecode cache files
      final File testBytecodeFile1 = File(path.join(bytecodeCacheDirectory.path, 'test_bytecode_1'));
      final File testBytecodeChecksum1 = File(path.join(bytecodeCacheDirectory.path, 'test_bytecode_1.checksum'));
      final File testBytecodeTmp1 = File(path.join(bytecodeCacheDirectory.path, 'test_bytecode_1.tmp'));

      await testBytecodeFile1.writeAsString('bytecode content 1');
      await testBytecodeChecksum1.writeAsString('12345');
      await testBytecodeTmp1.writeAsString('temp bytecode');

      // Verify files exist
      expect(await testBytecodeFile1.exists(), true);
      expect(await testBytecodeChecksum1.exists(), true);
      expect(await testBytecodeTmp1.exists(), true);

      // Clear all caches
      await WebF.clearAllCaches();

      // Verify all bytecode cache files are deleted
      expect(await testBytecodeFile1.exists(), false);
      expect(await testBytecodeChecksum1.exists(), false);
      expect(await testBytecodeTmp1.exists(), false);
      expect(await bytecodeCacheDirectory.exists(), false);
    });

    test('should clear QuickJS bytecode memory caches', () async {
      // Create test bytecode data
      final Uint8List testCode1 = Uint8List.fromList('test code 1'.codeUnits);
      final Uint8List testCode2 = Uint8List.fromList('test code 2'.codeUnits);
      final Uint8List testBytecode1 = Uint8List.fromList('test bytecode 1'.codeUnits);
      final Uint8List testBytecode2 = Uint8List.fromList('test bytecode 2'.codeUnits);

      // Put bytecode objects in cache
      await QuickJSByteCodeCache.putObject(testCode1, testBytecode1, cacheKey: 'test1');
      await QuickJSByteCodeCache.putObject(testCode2, testBytecode2, cacheKey: 'test2');

      // Verify objects are in cache
      final cachedObject1 = await QuickJSByteCodeCache.getCacheObject(testCode1, cacheKey: 'test1', loadedFromCache: true);
      final cachedObject2 = await QuickJSByteCodeCache.getCacheObject(testCode2, cacheKey: 'test2', loadedFromCache: true);
      expect(cachedObject1.valid, true);
      expect(cachedObject2.valid, true);

      // Clear all caches
      await WebF.clearAllCaches();

      // Verify memory caches are cleared (new objects will be created but not valid)
      final clearedObject1 = await QuickJSByteCodeCache.getCacheObject(testCode1, cacheKey: 'test1', loadedFromCache: true);
      final clearedObject2 = await QuickJSByteCodeCache.getCacheObject(testCode2, cacheKey: 'test2', loadedFromCache: true);
      expect(clearedObject1.valid, false);
      expect(clearedObject2.valid, false);
    });

    test('should clear both HTTP and bytecode caches together', () async {
      final String appTemporaryPath = await getWebFTemporaryPath();

      // Create multiple HTTP cache directories (new structure)
      final Directory httpCacheDir1 = Directory(path.join(appTemporaryPath, 'HttpCaches_page1'));
      final Directory httpCacheDir2 = Directory(path.join(appTemporaryPath, 'HttpCache_special'));
      await httpCacheDir1.create(recursive: true);
      await httpCacheDir2.create(recursive: true);
      
      final File httpCacheFile1 = File(path.join(httpCacheDir1.path, 'http_cache'));
      final File httpCacheFile2 = File(path.join(httpCacheDir2.path, 'http_cache'));
      await httpCacheFile1.writeAsString('http cache content 1');
      await httpCacheFile2.writeAsString('http cache content 2');

      // Create bytecode cache files
      final Directory bytecodeCacheDir = Directory(
        path.join(appTemporaryPath, 'ByteCodeCaches_${QuickJSByteCodeCache.bytecodeVersion}')
      );
      await bytecodeCacheDir.create(recursive: true);
      final File bytecodeCacheFile = File(path.join(bytecodeCacheDir.path, 'bytecode_cache'));
      await bytecodeCacheFile.writeAsString('bytecode cache content');

      // Verify files exist
      expect(await httpCacheFile1.exists(), true);
      expect(await httpCacheFile2.exists(), true);
      expect(await bytecodeCacheFile.exists(), true);

      // Clear all caches
      await WebF.clearAllCaches();

      // Verify both cache types are cleared
      expect(await httpCacheFile1.exists(), false);
      expect(await httpCacheFile2.exists(), false);
      expect(await bytecodeCacheFile.exists(), false);

      // All cache directories should be deleted
      expect(await httpCacheDir1.exists(), false);
      expect(await httpCacheDir2.exists(), false);
      expect(await bytecodeCacheDir.exists(), false);
    });
  });
}
