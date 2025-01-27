import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';

class RenderLayoutBoxWrapper extends RenderProxyBox {
  RenderLayoutBoxWrapper();

  @override
  void performLayout() {
    super.performLayout();

    if (child is RenderLayoutBox) {
      size = constraints.constrain((child as RenderLayoutBox).scrollableSize);
    }
  }
}

class LayoutBoxWrapper extends SingleChildRenderObjectWidget {
  LayoutBoxWrapper({ required Widget child }): super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLayoutBoxWrapper();
  }
}