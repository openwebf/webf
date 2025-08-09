/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:io';

import 'package:webf/webf.dart';

// TODO: Don't use header to mark context.
const String HttpHeaderContext = 'x-context';

class WebFHttpOverrides {
  static WebFHttpOverrides? _instance;

  WebFHttpOverrides._();

  factory WebFHttpOverrides.instance() {
    _instance ??= WebFHttpOverrides._();
    return _instance!;
  }

  static double? getContextHeader(HttpHeaders headers) {
    String? intVal = headers.value(HttpHeaderContext);
    if (intVal == null) {
      return null;
    }
    return double.tryParse(intVal);
  }

  static void setContextHeader(HttpHeaders headers, double contextId) {
    headers.set(HttpHeaderContext, contextId.toString());
  }

  final Map<double, HttpClientInterceptor> _contextIdToHttpClientInterceptorMap = <double, HttpClientInterceptor>{};

  void registerWebFContext(double contextId, HttpClientInterceptor httpClientInterceptor) {
    _contextIdToHttpClientInterceptorMap[contextId] = httpClientInterceptor;
  }

  bool unregisterWebFContext(double contextId) {
    // Returns true if [value] was in the map, false otherwise.
    return _contextIdToHttpClientInterceptorMap.remove(contextId) != null;
  }

  bool hasInterceptor(double contextId) {
    return _contextIdToHttpClientInterceptorMap.containsKey(contextId);
  }

  HttpClientInterceptor getInterceptor(double contextId) {
    return _contextIdToHttpClientInterceptorMap[contextId]!;
  }

  void clearInterceptors() {
    _contextIdToHttpClientInterceptorMap.clear();
  }
}

WebFHttpOverrides setupHttpOverrides(HttpClientInterceptor? httpClientInterceptor, {required double contextId}) {
  final WebFHttpOverrides httpOverrides = WebFHttpOverrides.instance();

  if (httpClientInterceptor != null) {
    httpOverrides.registerWebFContext(contextId, httpClientInterceptor);
  }
  return httpOverrides;
}

void removeHttpOverrides({required double contextId}) {
  final WebFHttpOverrides httpOverrides = WebFHttpOverrides.instance();
  httpOverrides.unregisterWebFContext(contextId);
}

/// Creates a WebF-aware HttpClient without modifying global HttpOverrides.
/// The returned client wraps a native HttpClient with ProxyHttpClient and applies
/// consistent connection settings.
HttpClient createWebFHttpClient() {
  final WebFHttpOverrides httpOverrides = WebFHttpOverrides.instance();
  final HttpClient nativeHttpClient = HttpClient()
    ..maxConnectionsPerHost = 30
    ..connectionTimeout = Duration(seconds: 30);
  return ProxyHttpClient(nativeHttpClient, httpOverrides);
}

// Returns the origin of the URI in the form scheme://host:port
String getOrigin(Uri uri) {
  if (uri.isScheme('http') || uri.isScheme('https')) {
    return uri.origin;
  } else {
    return uri.path;
  }
}

// @TODO: Remove controller dependency.
Uri getEntrypointUri(double? contextId) {
  WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
  String url = controller?.url ?? '';
  return Uri.tryParse(url) ?? WebFController.fallbackBundleUri(contextId ?? 0.0);
}
