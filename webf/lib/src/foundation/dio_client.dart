import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:webf/foundation.dart';
import 'package:webf/module.dart';
import 'package:webf/launcher.dart';

// import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
// import 'package:http_cache_hive_store/http_cache_hive_store.dart';

import 'bundle.dart';
import 'dio_interceptors.dart';

/// Creates a Dio client configured for WebF networking with cookie + cache handling.
/// Context arguments tailor the interceptor per-call without duplicating setup logic.
/// Create a Dio client configured for WebF networking.
///
/// Options align with Dio v5 docs. Defaults aim to match WebF HttpClient behavior
/// while allowing per-request overrides.
class _WebFDioPool {
  // Maintain a single Dio per context with a scheme-routing adapter.
  static final _instances = <double, Dio>{};

  static Dio getOrCreate({
    required double contextId,
    WebFBundle? ownerBundle,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 60),
    Duration sendTimeout = const Duration(seconds: 60),
    bool followRedirects = true,
    int maxRedirects = 5,
    int maxConnectionsPerHost = 30,
    String? userAgent,
  }) {
    if (_instances.containsKey(contextId)) {
      return _instances[contextId]!;
    }

    final headers = <String, dynamic>{
      HttpHeaders.userAgentHeader: userAgent ?? _getDefaultUserAgent(),
    };

    // Single dio that owns interceptors; adapter will route by scheme.
    final dio = Dio(BaseOptions(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
      responseType: ResponseType.bytes,
      headers: headers,
    ));
    // Build scheme-specific adapters and install routing adapter unless a custom adapter is provided.
    final controller = WebFController.getControllerOfJSContextId(contextId);
    final customAdapter = controller?.dioHttpClientAdapter;
    if (customAdapter != null) {
      dio.httpClientAdapter = customAdapter;
    } else {
      // Use native http client by default
      dio.httpClientAdapter = NativeAdapter();
    }

    // Backward-compat adapter to reuse HttpClientInterceptor hooks with Dio
    dio.interceptors.add(WebFDioHttpClientInterceptorAdapter(contextId: contextId));

    // Cookie + cache interceptor bound to this context
    dio.interceptors.add(WebFDioCacheCookieInterceptor(
      contextId: contextId,
      ownerBundle: ownerBundle,
    ));

    // Append user-provided interceptors (if any) after WebF's built-in interceptor
    final extras = controller?.dioInterceptors;
    if (extras != null && extras.isNotEmpty) {
      dio.interceptors.addAll(extras);
    }

    _instances[contextId] = dio;
    return dio;
  }

  static void dispose(double contextId) {
    final dio = _instances.remove(contextId);
    dio?.close(force: true);
  }
}

/// Get a WebF-configured Dio. Returns a shared instance per `contextId`.
/// When `contextId` is null, creates a new ephemeral instance.
Future<Dio> createWebFDio({
  double? contextId,
  WebFBundle? ownerBundle,
  Duration connectTimeout = const Duration(seconds: 30),
  Duration receiveTimeout = const Duration(seconds: 60),
  Duration sendTimeout = const Duration(seconds: 60),
  bool followRedirects = true,
  int maxRedirects = 5,
  int maxConnectionsPerHost = 15,
  String? userAgent,
  bool Function(int? statusCode)? validateStatus,
}) async {
  if (contextId != null) {
    final dio = _WebFDioPool.getOrCreate(
      contextId: contextId,
      ownerBundle: ownerBundle,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
      maxConnectionsPerHost: maxConnectionsPerHost,
      userAgent: userAgent,
    );
    // Per-request validateStatus can still be provided via Options in request.
    return dio;
  }

  // Fallback: create ephemeral client if no contextId provided.
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
    validateStatus: validateStatus,
    headers: headers,
  ));

  final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
  adapter.createHttpClient = () {
    final client = HttpClient()
      ..maxConnectionsPerHost = maxConnectionsPerHost
      ..connectionTimeout = connectTimeout
      ..autoUncompress = true;
    return client;
  };

  // For ephemeral usage, add interceptor if we still have a context for cookies/cache
  if (ownerBundle != null) {
    dio.interceptors.add(WebFDioCacheCookieInterceptor(
      contextId: contextId,
      ownerBundle: ownerBundle,
    ));
  }

  return dio;
}

/// Dispose the shared Dio for a specific WebF context when controller is torn down.
void disposeSharedDioForContext(double contextId) {
  _WebFDioPool.dispose(contextId);
}

String _getDefaultUserAgent() {
  try {
    return NavigatorModule.getUserAgent();
  } catch (_) {
    return 'WebF';
  }
}
