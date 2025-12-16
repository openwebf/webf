/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'package:webf/css.dart';

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

    // For sticky positioned elements, the placeholder must reserve space in the
    // normal flow equivalent to the element's own used size so that subsequent
    // content does not collapse upward. Absolute/fixed placeholders remain size 0.
    final RenderBoxModel? rbm = positioned;
    final bool isSticky = rbm != null && rbm.renderStyle.position == CSSPositionType.sticky;
    if (isSticky) {
      double phWidth = size.width;
      double phHeight = size.height;

      // Prefer explicit CSS width/height if specified; otherwise fall back to any
      // known box size from a previous layout, but only when the positioned box
      // has a valid size. Avoid reading boxSize before the child has laid out to
      // prevent assertion failures.
      final CSSRenderStyle rs = rbm.renderStyle;
      if (rs.width.isNotAuto) {
        phWidth = rs.width.computedValue;
      } else if (rbm.hasSize && rbm.boxSize != null) {
        phWidth = rbm.boxSize!.width;
      }

      if (rs.height.isNotAuto) {
        phHeight = rs.height.computedValue;
      } else if (rbm.hasSize && rbm.boxSize != null) {
        phHeight = rbm.boxSize!.height;
      }

      // Constrain to incoming constraints if any (typically unconstrained in flow).
      final BoxConstraints c = constraints;
      final Size desired = Size(phWidth, phHeight);
      size = c.constrain(desired);
    }
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
