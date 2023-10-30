/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/svg.dart';

import '../core/aspect_ratio.dart';
import 'container.dart';

class RenderSVGRoot extends RenderSVGContainer {
  Rect? _viewBox;

  // the developer provided viewbox, maybe is null
  get viewBox => _viewBox;

  set viewBox(value) {
    _viewBox = value;
    markNeedsPaint();
  }

  Rect _renderViewBox = DEFAULT_VIEW_BOX;

  // the final viewbox to render
  get renderViewBox => _renderViewBox;

  SVGPreserveAspectRatio _ratio;

  get ratio => _ratio;

  set ratio(val) {
    _ratio = val;
    markNeedsPaint();
  }

  @override
  get isRepaintBoundary => true;

  final _outerClipLayer = LayerHandle<ClipRectLayer>();
  final _innerClipLayer = LayerHandle<ClipRectLayer>();
  final _transformLayer = LayerHandle<TransformLayer>();

  RenderSVGRoot({
    required super.renderStyle,
    super.element,
    Rect? viewBox,
    SVGPreserveAspectRatio ratio = const SVGPreserveAspectRatio(),
  })  : _viewBox = viewBox,
        _ratio = ratio {}

  @override
  void performPaint(PaintingContext context, Offset offset) {
    _outerClipLayer.layer = context
        .pushClipRect(true, offset, Offset.zero & size, (context, offset) {
      _transformLayer.layer = context
          .pushTransform(false, offset, _ratio.getMatrix(_renderViewBox, size),
              (context, offset) {
        _innerClipLayer.layer = context
            .pushClipRect(false, offset, _renderViewBox, (context, offset) {
          // Draw debug rect
          // context.canvas.drawRect(_renderViewBox, Paint()..color = Color.fromARGB(255, 255, 0, 0)..style = PaintingStyle.stroke);
          visitChildren((child) {
            context.paintChild(child, offset);
          });
        }, oldLayer: _innerClipLayer.layer);
      }, oldLayer: _transformLayer.layer);
    }, oldLayer: _outerClipLayer.layer);
    // Debug rect
    // context.canvas.drawRect(offset & size, Paint()..color = Color.fromARGB(255, 0, 255, 0)..style = PaintingStyle.stroke);
  }

  @override
  void performLayout() {
    var width = renderStyle.width.isAuto
        ? DEFAULT_VIEW_BOX_WIDTH
        : renderStyle.width.computedValue;
    var height = renderStyle.height.isAuto
        ? DEFAULT_VIEW_BOX_HEIGHT
        : renderStyle.height.computedValue;

    width = width.isInfinite ? DEFAULT_VIEW_BOX_WIDTH : width;
    height = height.isInfinite ? DEFAULT_VIEW_BOX_HEIGHT : height;

    final biggestSize = constraints.biggest;

    size = biggestSize.isFinite ? biggestSize : constraints.constrain(Size(width, height));

    if (_viewBox == null) {
      // When viewBox is not valid, should use width/height
      // To keep same behavior with Chrome
      _renderViewBox = Rect.fromLTWH(0, 0, width, height);
    } else {
      _renderViewBox = viewBox;
    }

    visitChildren((child) {
      // unconstraint child size
      child.layout(BoxConstraints());
    });
    // HACK: must be call this function otherwise the BoxModel cannot works correctly.
    // Improve it in the future.
    initOverflowLayout(Rect.fromLTWH(0, 0, size.width, size.height),
        Rect.fromLTWH(0, 0, size.width, size.height));
    dispatchResize(contentSize, boxSize ?? Size.zero);
  }

  @override
  void dispose() {
    super.dispose();
    _outerClipLayer.layer = null;
    _innerClipLayer.layer = null;
    _transformLayer.layer = null;
  }
}
