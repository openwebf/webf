/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter/foundation.dart';

/// Options to configure HTTP logging via PrettyDioLogger for a WebFController.
///
/// These mirror commonly used PrettyDioLogger constructor parameters.
class HttpLoggerOptions {
  /// Whether the logger interceptor is enabled.
  /// Defaults to `kDebugMode` to avoid logging in release.
  final bool enabled;

  /// Log request headers.
  final bool requestHeader;

  /// Log request body.
  final bool requestBody;

  /// Log response headers.
  final bool responseHeader;

  /// Log response body.
  final bool responseBody;

  /// Log error bodies.
  final bool error;

  /// Compact print style.
  final bool compact;

  /// Max output width used by PrettyDioLogger.
  final int maxWidth;

  const HttpLoggerOptions({
    this.enabled = kDebugMode,
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = false,
    this.error = true,
    this.compact = true,
    this.maxWidth = 120,
  });
}
