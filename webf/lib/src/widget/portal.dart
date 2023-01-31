import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

/// Portal is essential to capture WebF gestures on WebF elements when the renderObject is located outside of WebF's root renderObject tree.
/// Exp: using [showModalBottomSheet] or [showDialog], it will create a standalone Widget Tree alone side with the original Widget Tree.
/// Use this widget to make the gesture dispatcher works.
class Portal extends SingleChildRenderObjectWidget {
  final dom.Element webFElement;

  Portal({Widget? child, required this.webFElement}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPortal(controller: webFElement.ownerDocument.controller);
  }

  @override
  _PortalElement createElement() => _PortalElement(this);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {}
}

class _PortalElement extends SingleChildRenderObjectElement {
  _PortalElement(super.widget);

  @override
  Portal get widget => super.widget as Portal;

  @override
  RenderPortal get renderObject => super.renderObject as RenderPortal;

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child as RenderBox;
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    renderObject.child = null;
  }
}
