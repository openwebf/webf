/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';

class InspectNetworkModule extends UIInspectorModule implements HttpClientInterceptor {
  InspectNetworkModule(DevToolsService devtoolsService) : super(devtoolsService) {
    _registerHttpClientInterceptor();
  }

  void _registerHttpClientInterceptor() {
    setupHttpOverrides(this, contextId: devtoolsService.controller!.view.contextId);
  }

  HttpClientInterceptor? get _customHttpClientInterceptor => devtoolsService.controller?.httpClientInterceptor;

  @override
  String get name => 'Network';

  final HttpCacheMode _httpCacheOriginalMode = HttpCacheController.mode;
  final int _initialTimestamp = DateTime.now().millisecondsSinceEpoch;

  // RequestId to data buffer.
  final Map<String, Uint8List> _responseBuffers = {};

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
  Future<HttpClientRequest?> beforeRequest(HttpClientRequest request) {
    List<int> data = List<int>.from((request as ProxyHttpClientRequest).data);

    sendEventToFrontend(NetworkRequestWillBeSentEvent(
      requestId: _getRequestId(request),
      loaderId: devtoolsService.controller!.view.contextId.toString(),
      requestMethod: request.method,
      url: request.uri.toString(),
      headers: _getHttpHeaders(request.headers),
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) ~/ 1000,
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
        requestId: _getRequestId(request)));
    HttpClientInterceptor? customHttpClientInterceptor = _customHttpClientInterceptor;
    if (customHttpClientInterceptor != null) {
      return customHttpClientInterceptor.beforeRequest(request);
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<HttpClientResponse?> afterResponse(HttpClientRequest request, HttpClientResponse response) async {
    String requestId = _getRequestId(request);
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
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) ~/ 1000,
    ));
    sendEventToFrontend(NetworkLoadingFinishedEvent(
      requestId: requestId,
      contentLength: response.contentLength,
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) ~/ 1000,
    ));
    Uint8List data = await consolidateHttpClientResponseBytes(response);
    _responseBuffers[requestId] = data;

    HttpClientStreamResponse proxyResponse = HttpClientStreamResponse(Stream.value(data),
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        initialHeaders: createHttpHeaders(initialHeaders: _getHttpHeaders(response.headers)));

    HttpClientInterceptor? customHttpClientInterceptor = _customHttpClientInterceptor;
    if (customHttpClientInterceptor != null) {
      return customHttpClientInterceptor.afterResponse(request, proxyResponse);
    } else {
      return Future.value(proxyResponse);
    }
  }

  @override
  Future<HttpClientResponse?> shouldInterceptRequest(HttpClientRequest request) {
    HttpClientInterceptor? customHttpClientInterceptor = _customHttpClientInterceptor;
    if (customHttpClientInterceptor != null) {
      return customHttpClientInterceptor.shouldInterceptRequest(request);
    } else {
      return Future.value(null);
    }
  }
}

class NetworkRequestWillBeSentEvent extends InspectorEvent {
  final String requestId;
  final String loaderId;
  final String url;
  final String requestMethod;
  final Map<String, List<String>> headers;
  final int timestamp;
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
        'wallTime': timestamp,
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
  final int timestamp;

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
  final int timestamp;

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

String _getRequestId(HttpClientRequest request) {
  // @NOTE: For creating backend request, only uri is the same object reference.
  // See http_client_request.dart [_createBackendClientRequest]
  return request.uri.hashCode.toString();
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
      urlPath.endsWith('.webp')) {
    return 'Image';
  } else if (urlPath.endsWith('.html') || urlPath.endsWith('.htm')) {
    return 'Document';
  } else {
    return 'Fetch';
  }
}
