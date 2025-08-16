/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Enum for different types of network requests
enum NetworkRequestType {
  document,
  stylesheet,
  script,
  image,
  media,
  font,
  xhr,
  fetch,
  websocket,
  manifest,
  other
}

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

  /// Get the type of this request based on URL, headers, and MIME type
  NetworkRequestType get type {
    // Check for WebSocket upgrade
    final upgradeHeader = requestHeaders['upgrade'];
    if (upgradeHeader != null && upgradeHeader.any((value) => value.toLowerCase() == 'websocket')) {
      return NetworkRequestType.websocket;
    }

    // Check for XHR/Fetch requests
    final xRequestedWith = requestHeaders['x-requested-with'];
    if (xRequestedWith != null && xRequestedWith.any((value) => value.toLowerCase() == 'xmlhttprequest')) {
      return NetworkRequestType.xhr;
    }

    // Check Accept header for fetch/XHR hints
    final accept = requestHeaders['accept'];
    if (accept != null && accept.any((value) => value.contains('application/json') || value.contains('*/*'))) {
      // If it's a data request (not document), consider it fetch/xhr
      if (!url.endsWith('.html') && !url.endsWith('.htm') && !url.endsWith('/')) {
        return NetworkRequestType.fetch;
      }
    }

    // Use MIME type if available
    if (mimeType != null) {
      final lowerMimeType = mimeType!.toLowerCase();
      
      // Document types
      if (lowerMimeType.contains('text/html') || lowerMimeType.contains('application/xhtml')) {
        return NetworkRequestType.document;
      }
      
      // Stylesheet
      if (lowerMimeType.contains('text/css')) {
        return NetworkRequestType.stylesheet;
      }
      
      // Script
      if (lowerMimeType.contains('javascript') || lowerMimeType.contains('ecmascript')) {
        return NetworkRequestType.script;
      }
      
      // Images
      if (lowerMimeType.startsWith('image/')) {
        return NetworkRequestType.image;
      }
      
      // Media (audio/video)
      if (lowerMimeType.startsWith('audio/') || lowerMimeType.startsWith('video/')) {
        return NetworkRequestType.media;
      }
      
      // Fonts
      if (lowerMimeType.contains('font/') || lowerMimeType.contains('application/font')) {
        return NetworkRequestType.font;
      }
      
      // JSON (likely API calls)
      if (lowerMimeType.contains('application/json')) {
        return NetworkRequestType.fetch;
      }
      
      // Manifest
      if (lowerMimeType.contains('manifest')) {
        return NetworkRequestType.manifest;
      }
    }

    // Fallback to URL-based detection
    final lowerUrl = url.toLowerCase();
    
    // Documents
    if (lowerUrl.endsWith('.html') || lowerUrl.endsWith('.htm') || 
        (lowerUrl.endsWith('/') && method.toUpperCase() == 'GET')) {
      return NetworkRequestType.document;
    }
    
    // Stylesheets
    if (lowerUrl.endsWith('.css')) {
      return NetworkRequestType.stylesheet;
    }
    
    // Scripts
    if (lowerUrl.endsWith('.js') || lowerUrl.endsWith('.mjs')) {
      return NetworkRequestType.script;
    }
    
    // Images
    if (lowerUrl.endsWith('.png') || lowerUrl.endsWith('.jpg') || lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.gif') || lowerUrl.endsWith('.webp') || lowerUrl.endsWith('.svg') ||
        lowerUrl.endsWith('.ico') || lowerUrl.endsWith('.bmp')) {
      return NetworkRequestType.image;
    }
    
    // Media
    if (lowerUrl.endsWith('.mp4') || lowerUrl.endsWith('.webm') || lowerUrl.endsWith('.mp3') ||
        lowerUrl.endsWith('.wav') || lowerUrl.endsWith('.ogg')) {
      return NetworkRequestType.media;
    }
    
    // Fonts
    if (lowerUrl.endsWith('.woff') || lowerUrl.endsWith('.woff2') || lowerUrl.endsWith('.ttf') ||
        lowerUrl.endsWith('.otf') || lowerUrl.endsWith('.eot')) {
      return NetworkRequestType.font;
    }
    
    // Manifest
    if (lowerUrl.endsWith('.json') && lowerUrl.contains('manifest')) {
      return NetworkRequestType.manifest;
    }
    
    // Default to 'other'
    return NetworkRequestType.other;
  }

  /// Get a display name for the request type
  String get typeDisplayName {
    switch (type) {
      case NetworkRequestType.document:
        return 'Doc';
      case NetworkRequestType.stylesheet:
        return 'CSS';
      case NetworkRequestType.script:
        return 'JS';
      case NetworkRequestType.image:
        return 'Img';
      case NetworkRequestType.media:
        return 'Media';
      case NetworkRequestType.font:
        return 'Font';
      case NetworkRequestType.xhr:
        return 'XHR';
      case NetworkRequestType.fetch:
        return 'Fetch';
      case NetworkRequestType.websocket:
        return 'WS';
      case NetworkRequestType.manifest:
        return 'Manifest';
      case NetworkRequestType.other:
        return 'Other';
    }
  }

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
