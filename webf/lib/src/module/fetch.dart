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

import 'package:flutter/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:dio/dio.dart' hide FormData;
import 'package:webf/foundation.dart';
import 'package:webf/html.dart';
import 'package:webf/launcher.dart';
import 'package:webf/module.dart';

const String emptyString = '';

class FetchModule extends WebFBaseModule {
  @override
  String get name => 'Fetch';

  bool _disposed = false;

  FetchModule(super.moduleManager);

  @override
  void dispose() {
    _disposed = true;
  }

  static final HttpClient _sharedHttpClient = (() {
    final client = createWebFHttpClient();
    client.userAgent = NavigatorModule.getUserAgent();
    return client;
  })();
  HttpClient get httpClient => _sharedHttpClient;
  CancelToken? _dioCancelToken;

  Uri _resolveUri(String input) {
    final Uri parsedUri = Uri.parse(input);

    if (moduleManager != null) {
      Uri base = Uri.parse(moduleManager!.controller.url);
      UriParser uriParser = moduleManager!.controller.uriParser!;
      return uriParser.resolve(base, parsedUri);
    } else {
      return parsedUri;
    }
  }

  static const String fallbackUserAgent = 'WebF';
  static String? _defaultUserAgent;
  static String _getDefaultUserAgent() {
    if (_defaultUserAgent == null) {
      try {
        _defaultUserAgent = NavigatorModule.getUserAgent();
      } catch (error) {
        // Ignore if dynamic library is missing.
        return fallbackUserAgent;
      }
    }
    return _defaultUserAgent!;
  }

  @visibleForTesting
  Future<HttpClientRequest> getRequest(Uri uri, String? method, Map? headers, data) {
    return httpClient.openUrl(method ?? 'GET', uri).then((HttpClientRequest request) {
      // Reset Kraken UA.
      request.headers.removeAll(HttpHeaders.userAgentHeader);
      request.headers.add(HttpHeaders.userAgentHeader, _getDefaultUserAgent());

      // Add additional headers.
      if (headers is Map<String, dynamic>) {
        for (MapEntry<String, dynamic> entry in headers.entries) {
          request.headers.add(entry.key, entry.value);
        }
      }

      // Set ContextID Header
      if (moduleManager != null) {
      request.headers.set(httpHeaderContext, moduleManager!.contextId.toString());
      }

      // Mark this as a Fetch/XHR request
      request.headers.set('X-WebF-Request-Type', 'fetch');

      if (data is Stream<List<int>>) {
        request.addStream(data);
      } else if (data is List<int>) {
        request.add(data);
      } else if (data != null) {
        // Treat as string as default.
        request.add(utf8.encode(data));
      }

      return request;
    });
  }

  HttpClientRequest? _currentRequest;

  void _abortRequest() {
    if (WebFControllerManager.instance.useDioForNetwork) {
      _dioCancelToken?.cancel('aborted');
      _dioCancelToken = null;
    } else {
      _currentRequest?.abort();
      _currentRequest = null;
    }
  }

  Future<dynamic> _invokeWithHttpRequest(String method, List<dynamic> params) async {
    Completer<dynamic> completer = Completer();

    Uri uri = _resolveUri(method);

    final body = params[0];
    final headers = params[1];
    final requestMethod = params[2] ?? 'GET';

    dynamic requestBody;

    if (body is FormDataBindings) {
      final formData = FormData.fromMap(body.storage);
      final stream = formData.finalize();
      final chunks = await stream.toList();
      requestBody = Uint8List.fromList(chunks.expand((e) => e).toList());
      headers['content-type'] = 'multipart/form-data; boundary=${formData.boundary}';
    } else if (body is NativeByteData) {
      requestBody = body.bytes;
    } else if (body is String) {
      requestBody = body;
    }

    handleError(Object error, StackTrace? stackTrace) {
      // Record the fetch error in LoadingState
      if (moduleManager != null) {
        final contextId = moduleManager!.contextId;
        final dumper = LoadingStateRegistry.instance.getDumper(contextId);
        // Use the resolved URI for error reporting
        dumper?.recordNetworkRequestError(
            uri.toString(),  // Use the resolved URI
            error.toString(),
            isXHR: true  // Mark as XHR/Fetch request
        );
      }
      completer.completeError(error, stackTrace);
    }

    if (uri.host.isEmpty) {
      // No host specified in URI.
      handleError('Failed to parse URL from $uri.', null);
    } else {
      HttpClientResponse? response;

      getRequest(uri, requestMethod, headers, requestBody).then((HttpClientRequest request) {
        if (_disposed) return Future.value(null);
        _currentRequest = request;
        return request.close();
      }).then((HttpClientResponse? res) {
        if (res == null) {
          return Future.value(null);
        } else {
          response = res;
          return consolidateHttpClientResponseBytes(res);
        }
      }).then((Uint8List? bytes) {
        if (bytes != null) {
          completer.complete([emptyString, response?.statusCode, bytes]);
        } else {
          throw FlutterError('Failed to read response.');
        }
      }).catchError(handleError);
    }

    return completer.future;
  }

