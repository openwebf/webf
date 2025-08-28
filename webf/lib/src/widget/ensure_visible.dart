import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';

class WebFEnsureVisible {
  static bool _isOnScreen(RenderObject target, RenderViewportBox root) {
    final Rect bounds = target.paintBounds;
    final Offset toRoot = getLayoutTransformTo(target, root);
    final Rect rectOnRoot = bounds.shift(toRoot);
    final Size visible = root.size;
    return rectOnRoot.top >= 0 && rectOnRoot.bottom <= visible.height;
  }

  /// Ensures [targetContext] is visible by cascading ensures across nested scrollables (inner → outer).
  /// This is IME-friendly and will use each ancestor ScrollPosition.ensureVisible in order.
  static Future<void> acrossScrollables(
    BuildContext targetContext, {
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    double alignment = 0,
  }) async {
    final RenderObject? target = targetContext.findRenderObject();
    if (target == null || !target.attached) return;

    // Find root WebF viewport.
    RenderViewportBox? root;
    RenderObject? r = target.parent as RenderObject?;
    while (r != null) {
      if (r is RenderViewportBox) { root = r; break; }
      r = (r.parent as RenderObject?);
    }
    if (root == null) return;

    // Gather ancestor scroll positions (nearest first).
    final positions = <ScrollPosition>[];
    targetContext.visitAncestorElements((el) {
      if (el is StatefulElement && el.state is ScrollableState) {
        positions.add((el.state as ScrollableState).position);
      }
      return true;
    });
    if (positions.isEmpty) return;

    // Try each vertical ScrollPosition in order until the target is on screen.
    for (final pos in positions) {
      if (pos.axis == Axis.vertical) {
        await pos.ensureVisible(
          target,
          alignment: alignment,
          duration: duration,
          curve: curve,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
          targetRenderObject: null,
        );
        if (_isOnScreen(target, root)) break;
      }
    }
  }
}

