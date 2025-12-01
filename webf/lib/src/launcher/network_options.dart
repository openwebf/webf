/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'dart:io' show Platform;
import 'package:dio/dio.dart' show HttpClientAdapter;

/// Network-related options for a `WebFController`.
///
/// Combines HTTP cache toggle and Dio `HttpClientAdapter` into one place,
/// with optional per-platform overrides.
class WebFNetworkOptions {
  /// Toggle WebF's HTTP cache for this controller.
  /// - true: force enable cache for this controller
  /// - false: force disable cache for this controller
  /// - null: follow global/platform defaults
  final bool? enableHttpCache;

  /// Optional async factory for Dio `HttpClientAdapter` for this controller.
  /// If provided, WebF's Dio instance will await the adapter returned by this
  /// callback during client creation. If null, WebF chooses a reasonable
  /// default adapter per platform.
  final Future<HttpClientAdapter> Function()? httpClientAdapter;

  /// Platform-specific overrides. When present, values here take precedence
  /// over the top-level values on the corresponding platform.
  final WebFNetworkOptions? android;
  final WebFNetworkOptions? ios;
  final WebFNetworkOptions? macos;
  final WebFNetworkOptions? windows;
  final WebFNetworkOptions? linux;
  final WebFNetworkOptions? fuchsia;

  const WebFNetworkOptions({
    this.enableHttpCache,
    this.httpClientAdapter,
    this.android,
    this.ios,
    this.macos,
    this.windows,
    this.linux,
    this.fuchsia,
  });

  /// Returns the platform override for the current platform if provided.
  WebFNetworkOptions? get _platformOverride {
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    if (Platform.isMacOS) return macos;
    if (Platform.isWindows) return windows;
    if (Platform.isLinux) return linux;
    if (Platform.isFuchsia) return fuchsia;
    return null;
  }

  /// Effective `enableHttpCache` considering platform override.
  bool? get effectiveEnableHttpCache => _platformOverride?.enableHttpCache ?? enableHttpCache;

  /// Effective `httpClientAdapter` considering platform override.
  Future<HttpClientAdapter?> getEffectiveHttpClientAdapter() async {
    final factory = _platformOverride?.httpClientAdapter ?? httpClientAdapter;
    if (factory == null) return null;
    return await factory();
  }
}
