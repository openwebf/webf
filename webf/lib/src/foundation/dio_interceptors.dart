import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes;
import 'package:webf/foundation.dart';

import 'cookie_jar.dart';
import 'http_cache.dart';
import 'http_cache_object.dart';
import 'http_client.dart';
import 'http_client_request.dart';
import 'http_client_response.dart';
import 'http_overrides.dart';
import 'bundle.dart';
import '../launcher/controller.dart' show WebFController; // for getEntrypointUri via http_overrides.dart

class WebFDioCacheCookieInterceptor extends InterceptorsWrapper {
  WebFDioCacheCookieInterceptor({required this.contextId, this.ownerBundle});

  final double? contextId;
  final WebFBundle? ownerBundle;
  // XHR marking is determined per-request by headers or options, not per-client.

  static const _kCacheObjectKey = 'webf_cache_object';
  static const _kOriginKey = 'webf_origin';
  static const _kCacheHitKey = 'webf_cache_hit';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // If present, use a ProxyHttpClientRequest prepared by the bridge to keep compatibility
    // with HttpClientInterceptor implementations that expect ProxyHttpClientRequest.
    ProxyHttpClientRequest? proxyRequest = options.extra[_Bridge._kProxyRequestKey] as ProxyHttpClientRequest?;

    final uri = options.uri;
    // Attach WebF context header
    options.headers[HttpHeaderContext] = (contextId ?? 0).toString();

    // Attach Referer/Origin based on entrypoint
    if (contextId != null) {
      final referrer = getEntrypointUri(contextId);
      final isLocalRequest = uri.isScheme('file') || uri.isScheme('data') || uri.isScheme('assets');
      final isUnsafe = referrer.isScheme('https') && !uri.isScheme('https');
      if (!isLocalRequest && !isUnsafe) {
        options.headers[HttpHeaders.refererHeader] = referrer.toString();
      }
      if (options.method != 'GET' && options.method != 'HEAD') {
        options.headers['origin'] = getOrigin(referrer);
      }
    }

    // If caller marks XHR via header/extra, leave it as-is.

    // Load cookies
    final cookies = <Cookie>[];
    await CookieManager.loadForRequest(uri, cookies);
    if (cookies.isNotEmpty) {
      options.headers[HttpHeaders.cookieHeader] = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    }

    // Cache negotiation
    final ref = contextId != null ? getEntrypointUri(contextId) : uri;
    final origin = getOrigin(ref);
    options.extra[_kOriginKey] = origin;

    if (HttpCacheController.mode != HttpCacheMode.NO_CACHE) {
      final controller = HttpCacheController.instance(origin);
      final cacheObject = await controller.getCacheObject(uri);
      options.extra[_kCacheObjectKey] = cacheObject;

      if (cacheObject.hitLocalCache(_DummyRequest(options))) {
        // Serve from local cache immediately.
        final native = HttpClient();
        final cached = await cacheObject.toHttpClientResponse(native);
        if (cached != null) {
          final bytes = await consolidateHttpClientResponseBytes(cached);
          final headers = <String, List<String>>{};
          cached.headers.forEach((k, v) => headers[k] = List<String>.from(v));
          options.extra[_kCacheHitKey] = true;
          return handler.resolve(
            Response<Uint8List>(
              requestOptions: options,
              data: Uint8List.fromList(bytes),
              statusCode: cached.statusCode,
              statusMessage: '',
              headers: Headers.fromMap(headers),
            ),
          );
        }
      }

      // Add negotiation headers when needed
      if (cacheObject.valid &&
          options.headers[HttpHeaders.ifNoneMatchHeader] == null &&
          options.headers[HttpHeaders.ifModifiedSinceHeader] == null) {
        if (cacheObject.eTag != null) {
          options.headers[HttpHeaders.ifNoneMatchHeader] = cacheObject.eTag!;
        } else if (cacheObject.lastModified != null) {
          options.headers[HttpHeaders.ifModifiedSinceHeader] = HttpDate.format(cacheObject.lastModified!);
        }
      }
    }

