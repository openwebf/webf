/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/foundation/positioned_layout_logging.dart';

/// A placeholder for positioned RenderBox
class RenderPositionPlaceholder extends RenderPreferredSize {
  RenderPositionPlaceholder({
    required super.preferredSize,
    this.positioned,
    super.child,
  });

  // Real position of this renderBox.
  RenderBoxModel? positioned;

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  Size? _boxSize;

  Size? get boxSize {
    assert(_boxSize != null, 'box does not have laid out.');
    return _boxSize;
  }

  @override
  set size(Size value) {
    _boxSize = value;
    super.size = value;
  }

  @override
  void performLayout() {
    super.performLayout();
    // The relative offset of positioned renderBox are depends on positionHolder' offset.
    // When the placeHolder got layout, should notify the positioned renderBox to layout again.
    try {
      final String mapped = positioned?.renderStyle.target.tagName.toLowerCase() ?? '';
      final Offset? off = (parentData is RenderLayoutParentData) ? (parentData as RenderLayoutParentData).offset : null;
      PositionedLayoutLog.log(
        impl: PositionedImpl.placeholder,
        feature: PositionedFeature.layout,
        message: () => 'layout size=${size.width.toStringAsFixed(2)}×${size.height.toStringAsFixed(2)} '
            'offset=${off == null ? 'null' : '${off.dx.toStringAsFixed(2)},${off.dy.toStringAsFixed(2)}'} '
            'mappedTo=<$mapped>',
      );
    } catch (_) {}
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      if (positioned?.disposed == false) {
        positioned?.markNeedsLayout();
      }
    });
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    return false;
  }

  // Get the layout offset of renderObject to its ancestor which does not include the paint offset
  // such as scroll or transform.
  Offset getOffsetToAncestor(Offset point, RenderObject ancestor, {bool excludeScrollOffset = false}) {
    return getLayoutTransformTo(this, ancestor, excludeScrollOffset: excludeScrollOffset) + point;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('positioned', positioned));
  }
}

bool isPositionPlaceholder(RenderBox box) {
  return box is RenderPositionPlaceholder;
}
