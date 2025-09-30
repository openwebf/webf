/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

/// Global logger configuration for WebF
class WebFLogger {
  static bool _initialized = false;

  /// Initialize the logger with default configuration
  static void initialize() {
    if (_initialized) return;

    // Enable hierarchical logging to allow fine-grained control
    hierarchicalLoggingEnabled = true;

    // Set root logger level based on build mode
    if (kReleaseMode) {
      Logger.root.level = Level.WARNING;
    } else if (kProfileMode) {
      Logger.root.level = Level.INFO;
    } else {
      // Debug mode
      Logger.root.level = Level.ALL;
    }

    // Configure the root logger to print messages
    Logger.root.onRecord.listen((LogRecord record) {
      final logger = record.loggerName.padRight(5);
      final message = record.message;

      // Format: [TIME] LEVEL   LOGGER               MESSAGE
      final logMessage = '$logger $message';

      // In debug mode, use debugPrint for better Flutter integration
      if (kDebugMode) {
        Platform.isMacOS ? debugPrintSynchronously(logMessage) : debugPrint(logMessage);
        if (record.error != null) {
          debugPrintSynchronously('Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          debugPrintSynchronously('Stack trace:\n${record.stackTrace}');
        }
      } else {
        // In release/profile mode, you might want to send logs to a service
        // For now, we'll just use print
        print(logMessage);
      }
    });

    _initialized = true;
  }

  /// Get a logger instance for a specific component
  static Logger getLogger(String name) {
    if (!_initialized) {
      initialize();
    }
    return Logger(name);
  }
}

// Convenience loggers for different components
final Logger bridgeLogger = WebFLogger.getLogger('WebF.Bridge');
final Logger domLogger = WebFLogger.getLogger('WebF.DOM');
final Logger cssLogger = WebFLogger.getLogger('WebF.CSS');
final Logger renderingLogger = WebFLogger.getLogger('WebF.Rendering');
final Logger canvasLogger = WebFLogger.getLogger('WebF.Canvas');
final Logger devToolsLogger = WebFLogger.getLogger('WebF.DevTools');
final Logger devToolsProtocolLogger = WebFLogger.getLogger('WebF.DevTools.CDP');