    // If a Proxy request exists, make sure its headers mirror the final options headers for downstream hooks
    if (proxyRequest != null) {
      // Clear any previous headers and copy over current ones
      final headersMap = options.headers.map((k, v) => MapEntry(k, [v.toString()]));
      final syncHeaders = createHttpHeaders(initialHeaders: headersMap);
      syncHeaders.forEach(proxyRequest.headers.set);
    }

    // For backward compatibility, after cache negotiation but before the network,
    // consult HttpClientInterceptor.shouldInterceptRequest to allow short-circuiting.
    if (contextId != null) {
      final overrides = WebFHttpOverrides.instance();
      if (overrides.hasInterceptor(contextId!)) {
        final httpInterceptor = overrides.getInterceptor(contextId!);
        final String requestId = (options.extra[_Bridge._kRequestIdKey] as String?) ?? _Bridge.generateRequestId();
        options.extra[_Bridge._kRequestIdKey] = requestId;

        // Build a minimal fallback HttpClientRequest if no proxy was prepared earlier
        final HttpClientRequest httpRequest = proxyRequest ?? _Bridge.buildProxyFromOptions(options);

        final HttpClientResponse? intercepted = await _Bridge.invokeShouldInterceptRequest(
          requestId,
          httpInterceptor,
          httpRequest,
        );
        if (intercepted != null) {
          final Response<Uint8List> dioResp = await _Bridge.convertHttpClientResponseToDio(options, intercepted);
          return handler.resolve(dioResp);
        }
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    final options = response.requestOptions;
    final uri = options.uri;
    final origin = options.extra[_kOriginKey] as String? ?? getOrigin(uri);
    final cacheObject = options.extra[_kCacheObjectKey] as HttpCacheObject?;

    // Handle 304 with cache
    if (response.statusCode == HttpStatus.notModified && cacheObject != null) {
      final native = HttpClient();
      final cached = await cacheObject.toHttpClientResponse(native);
      if (cached != null) {
        final bytes = await consolidateHttpClientResponseBytes(cached);
        final headers = <String, List<String>>{};
        cached.headers.forEach((k, v) => headers[k] = List<String>.from(v));
        options.extra[_kCacheHitKey] = true;
        return handler.resolve(
          Response<Uint8List>(
            requestOptions: options,
            data: Uint8List.fromList(bytes),
            statusCode: cached.statusCode,
            statusMessage: '',
            headers: Headers.fromMap(headers),
          ),
        );
      }
    }

    // Save Set-Cookie
    final setCookieHeaders = response.headers.map[HttpHeaders.setCookieHeader.toLowerCase()];
    if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
      await CookieManager.saveFromResponseRaw(uri, setCookieHeaders);
    }

    // Write to cache for 200 OK
    if (cacheObject != null && response.data is Uint8List && response.statusCode == HttpStatus.ok) {
      final native = HttpClient();
      final httpHeaders = <String, List<String>>{};
      response.headers.forEach((k, v) => httpHeaders[k] = List<String>.from(v));
      if (httpHeaders[HttpHeaders.contentLengthHeader] == null) {
        httpHeaders[HttpHeaders.contentLengthHeader] = ['${(response.data as Uint8List).length}'];
      }
      final hdr = createHttpHeaders(initialHeaders: httpHeaders);
      final httpResp = HttpClientStreamResponse(
        Stream<List<int>>.value(response.data as Uint8List),
        statusCode: response.statusCode ?? HttpStatus.ok,
        initialHeaders: hdr,
      );
      final dummyReq = _DummyRequest(options);
      final intercepted = await HttpCacheController.instance(origin)
          .interceptResponse(dummyReq, httpResp, cacheObject, native, ownerBundle);

      // IMPORTANT: Consume the intercepted response stream to drive cache writes.
      // HttpCacheController.interceptResponse returns a HttpClientCachedResponse whose
      // cache write completion future is tracked in _pendingCacheWrites. However, the
      // actual write only happens when the stream is listened to and completes.
      // Since Dio already provided the full bytes, we drain the intercepted stream
      // here to ensure _onDone() fires and pending cache writes complete.
      try {
        await consolidateHttpClientResponseBytes(intercepted);
      } catch (_) {
        // Ignore draining errors; cache layer handles cleanup/logging.
      }
    }

    handler.next(response);
  }
}

