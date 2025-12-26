/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:webf/foundation.dart';

import '../launcher/controller.dart' show WebFController; // controller lookup for per-controller cache toggle

class ProxyHttpClientRequest implements HttpClientRequest {
  final HttpClient _nativeHttpClient;
  final String _method;
  final Uri _uri;

  HttpClientRequest? _backendRequest;
  WebFBundle? ownerBundle;

  // Saving all the data before calling real `close` to [HttpClientRequest].
  final List<int> _data = [];

  // Saving cookies.
  final List<Cookie> _cookies = <Cookie>[];

  // Saving request headers.
  final HttpHeaders _httpHeaders = createHttpHeaders();

  ProxyHttpClientRequest(String method, Uri uri, WebFHttpOverrides _, HttpClient nativeHttpClient)
      : _method = method.toUpperCase(),
        _uri = uri,
        _nativeHttpClient = nativeHttpClient;

  @override
  bool get bufferOutput => _backendRequest?.bufferOutput ?? true;

  @override
  set bufferOutput(bool value) {
    if (_backendRequest != null) {
      _backendRequest!.bufferOutput = value;
    }
  }

  @override
  int get contentLength => _backendRequest?.contentLength ?? -1;

  @override
  set contentLength(int value) {
    if (_backendRequest != null) {
      _backendRequest!.contentLength = value;
    }
  }

  @override
  bool get followRedirects => _backendRequest?.followRedirects ?? true;

  @override
  set followRedirects(bool value) {
    if (_backendRequest != null) {
      _backendRequest!.followRedirects = value;
    }
  }

  @override
  int get maxRedirects => _backendRequest?.maxRedirects ?? 5;

  @override
  set maxRedirects(int value) {
    if (_backendRequest != null) {
      _backendRequest!.maxRedirects = value;
    }
  }

  @override
  bool get persistentConnection => _backendRequest?.persistentConnection ?? true;

  @override
  set persistentConnection(bool value) {
    if (_backendRequest != null) {
      _backendRequest!.persistentConnection = value;
    }
  }

  @override
  Encoding get encoding => _backendRequest?.encoding ?? utf8;

  @override
  set encoding(Encoding encoding) {
    _backendRequest?.encoding = encoding;
  }

  @override
  void add(List<int> data) {
    _data.addAll(data);
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    // Consume stream.
    Completer<void> completer = Completer();
    stream.listen(_data.addAll, onError: completer.completeError, onDone: completer.complete, cancelOnError: true);
    return completer.future;
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    _backendRequest?.abort(exception, stackTrace);
  }

  @override
  void addError(error, [StackTrace? stackTrace]) {
    _backendRequest?.addError(error, stackTrace);
  }

  // Legacy HttpClientInterceptor hooks removed.

  static const String _httpHeadersOrigin = 'origin';

