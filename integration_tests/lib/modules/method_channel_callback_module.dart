import 'dart:async';

import 'package:webf/bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/webf.dart';

class MethodChannelCallbackModule extends WebFBaseModule {
  MethodChannelCallbackModule(super.moduleManager);

  JSFunction? _callback;

  @override
  String get name => 'MethodChannelCallback';

  void setCallback(JSFunction? callback) {
    _callback?.dispose();
    _callback = callback;
  }

  Future<dynamic> _callStored(List<dynamic> args) async {
    final callback = _callback;
    if (callback == null) return null;
    return await callback.invoke(args);
  }

  @override
  dynamic invoke(String method, List<dynamic> params) {
    switch (method) {
      case 'hasCallback':
        return _callback != null;
      case 'clear':
        setCallback(null);
        return true;
      case 'callStored':
        return _callStored(params);
      case 'callStoredTwice':
        return Future.wait([_callStored(params), _callStored(params)]);
      case 'callStoredAndCallReturned':
        return () async {
          final callback = _callback;
          if (callback == null) return null;

          dynamic returned = await callback.invoke([params.isNotEmpty ? params[0] : null]);
          if (returned is! JSFunction) {
            return null;
          }
          return await returned.invoke(params.length > 1 ? params.sublist(1) : const []);
        }();
    }

    return Future.error(FlutterError('MethodChannelCallback: unknown method "$method"'));
  }

  @override
  void dispose() {
    setCallback(null);
  }
}
