import 'package:webf/module.dart';

class DOMMatrixModule extends BaseModule {
  DOMMatrixModule(super.moduleManager);

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