  @override
  Future<HttpClientResponse> close() async {
    double? contextId = WebFHttpOverrides.getContextHeader(headers);
    HttpClientRequest request = this;

    // Get the loading state dumper for tracking
    final dumper = contextId != null ? LoadingStateRegistry.instance.getDumper(contextId) : null;

    // Track request start if not already tracked by NetworkBundle
    if (dumper != null && ownerBundle == null) {
      final requestHeaders = <String, String>{};
      headers.forEach((name, values) {
        requestHeaders[name] = values.join(', ');
      });
      // Check if this is a Fetch/XHR request by looking for the marker header
      final isFetchRequest = headers.value('X-WebF-Request-Type') == 'fetch';
      dumper.recordNetworkRequestStart(
        _uri.toString(),
        method: _method,
        headers: requestHeaders,
        isXHR: isFetchRequest,
        protocol: _uri.scheme,
        remotePort: _uri.hasAuthority ? _uri.port : null,
      );
    }

    if (contextId != null) {
      // Standard reference: https://datatracker.ietf.org/doc/html/rfc7231#section-5.5.2
      //   Most general-purpose user agents do not send the
      //   Referer header field when the referring resource is a local "file" or
      //   "data" URI.  A user agent MUST NOT send a Referer header field in an
      //   unsecured HTTP request if the referring page was received with a
      //   secure protocol.
      Uri referrer = getEntrypointUri(contextId);
      bool isUnsafe = referrer.isScheme('https') && !uri.isScheme('https');
      bool isLocalRequest = uri.isScheme('file') || uri.isScheme('data') || uri.isScheme('assets');
      if (!isUnsafe && !isLocalRequest) {
        headers.set(HttpHeaders.refererHeader, referrer.toString());
      }

      // Standard reference: https://fetch.spec.whatwg.org/#origin-header
      // `if request’s method is neither `GET` nor `HEAD`, then follow referrer policy to append origin.`
      // @TODO: Apply referrer policy.
      String origin = getOrigin(referrer);
      if (method != 'GET' && method != 'HEAD') {
        headers.set(_httpHeadersOrigin, origin);
      }

      // Step 1: Prepare request (no custom interceptor).
      await CookieManager.loadForRequest(_uri, request.cookies);

      // Step 2: Handle cache-control and expires,
      //        if hit, no need to open request.
      HttpCacheObject? cacheObject;
      // Per-controller cache toggle: allow a controller to override global cache mode.
      bool cacheEnabled = true;
      final ctrl = WebFController.getControllerOfJSContextId(contextId);
      final bool controllerWantsCache = ctrl?.networkOptions?.effectiveEnableHttpCache == true;
      final bool controllerForbidsCache = ctrl?.networkOptions?.effectiveEnableHttpCache == false;
      final bool globalCacheOn = HttpCacheController.mode != HttpCacheMode.NO_CACHE;
      cacheEnabled = controllerForbidsCache ? false : (controllerWantsCache ? true : globalCacheOn);

      if (cacheEnabled) {
        HttpCacheController cacheController = HttpCacheController.instance(origin);
        cacheObject = await cacheController.getCacheObject(request.uri);
        if (cacheObject.hitLocalCache(request)) {
          HttpClientResponse? cacheResponse = await cacheObject.toHttpClientResponse(_nativeHttpClient);
          ownerBundle?.setLoadingFromCache();
          if (cacheResponse != null) {
            // Track cache hit
            dumper?.recordNetworkRequestCacheInfo(_uri.toString(),
              cacheHit: true,
              cacheType: 'disk',
              cacheEntryTime: cacheObject.lastUsed,
              cacheHeaders: {},
            );

            // Track completion for cache hit
            final responseHeaders = <String, String>{};
            String? contentType;
            cacheResponse.headers.forEach((name, values) {
              final headerValue = values.join(', ');
              responseHeaders[name] = headerValue;
              if (name.toLowerCase() == 'content-type') {
                contentType = headerValue;
              }
            });
            dumper?.recordNetworkRequestComplete(_uri.toString(),
              statusCode: cacheResponse.statusCode,
              responseHeaders: responseHeaders,
              contentType: contentType,
            );

            return cacheResponse;
          }
        }

        // Step 3: Handle negotiate cache request header.
        if (cacheObject.valid &&
            headers.ifModifiedSince == null &&
            headers.value(HttpHeaders.ifNoneMatchHeader) == null) {
          // ETag has higher priority of lastModified.
          if (cacheObject.eTag != null) {
            headers.set(HttpHeaders.ifNoneMatchHeader, cacheObject.eTag!);
          } else if (cacheObject.lastModified != null) {
            headers.set(HttpHeaders.ifModifiedSinceHeader, HttpDate.format(cacheObject.lastModified!));
          }
        }
      }

      request = await _createBackendClientRequest();
      // Send the real data to backend client.
      if (_data.isNotEmpty) {
        await request.addStream(Stream.value(_data));
        _data.clear();
      }

      // Step 4: Send network request
      late HttpClientResponse response;
      bool hitNegotiateCache = false;

      // If cache only, but no cache hit (we'd have returned earlier), abort.
      if (HttpCacheController.mode == HttpCacheMode.CACHE_ONLY) {
        final errorMsg = 'CACHE_ONLY mode but no cache hit';
        // Check if this is a Fetch/XHR request by looking for the marker header
        final isFetchRequest = headers.value('X-WebF-Request-Type') == 'fetch';
        dumper?.recordNetworkRequestError(_uri.toString(), errorMsg, isXHR: isFetchRequest);
        throw FlutterError('HttpCacheMode is CACHE_ONLY, but no cache hit for $uri');
      }

      // Handle response and 304 negotiation
      HttpClientResponse rawResponse;
      try {
        rawResponse = await request.close();
        // Track redirects if any occurred
        if (rawResponse.redirects.isNotEmpty && dumper != null && ownerBundle == null) {
          for (final redirect in rawResponse.redirects) {
            dumper.recordNetworkRequestRedirect(
              _uri.toString(),
              redirect.location.toString(),
              statusCode: redirect.statusCode,
            );
          }
        }
      } catch (e) {
        // If still failing, log and rethrow
        networkLogger.warning('Error closing HTTP request for $uri', e);
        // Check if this is a Fetch/XHR request by looking for the marker header
        final isFetchRequest = headers.value('X-WebF-Request-Type') == 'fetch';
        dumper?.recordNetworkRequestError(_uri.toString(), e.toString(), isXHR: isFetchRequest);
        rethrow;
      }
      response = cacheObject == null
          ? rawResponse
          : await HttpCacheController.instance(origin)
              .interceptResponse(request, rawResponse, cacheObject, _nativeHttpClient, ownerBundle);
      hitNegotiateCache = rawResponse != response;

      // Step 5: Save cookies from response.
      await CookieManager.saveFromResponseRaw(uri, response.headers[HttpHeaders.setCookieHeader]);

      // Track 304 Not Modified response
      if (hitNegotiateCache && response.statusCode == HttpStatus.notModified) {
        dumper?.recordNetworkRequestCacheInfo(_uri.toString(),
          cacheHit: true,
          cacheType: 'network_validated',
          cacheHeaders: {},
        );
      }

      // Track redirects from the final response if any occurred
      if (response.redirects.isNotEmpty && dumper != null && ownerBundle == null) {
        for (final redirect in response.redirects) {
          dumper.recordNetworkRequestRedirect(
            _uri.toString(),
            redirect.location.toString(),
            statusCode: redirect.statusCode,
          );
        }
      }

      // Track final response
      if (dumper != null && ownerBundle == null) {
        final responseHeaders = <String, String>{};
        String? contentType;
        response.headers.forEach((name, values) {
          final headerValue = values.join(', ');
          responseHeaders[name] = headerValue;
          if (name.toLowerCase() == 'content-type') {
            contentType = headerValue;
          }
        });
        dumper.recordNetworkRequestComplete(_uri.toString(),
          statusCode: response.statusCode,
          responseHeaders: responseHeaders,
          contentType: contentType,
        );
      }

      // Check match cache, and then return cache.
      if (hitNegotiateCache) {
        return Future.value(response);
      }

      if (cacheObject != null) {
        // Step 6: Intercept response by cache controller (handle 304).
        // Note: No need to negotiate cache here, this is final response, hit or not hit.
        return HttpCacheController.instance(origin)
            .interceptResponse(request, response, cacheObject, _nativeHttpClient, ownerBundle);
      } else {
        return response;
      }
    } else {
      request = await _createBackendClientRequest();
      // Not using request.add, because large data will cause core exception.
      if (_data.isNotEmpty) {
        await request.addStream(Stream.value(_data));
        _data.clear();
      }
    }

    return await request.close();
  }

