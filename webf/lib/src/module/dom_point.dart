import 'package:webf/bridge.dart';
import 'package:webf/module.dart';
import 'package:webf/src/geometry/dom_point.dart';

class DOMPointModule extends BaseModule {
  DOMPointModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  invoke(String method, params, InvokeModuleCallback callback) {
    if (method == 'fromPoint') {
      if (params.runtimeType == DOMPoint) {
        DOMPoint domPoint = (params as DOMPoint);

        return DOMPoint.fromPoint(
            BindingContext(domPoint.ownerView, domPoint.ownerView.contextId, allocateNewBindingObject()), domPoint);
      }
    }
  }

  @override
  String get name => 'DOMPoint';

}
