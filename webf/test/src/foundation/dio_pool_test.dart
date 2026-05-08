import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/foundation/dio_client.dart';

import '../../setup.dart';

void main() {
  final uri = Uri.parse('https://example.com/');
  // dio_client constructs URLSessionConfiguration eagerly on iOS/macOS,
  // which calls into the objective_c plugin and is not available under
  // `flutter test`.
  final macOSSkip = (Platform.isIOS || Platform.isMacOS)
      ? 'dio_client uses cupertino URLSession on iOS/macOS which requires native plugins'
      : null;

  setUp(() {
    setupTest();
  });

  group('WebF Dio pool', () {
    test('returns shared instance per contextId', () async {
      final dio1 = await getOrCreateWebFDio(contextId: 42.0, uri: uri);
      final dio2 = await getOrCreateWebFDio(contextId: 42.0, uri: uri);
      expect(identical(dio1, dio2), isTrue);

      final dioOther = await getOrCreateWebFDio(contextId: 7.0, uri: uri);
      expect(identical(dio1, dioOther), isFalse);
    }, skip: macOSSkip);

    test('disposes and recreates after disposeSharedDioForContext', () async {
      final a = await getOrCreateWebFDio(contextId: 99.0, uri: uri);
      disposeSharedDioForContext(99.0);
      final b = await getOrCreateWebFDio(contextId: 99.0, uri: uri);
      expect(identical(a, b), isFalse);
      // Ensure new instance is usable (no throw)
      expect(b, isA<Dio>());
    }, skip: macOSSkip);
  });
}

