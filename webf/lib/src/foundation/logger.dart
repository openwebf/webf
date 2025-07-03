/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

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
      final time = record.time.toIso8601String();
      final level = record.level.name.padRight(7);
      final logger = record.loggerName.padRight(20);
      final message = record.message;
      
      // Format: [TIME] LEVEL   LOGGER               MESSAGE
      final logMessage = '[$time] $level $logger $message';
      
      // In debug mode, use debugPrint for better Flutter integration
      if (kDebugMode) {
        debugPrint(logMessage);
        if (record.error != null) {
          debugPrint('Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          debugPrint('Stack trace:\n${record.stackTrace}');
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