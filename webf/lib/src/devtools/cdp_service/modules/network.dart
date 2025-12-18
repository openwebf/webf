/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/devtools/panel/network_store.dart';

class InspectNetworkModule extends UIInspectorModule {
  InspectNetworkModule(super.devtoolsService) {
    _maybeRegisterDioInterceptor();
  }

  void _maybeRegisterDioInterceptor() {
    // Only install Dio interceptor when global Dio networking is enabled
    final useDio = WebFControllerManager.instance.useDioForNetwork;
    if (!useDio) return;

    final context = devtoolsService.context;
    final controller = context?.getController();
    if (controller == null) return;

    final contextId = controller.view.contextId;
    // Register an installer with the Dio pool so it applies immediately if Dio exists,
    // and also for any future Dio creations for this context.
    registerWebFDioInterceptorInstaller(contextId, (dio) {
      final alreadyAdded = dio.interceptors.any((i) => i is _InspectDioInterceptor);
      if (!alreadyAdded) {
        dio.interceptors.add(_InspectDioInterceptor(this, contextId));
      }
    });
  }

  @override
  String get name => 'Network';

  final HttpCacheMode _httpCacheOriginalMode = HttpCacheController.mode;
  final int _initialTimestamp = DateTime.now().millisecondsSinceEpoch;

  // RequestId to data buffer.
  final Map<String, Uint8List> _responseBuffers = {};

  // Helper for request ID generation in Dio path
  int _dioRequestIdCounter = 0;

