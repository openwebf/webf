import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'nested_scroll_forwarder.dart';

class WebFEnsureVisible {
  static bool _isOnScreen(RenderObject target, RenderViewportBox root) {
    final Rect bounds = target.paintBounds;
    final Offset toRoot = (target as RenderBox).localToGlobal(Offset.zero, ancestor: root);
    final Rect rectOnRoot = bounds.shift(toRoot);
    final Size visible = root.size;

    final bool result = rectOnRoot.top >= 0 && rectOnRoot.bottom <= visible.height;
    return result;
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
    if (target == null || !target.attached) {
      return;
    }

    // Find root WebF viewport.
    RenderViewportBox? root;
    RenderObject? r = target.parent as RenderObject?;
    while (r != null) {
      if (r is RenderViewportBox) { root = r; break; }
      r = (r.parent as RenderObject?);
    }
    if (root == null) {
      return;
    }

    // Gather ancestor scroll positions (nearest first).
    final positions = <ScrollPosition>[];
    targetContext.visitAncestorElements((el) {
      if (el is StatefulElement && el.state is ScrollableState) {
        positions.add((el.state as ScrollableState).position);
      }
      return true;
    });
    if (positions.isEmpty) {
      return;
    }

    await SchedulerBinding.instance.endOfFrame;

    // Try each vertical ScrollPosition in order until the target is on screen.
    for (final pos in positions) {
      if (pos.axis == Axis.vertical) {
        await pos.ensureVisible(
          target,
          alignment: alignment,
          duration: duration,
          curve: curve,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          targetRenderObject: null,
        );
        await SchedulerBinding.instance.endOfFrame;
        final bool isOnScreen = _isOnScreen(target, root);
        if (isOnScreen) {
          return;
        }
      }
    }
  }
}
