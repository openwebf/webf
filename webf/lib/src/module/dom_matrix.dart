import 'package:webf/module.dart';

class DOMMatrix extends BaseModule {
  DOMMatrix(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  invoke(String method, params, InvokeModuleCallback callback) {
    if (method == 'fromMatrix') {
        print('call DOMMatrix.fromMatrix');
    }
  }

  @override
  String get name => 'DOMMatrix';

}
