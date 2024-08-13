import 'dart:async';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart';

class DemoModule extends BaseModule {
  DemoModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  String get name => "Demo";

  @override
  dynamic invoke(String method, params, InvokeModuleCallback callback) {
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
      case 'callAsyncFn':
        Timer(Duration(milliseconds: 100), () async {
          dynamic returnValue = await callback(data: [
            1,
            '2',
            null,
            4.0,
            {'value': 1}
          ]);
          assert(returnValue == 'success');
        });
        return params;
      case 'callAsyncFnFail':
        Timer(Duration(milliseconds: 100), () async {
          dynamic returnValue = await callback(error: 'Must to fail');
          assert(returnValue == 'fail');
        });
        return null;
      case 'callToDispatchEvent':
        CustomEvent customEvent = CustomEvent('click', detail: 'helloworld');
        dynamic result =
            dispatchEvent(event: customEvent, data: [1, 2, 3, 4, 5]);
        assert(result == 'success');
    }
  }

  @override
  void dispose() {}
}
