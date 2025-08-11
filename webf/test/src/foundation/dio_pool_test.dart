import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/foundation/dio_client.dart';

void main() {
  group('WebF Dio pool', () {
    test('returns shared instance per contextId', () async {
      final dio1 = await getOrCreateWebFDio(contextId: 42.0);
      final dio2 = await getOrCreateWebFDio(contextId: 42.0);
      expect(identical(dio1, dio2), isTrue);

      final dioOther = await getOrCreateWebFDio(contextId: 7.0);
      expect(identical(dio1, dioOther), isFalse);
    });

    test('disposes and recreates after disposeSharedDioForContext', () async {
      final a = await getOrCreateWebFDio(contextId: 99.0);
      disposeSharedDioForContext(99.0);
      final b = await getOrCreateWebFDio(contextId: 99.0);
      expect(identical(a, b), isFalse);
      // Ensure new instance is usable (no throw)
      expect(b, isA<Dio>());
    });
  });
}

