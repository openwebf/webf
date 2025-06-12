/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:path/path.dart' as path;

import '../../webf_test.dart';

void main() {
  setUp(() {
    setupTest();
  });

  group('WebF.clearAllCaches', () {
    test('should clear all HTTP disk cache files', () async {
      // Create a test cache directory structure
      final String appTemporaryPath = await getWebFTemporaryPath();
      final Directory cacheDirectory = Directory(path.join(appTemporaryPath, 'HttpCaches'));
      
      // Create some test cache files
      if (!await cacheDirectory.exists()) {
        await cacheDirectory.create(recursive: true);
      }
      
      // Create test cache files
      final File testCacheFile1 = File(path.join(cacheDirectory.path, 'test_cache_1'));
      final File testCacheFile2 = File(path.join(cacheDirectory.path, 'test_cache_2'));
      final File testCacheBlobFile = File(path.join(cacheDirectory.path, 'test_cache_1-blob'));
      
      await testCacheFile1.writeAsString('test cache content 1');
      await testCacheFile2.writeAsString('test cache content 2');
      await testCacheBlobFile.writeAsString('test blob content');
      
      // Verify files exist
      expect(await testCacheFile1.exists(), true);
      expect(await testCacheFile2.exists(), true);
      expect(await testCacheBlobFile.exists(), true);
      
      // Clear all caches
      await WebF.clearAllCaches();
      
      // Verify all cache files are deleted
      expect(await testCacheFile1.exists(), false);
      expect(await testCacheFile2.exists(), false);
      expect(await testCacheBlobFile.exists(), false);
      
      // Verify cache directory is recreated
      expect(await cacheDirectory.exists(), true);
    });

    test('should clear all memory caches', () async {
      // Create a mock HTTP cache controller and add some cache objects
      final HttpCacheController controller1 = HttpCacheController.instance('https://example.com');
      final HttpCacheController controller2 = HttpCacheController.instance('https://test.com');
      
      // Create cache objects
      final Uri uri1 = Uri.parse('https://example.com/test.js');
      final Uri uri2 = Uri.parse('https://test.com/style.css');
      
      final String cacheDir = (await HttpCacheController.getCacheDirectory()).path;
      
      final HttpCacheObject cacheObject1 = HttpCacheObject(
        HttpCacheController.getCacheKey(uri1),
        cacheDir,
        contentLength: 100,
      );
      
      final HttpCacheObject cacheObject2 = HttpCacheObject(
        HttpCacheController.getCacheKey(uri2),
        cacheDir,
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
      await WebF.clearAllCaches();
      
      // Create new controller instances (since old ones were cleared)
      final HttpCacheController newController1 = HttpCacheController.instance('https://example.com');
      final HttpCacheController newController2 = HttpCacheController.instance('https://test.com');
      
      // Verify memory caches are cleared (objects will be recreated but not valid)
      final clearedObject1 = await newController1.getCacheObject(uri1);
      final clearedObject2 = await newController2.getCacheObject(uri2);
      expect(clearedObject1.valid, false);
      expect(clearedObject2.valid, false);
    });

    test('should handle case when cache directory does not exist', () async {
      // Get the cache directory path
      final String appTemporaryPath = await getWebFTemporaryPath();
      final Directory cacheDirectory = Directory(path.join(appTemporaryPath, 'HttpCaches'));
      
      // Delete the cache directory if it exists
      if (await cacheDirectory.exists()) {
        await cacheDirectory.delete(recursive: true);
      }
      
      // Verify directory doesn't exist
      expect(await cacheDirectory.exists(), false);
      
      // Clear all caches should not throw
      await expectLater(WebF.clearAllCaches(), completes);
      
      // Cache directory might not exist after clearing if it didn't exist before
      // The important thing is that the operation completes without throwing
    });

    test('should handle concurrent cache clearing', () async {
      // Create test cache files
      final String appTemporaryPath = await getWebFTemporaryPath();
      final Directory cacheDirectory = Directory(path.join(appTemporaryPath, 'HttpCaches'));
      
      if (!await cacheDirectory.exists()) {
        await cacheDirectory.create(recursive: true);
      }
      
      // Create multiple test files
      for (int i = 0; i < 10; i++) {
        final File testFile = File(path.join(cacheDirectory.path, 'test_cache_$i'));
        await testFile.writeAsString('test content $i');
      }
      
      // Clear caches concurrently
      final futures = <Future>[];
      for (int i = 0; i < 5; i++) {
        futures.add(WebF.clearAllCaches());
      }
      
      // All operations should complete without error
      await expectLater(Future.wait(futures), completes);
      
      // Verify cache directory exists and is empty
      expect(await cacheDirectory.exists(), true);
      final List<FileSystemEntity> files = cacheDirectory.listSync();
      expect(files.isEmpty, true);
    });

    test('should work correctly after clearing caches', () async {
      // Clear all caches first
      await WebF.clearAllCaches();
      
      // Create a new cache object and verify it works
      final HttpCacheController controller = HttpCacheController.instance('https://example.com');
      final Uri uri = Uri.parse('https://example.com/new.js');
      final String cacheDir = (await HttpCacheController.getCacheDirectory()).path;
      
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
      // Mock a file system error by creating a read-only directory
      final String appTemporaryPath = await getWebFTemporaryPath();
      final Directory cacheDirectory = Directory(path.join(appTemporaryPath, 'HttpCaches'));
      
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
      
      // Create HTTP cache files
      final Directory httpCacheDir = Directory(path.join(appTemporaryPath, 'HttpCaches'));
      await httpCacheDir.create(recursive: true);
      final File httpCacheFile = File(path.join(httpCacheDir.path, 'http_cache'));
      await httpCacheFile.writeAsString('http cache content');
      
      // Create bytecode cache files
      final Directory bytecodeCacheDir = Directory(
        path.join(appTemporaryPath, 'ByteCodeCaches_${QuickJSByteCodeCache.bytecodeVersion}')
      );
      await bytecodeCacheDir.create(recursive: true);
      final File bytecodeCacheFile = File(path.join(bytecodeCacheDir.path, 'bytecode_cache'));
      await bytecodeCacheFile.writeAsString('bytecode cache content');
      
      // Verify files exist
      expect(await httpCacheFile.exists(), true);
      expect(await bytecodeCacheFile.exists(), true);
      
      // Clear all caches
      await WebF.clearAllCaches();
      
      // Verify both cache types are cleared
      expect(await httpCacheFile.exists(), false);
      expect(await bytecodeCacheFile.exists(), false);
      
      // HTTP cache directory should be recreated, bytecode cache directory should not
      expect(await httpCacheDir.exists(), true);
      expect(await bytecodeCacheDir.exists(), false);
    });
  });
}