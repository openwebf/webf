import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart' as dom;

class RenderLayoutBoxWrapper extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderLayoutBoxWrapper({
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
  }

  @override
  void performLayout() {
    super.performLayout();

    if (child is RenderLayoutBox) {
      double childMarginTop = renderStyle.marginTop.computedValue;
      double childMarginBottom = renderStyle.marginBottom.computedValue;
      Size scrollableSize = (child as RenderLayoutBox).scrollableSize;

      size = constraints.constrain(Size(scrollableSize.width, childMarginTop + scrollableSize.height + childMarginBottom));

      double childMarginLeft = renderStyle.marginLeft.computedValue;

      // No need to add padding and border for scrolling content box.
      Offset relativeOffset = Offset(childMarginLeft, childMarginTop);
      // Apply position relative offset change.
      CSSPositionedLayout.applyRelativeOffset(relativeOffset, child as RenderLayoutBox);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child == null) {
      return;
    }
    final BoxParentData childParentData = child.parentData as BoxParentData;
    context.paintChild(child, offset + childParentData.offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final RenderBox? child = this.child;
    if (child == null) {
      return false;
    }
    final BoxParentData childParentData = child.parentData as BoxParentData;
    return super.hitTest(result, position: position - childParentData.offset);
  }
}

class LayoutBoxWrapper extends SingleChildRenderObjectWidget {
  final dom.Element ownerElement;

  LayoutBoxWrapper({required Widget child, required this.ownerElement}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLayoutBoxWrapper(renderStyle: ownerElement.renderStyle);
  }
}
