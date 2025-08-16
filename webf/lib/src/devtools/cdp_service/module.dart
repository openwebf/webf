/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';

abstract class _InspectorModule {
  String get name;

  bool _enable = false;

  void invoke(int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'enable':
        _enable = true;
        sendToFrontend(id, null);
        // Hook for modules to handle enable
        try { onEnabled(); } catch (_) {}
        break;
      case 'disable':
        _enable = false;
        sendToFrontend(id, null);
        // Hook for modules to handle disable
        try { onDisabled(); } catch (_) {}
        break;

      case 'setCacheDisabled':
        bool disableCache = params?['cacheDisabled'] ?? false;

        if (disableCache) {
          HttpCacheController.mode = HttpCacheMode.NO_CACHE;
        } else {
          HttpCacheController.mode = HttpCacheMode.DEFAULT;
        }
        break;
      default:
        if (_enable) receiveFromFrontend(id, method, params);
    }
  }

  void sendToFrontend(int? id, JSONEncodable? result);
  void sendEventToFrontend(InspectorEvent event);
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params);

  // Optional hooks for subclasses
  void onEnabled() {}
  void onDisabled() {}

  // Expose enable state for synchronization across controllers.
  bool get isEnabled => _enable;
  void setEnabled(bool enabled) {
    _enable = enabled;
  }
}

// Inspector modules working on flutter.ui thread.
abstract class UIInspectorModule extends _InspectorModule {
  final DevToolsService devtoolsService;
  UIInspectorModule(this.devtoolsService);

  @override
  void sendToFrontend(int? id, JSONEncodable? result) {
    // For the unified service, send directly through the service
    if (devtoolsService is ChromeDevToolsService) {
      final resultMap = result?.toJson() ?? <String, dynamic>{};
      // Cast the Map to ensure it's Map<String, dynamic>
      ChromeDevToolsService.unifiedService.sendMethodResult(id ?? 0, Map<String, dynamic>.from(resultMap));
    }
  }

  @override
  void sendEventToFrontend(InspectorEvent event) {
    // For the unified service, send directly through the service
    if (devtoolsService is ChromeDevToolsService) {
      ChromeDevToolsService.unifiedService.sendEventToFrontend(event);
    }
  }
}