  String _nextDioRequestId() {
    _dioRequestIdCounter++;
    return 'dio_${_dioRequestIdCounter}_${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  void onEnabled() {
    // On Network.enable, replay past requests for this controller.
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] Network.enable');
    }
    _replayPastRequests();
  }

  // Helper and state for HttpClient-originated requests (non-Dio)
  int _httpRequestIdCounter = 0;

  String _nextHttpRequestId() {
    _httpRequestIdCounter++;
    return 'http_${_httpRequestIdCounter}_${DateTime.now().microsecondsSinceEpoch}';
  }

  String _guessTypeFromPath(String path) {
    if (path.endsWith('.js') || path.endsWith('.mjs')) return 'Script';
    if (path.endsWith('.css')) return 'Stylesheet';
    if (path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp') ||
        path.endsWith('.svg') ||
        path.endsWith('.ico')) {
      return 'Image';
    }
    if (path.endsWith('.html') || path.endsWith('.htm') || path.endsWith('/')) return 'Document';
    return 'Fetch';
  }

  Map<String, List<String>> _headersToMultiMap(Map<String, String>? headers) {
    final map = <String, List<String>>{};
    headers?.forEach((k, v) => map[k] = [v]);
    return map;
  }

  /// Public API for non-Dio networking to report a request start to DevTools.
  /// Returns a generated requestId to be used for subsequent events.
  String reportHttpClientRequestStart({
    required double contextId,
    required Uri uri,
    String method = 'GET',
    Map<String, String>? headers,
    List<int> data = const <int>[],
  }) {
    final requestId = _nextHttpRequestId();

    // Track in NetworkStore so DevTools panel can render the row
    final networkRequest = NetworkRequest(
      requestId: requestId,
      url: uri.toString(),
      method: method,
      requestHeaders: _headersToMultiMap(headers),
      requestData: List<int>.from(data),
      startTime: DateTime.now(),
    );
    NetworkStore().addRequest(contextId.toInt(), networkRequest);

    // Emit CDP requestWillBeSent
    sendEventToFrontend(NetworkRequestWillBeSentEvent(
      requestId: requestId,
      loaderId: contextId.toString(),
      requestMethod: method,
      url: uri.toString(),
      headers: _headersToMultiMap(headers),
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000,
      data: data,
    ));

    // Optionally emit extra info
    final extraHeaders = <String, List<String>>{
      ':authority': [uri.authority],
      ':method': [method],
      ':path': [uri.path],
      ':scheme': [uri.scheme],
    };
    sendEventToFrontend(NetworkRequestWillBeSendExtraInfo(
      associatedCookies: const [],
      clientSecurityState: const {
        'initiatorIsSecureContext': true,
        'initiatorIPAddressSpace': 'Local',
        'privateNetworkRequestPolicy': 'PreflightWarn'
      },
      connectTiming: {
        'requestTime': (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000,
      },
      headers: {
        ..._headersToMultiMap(headers),
        ...extraHeaders,
      },
      siteHasCookieInOtherPartition: false,
      requestId: requestId,
    ));

    return requestId;
  }

  /// Public API for non-Dio networking to report a request failure to DevTools.
  void reportHttpClientLoadingFailed({
    required String requestId,
    required double contextId,
    required Uri uri,
    required String errorText,
    bool canceled = false,
  }) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000;
    final type = _guessTypeFromPath(uri.path);

    // Emit CDP loadingFailed
    sendEventToFrontend(NetworkLoadingFailedEvent(
      requestId: requestId,
      timestamp: timestamp,
      type: type,
      errorText: errorText,
      canceled: canceled,
    ));

    // Update NetworkStore for UI
    NetworkStore().updateRequest(
      requestId,
      statusCode: 0,
      statusText: errorText,
      mimeType: 'text/plain',
      responseBody: Uint8List(0),
      endTime: DateTime.now(),
      contentLength: 0,
      fromCache: false,
      remoteIPAddress: uri.host,
      remotePort: uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80),
    );
  }

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] Network.$method');
    }
    switch (method) {
      case 'setCacheDisabled':
        bool cacheDisabled = params?['cacheDisabled'];
        if (cacheDisabled) {
          HttpCacheController.mode = HttpCacheMode.NO_CACHE;
        } else {
          HttpCacheController.mode = _httpCacheOriginalMode;
        }
        sendToFrontend(id, null);
        break;
      case 'getResponseBody':
        String requestId = params!['requestId'];
        Uint8List? buffer = _responseBuffers[requestId];
        // Decide whether to return text or base64 based on MIME type
        final req = NetworkStore().getRequestById(requestId);
        final mime = req?.mimeType?.toLowerCase();
        final isText = _isTextMimeType(mime);
        String bodyStr = '';
        bool base64 = false;
        if (buffer != null) {
          if (isText) {
            bodyStr = utf8.decode(buffer, allowMalformed: true);
            base64 = false;
          } else {
            bodyStr = base64Encode(buffer);
            base64 = true;
          }
        }
        sendToFrontend(
            id,
            JSONEncodableMap({
              'body': bodyStr,
              'base64Encoded': base64,
            }));
        break;

      case 'setAttachDebugStack':
        sendToFrontend(id, JSONEncodableMap({}));
        break;

      case 'clearAcceptedEncodingsOverride':
        sendToFrontend(id, JSONEncodableMap({}));
        break;
    }
  }

  @override
  void onContextChanged() {
    super.onContextChanged();
    // Reinitialize Dio interceptor when context changes
    _maybeRegisterDioInterceptor();
  }

  // Legacy HttpClientInterceptor support has been removed. Network inspection now
  // relies on Dio interceptors when Dio networking is enabled.

  void _replayPastRequests() {
    final context = devtoolsService.context;
    final controller = context?.getController();
    if (controller == null || !controller.isFlutterAttached) return;
    final ctxId = controller.view.contextId.toInt();
    final requests = List<NetworkRequest>.from(NetworkStore().getRequestsForContext(ctxId));
    if (requests.isEmpty) return;

    // Use earliest start as base for timestamps
    final baseMs = requests.map((r) => r.startTime.millisecondsSinceEpoch).reduce((a, b) => a < b ? a : b);
    requests.sort((a, b) => a.startTime.compareTo(b.startTime));

    for (final req in requests) {
      final requestId = req.requestId;
      final loaderId = controller.view.contextId.toString();
      final uri = Uri.tryParse(req.url);
      if (uri == null) continue;

      final tsStart = (req.startTime.millisecondsSinceEpoch - baseMs) / 1000;
      final headers = req.requestHeaders;
      final postData = req.requestData;

      // Emit requestWillBeSent
      sendEventToFrontend(NetworkRequestWillBeSentEvent(
        requestId: requestId,
        loaderId: loaderId,
        requestMethod: req.method,
        url: req.url,
        headers: headers,
        timestamp: tsStart,
        data: postData,
      ));

      // If request completed, emit responseReceived/loadingFinished or loadingFailed
      if (req.isComplete) {
        final respBytes = _responseBuffers[requestId] ?? req.responseBody ?? Uint8List(0);
        String mime = (req.mimeType ?? '').isNotEmpty ? req.mimeType! : 'text/plain';
        if ((mime == 'text/plain' || mime == 'application/octet-stream') && respBytes.isNotEmpty) {
          final sniff = _sniffImageMime(respBytes);
          if (sniff != null) mime = sniff;
        }

        final type = mime.startsWith('image/') ? 'Image' : _guessTypeFromPath(uri.path);
        final tsEnd = (req.endTime!.millisecondsSinceEpoch - baseMs) / 1000;

        if (req.statusCode != null && req.statusCode != 0) {
          // Treat as a completed HTTP response
          final responseHeaders = req.responseHeaders ?? <String, List<String>>{};
          sendEventToFrontend(NetworkResponseReceivedEvent(
            requestId: requestId,
            loaderId: loaderId,
            url: req.url,
            headers: responseHeaders,
            status: req.statusCode!,
            statusText: req.statusText ?? '',
            mimeType: mime,
            remoteIPAddress: uri.host,
            remotePort: uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80),
            fromDiskCache: req.fromCache ?? false,
            encodedDataLength: respBytes.length,
            protocol: uri.scheme,
            type: type,
            timestamp: tsEnd,
          ));

          sendEventToFrontend(NetworkLoadingFinishedEvent(
            requestId: requestId,
            contentLength: respBytes.length,
            timestamp: tsEnd,
          ));
        } else {
          // Failure case
          sendEventToFrontend(NetworkLoadingFailedEvent(
            requestId: requestId,
            timestamp: tsEnd,
            type: type,
            errorText: req.statusText ?? 'Request failed',
            canceled: false,
          ));
        }
      }
    }
  }
}

