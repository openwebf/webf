import 'dart:async';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart';

class DemoModule extends BaseModule {
  DemoModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  String get name => "Demo";

  @override
  dynamic invoke(String method, List<dynamic> params) {
    switch (method) {
      case 'noParams':
        assert(params.isEmpty);
        return true;
      case 'callInt':
        assert(params[0] is int);
        return params[0] + params[0];
      case 'callDouble':
        assert(params[0] is double);
        return (params[0] as double) + params[0];
      case 'callString':
        assert(params[0] == 'helloworld');
        return (params[0] as String).toUpperCase();
      case 'callArray':
        assert(params[0] is List);
        return (params[0] as List).reduce((e, i) => e + i);
      case 'callNull':
        return null;
      case 'callObject':
        assert(params[0] is Map);
        return params[0]['value'];
      case 'callToDispatchEvent':
        CustomEvent customEvent = CustomEvent('click', detail: 'helloworld');
        dispatchEvent(event: customEvent, data: [1, 2, 3, 4, 5]).then((result) {
          assert(result == 'success');
        });
        return '';
    }
  }

  @override
  void dispose() {}
}
