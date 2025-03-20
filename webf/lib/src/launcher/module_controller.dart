/*
 * Copyright (C) 2024-present The OpenWebF(Cayman) company. All rights reserved.
 */

// An controller designed to control functional modules.
import 'package:webf/launcher.dart';
import 'package:webf/module.dart';

class WebFModuleController with TimerMixin, ScheduleFrameMixin {
  late ModuleManager _moduleManager;

  ModuleManager get moduleManager => _moduleManager;

  WebFModuleController(WebFController controller, double contextId) {
    _moduleManager = ModuleManager(controller, contextId);
  }

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _moduleManager.initialize();
    _initialized = true;
  }

  void dispose() {
    disposeTimer();
    disposeScheduleFrame();
    _moduleManager.dispose();
  }
}
