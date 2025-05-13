import 'dart:async';

import 'package:webf/module.dart';

class UnresponsiveModule extends BaseModule {
  UnresponsiveModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  invoke(String method, params) {
    Completer<void> completer = Completer();
    Timer(Duration(milliseconds: 800), () {
      completer.complete();
    });
  }

  @override
  String get name => 'UnresponsiveModule';
}
