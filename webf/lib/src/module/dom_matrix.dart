import 'package:webf/bridge.dart';
import 'package:webf/geometry.dart';
import 'package:webf/module.dart';

class DOMMatrixModule extends BaseModule {
  DOMMatrixModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  invoke(String method, params, InvokeModuleCallback callback) {
    if (method == 'fromMatrix') {
      if (params.runtimeType == DOMMatrix) {
        DOMMatrix domMatrix = (params as DOMMatrix);
        return DOMMatrix.fromMatrix4(
            BindingContext(domMatrix.ownerView, domMatrix.ownerView.contextId, allocateNewBindingObject()),
            domMatrix.matrix.clone(),
            domMatrix.is2D);
      }
    }
  }

  @override
  String get name => 'DOMMatrix';

}
