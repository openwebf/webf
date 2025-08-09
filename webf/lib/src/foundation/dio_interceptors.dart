import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes;

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
  WebFDioCacheCookieInterceptor({required this.contextId, this.ownerBundle, this.isXHR = false});

  final double? contextId;
  final WebFBundle? ownerBundle;
  final bool isXHR;

  static const _kCacheObjectKey = 'webf_cache_object';
  static const _kOriginKey = 'webf_origin';
  static const _kCacheHitKey = 'webf_cache_hit';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
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

    // Mark XHR requests
    if (isXHR) {
      options.headers['X-WebF-Request-Type'] = 'fetch';
    }

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

    if (uri.toString() == 'https://miracleplus.openwebf.com/js/chunk-vendors.8a6ffd16.js') {
      print(1);
    }

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
      await HttpCacheController.instance(origin)
          .interceptResponse(dummyReq, httpResp, cacheObject, native, ownerBundle);
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
