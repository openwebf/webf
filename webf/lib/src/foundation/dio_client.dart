import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/module.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';

import 'bundle.dart';
import 'dio_interceptors.dart';

/// Creates a Dio client configured for WebF networking with cookie + cache handling.
/// Context arguments tailor the interceptor per-call without duplicating setup logic.
/// Create a Dio client configured for WebF networking.
///
/// Options align with Dio v5 docs. Defaults aim to match WebF HttpClient behavior
/// while allowing per-request overrides.
Future<Dio> createWebFDio({
  double? contextId,
  WebFBundle? ownerBundle,
  bool isXHR = false,
  Duration connectTimeout = const Duration(seconds: 30),
  Duration receiveTimeout = const Duration(seconds: 60),
  Duration sendTimeout = const Duration(seconds: 60),
  bool followRedirects = true,
  int maxRedirects = 5,
  int maxConnectionsPerHost = 30,
  String? userAgent,
  bool Function(int? statusCode)? validateStatus,
}) async {
  final headers = <String, dynamic>{
    HttpHeaders.userAgentHeader: userAgent ?? _getDefaultUserAgent(),
  };

  final dio = Dio(BaseOptions(
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    sendTimeout: sendTimeout,
    followRedirects: followRedirects,
    maxRedirects: maxRedirects,
    responseType: ResponseType.bytes,
    // If not provided, Dio's default applies (2xx only)
    validateStatus: validateStatus,
    headers: headers,
  ));

  // Tune underlying HttpClient
  final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
  adapter.createHttpClient = () {
    final client = HttpClient()
      ..maxConnectionsPerHost = maxConnectionsPerHost
      ..connectionTimeout = connectTimeout
      ..autoUncompress = true;
    return client;
  };

  Directory cacheDirectory = await HttpCacheController.getCacheDirectory();
  cacheDirectory.path;

  // WebF cookie + cache interceptor
  dio.interceptors.add(WebFDioCacheCookieInterceptor(
    contextId: contextId,
    ownerBundle: ownerBundle,
    isXHR: isXHR,
  ));

  // Global options
  // final cacheOptions = CacheOptions(
  //   // A default store is required for interceptor.
  //   store: MemCacheStore(),
  //
  //   // All subsequent fields are optional to get a standard behaviour.
  //
  //   // Default.
  //   policy: CachePolicy.request,
  //   // Returns a cached response on error for given status codes.
  //   // Defaults to `[]`.
  //   hitCacheOnErrorCodes: [500],
  //   // Allows to return a cached response on network errors (e.g. offline usage).
  //   // Defaults to `false`.
  //   hitCacheOnNetworkFailure: true,
  //   // Overrides any HTTP directive to delete entry past this duration.
  //   // Useful only when origin server has no cache config or custom behaviour is desired.
  //   // Defaults to `null`.
  //   maxStale: const Duration(days: 7),
  //   // Default. Allows 3 cache sets and ease cleanup.
  //   priority: CachePriority.normal,
  //   // Default. Body and headers encryption with your own algorithm.
  //   cipher: null,
  //   // Default. Key builder to retrieve requests.
  //   keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  //   // Default. Allows to cache POST requests.
  //   // Assigning a [keyBuilder] is strongly recommended when `true`.
  //   allowPostMethod: false,
  // );
  //
  // dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

  return dio;
}

String _getDefaultUserAgent() {
  try {
    return NavigatorModule.getUserAgent();
  } catch (_) {
    return 'WebF';
  }
}