  Future<HttpClientRequest> _createBackendClientRequest() async {
    HttpClientRequest backendRequest;

    // Track connection stages
    final contextId = WebFHttpOverrides.getContextHeader(headers);
    final dumper = contextId != null ? LoadingStateRegistry.instance.getDumper(contextId) : null;

    try {
      // Track DNS and TCP stages for new connections
      if (dumper != null && ownerBundle == null) {
        dumper.recordNetworkRequestStage(_uri.toString(), 'dns_lookup', metadata: {
          'host': _uri.host,
        });
      }

      backendRequest = await _nativeHttpClient.openUrl(_method, _uri);

      if (dumper != null && ownerBundle == null) {
        dumper.recordNetworkRequestStage(_uri.toString(), 'tcp_connection', metadata: {
          'host': _uri.host,
          'port': _uri.port.toString(),
          'scheme': _uri.scheme,
        });

        // Track TLS handshake for HTTPS
        if (_uri.scheme == 'https') {
          dumper.recordNetworkRequestStage(_uri.toString(), 'tls_handshake', metadata: {
            'host': _uri.host,
          });
        }
      }
    } catch (e) {
      // Handle "Bad file descriptor" and other socket errors
      if (e is SocketException || e.toString().contains('Bad file descriptor')) {
        networkLogger.warning('Socket error when opening URL $_uri', e);
        try {
          backendRequest = await _nativeHttpClient.openUrl(_method, _uri);
          networkLogger.info('Successfully recovered with new HTTP client for $_uri');
        } catch (retryError) {
          networkLogger.warning('Failed to recover with new HTTP client for $_uri', retryError);
          rethrow;
        }
      } else {
        rethrow;
      }
    }

    if (_cookies.isNotEmpty) {
      backendRequest.cookies.addAll(_cookies);
      _cookies.clear();
    }

    // Forward all headers except internal WebF headers
    _httpHeaders.forEach((String name, List<String> values) {
      // Filter out internal WebF headers that shouldn't be sent to the server
      final lowerName = name.toLowerCase();
      if (lowerName != 'x-webf-request-type' && lowerName != 'x-context') {
        backendRequest.headers.set(name, values);
      }
    });
    _httpHeaders.clear();

    // Assign configs for backend request.
    backendRequest
      ..bufferOutput = bufferOutput
      ..contentLength = contentLength
      ..followRedirects = followRedirects
      ..persistentConnection = persistentConnection
      ..maxRedirects = maxRedirects;

    _backendRequest = backendRequest;
    return backendRequest;
  }

  @override
  HttpConnectionInfo? get connectionInfo => _backendRequest?.connectionInfo;

  @override
  List<Cookie> get cookies => _backendRequest?.cookies ?? _cookies;

  List get data => _data;

  @override
  Future<HttpClientResponse> get done async {
    if (_backendRequest == null) {
      await _createBackendClientRequest();
    }
    return _backendRequest!.done;
  }

  @override
  Future flush() async {
    if (_backendRequest == null) {
      await _createBackendClientRequest();
    }
    return _backendRequest!.flush();
  }

  @override
  HttpHeaders get headers => _backendRequest?.headers ?? _httpHeaders;

  @override
  String get method => _method;

  @override
  Uri get uri => _uri;

  @override
  void write(Object? obj) {
    String string = '$obj';
    if (string.isEmpty) return;

    _data.addAll(Uint8List.fromList(
      utf8.encode(string),
    ));
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    Iterator iterator = objects.iterator;
    if (!iterator.moveNext()) return;
    if (separator.isEmpty) {
      do {
        write(iterator.current);
      } while (iterator.moveNext());
    } else {
      write(iterator.current);
      while (iterator.moveNext()) {
        write(separator);
        write(iterator.current);
      }
    }
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    write(object);
    write('\n');
  }
}