  @override
  dynamic invoke(String method, List<dynamic> params) {
    if (method == 'abortRequest') {
      _abortRequest();
      return '';
    }

    // Use Dio path when globally enabled
    if (WebFControllerManager.instance.useDioForNetwork) {
      return _invokeWithDio(method, params);
    }

    return _invokeWithHttpRequest(method, params);
  }

  Future<dynamic> _invokeWithDio(String method, List<dynamic> params) async {
    Completer<dynamic> completer = Completer();

    final Uri uri = _resolveUri(method);
    final body = params[0];
    final headers = Map<String, dynamic>.from(params[1] ?? {});
    // Mark as XHR/fetch so downstream can treat accordingly.
    headers['X-WebF-Request-Type'] = 'fetch';
    final requestMethod = (params[2] ?? 'GET') as String;

    // Prepare body
    Uint8List? bodyBytes;
    if (body is FormDataBindings) {
      final formData = FormData.fromMap(body.storage);
      final stream = formData.finalize();
      final chunks = await stream.toList();
      bodyBytes = Uint8List.fromList(chunks.expand((e) => e).toList());
      headers['content-type'] = 'multipart/form-data; boundary=${formData.boundary}';
    } else if (body is NativeByteData) {
      bodyBytes = Uint8List.fromList(body.bytes);
    } else if (body is String) {
      bodyBytes = Uint8List.fromList(utf8.encode(body));
    }

    try {
      final dio = await getOrCreateWebFDio(
        contextId: moduleManager!.contextId,
        uri: uri,
        // Fetch semantics: resolve with Response for all HTTP statuses
        validateStatus: (_) => true,
      );
      _dioCancelToken = CancelToken();

      // LoadingState tracking for fetch via Dio
      final contextId = moduleManager?.contextId;
      final dumper = contextId != null ? LoadingStateRegistry.instance.getDumper(contextId) : null;
      // Record request start and request_sent stage
      try {
        if (dumper != null) {
          final headerStrings = <String, String>{};
          headers.forEach((k, v) => headerStrings[k.toString()] = v?.toString() ?? '');
          dumper.recordNetworkRequestStart(
            uri.toString(),
            method: requestMethod,
            headers: headerStrings,
            isXHR: true,
            protocol: uri.scheme,
            remotePort: uri.hasAuthority ? uri.port : null,
          );
          dumper.recordNetworkRequestStage(uri.toString(), LoadingState.stageRequestSent, metadata: {
            'method': requestMethod,
          });
        }
      } catch (_) {}

      bool responseStartedEmitted = false;

      final resp = await dio.requestUri<Uint8List>(
        uri,
        data: bodyBytes,
        options: Options(
          method: requestMethod,
          responseType: ResponseType.bytes,
          headers: headers,
          followRedirects: true,
          validateStatus: (_) => true,
        ),
        cancelToken: _dioCancelToken,
        onReceiveProgress: (received, total) {
          if (!responseStartedEmitted && received > 0) {
            responseStartedEmitted = true;
            try {
              dumper?.recordNetworkRequestStage(uri.toString(), LoadingState.stageResponseStarted, metadata: {
                'contentLength': total,
              });
            } catch (_) {}
          }
        },
      );

      // Emit response_started if no progress callback fired
      if (!responseStartedEmitted) {
        try {
          dumper?.recordNetworkRequestStage(uri.toString(), LoadingState.stageResponseStarted, metadata: {
            'statusCode': resp.statusCode,
            'contentLength': resp.data?.length ?? 0,
          });
        } catch (_) {}
      }

      // Cache hit info via interceptor
      try {
        if (resp.requestOptions.extra['webf_cache_hit'] == true) {
          dumper?.recordNetworkRequestCacheInfo(uri.toString(), cacheHit: true, cacheType: 'disk');
        }
      } catch (_) {}

      final bytes = resp.data ?? Uint8List(0);

      // Record response_received and completion
      try {
        dumper?.recordNetworkRequestStage(uri.toString(), LoadingState.stageResponseReceived, metadata: {
          'responseSize': bytes.length,
        });
        final responseHeaders = <String, String>{};
        String? contentType;
        resp.headers.forEach((name, values) {
          final headerValue = values.join(', ');
          responseHeaders[name] = headerValue;
          if (name.toLowerCase() == 'content-type') {
            contentType = headerValue;
          }
        });
        dumper?.recordNetworkRequestComplete(uri.toString(),
          statusCode: resp.statusCode ?? 0,
          responseSize: bytes.length,
          contentType: contentType,
          responseHeaders: responseHeaders,
        );
      } catch (_) {}

      completer.complete([emptyString, resp.statusCode ?? 0, bytes]);
    } catch (e, st) {
      // Record the fetch error in LoadingState
      if (moduleManager != null) {
        final contextId = moduleManager!.contextId;
        final dumper = LoadingStateRegistry.instance.getDumper(contextId);
        dumper?.recordNetworkRequestError(uri.toString(), e.toString(), isXHR: true);
      }
      if (e is DioException) {
        completer.completeError(e.error as Object);
      } else {
        completer.completeError(e, st);
      }
    }

    return completer.future;
  }
}
