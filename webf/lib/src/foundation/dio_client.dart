/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'dart:io';

import 'package:cupertino_http/cupertino_http.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/foundation.dart';
import 'package:webf/module.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/foundation/cupertino_adapter.dart';
import 'dio_logger.dart';

/// Creates a Dio client configured for WebF networking with cookie + cache handling.
/// Context arguments tailor the interceptor per-call without duplicating setup logic.
/// Create a Dio client configured for WebF networking.
///
/// Options align with Dio v5 docs. Defaults aim to match WebF HttpClient behavior
/// while allowing per-request overrides.
class _WebFDioPool {
  // Maintain a single Dio per context with a scheme-routing adapter.
  static final _instances = <double, Dio>{};
  // Installers registered by other subsystems (e.g., DevTools) to attach
  // context-aware interceptors regardless of creation order.
  static final _installers = <double, List<void Function(Dio)>>{};

  static void registerInstaller(double contextId, void Function(Dio) installer) {
    _installers.putIfAbsent(contextId, () => <void Function(Dio)>[]).add(installer);
    // If an instance already exists, apply immediately.
    final dio = _instances[contextId];
    if (dio != null) {
      try {
        installer(dio);
      } catch (_) {
        // Ignore installer errors to avoid breaking networking.
      }
    }
  }

  static void unregisterInstallers(double contextId) {
    _installers.remove(contextId);
  }

  static Future<Dio> getOrCreate({
    required double contextId,
    required Uri uri,
    WebFBundle? ownerBundle,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 60),
    Duration sendTimeout = const Duration(seconds: 60),
    bool followRedirects = true,
    int maxRedirects = 5,
    int maxConnectionsPerHost = 30,
    String? userAgent,
  }) async {
    if (_instances.containsKey(contextId)) {
      return _instances[contextId]!;
    }

    final headers = <String, dynamic>{
      HttpHeaders.userAgentHeader: userAgent ?? _getDefaultUserAgent(),
    };

    // Single dio that owns interceptors; adapter will route by scheme.
    final dio = Dio(BaseOptions(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
      responseType: ResponseType.bytes,
      headers: headers,
    ));
    // Build scheme-specific adapters and install routing adapter unless a custom adapter is provided.
    final controller = WebFController.getControllerOfJSContextId(contextId);
    // Resolve platform-specific adapter via unified network options if provided.
    HttpClientAdapter? selectedAdapter;
    if (controller?.networkOptions != null) {
      selectedAdapter = await controller!.networkOptions!.getEffectiveHttpClientAdapter();
    }

    if (selectedAdapter != null) {
      dio.httpClientAdapter = selectedAdapter;
    } else {
      String cacheDirectory = await HttpCacheController.getCacheDirectory(uri);

      HttpClientAdapter httpClientAdapter;
      // NativeAdapter nativeAdapter;
      if (Platform.isIOS || Platform.isMacOS) {
        URLSessionConfiguration configuration = URLSessionConfiguration.defaultSessionConfiguration()
          ..allowsConstrainedNetworkAccess = true
          ..allowsExpensiveNetworkAccess = true
          ..cache = URLCache.withCapacity(
              memoryCapacity: 2 * 1024 * 1024, diskCapacity: 24 * 1024 * 1024, directory: Uri.parse(cacheDirectory));
        httpClientAdapter = CupertinoAdapter(configuration);
      } else {
        httpClientAdapter = IOHttpClientAdapter();
      }

      // Use native http client by default
      dio.httpClientAdapter = httpClientAdapter;
    }

    // Cookie + cache interceptor bound to this context
    dio.interceptors.add(WebFDioCacheCookieInterceptor(
      contextId: contextId,
      ownerBundle: ownerBundle,
    ));

    // Append user-provided interceptors (if any) after WebF's built-in interceptor
    final extras = controller?.dioInterceptors;
    if (extras != null && extras.isNotEmpty) {
      dio.interceptors.addAll(extras);
    }

    // Configure PrettyDioLogger based on controller options (defaults to debug-only)
    final loggerOptions = controller?.httpLoggerOptions;
    final bool loggerEnabled = (loggerOptions?.enabled ?? kDebugMode);
    if (loggerEnabled) {
      dio.interceptors.add(PrettyDioLogger(
        enabled: kDebugMode,
        requestHeader: loggerOptions?.requestHeader ?? false,
        requestBody: loggerOptions?.requestBody ?? false,
        responseHeader: loggerOptions?.responseHeader ?? false,
        responseBody: loggerOptions?.responseBody ?? false,
        error: loggerOptions?.error ?? true,
        compact: loggerOptions?.compact ?? true,
        maxWidth: loggerOptions?.maxWidth ?? 120,
      ));
    }

    _instances[contextId] = dio;
    // Apply any late-bound installers for this context (e.g., DevTools inspectors)
    final installers = _installers[contextId];
    if (installers != null && installers.isNotEmpty) {
      for (final fn in installers) {
        try {
          fn(dio);
        } catch (_) {
          // Best effort; keep network resilient.
        }
      }
    }
    return dio;
  }

  static void dispose(double contextId) {
    final dio = _instances.remove(contextId);
    dio?.close(force: true);
    // Do not clear installers here; DevTools may still want to reapply when recreated.
  }
}

/// Get a WebF-configured Dio. Returns a shared instance per `contextId`.
/// When `contextId` is null, creates a new ephemeral instance.
Future<Dio> getOrCreateWebFDio({
  required double contextId,
  required Uri uri,
  WebFBundle? ownerBundle,
  Duration connectTimeout = const Duration(seconds: 30),
  Duration receiveTimeout = const Duration(seconds: 60),
  Duration sendTimeout = const Duration(seconds: 60),
  bool followRedirects = true,
  int maxRedirects = 5,
  int maxConnectionsPerHost = 15,
  String? userAgent,
  bool Function(int? statusCode)? validateStatus,
}) async {
  final dio = await _WebFDioPool.getOrCreate(
    contextId: contextId,
    uri: uri,
    ownerBundle: ownerBundle,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    sendTimeout: sendTimeout,
    followRedirects: followRedirects,
    maxRedirects: maxRedirects,
    maxConnectionsPerHost: maxConnectionsPerHost,
    userAgent: userAgent,
  );

  // Per-request validateStatus can still be provided via Options in request.
  return dio;
}

/// Dispose the shared Dio for a specific WebF context when controller is torn down.
void disposeSharedDioForContext(double contextId) {
  _WebFDioPool.dispose(contextId);
}

/// Register a context-aware installer to be invoked for the Dio instance
/// associated with the given context. If the Dio already exists, the installer
/// is applied immediately; otherwise it will be applied on first creation.
void registerWebFDioInterceptorInstaller(double contextId, void Function(Dio) installer) {
  _WebFDioPool.registerInstaller(contextId, installer);
}

/// Remove all registered installers for a given context.
void unregisterWebFDioInterceptorInstallers(double contextId) {
  _WebFDioPool.unregisterInstallers(contextId);
}

String _getDefaultUserAgent() {
  try {
    return NavigatorModule.getUserAgent();
  } catch (_) {
    return 'WebF';
  }
}
