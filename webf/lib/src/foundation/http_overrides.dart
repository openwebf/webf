/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'dart:io';

import 'package:webf/webf.dart';

// TODO: Don't use header to mark context.
const String httpHeaderContext = 'x-context';
@Deprecated('Use httpHeaderContext')
// ignore: constant_identifier_names
const String HttpHeaderContext = httpHeaderContext;

class WebFHttpOverrides {
  static WebFHttpOverrides? _instance;

  WebFHttpOverrides._();

  factory WebFHttpOverrides.instance() {
    _instance ??= WebFHttpOverrides._();
    return _instance!;
  }

  static double? getContextHeader(HttpHeaders headers) {
    String? intVal = headers.value(httpHeaderContext);
    if (intVal == null) {
      return null;
    }
    return double.tryParse(intVal);
  }

  static void setContextHeader(HttpHeaders headers, double contextId) {
    headers.set(httpHeaderContext, contextId.toString());
  }
}

WebFHttpOverrides setupHttpOverrides({required double contextId}) {
  // Kept for compatibility; no-op since HttpClientInterceptor was removed.
  return WebFHttpOverrides.instance();
}

void removeHttpOverrides({required double contextId}) {
  // No-op since we no longer keep per-context state here.
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
