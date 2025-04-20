import 'dart:async';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart';

class DemoModule extends BaseModule {
  DemoModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  String get name => "Demo";

  @override
  dynamic invoke(String method, params) {
    switch (method) {
      case 'noParams':
        assert(params == null);
        return true;
      case 'callInt':
        assert(params is int);
        return params + params;
      case 'callDouble':
        assert(params is double);
        return (params as double) + params;
      case 'callString':
        assert(params == 'helloworld');
        return (params as String).toUpperCase();
      case 'callArray':
        assert(params is List);
        return (params as List).reduce((e, i) => e + i);
      case 'callNull':
        return null;
      case 'callObject':
        assert(params is Map);
        return params['value'];
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