bool _isTextMimeType(String? mime) {
  if (mime == null) return false;
  if (mime.startsWith('text/')) return true;
  return mime.contains('json') ||
      mime.contains('+json') ||
      mime.contains('xml') ||
      mime.contains('+xml') ||
      mime.contains('html') ||
      mime.contains('javascript') ||
      mime.contains('css') ||
      mime.contains('csv') ||
      mime.contains('urlencoded');
}

class _InspectDioInterceptor extends InterceptorsWrapper {
  _InspectDioInterceptor(this.module, this.contextId);

  final InspectNetworkModule module;
  final double contextId;

  static const _kInspectorRequestId = 'webf_inspector_request_id';

  Map<String, List<String>> _headersToMultiMap(Map<String, dynamic> headers) {
    final map = <String, List<String>>{};
    headers.forEach((k, v) {
      map[k.toString()] = [v?.toString() ?? ''];
    });
    return map;
  }

  List<int> _extractRequestBody(dynamic data) {
    if (data == null) return const <int>[];
    if (data is Uint8List) return data;
    if (data is List<int>) return data;
    if (data is String) return utf8.encode(data);
    return const <int>[];
  }

  String _guessTypeFromPath(String path) {
    if (path.endsWith('.js') || path.endsWith('.mjs')) return 'Script';
    if (path.endsWith('.css')) return 'Stylesheet';
    if (path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp') ||
        path.endsWith('.svg') ||
        path.endsWith('.ico')) {
      return 'Image';
    }
    if (path.endsWith('.html') || path.endsWith('.htm') || path.endsWith('/')) return 'Document';
    return 'Fetch';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = module._nextDioRequestId();
    options.extra[_kInspectorRequestId] = requestId;

    final dataBytes = _extractRequestBody(options.data);

    // Store request in NetworkStore
    final networkRequest = NetworkRequest(
      requestId: requestId,
      url: options.uri.toString(),
      method: options.method,
      requestHeaders: _headersToMultiMap(options.headers),
      requestData: List<int>.from(dataBytes),
      startTime: DateTime.now(),
    );
    NetworkStore().addRequest(contextId.toInt(), networkRequest);

    // Send request events
    module.sendEventToFrontend(NetworkRequestWillBeSentEvent(
      requestId: requestId,
      loaderId: contextId.toString(),
      requestMethod: options.method,
      url: options.uri.toString(),
      headers: _headersToMultiMap(options.headers),
      timestamp: (DateTime.now().millisecondsSinceEpoch - module._initialTimestamp) / 1000,
      data: dataBytes,
    ));

    final extraHeaders = <String, List<String>>{
      ':authority': [options.uri.authority],
      ':method': [options.method],
      ':path': [options.uri.path],
      ':scheme': [options.uri.scheme],
    };

    final ts = (DateTime.now().millisecondsSinceEpoch - module._initialTimestamp) / 1000;
    module.sendEventToFrontend(NetworkRequestWillBeSendExtraInfo(
      associatedCookies: const [],
      clientSecurityState: const {
        'initiatorIsSecureContext': true,
        'initiatorIPAddressSpace': 'Local',
        'privateNetworkRequestPolicy': 'PreflightWarn'
      },
      connectTiming: {'requestTime': ts},
      headers: {
        ..._headersToMultiMap(options.headers),
        ...extraHeaders,
      },
      siteHasCookieInOtherPartition: false,
      requestId: requestId,
    ));

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final requestId = (options.extra[_kInspectorRequestId] as String?) ?? module._nextDioRequestId();
    final bytes = response.data is Uint8List ? response.data as Uint8List : Uint8List(0);

    final headersMap = <String, List<String>>{};
    response.headers.forEach((k, v) => headersMap[k] = List<String>.from(v));

    final urlStr = options.uri.toString();
    String mimeType = response.headers.value(HttpHeaders.contentTypeHeader) ?? 'text/plain';
    // Auto-detect common image types if content-type is missing or generic
    if ((mimeType == 'text/plain' || mimeType == 'application/octet-stream' || mimeType.isEmpty) && bytes.isNotEmpty) {
      final sniffed = _sniffImageMime(bytes);
      if (sniffed != null) {
        mimeType = sniffed;
      }
    }
    final remoteIp = options.uri.host; // Best effort; real IP not exposed by Dio
    final remotePort = options.uri.hasPort ? options.uri.port : (options.uri.scheme == 'https' ? 443 : 80);
    final fromDiskCache = options.extra['webf_cache_hit'] == true;
    final encodedLen = bytes.length;
    final protocol = options.uri.scheme;
    String type = _guessTypeFromPath(options.uri.path);
    if (type == 'Fetch' && mimeType.startsWith('image/')) {
      type = 'Image';
    }
    final timestamp = (DateTime.now().millisecondsSinceEpoch - module._initialTimestamp) / 1000;

    module.sendEventToFrontend(NetworkResponseReceivedEvent(
      requestId: requestId,
      loaderId: contextId.toString(),
      url: urlStr,
      headers: headersMap,
      status: response.statusCode ?? 0,
      statusText: response.statusMessage ?? '',
      mimeType: mimeType,
      remoteIPAddress: remoteIp,
      remotePort: remotePort,
      fromDiskCache: fromDiskCache,
      encodedDataLength: encodedLen,
      protocol: protocol,
      type: type,
      timestamp: timestamp,
    ));

    module.sendEventToFrontend(NetworkLoadingFinishedEvent(
      requestId: requestId,
      contentLength: encodedLen,
      timestamp: timestamp,
    ));

    // Store response body for getResponseBody
    module._responseBuffers[requestId] = bytes;

    // Update NetworkStore
    NetworkStore().updateRequest(
      requestId,
      responseHeaders: headersMap,
      statusCode: response.statusCode ?? 0,
      statusText: response.statusMessage ?? '',
      mimeType: mimeType,
      responseBody: bytes,
      endTime: DateTime.now(),
      contentLength: encodedLen,
      fromCache: fromDiskCache,
      remoteIPAddress: remoteIp,
      remotePort: remotePort,
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // For errors, still produce CDP events. Distinguish HTTP error responses vs. network failures.
    final options = err.requestOptions;
    final requestId = (options.extra[_kInspectorRequestId] as String?) ?? module._nextDioRequestId();

    if (err.type == DioExceptionType.badResponse && err.response != null) {
      // HTTP error (4xx/5xx or others rejected by validateStatus): emit responseReceived + loadingFinished
      final response = err.response!;
      final headersMap = <String, List<String>>{};
      response.headers.forEach((k, v) => headersMap[k] = List<String>.from(v));

      // Convert body to bytes if present, for body retrieval and size reporting
      Uint8List bytes;
      final body = response.data;
      if (body == null) {
        bytes = Uint8List(0);
      } else if (body is Uint8List) {
        bytes = body;
      } else if (body is List<int>) {
        bytes = Uint8List.fromList(body);
      } else if (body is String) {
        bytes = Uint8List.fromList(utf8.encode(body));
      } else {
        // Best-effort JSON encoding
        try {
          bytes = Uint8List.fromList(utf8.encode(jsonEncode(body)));
        } catch (_) {
          bytes = Uint8List(0);
        }
      }

      final urlStr = options.uri.toString();
      String mimeType = response.headers.value(HttpHeaders.contentTypeHeader) ?? 'text/plain';
      if ((mimeType == 'text/plain' || mimeType == 'application/octet-stream' || mimeType.isEmpty) &&
          bytes.isNotEmpty) {
        final sniffed = _sniffImageMime(bytes);
        if (sniffed != null) {
          mimeType = sniffed;
        }
      }
      final remoteIp = options.uri.host;
      final remotePort = options.uri.hasPort ? options.uri.port : (options.uri.scheme == 'https' ? 443 : 80);
      final encodedLen = bytes.length;
      final protocol = options.uri.scheme;
      String type = _guessTypeFromPath(options.uri.path);
      if (type == 'Fetch' && mimeType.startsWith('image/')) {
        type = 'Image';
      }
      final timestamp = (DateTime.now().millisecondsSinceEpoch - module._initialTimestamp) / 1000;

      module.sendEventToFrontend(NetworkResponseReceivedEvent(
        requestId: requestId,
        loaderId: contextId.toString(),
        url: urlStr,
        headers: headersMap,
        status: response.statusCode ?? 0,
        statusText: response.statusMessage ?? '',
        mimeType: mimeType,
        remoteIPAddress: remoteIp,
        remotePort: remotePort,
        fromDiskCache: false,
        encodedDataLength: encodedLen,
        protocol: protocol,
        type: type,
        timestamp: timestamp,
      ));

      module.sendEventToFrontend(NetworkLoadingFinishedEvent(
        requestId: requestId,
        contentLength: encodedLen,
        timestamp: timestamp,
      ));

      // Store response body for getResponseBody and update NetworkStore
      module._responseBuffers[requestId] = bytes;
      NetworkStore().updateRequest(
        requestId,
        responseHeaders: headersMap,
        statusCode: response.statusCode ?? 0,
        statusText: response.statusMessage ?? '',
        mimeType: mimeType,
        responseBody: bytes,
        endTime: DateTime.now(),
        contentLength: encodedLen,
        fromCache: false,
        remoteIPAddress: remoteIp,
        remotePort: remotePort,
      );
    } else {
      // Real network failure (DNS, timeout, cancel, etc.): emit loadingFailed
      final timestamp = (DateTime.now().millisecondsSinceEpoch - module._initialTimestamp) / 1000;
      final type = _guessTypeFromPath(options.uri.path);
      final errorText = err.message ?? err.error?.toString() ?? 'Request failed';
      module.sendEventToFrontend(NetworkLoadingFailedEvent(
        requestId: requestId,
        timestamp: timestamp,
        type: type,
        errorText: errorText,
        canceled: err.type == DioExceptionType.cancel,
      ));

      // Update NetworkStore minimal info
      NetworkStore().updateRequest(
        requestId,
        statusCode: 0,
        statusText: errorText,
        mimeType: 'text/plain',
        responseBody: Uint8List(0),
        endTime: DateTime.now(),
        contentLength: 0,
        fromCache: false,
        remoteIPAddress: options.uri.host,
        remotePort: options.uri.hasPort ? options.uri.port : (options.uri.scheme == 'https' ? 443 : 80),
      );
    }

    handler.next(err);
  }
}

// Sniff common image binary signatures (PNG, JPEG) for better DevTools previews.
String? _sniffImageMime(Uint8List bytes) {
  if (bytes.length >= 8) {
    // PNG signature: 89 50 4E 47 0D 0A 1A 0A
    const pngSig = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    bool isPng = true;
    for (int i = 0; i < pngSig.length; i++) {
      if (bytes[i] != pngSig[i]) {
        isPng = false;
        break;
      }
    }
    if (isPng) return 'image/png';
  }
  if (bytes.length >= 3) {
    // JPEG signature: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
  }
  return null;
}

class NetworkRequestWillBeSentEvent extends InspectorEvent {
  final String requestId;
  final String loaderId;
  final String url;
  final String requestMethod;
  final Map<String, List<String>> headers;
  final double timestamp;
  final List<int> data;

