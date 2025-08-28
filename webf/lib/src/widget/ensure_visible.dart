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
    
    print('[_isOnScreen] bounds: $bounds');
    print('[_isOnScreen] toRoot offset: $toRoot');
    print('[_isOnScreen] rectOnRoot: $rectOnRoot');
    print('[_isOnScreen] visible size: $visible');
    print('[_isOnScreen] top check: ${rectOnRoot.top} >= 0 = ${rectOnRoot.top >= 0}');
    print('[_isOnScreen] bottom check: ${rectOnRoot.bottom} <= ${visible.height} = ${rectOnRoot.bottom <= visible.height}');
    
    final bool result = rectOnRoot.top >= 0 && rectOnRoot.bottom <= visible.height;
    print('[_isOnScreen] Result: $result');
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
    print('[WebFEnsureVisible] acrossScrollables called');
    final RenderObject? target = targetContext.findRenderObject();
    if (target == null || !target.attached) {
      print('[WebFEnsureVisible] Target render object not found or not attached');
      return;
    }
    print('[WebFEnsureVisible] Target render object: ${target.runtimeType}');

    // Find root WebF viewport.
    RenderViewportBox? root;
    RenderObject? r = target.parent as RenderObject?;
    while (r != null) {
      if (r is RenderViewportBox) { root = r; break; }
      r = (r.parent as RenderObject?);
    }
    if (root == null) {
      print('[WebFEnsureVisible] No RenderViewportBox found in ancestor chain');
      return;
    }
    print('[WebFEnsureVisible] Found root viewport: ${root.runtimeType}');

    // Gather ancestor scroll positions (nearest first).
    final positions = <ScrollPosition>[];
    targetContext.visitAncestorElements((el) {
      if (el is StatefulElement && el.state is ScrollableState) {
        positions.add((el.state as ScrollableState).position);
        print('[WebFEnsureVisible] Found ScrollableState: ${el.state.runtimeType}');
      }
      return true;
    });
    if (positions.isEmpty) {
      print('[WebFEnsureVisible] No ScrollableState found in ancestor chain');
      return;
    }
    print('[WebFEnsureVisible] Found ${positions.length} scroll positions');

    await SchedulerBinding.instance.endOfFrame;

    // Try each vertical ScrollPosition in order until the target is on screen.
    for (final pos in positions) {
      print('[WebFEnsureVisible] Processing position: axis=${pos.axis}, pixels=${pos.pixels}');
      if (pos.axis == Axis.vertical) {
        print('[WebFEnsureVisible] Calling ensureVisible on vertical position');
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
        print('[WebFEnsureVisible] After ensureVisible: isOnScreen=$isOnScreen');
        if (isOnScreen) {
          print('[WebFEnsureVisible] Target is now visible, done');
          return;
        }
      }
    }
    print('[WebFEnsureVisible] Finished processing all positions');
    //
    // if (!_isOnScreen(target, root)) {
    //   await SchedulerBinding.instance.endOfFrame;
    //   for (final pos in positions) {
    //     if (pos.axis == Axis.vertical) {
    //       await pos.ensureVisible(
    //         target,
    //         alignment: alignment,
    //         duration: duration,
    //         curve: curve,
    //         alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    //         targetRenderObject: null,
    //       );
    //       if (_isOnScreen(target, root)) break;
    //     }
    //   }
    // }
  }

  static Future<void> _waitForIdle(List<ScrollPosition> positions) async {
    final futures = <Future<void>>[];
    for (final p in positions) {
      if (p.activity?.isScrolling == true) {
        final c = Completer<void>();
        void listener() {
          if (!(p.activity?.isScrolling == true)) {
            p.isScrollingNotifier.removeListener(listener);
            if (!c.isCompleted) c.complete();
          }
        }
        p.isScrollingNotifier.addListener(listener);
        futures.add(c.future);
      }
    }
    if (futures.isNotEmpty) {
      await Future.any([
        Future.wait(futures),
        Future.delayed(const Duration(milliseconds: 250)),
      ]);
    }
  }
}
