/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes;
import 'package:webf/foundation.dart';

import '../launcher/controller.dart' show WebFController; // controller lookup by contextId

bool useWebFHttpCache = Platform.isLinux || Platform.isWindows || Platform.isAndroid;

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
    final uri = options.uri;
    
    // Check if this is a Fetch/XHR request and save to extras for tracking
    final isFetchRequest = options.headers['X-WebF-Request-Type'] == 'fetch';
    if (isFetchRequest) {
      options.extra['webf_is_xhr'] = true;
    }
    
    // Save context ID to extras for internal use
    if (contextId != null) {
      options.extra['webf_context_id'] = contextId;
    }
    
    // Remove internal WebF headers that shouldn't be sent to the server
    options.headers.remove('X-WebF-Request-Type');
    options.headers.remove(httpHeaderContext); // Remove x-context header

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
    } else {
      options.headers[HttpHeaders.cookieHeader] = '';
    }

    // Cache negotiation
    final ref = contextId != null ? getEntrypointUri(contextId) : uri;
    final origin = getOrigin(ref);
    options.extra[_kOriginKey] = origin;

    // Determine cache enablement by controller override or global mode.
    final ctrl = contextId != null ? WebFController.getControllerOfJSContextId(contextId) : null;
    final bool controllerWantsCache = ctrl?.networkOptions?.effectiveEnableHttpCache == true;
    final bool controllerForbidsCache = ctrl?.networkOptions?.effectiveEnableHttpCache == false;
    final bool globalCacheOn = (useWebFHttpCache && HttpCacheController.mode != HttpCacheMode.NO_CACHE);
    final bool cacheEnabled = controllerForbidsCache ? false : (controllerWantsCache ? true : globalCacheOn);

    if (cacheEnabled) {
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
    final ctrl = contextId != null ? WebFController.getControllerOfJSContextId(contextId) : null;
    final bool controllerWantsCache = ctrl?.networkOptions?.effectiveEnableHttpCache == true;
    final bool controllerForbidsCache = ctrl?.networkOptions?.effectiveEnableHttpCache == false;
    final bool globalCacheOn = (useWebFHttpCache && HttpCacheController.mode != HttpCacheMode.NO_CACHE);
    final bool cacheEnabled = controllerForbidsCache ? false : (controllerWantsCache ? true : globalCacheOn);

    if (cacheEnabled && response.statusCode == HttpStatus.notModified && cacheObject != null) {
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
    if (cacheEnabled && cacheObject != null && response.data is Uint8List && response.statusCode == HttpStatus.ok) {
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

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    handler.next(err);
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