  NetworkRequestWillBeSentEvent({
    required this.requestId,
    required this.loaderId,
    required this.requestMethod,
    required this.url,
    required this.headers,
    required this.timestamp,
    required this.data,
  });

  @override
  String get method => 'Network.requestWillBeSent';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'requestId': requestId,
        'loaderId': loaderId,
        'documentURL': '',
        'request': {
          'url': url,
          'method': requestMethod,
          'headers': headers.map((key, value) => MapEntry(key, value.join(''))),
          'initialPriority': 'Medium',
          'referrerPolicy': '',

          'hasPostData': data.isNotEmpty,
          'postData': String.fromCharCodes(data),
          // 'mixedContentType': 'none',
          // 'isSameSite': false
        },
        'timestamp': timestamp,
        'wallTime': DateTime.now().millisecondsSinceEpoch / 1000,
        'initiator': {
          'type': 'script',
          'lineNumber': 0,
          'columnNumber': 0,
        },
        'redirectHasExtraInfo': false,
        // 'type': 'XHR',
        // 'hasUserGesture': false,
        //
        // 'frameId': '',
      });
}

class NetworkResponseReceivedEvent extends InspectorEvent {
  final String requestId;
  final String loaderId;
  final String url;
  final Map<String, List<String>> headers;
  final int status;
  final String statusText;
  final String mimeType;
  final String remoteIPAddress;
  final int remotePort;
  final bool fromDiskCache;
  final int encodedDataLength;
  final String protocol;
  final String type;
  final double timestamp;

