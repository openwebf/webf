/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Represents a single network request with all its associated data
class NetworkRequest {
  final String requestId;
  final String url;
  final String method;
  final Map<String, List<String>> requestHeaders;
  final List<int> requestData;
  final DateTime startTime;

  Map<String, List<String>>? responseHeaders;
  int? statusCode;
  String? statusText;
  String? mimeType;
  Uint8List? responseBody;
  DateTime? endTime;
  int? contentLength;
  bool? fromCache;
  String? remoteIPAddress;
  int? remotePort;

  NetworkRequest({
    required this.requestId,
    required this.url,
    required this.method,
    required this.requestHeaders,
    required this.requestData,
    required this.startTime,
  });

  /// Calculate the duration of the request
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Get the size of the request body
  int get requestSize => requestData.length;

  /// Get the size of the response body
  int get responseSize => responseBody?.length ?? 0;

  /// Check if the request is complete
  bool get isComplete => endTime != null;

  /// Get a human-readable status
  String get status {
    if (!isComplete) return 'Pending';
    if (statusCode == null) return 'Failed';
    if (statusCode! >= 200 && statusCode! < 300) return 'Success';
    if (statusCode! >= 300 && statusCode! < 400) return 'Redirect';
    if (statusCode! >= 400 && statusCode! < 500) return 'Client Error';
    if (statusCode! >= 500) return 'Server Error';
    return 'Unknown';
  }

  /// Get status color based on the status code
  Color get statusColor {
    if (!isComplete) return const Color(0xFF9E9E9E); // Grey
    if (statusCode == null) return const Color(0xFFF44336); // Red
    if (statusCode! >= 200 && statusCode! < 300) return const Color(0xFF4CAF50); // Green
    if (statusCode! >= 300 && statusCode! < 400) return const Color(0xFFFF9800); // Orange
    if (statusCode! >= 400 && statusCode! < 500) return const Color(0xFFFF5722); // Deep Orange
    if (statusCode! >= 500) return const Color(0xFFF44336); // Red
    return const Color(0xFF9E9E9E); // Grey
  }
}

/// A singleton store that holds all network requests for the DevTools panel
class NetworkStore {
  static final NetworkStore _instance = NetworkStore._internal();
  factory NetworkStore() => _instance;
  NetworkStore._internal();

  /// Map of contextId to list of network requests
  final Map<int, List<NetworkRequest>> _requestsByContext = {};

  /// Map of requestId to NetworkRequest for quick lookup
  final Map<String, NetworkRequest> _requestsById = {};

  /// Maximum number of requests to keep per context
  static const int maxRequestsPerContext = 1000;

  /// Add a new request
  void addRequest(int contextId, NetworkRequest request) {
    // Add to the by-ID map
    _requestsById[request.requestId] = request;

    // Add to the by-context map
    if (!_requestsByContext.containsKey(contextId)) {
      _requestsByContext[contextId] = [];
    }

    final requests = _requestsByContext[contextId]!;
    requests.add(request);

    // Limit the number of stored requests
    if (requests.length > maxRequestsPerContext) {
      final removed = requests.removeAt(0);
      _requestsById.remove(removed.requestId);
    }
  }

  /// Update an existing request with response data
  void updateRequest(String requestId, {
    Map<String, List<String>>? responseHeaders,
    int? statusCode,
    String? statusText,
    String? mimeType,
    Uint8List? responseBody,
    DateTime? endTime,
    int? contentLength,
    bool? fromCache,
    String? remoteIPAddress,
    int? remotePort,
  }) {
    final request = _requestsById[requestId];
    if (request == null) return;

    if (responseHeaders != null) request.responseHeaders = responseHeaders;
    if (statusCode != null) request.statusCode = statusCode;
    if (statusText != null) request.statusText = statusText;
    if (mimeType != null) request.mimeType = mimeType;
    if (responseBody != null) request.responseBody = responseBody;
    if (endTime != null) request.endTime = endTime;
    if (contentLength != null) request.contentLength = contentLength;
    if (fromCache != null) request.fromCache = fromCache;
    if (remoteIPAddress != null) request.remoteIPAddress = remoteIPAddress;
    if (remotePort != null) request.remotePort = remotePort;
  }

  /// Get all requests for a specific context
  List<NetworkRequest> getRequestsForContext(int contextId) {
    return _requestsByContext[contextId] ?? [];
  }

  /// Get a specific request by ID
  NetworkRequest? getRequestById(String requestId) {
    return _requestsById[requestId];
  }

  /// Clear all requests for a specific context
  void clearContext(int contextId) {
    final requests = _requestsByContext[contextId];
    if (requests != null) {
      for (final request in requests) {
        _requestsById.remove(request.requestId);
      }
      _requestsByContext.remove(contextId);
    }
  }

  /// Clear all stored requests
  void clearAll() {
    _requestsByContext.clear();
    _requestsById.clear();
  }

  /// Get the total number of requests across all contexts
  int get totalRequestCount => _requestsById.length;

  /// Get the number of contexts with requests
  int get contextCount => _requestsByContext.length;
}
