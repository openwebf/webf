import 'dart:async';

import 'package:webf/module.dart';

class UnresponsiveModule extends BaseModule {
  UnresponsiveModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  invoke(String method, params, InvokeModuleCallback callback) {
    Timer(Duration(milliseconds: 800), () {
      callback();
    });
  }

  @override
  String get name => 'UnresponsiveModule';
}
