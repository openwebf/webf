/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/devtools/network_store.dart';
import 'package:webf/src/foundation/dio_client.dart';

class InspectNetworkModule extends UIInspectorModule implements HttpClientInterceptor {
  InspectNetworkModule(DevToolsService devtoolsService) : super(devtoolsService) {
    _registerHttpClientInterceptor();
    _maybeRegisterDioInterceptor();
  }

  void _registerHttpClientInterceptor() {
    setupHttpOverrides(this, contextId: devtoolsService.controller!.view.contextId);
  }

  void _maybeRegisterDioInterceptor() {
    // Only install Dio interceptor when global Dio networking is enabled
    final useDio = WebFControllerManager.instance.useDioForNetwork;
    if (!useDio) return;

    final controller = devtoolsService.controller;
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

  HttpClientInterceptor? get _customHttpClientInterceptor => devtoolsService.controller?.httpClientInterceptor;

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
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
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
        sendToFrontend(
            id,
            JSONEncodableMap({
              if (buffer != null) 'body': utf8.decode(buffer),
              // True, if content was sent as base64.
              'base64Encoded': false,
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
  Future<HttpClientRequest?> beforeRequest(String requestId, HttpClientRequest request) {
    List<int> data = List<int>.from((request as ProxyHttpClientRequest).data);
    
    // Store request in NetworkStore
    final contextId = devtoolsService.controller!.view.contextId;
    final networkRequest = NetworkRequest(
      requestId: requestId,
      url: request.uri.toString(),
      method: request.method,
      requestHeaders: _getHttpHeaders(request.headers),
      requestData: data,
      startTime: DateTime.now(),
    );
    NetworkStore().addRequest(contextId.toInt(), networkRequest);

    sendEventToFrontend(NetworkRequestWillBeSentEvent(
      requestId: requestId,
      loaderId: devtoolsService.controller!.view.contextId.toString(),
      requestMethod: request.method,
      url: request.uri.toString(),
      headers: _getHttpHeaders(request.headers),
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000,
      data: data,
    ));

    Map<String, List<String>> extraHeaders = {
      ':authority': [request.uri.authority],
      ':method': [request.method],
      ':path': [request.uri.path],
      ':scheme': [request.uri.scheme],
    };
    sendEventToFrontend(NetworkRequestWillBeSendExtraInfo(
          associatedCookies: [],
          clientSecurityState: {
          'initiatorIsSecureContext': true,
          'initiatorIPAddressSpace': 'Local',
          'privateNetworkRequestPolicy': 'PreflightWarn'
        },
        connectTiming: {
          'requestTime': 100000
        },
        headers: {
          ..._getHttpHeaders(request.headers),
          ...extraHeaders
        },
        siteHasCookieInOtherPartition: false,
        requestId: requestId));
    HttpClientInterceptor? customHttpClientInterceptor = _customHttpClientInterceptor;
    if (customHttpClientInterceptor != null) {
      return customHttpClientInterceptor.beforeRequest(requestId, request);
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<HttpClientResponse?> afterResponse(String requestId, HttpClientRequest request, HttpClientResponse response) async {
    if (devtoolsService.controller == null) {
      return response;
    }

    sendEventToFrontend(NetworkResponseReceivedEvent(
      requestId: requestId,
      loaderId: devtoolsService.controller!.view.contextId.toString(),
      url: request.uri.toString(),
      headers: _getHttpHeaders(response.headers),
      status: response.statusCode,
      statusText: response.reasonPhrase,
      mimeType: response.headers.value(HttpHeaders.contentTypeHeader) ?? 'text/plain',
      remoteIPAddress: response.connectionInfo!.remoteAddress.address,
      remotePort: response.connectionInfo!.remotePort,
      // HttpClientStreamResponse is the internal implementation for disk cache.
      fromDiskCache: response is HttpClientStreamResponse,
      encodedDataLength: response.contentLength,
      protocol: request.uri.scheme,
      type: _getRequestType(request),
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000,
    ));
    sendEventToFrontend(NetworkLoadingFinishedEvent(
      requestId: requestId,
      contentLength: response.contentLength,
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000,
    ));
    Uint8List data = await consolidateHttpClientResponseBytes(response);
    _responseBuffers[requestId] = data;
    
    // Update response data in NetworkStore
    NetworkStore().updateRequest(
      requestId,
      responseHeaders: _getHttpHeaders(response.headers),
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
      mimeType: response.headers.value(HttpHeaders.contentTypeHeader) ?? 'text/plain',
      responseBody: data,
      endTime: DateTime.now(),
      contentLength: response.contentLength,
      fromCache: response is HttpClientStreamResponse,
      remoteIPAddress: response.connectionInfo?.remoteAddress.address,
      remotePort: response.connectionInfo?.remotePort,
    );

    HttpClientStreamResponse proxyResponse = HttpClientStreamResponse(Stream.value(data),
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        initialHeaders: createHttpHeaders(initialHeaders: _getHttpHeaders(response.headers)));

    HttpClientInterceptor? customHttpClientInterceptor = _customHttpClientInterceptor;
    if (customHttpClientInterceptor != null) {
      return customHttpClientInterceptor.afterResponse(requestId, request, proxyResponse);
    } else {
      return Future.value(proxyResponse);
    }
  }

  @override
  Future<HttpClientResponse?> shouldInterceptRequest(String requestId, HttpClientRequest request) {
    HttpClientInterceptor? customHttpClientInterceptor = _customHttpClientInterceptor;
    if (customHttpClientInterceptor != null) {
      return customHttpClientInterceptor.shouldInterceptRequest(requestId, request);
    } else {
      return Future.value(null);
    }
  }
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
    if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.gif') || path.endsWith('.webp') || path.endsWith('.svg') || path.endsWith('.ico')) {
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
      connectTiming: {
        'requestTime': ts
      },
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
    final mimeType = response.headers.value(HttpHeaders.contentTypeHeader) ?? 'text/plain';
    final remoteIp = options.uri.host; // Best effort; real IP not exposed by Dio
    final remotePort = options.uri.hasPort ? options.uri.port : (options.uri.scheme == 'https' ? 443 : 80);
    final fromDiskCache = options.extra['webf_cache_hit'] == true;
    final encodedLen = bytes.length;
    final protocol = options.uri.scheme;
    final type = _guessTypeFromPath(options.uri.path);
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
    // For errors, we still want to mark the request as finished if we created an id
    final options = err.requestOptions;
    final requestId = options.extra[_kInspectorRequestId] as String?;
    if (requestId != null) {
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
    }
    handler.next(err);
  }
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
  final Bool cookiePartitionKeyOpaque;
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

Map<String, List<String>> _getHttpHeaders(HttpHeaders headers) {
  Map<String, List<String>> map = {};
  headers.forEach((String name, List<String> values) {
    map[name] = values;
  });
  return map;
}

// Allowed Values: Document, Stylesheet, Image, Media, Font, Script, TextTrack, XHR, Fetch, EventSource, WebSocket,
// Manifest, SignedExchange, Ping, CSPViolationReport, Preflight, Other
String _getRequestType(HttpClientRequest request) {
  String urlPath = request.uri.path;
  if (urlPath.endsWith('.js')) {
    return 'Script';
  } else if (urlPath.endsWith('.css')) {
    return 'Stylesheet';
  } else if (urlPath.endsWith('.jpg') ||
      urlPath.endsWith('.png') ||
      urlPath.endsWith('.gif') ||
      urlPath.endsWith('.webp') ||
      urlPath.endsWith('.svg')) {
    return 'Image';
  } else if (urlPath.endsWith('.html') || urlPath.endsWith('.htm')) {
    return 'Document';
  } else {
    return 'Fetch';
  }
}
