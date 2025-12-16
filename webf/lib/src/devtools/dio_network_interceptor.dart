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
import 'package:flutter/foundation.dart';
import 'package:webf/devtools.dart';
import 'package:webf/src/devtools/panel/network_store.dart';

/// Dio interceptor for capturing network requests in DevTools
class DioNetworkInspectorInterceptor extends InterceptorsWrapper {
  final InspectNetworkModule networkModule;
  final int _initialTimestamp = DateTime.now().millisecondsSinceEpoch;

  // RequestId to response data buffer
  final Map<String, Uint8List> _responseBuffers = {};

  // Store request IDs for tracking
  final Map<RequestOptions, String> _requestIds = {};

  DioNetworkInspectorInterceptor({required this.networkModule});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Generate unique request ID
    final requestId = '${options.uri.toString()}_${DateTime.now().microsecondsSinceEpoch}';
    _requestIds[options] = requestId;

    // Extract request data
    List<int> data = [];
    if (options.data != null) {
      if (options.data is String) {
        data = utf8.encode(options.data);
      } else if (options.data is List<int>) {
        data = options.data;
      } else if (options.data is FormData) {
        // For FormData, convert to string representation
        data = utf8.encode(options.data.toString());
      } else if (options.data is Map) {
        data = utf8.encode(jsonEncode(options.data));
      }
    }

    // Store request in NetworkStore
    final contextId = networkModule.devtoolsService.controller!.view.contextId;
    final networkRequest = NetworkRequest(
      requestId: requestId,
      url: options.uri.toString(),
      method: options.method,
      requestHeaders: _convertHeaders(options.headers),
      requestData: data,
      startTime: DateTime.now(),
    );
    NetworkStore().addRequest(contextId.toInt(), networkRequest);

    // Send event to DevTools frontend
    networkModule.sendEventToFrontend(NetworkRequestWillBeSentEvent(
      requestId: requestId,
      loaderId: contextId.toString(),
      requestMethod: options.method,
      url: options.uri.toString(),
      headers: _convertHeaders(options.headers),
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000,
      data: data,
    ));

    // Send extra info event
    Map<String, List<String>> extraHeaders = {
      ':authority': [options.uri.authority],
      ':method': [options.method],
      ':path': [options.uri.path],
      ':scheme': [options.uri.scheme],
    };

    networkModule.sendEventToFrontend(NetworkRequestWillBeSendExtraInfo(
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
        ..._convertHeaders(options.headers),
        ...extraHeaders
      },
      siteHasCookieInOtherPartition: false,
      requestId: requestId,
    ));

    handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    final requestId = _requestIds[response.requestOptions];
    if (requestId == null) {
      handler.next(response);
      return;
    }

    // Convert response data to bytes
    Uint8List responseData;
    if (response.data == null) {
      responseData = Uint8List(0);
    } else if (response.data is Uint8List) {
      responseData = response.data;
    } else if (response.data is List<int>) {
      responseData = Uint8List.fromList(response.data);
    } else if (response.data is String) {
      responseData = Uint8List.fromList(utf8.encode(response.data));
    } else {
      // For other types, convert to JSON string
      responseData = Uint8List.fromList(utf8.encode(jsonEncode(response.data)));
    }

    // Store response buffer for later retrieval
    _responseBuffers[requestId] = responseData;

    // Send response received event
    networkModule.sendEventToFrontend(NetworkResponseReceivedEvent(
      requestId: requestId,
      loaderId: networkModule.devtoolsService.controller!.view.contextId.toString(),
      url: response.requestOptions.uri.toString(),
      headers: _convertHeaders(response.headers.map),
      status: response.statusCode ?? 0,
      statusText: response.statusMessage ?? '',
      mimeType: response.headers.value(HttpHeaders.contentTypeHeader) ?? 'text/plain',
      remoteIPAddress: '0.0.0.0', // Dio doesn't provide this info directly
      remotePort: response.requestOptions.uri.port != 0 ? response.requestOptions.uri.port :
                  (response.requestOptions.uri.scheme == 'https' ? 443 : 80),
      fromDiskCache: false, // Check if response came from cache
      encodedDataLength: responseData.length,
      protocol: response.requestOptions.uri.scheme,
      type: _getRequestType(response.requestOptions),
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000,
    ));

    // Send loading finished event
    networkModule.sendEventToFrontend(NetworkLoadingFinishedEvent(
      requestId: requestId,
      contentLength: responseData.length,
      timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000,
    ));

    // Update response data in NetworkStore
    NetworkStore().updateRequest(
      requestId,
      responseHeaders: _convertHeaders(response.headers.map),
      statusCode: response.statusCode ?? 0,
      statusText: response.statusMessage ?? '',
      mimeType: response.headers.value(HttpHeaders.contentTypeHeader) ?? 'text/plain',
      responseBody: responseData,
      endTime: DateTime.now(),
      contentLength: responseData.length,
      fromCache: false,
      remoteIPAddress: '0.0.0.0',
      remotePort: response.requestOptions.uri.port != 0 ? response.requestOptions.uri.port :
                  (response.requestOptions.uri.scheme == 'https' ? 443 : 80),
    );

    // Clean up request ID mapping
    _requestIds.remove(response.requestOptions);

    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestId = _requestIds[err.requestOptions];
    if (requestId != null) {
      // Send error event to DevTools
      networkModule.sendEventToFrontend(NetworkLoadingFinishedEvent(
        requestId: requestId,
        contentLength: 0,
        timestamp: (DateTime.now().millisecondsSinceEpoch - _initialTimestamp) / 1000,
      ));

      // Update NetworkStore with error
      NetworkStore().updateRequest(
        requestId,
        responseHeaders: {},
        statusCode: err.response?.statusCode ?? 0,
        statusText: err.message ?? 'Network Error',
        mimeType: 'text/plain',
        responseBody: Uint8List.fromList(utf8.encode(err.toString())),
        endTime: DateTime.now(),
        contentLength: 0,
        fromCache: false,
        remoteIPAddress: '0.0.0.0',
        remotePort: 0,
      );

      // Clean up request ID mapping
      _requestIds.remove(err.requestOptions);
    }

    handler.next(err);
  }

  /// Get response body for a specific request ID
  Uint8List? getResponseBody(String requestId) {
    return _responseBuffers[requestId];
  }

  /// Clear stored response buffers
  void clearBuffers() {
    _responseBuffers.clear();
    _requestIds.clear();
  }

  /// Convert headers to the format expected by DevTools
  Map<String, List<String>> _convertHeaders(Map<String, dynamic> headers) {
    final Map<String, List<String>> result = {};
    headers.forEach((key, value) {
      if (value is List) {
        result[key] = value.map((v) => v.toString()).toList();
      } else {
        result[key] = [value.toString()];
      }
    });
    return result;
  }

  /// Determine request type based on URL and headers
  String _getRequestType(RequestOptions request) {
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
}
