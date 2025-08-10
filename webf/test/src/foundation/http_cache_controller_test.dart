import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/foundation.dart';
import 'package:webf/src/foundation/http_cache.dart';
import 'package:webf/src/foundation/http_cache_object.dart';
import 'package:webf/src/foundation/http_client.dart' show createHttpHeaders;
import 'package:webf/src/foundation/http_client_response.dart';
import 'package:webf/src/foundation/http_client_request.dart';

import '../../setup.dart';

// Minimal request for tests
class _FakeRequest implements HttpClientRequest {
  _FakeRequest(this._uri, {Map<String, String>? headers})
      : _headers = createHttpHeaders(
      initialHeaders: headers?.map((k, v) => MapEntry(k, <String>[v])));
  final Uri _uri;
  final HttpHeaders _headers;
  @override
  HttpHeaders get headers => _headers;
  @override
  Uri get uri => _uri;
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory tmp;



  setUp(() {
    tmp = setupTest();
  });

  group('HttpCacheController basics', () {
    test('getCacheDirectory uses HttpCaches under temp', () async {
      final dir = await HttpCacheController.getCacheDirectory();
      expect(dir.path, '${tmp.path}/HttpCaches');
      expect(await dir.exists(), isTrue);
    });

    test('instance returns same controller per origin', () async {
      final c1 = HttpCacheController.instance('https://a');
      final c2 = HttpCacheController.instance('https://a');
      final c3 = HttpCacheController.instance('https://b');
      expect(identical(c1, c2), isTrue);
      expect(identical(c1, c3), isFalse);
    });

    test('putObject/getCacheObject returns in-memory object', () async {
      final controller = HttpCacheController.instance('https://example');
      final uri = Uri.parse('https://example/path.txt');
      final cacheDir = (await HttpCacheController.getCacheDirectory()).path;
      final obj = HttpCacheObject(HttpCacheController.getCacheKey(uri), cacheDir, contentLength: 5);
      controller.putObject(uri, obj);

      final got = await controller.getCacheObject(uri);
      expect(identical(got, obj), isTrue);
      expect(got.contentLength, 5);
    });

    test('clearAllMemoryCaches resets controllers map', () async {
      final c1 = HttpCacheController.instance('https://reset');
      HttpCacheController.clearAllMemoryCaches();
      final c2 = HttpCacheController.instance('https://reset');
      expect(identical(c1, c2), isFalse);
    });

    test('interceptResponse serves 304 from cache', () async {
      final controller = HttpCacheController.instance('https://origin');
      final uri = Uri.parse('https://origin/asset.js');
      final cacheDir = (await HttpCacheController.getCacheDirectory()).path;
      final obj = HttpCacheObject(HttpCacheController.getCacheKey(uri), cacheDir,
          headers: 'content-type: application/javascript\n', contentLength: 5);

      // Seed cache with blob and index
      final blob = obj.openBlobWrite();
      blob.add([1, 2, 3, 4, 5]);
      await blob.close();
      await obj.updateContentChecksum();
      await obj.writeIndex();
      await obj.read();
      expect(obj.valid, isTrue);

      // Create a 304 response
      final hdrs = createHttpHeaders(initialHeaders: {
        HttpHeaders.etagHeader: ['"abc"'],
      });
      final notModified = HttpClientStreamResponse(Stream<List<int>>.empty(),
          statusCode: HttpStatus.notModified, initialHeaders: hdrs);

      final req = _FakeRequest(uri);

      final served = await controller.interceptResponse(req, notModified, obj, HttpClient(), null);
      // Should resolve to the cached content
      final bytes = await served.fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
      expect(bytes.length, 5);
      expect(served.statusCode, HttpStatus.ok);
      expect(served.headers.value(HttpHeaders.contentLengthHeader), '5');
    });
  });
}