/// Minimal HttpClientRequest facade for cache negotiation and write paths.
class _DummyRequest implements HttpClientRequest {
  _DummyRequest(RequestOptions options)
      : _method = options.method,
        _uri = options.uri,
        _headers = createHttpHeaders(initialHeaders: options.headers.map((k, v) => MapEntry(k, [v.toString()])));

  final String _method;
  final Uri _uri;
  final HttpHeaders _headers;

  @override
  HttpHeaders get headers => _headers;
  @override
  String get method => _method;
  @override
  Uri get uri => _uri;

  // Unused members for cache flow
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// NOTE: The Dio factory is defined in dio_client.dart to keep concerns separated.

/// Bridge adapter to route HttpClientInterceptor hooks through Dio's interceptor lifecycle.
///
/// Ordering requirements:
/// - This adapter MUST be installed before [WebFDioCacheCookieInterceptor]
///   so that `beforeRequest` runs prior to cache negotiation and is recorded
///   even when local cache serves the response.
/// - `shouldInterceptRequest` is invoked inside WebFDioCacheCookieInterceptor.onRequest
///   after cache negotiation to preserve original behavior.
class WebFDioHttpClientInterceptorAdapter extends InterceptorsWrapper {
  WebFDioHttpClientInterceptorAdapter({required this.contextId});

  final double contextId;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Stash a unique request ID for correlation across hooks
    final String requestId = _Bridge.generateRequestId();
    options.extra[_Bridge._kRequestIdKey] = requestId;

    final overrides = WebFHttpOverrides.instance();
    if (!overrides.hasInterceptor(contextId)) {
      return handler.next(options);
    }

    final httpInterceptor = overrides.getInterceptor(contextId);

    // Build a ProxyHttpClientRequest from current options
    final proxy = _Bridge.buildProxyFromOptions(options, contextId: contextId);
    options.extra[_Bridge._kProxyRequestKey] = proxy;

    // Run beforeRequest to allow mutation of URL/method/headers/body
    final HttpClientRequest effectiveRequest =
        await _Bridge.invokeBeforeRequest(requestId, httpInterceptor, proxy) ?? proxy;

    // Apply possible changes back to Dio RequestOptions
    _Bridge.applyHttpRequestToDioOptions(effectiveRequest, options);

    // Do NOT run shouldInterceptRequest here; it will be called after cache negotiation
    // inside WebFDioCacheCookieInterceptor to preserve behavior.
    handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    final overrides = WebFHttpOverrides.instance();

    if (!overrides.hasInterceptor(contextId)) {
      return handler.next(response);
    }

    final httpInterceptor = overrides.getInterceptor(contextId);
    final RequestOptions options = response.requestOptions;
    final String requestId = (options.extra[_Bridge._kRequestIdKey] as String?) ?? _Bridge.generateRequestId();

    // Recreate a minimal HttpClientRequest for afterResponse; prefer the saved proxy
    final HttpClientRequest httpRequest =
        (options.extra[_Bridge._kProxyRequestKey] as HttpClientRequest?) ?? _Bridge.buildProxyFromOptions(options);

    // Convert Dio response to HttpClientResponse stream and allow mutation
    final HttpClientResponse proxyResponse = await _Bridge.convertDioToHttpClientResponse(response);
    final HttpClientResponse? replaced = await _Bridge.invokeAfterResponse(
      requestId,
      httpInterceptor,
      httpRequest,
      proxyResponse,
    );

    if (replaced != null) {
      final Response<Uint8List> dioResp = await _Bridge.convertHttpClientResponseToDio(options, replaced);
      return handler.resolve(dioResp);
    }

    handler.next(response);
  }
}

/// Internal utilities for adapting HttpClientInterceptor to Dio.
class _Bridge {
  static const String _kRequestIdKey = 'webf_request_id';
  static const String _kProxyRequestKey = 'webf_proxy_request';

  static int _counter = 0;
  static String generateRequestId() {
    _counter++;
    return '${_counter}_${DateTime.now().microsecondsSinceEpoch}';
  }