  NetworkResponseReceivedEvent({
    required this.requestId,
    required this.loaderId,
    required this.url,
    required this.headers,
    required this.status,
    required this.statusText,
    required this.mimeType,
    required this.remoteIPAddress,
    required this.remotePort,
    required this.fromDiskCache,
    required this.encodedDataLength,
    required this.protocol,
    required this.type,
    required this.timestamp,
  });

  @override
  String get method => 'Network.responseReceived';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'requestId': requestId,
        'loaderId': loaderId,
        'timestamp': timestamp,
        'type': type,
        'response': {
          'url': url,
          'status': status,
          'statusText': statusText,
          'headers': headers.map((key, value) => MapEntry(key, value.join(''))),
          'mimeType': mimeType,
          'connectionReused': false,
          'connectionId': 0,
          'remoteIPAddress': remoteIPAddress,
          'remotePort': remotePort,
          'fromDiskCache': fromDiskCache,
          'encodedDataLength': encodedDataLength,
          'protocol': protocol,
          'securityState': 'secure',
        },
        'hasExtraInfo': false,
      });
}

class NetworkLoadingFinishedEvent extends InspectorEvent {
  final String requestId;
  final int contentLength;
  final double timestamp;

  NetworkLoadingFinishedEvent({required this.requestId, required this.contentLength, required this.timestamp});

