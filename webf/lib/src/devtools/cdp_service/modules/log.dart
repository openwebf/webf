/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';

class InspectLogModule extends UIInspectorModule {
  InspectLogModule(super.server) {
    _setupLogHandler();
  }

  void _setupLogHandler() {
    // Set up log handler if context is available
    final context = devtoolsService.context;
    if (context != null) {
      final controller = context.getController();
      if (controller != null) {
        controller.onJSLog = (level, message) {
          handleMessage(level, message);
        };
      }
    }
  }

  @override
  void onEnabled() {
    super.onEnabled();
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] Log.enable');
    }
    _setupLogHandler();
  }

  @override
  void onDisabled() {
    super.onDisabled();
    // Clear log handler when disabled
    final context = devtoolsService.context;
    if (context != null) {
      final controller = context.getController();
      if (controller != null) {
        controller.onJSLog = null;
      }
    }
  }

  void handleMessage(int level, String message) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] Log.entry level=$level "$message"');
    }
    sendEventToFrontend(LogEntryEvent(
      text: message,
      level: getLevelStr(level),
    ));
  }

  /// Log = 1,
  /// Warning = 2,
  /// Error = 3,
  /// Debug = 4,
  /// Info = 5,
  String getLevelStr(int level) {
    switch (level) {
      case 1:
        return 'verbose';
      case 2:
        return 'warning';
      case 3:
        return 'error';
      case 4:
        return 'verbose';
      case 5:
        return 'info';
      default:
        return 'verbose';
    }
  }

  @override
  String get name => 'Log';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    // callNativeInspectorMethod(id, method, params);
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] Log.$method');
    }
  }

  @override
  void onContextChanged() {
    super.onContextChanged();
    // Reinitialize log handler when context changes
    _setupLogHandler();
  }
}

class LogEntryEvent extends InspectorEvent {
  // Allowed Values: xml, javascript, network, storage, appcache,
  // rendering, security, deprecation, worker, violation, intervention,
  // recommendation, other
  String source;

  // Allowed Values: verbose, info, warning, error
  String level;

  // The output text.
  String text;

  String? url;

  LogEntryEvent({
    required this.level,
    required this.text,
    this.source = 'javascript',
    this.url,
  });

  @override
  String get method => 'Log.entryAdded';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'entry': {
          'source': source,
          'level': level,
          'text': text,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          if (url != null) 'url': url,
        },
      });
}
