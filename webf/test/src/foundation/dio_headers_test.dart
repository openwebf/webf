import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/foundation/dio_client.dart';
import 'package:webf/src/foundation/http_overrides.dart';
import 'package:webf/src/foundation/cookie_jar/persist_cookie_jar.dart';
import 'package:webf/src/foundation/cookie_jar/file_storage.dart';
import 'package:webf/src/foundation/cookie_jar.dart';
import 'package:webf/src/foundation/http_cache.dart';

class _CaptureOptionsInterceptor extends InterceptorsWrapper {
  _CaptureOptionsInterceptor(this._onRequest);
  final void Function(RequestOptions) _onRequest;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _onRequest(options);
    // Short-circuit network by resolving immediately
    handler.resolve(Response<Uint8List>(
      requestOptions: options,
      statusCode: 200,
      data: Uint8List(0),
    ));
  }
}

void main() {
  setUpAll(() async {
    // Disable cache to avoid platform channel for temporary directory
    HttpCacheController.mode = HttpCacheMode.NO_CACHE;
    // Initialize cookie jar to avoid platform channel usage in tests
    final dir = await Directory.systemTemp.createTemp('webf_test_cookies');
    final jar = PersistCookieJar(storage: FileStorage(dir.path));
    await CookieManager.afterCookieJarLoaded(jar);
  });

  group('WebF Dio headers', () {
    test('injects x-context and referer for GET', () async {
      const ctx = 7.0;
      final dio = await createWebFDio(contextId: ctx);
      RequestOptions? seen;
      dio.interceptors.add(_CaptureOptionsInterceptor((opts) => seen = opts));

      await dio.getUri(Uri.parse('https://example.com/test'));

      expect(seen, isNotNull);
      expect(seen!.headers[HttpHeaderContext], ctx.toString());
      final expectedRef = getEntrypointUri(ctx).toString();
      expect(seen!.headers['referer'], expectedRef);
      // For GET, origin should be absent
      expect(seen!.headers['origin'], isNull);
    });

    test('injects origin for non-GET', () async {
      const ctx = 8.0;
      final dio = await createWebFDio(contextId: ctx);
      RequestOptions? seen;
      dio.interceptors.add(_CaptureOptionsInterceptor((opts) => seen = opts));

      await dio.requestUri(Uri.parse('https://example.org/submit'), options: Options(method: 'POST'));

      expect(seen, isNotNull);
      expect(seen!.headers[HttpHeaderContext], ctx.toString());
      final ref = getEntrypointUri(ctx);
      final expectedOrigin = getOrigin(ref);
      expect(seen!.headers['origin'], expectedOrigin);
    });

    test('preserves X-WebF-Request-Type from caller', () async {
      const ctx = 9.0;
      final dio = await createWebFDio(contextId: ctx);
      RequestOptions? seen;
      dio.interceptors.add(_CaptureOptionsInterceptor((opts) => seen = opts));

      await dio.getUri(
        Uri.parse('https://example.net/xhr'),
        options: Options(headers: {'X-WebF-Request-Type': 'fetch'}),
      );

      expect(seen, isNotNull);
      expect(seen!.headers['X-WebF-Request-Type'], 'fetch');
    });
  });
}