  @override
  String get method => 'Network.loadingFinished';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'requestId': requestId,
        'timestamp': timestamp,
        'encodedDataLength': contentLength,
      });
}

class NetworkLoadingFailedEvent extends InspectorEvent {
  final String requestId;
  final double timestamp;
  final String type;
  final String errorText;
  final bool canceled;

  NetworkLoadingFailedEvent({
    required this.requestId,
    required this.timestamp,
    required this.type,
    required this.errorText,
    this.canceled = false,
  });

  @override
  String get method => 'Network.loadingFailed';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'requestId': requestId,
        'timestamp': timestamp,
        'type': type,
        'errorText': errorText,
        'canceled': canceled,
      });
}

//TODO:[answer] 补全其他的事件
/// Network.requestWillBeSentExtraInfo
/// Network.responseReceivedExtraInfo
/// Network.dataReceived
/// Network.resourceChangedPriority
/// Network.loadNetworkResource
/// Network.requestServedFromCache
///

class NetworkRequestWillBeSendExtraInfo extends InspectorEvent {
  final List associatedCookies;
  final Map<String, dynamic> clientSecurityState;
  final Map<String, dynamic> connectTiming;
  final Map<String, List<String>> headers;
  final String requestId;
  final bool siteHasCookieInOtherPartition;