  static ProxyHttpClientRequest buildProxyFromOptions(RequestOptions options, {double? contextId}) {
    final proxy = ProxyHttpClientRequest(
      options.method,
      options.uri,
      WebFHttpOverrides.instance(),
      HttpClient(),
    );

    // Propagate context header to keep parity
    if (contextId != null) {
      WebFHttpOverrides.setContextHeader(proxy.headers, contextId);
    }

    // Headers
    options.headers.forEach((key, value) {
      proxy.headers.set(key, value.toString());
    });

    // Body
    final data = options.data;
    if (data != null) {
      if (data is Uint8List) {
        proxy.add(data);
      } else if (data is List<int>) {
        proxy.add(Uint8List.fromList(data));
      } else if (data is String) {
        proxy.add(Uint8List.fromList(utf8.encode(data)));
      } else {
        // Fallback to JSON encoding for arbitrary types
        try {
          final encoded = utf8.encode(jsonEncode(data));
          proxy.add(Uint8List.fromList(encoded));
        } catch (_) {}
      }
    }
    return proxy;
  }

  static void applyHttpRequestToDioOptions(HttpClientRequest req, RequestOptions options) {
    // Method and URL
    options.method = req.method;
    // Force absolute path to bypass baseUrl
    options.path = req.uri.toString();

    // Headers: clear and copy
    final newHeaders = <String, dynamic>{};
    req.headers.forEach((name, values) {
      if (values.isNotEmpty) newHeaders[name] = values.join(', ');
    });
    options.headers
      ..clear()
      ..addAll(newHeaders);

    // Body (only if we can read it)
    if (req is ProxyHttpClientRequest) {
      final body = req.data;
      if (body is List<int> && body.isNotEmpty) {
        options.data = Uint8List.fromList(body);
      }
    }
  }

  static Future<HttpClientRequest?> invokeBeforeRequest(
      String requestId, HttpClientInterceptor interceptor, HttpClientRequest req) async {
    try {
      return await interceptor.beforeRequest(requestId, req);
    } catch (_) {
      return null;
    }
  }

  static Future<HttpClientResponse?> invokeShouldInterceptRequest(
      String requestId, HttpClientInterceptor interceptor, HttpClientRequest req) async {
    try {
      return await interceptor.shouldInterceptRequest(requestId, req);
    } catch (_) {
      return null;
    }
  }

  static Future<HttpClientResponse?> invokeAfterResponse(String requestId, HttpClientInterceptor interceptor,
      HttpClientRequest req, HttpClientResponse resp) async {
    try {
      return await interceptor.afterResponse(requestId, req, resp);
    } catch (_) {
      return null;
    }
  }

  static Future<HttpClientResponse> convertDioToHttpClientResponse(Response response) async {
    final httpHeaders = <String, List<String>>{};
    response.headers.forEach((k, v) => httpHeaders[k] = List<String>.from(v));
    if (response.data is Uint8List && httpHeaders[HttpHeaders.contentLengthHeader] == null) {
      httpHeaders[HttpHeaders.contentLengthHeader] = ['${(response.data as Uint8List).length}'];
    }
    final hdr = createHttpHeaders(initialHeaders: httpHeaders);
    return HttpClientStreamResponse(
      Stream<List<int>>.value(response.data is Uint8List ? response.data as Uint8List : Uint8List(0)),
      statusCode: response.statusCode ?? HttpStatus.ok,
      initialHeaders: hdr,
    );
  }

  static Future<Response<Uint8List>> convertHttpClientResponseToDio(
      RequestOptions options, HttpClientResponse intercepted) async {
    final bytes = await consolidateHttpClientResponseBytes(intercepted);
    final headers = <String, List<String>>{};
    intercepted.headers.forEach((k, v) => headers[k] = List<String>.from(v));
    return Response<Uint8List>(
      requestOptions: options,
      data: Uint8List.fromList(bytes),
      statusCode: intercepted.statusCode,
      statusMessage: intercepted.reasonPhrase,
      headers: Headers.fromMap(headers),
    );
  }
}
