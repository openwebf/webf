import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/foundation/http_cache_object.dart';
import 'package:webf/src/foundation/http_client.dart' show createHttpHeaders;

import '../../setup.dart';

class _FakeRequest implements HttpClientRequest {
  _FakeRequest(this._uri, {Map<String, String>? headers})
      : _headers = createHttpHeaders(initialHeaders: headers?.map((k, v) => MapEntry(k, <String>[v])));

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

  group('HttpCacheObject', () {
    test('write/read index roundtrip with checksum', () async {
      final dir = Directory('${tmp.path}/HttpCaches');
      await dir.create(recursive: true);
      final url = 'https://example.com/a.js';
      final obj = HttpCacheObject(url, dir.path,
          headers: 'content-type: application/javascript\n', contentLength: 3);

      // Write blob content and checksum
      final blob = obj.openBlobWrite();
      blob.add([1, 2, 3]);
      await blob.close();
      await obj.updateContentChecksum();
      await obj.writeIndex();

      // Read into a new object
      final obj2 = HttpCacheObject(url, dir.path);
      await obj2.read();
      expect(obj2.valid, isTrue);
      expect(obj2.contentLength, 3);
      expect(obj2.headers!.contains('content-type'), isTrue);
      // Validate checksum matches
      expect(await obj2.validateContent(), isTrue);

      // toHttpClientResponse should expose correct Content-Length
      final resp = await obj2.toHttpClientResponse(HttpClient());
      expect(resp, isNotNull);
      expect(resp!.headers.value(HttpHeaders.contentLengthHeader), '3');
    });

    test('hitLocalCache respects request no-cache', () async {
      final dir = Directory('${tmp.path}/HttpCaches');
      await dir.create(recursive: true);
      final url = 'https://example.com/b.css';
      final obj = HttpCacheObject(url, dir.path,
          headers: 'content-type: text/css\n',
          contentLength: 2,
          expiredTime: DateTime.now().add(const Duration(minutes: 5)));

      // Populate blob to make it valid
      final blob = obj.openBlobWrite();
      blob.add([0, 1]);
      await blob.close();
      await obj.updateContentChecksum();
      await obj.writeIndex();
      await obj.read();
      expect(obj.valid, isTrue);

      // no-cache should disable local cache hit
      final reqNoCache = _FakeRequest(Uri.parse(url), headers: {
        HttpHeaders.cacheControlHeader: 'no-cache',
      });
      expect(obj.hitLocalCache(reqNoCache), isFalse);

      // Without no-cache, hit should be true when valid
      final reqNormal = _FakeRequest(Uri.parse(url));
      expect(obj.hitLocalCache(reqNormal), isTrue);
    });

    test('toBinaryContent returns exact bytes', () async {
      final dir = Directory('${tmp.path}/HttpCaches');
      await dir.create(recursive: true);
      final url = 'https://example.com/data.bin';
      final obj = HttpCacheObject(url, dir.path, contentLength: 4);

      final blob = obj.openBlobWrite();
      blob.add([10, 20, 30, 40]);
      await blob.close();
      await obj.updateContentChecksum();
      await obj.writeIndex();
      await obj.read();

      final bytes = await obj.toBinaryContent();
      expect(bytes, Uint8List.fromList([10, 20, 30, 40]));
    });

    test('remove deletes files and invalidates', () async {
      final dir = Directory('${tmp.path}/HttpCaches');
      await dir.create(recursive: true);
      final url = 'https://example.com/remove.me';
      final obj = HttpCacheObject(url, dir.path, contentLength: 1);
      obj.openBlobWrite().add([1]);
      await obj.openBlobWrite().close();
      await obj.writeIndex();
      await obj.read();
      expect(obj.valid, isTrue);

      await obj.remove();
      expect(obj.valid, isFalse);
      // Re-read should detect missing files and remain invalid
      await obj.read();
      expect(obj.valid, isFalse);
    });
  });
}