  NetworkRequestWillBeSendExtraInfo({
    required this.associatedCookies,
    required this.clientSecurityState,
    required this.connectTiming,
    required this.headers,
    required this.siteHasCookieInOtherPartition,
    required this.requestId,
  });

  @override
  String get method => 'Network.requestWillBeSentExtraInfo';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'associatedCookies': associatedCookies,
        'clientSecurityState': clientSecurityState,
        'connectTiming': connectTiming,
        'headers': headers.map((key, value) => MapEntry(key, value.join(''))),
        'requestId': requestId,
        'siteHasCookieInOtherPartition': siteHasCookieInOtherPartition,
      });
}

class NetworkResponseReceivedExtraInfo extends InspectorEvent {
  final Map<String, dynamic> blockedCookies;
  final String cookiePartitionKey;
  final bool cookiePartitionKeyOpaque;
  final Map<String, List<String>> headers;
  final String requestId;
  final Map<String, dynamic> resourceIPAddressSpace;
  final int statusCode;

  NetworkResponseReceivedExtraInfo({
    required this.blockedCookies,
    required this.cookiePartitionKey,
    required this.cookiePartitionKeyOpaque,
    required this.headers,
    required this.requestId,
    required this.resourceIPAddressSpace,
    required this.statusCode,
  });

  @override
  String get method => 'Network.responseReceivedExtraInfo';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'blockedCookies': blockedCookies,
        'cookiePartitionKey': cookiePartitionKey,
        'cookiePartitionKeyOpaque': false,
        'headers': headers.map((key, value) => MapEntry(key, value.join(''))),
        'requestId': requestId,
        'resourceIPAddressSpace': resourceIPAddressSpace,
        'statusCode': 204,
      });
}

class NetworkDataReceived extends InspectorEvent {
  final int dataLength;
  final int encodedDataLength;
  final String requestId;
  final int timestamp;

  NetworkDataReceived({
    required this.dataLength,
    required this.encodedDataLength,
    required this.requestId,
    required this.timestamp,
  });

  @override
  String get method => 'Network.dataReceived';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'dataLength': dataLength,
        'encodedDataLength': encodedDataLength,
        'requestId': requestId,
        'timestamp': timestamp,
      });
}

class NetworkResourceChangedPriority extends InspectorEvent {
  final String requestId;
  final String newPriority;
  final int timestamp;

  NetworkResourceChangedPriority({
    required this.requestId,
    required this.newPriority,
    required this.timestamp,
  });

  @override
  String get method => 'Network.resourceChangedPriority';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'requestId': requestId,
        'newPriority': newPriority,
        'timestamp': timestamp,
      });
}

class NetworkLoadNetworkResource extends InspectorEvent {
  final Map<String, dynamic> resource;

  NetworkLoadNetworkResource({required this.resource});

  @override
  String get method => 'Network.loadNetworkResource';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'resource': resource,
      });
}

class NetworkRequestServedFromCache extends InspectorEvent {
  final String requestId;

  NetworkRequestServedFromCache({required this.requestId});

  @override
  String get method => 'Network.requestServedFromCache';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'requestId': requestId,
      });
}
