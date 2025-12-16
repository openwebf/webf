import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/foundation/http_cache_object.dart';
import 'package:webf/src/foundation/http_client.dart' show createHttpHeaders;

import '../../setup.dart';

class _Req implements HttpClientRequest {
  _Req(this._uri, {Map<String, String>? headers})
      : _headers = createHttpHeaders(
            initialHeaders: headers?.map((k, v) => MapEntry(k, <String>[v])));

  final Uri _uri;
  final HttpHeaders _headers;

  @override
  Uri get uri => _uri;

  @override
  HttpHeaders get headers => _headers;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory tmp;

  setUp(() {
    tmp = setupTest();
  });

  group('Http cache race conditions', () {
    test('partial blob write becomes valid after index write', () async {
      final dir = Directory('${tmp.path}/HttpCaches');
      await dir.create(recursive: true);
      final url = 'https://race.local/data_${DateTime.now().microsecondsSinceEpoch}.bin';
      final obj = HttpCacheObject(url, dir.path, contentLength: 6);

      // Start writing partial data without closing
      final blob = obj.openBlobWrite();
      blob.add([1, 2, 3]);
      // Mid-write, reading index should be invalid (no index yet)
      await obj.read();
      expect(obj.valid, isFalse);

      // Finish writing and persist index
      blob.add([4, 5, 6]);
      await blob.close();
      await obj.updateContentChecksum();
      await obj.writeIndex();
      await obj.read();

      // Now binary content should be available and complete
      final bin = await obj.toBinaryContent();
      expect(bin, isNotNull);
      expect(bin!.length, 6);
    });

    test('lock files are cleaned after index write', () async {
      final dir = Directory('${tmp.path}/HttpCaches');
      await dir.create(recursive: true);
      final url = 'https://locks.example/file.txt';
      final obj = HttpCacheObject(url, dir.path, contentLength: 1);
      obj.openBlobWrite().add([0]);
      await obj.openBlobWrite().close();
      await obj.writeIndex();

      // No stray .lock files should remain
      final lockFiles = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.lock'))
          .toList();
      expect(lockFiles.isEmpty, isTrue);
    });
  });
}
