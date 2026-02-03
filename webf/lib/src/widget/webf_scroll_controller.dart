/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/widgets.dart';

/// A [ScrollController] used by WebF overflow scroll containers.
///
/// This controller creates a custom [ScrollPosition] that avoids triggering a
/// ballistic activity during the layout phase when scroll metrics change but
/// the position is already in range. This prevents some third-party physics
/// implementations from calling setState during layout via
/// `createBallisticSimulation()`.
class WebFScrollController extends ScrollController {
  WebFScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
    super.onAttach,
    super.onDetach,
  });

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return WebFScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class WebFScrollPositionWithSingleContext
    extends ScrollPositionWithSingleContext {
  WebFScrollPositionWithSingleContext({
    required super.physics,
    required super.context,
    double? initialPixels = 0.0,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  }) : super(initialPixels: initialPixels);

  @override
  void goIdle() {
    beginActivity(_WebFIdleScrollActivity(this));
  }
}

class _WebFIdleScrollActivity extends IdleScrollActivity {
  _WebFIdleScrollActivity(super.delegate);

  @override
  void applyNewDimensions() {
    final ScrollActivityDelegate activityDelegate = delegate;
    final ScrollMetrics? metrics = activityDelegate is ScrollMetrics
        ? (activityDelegate as ScrollMetrics)
        : null;
    if (metrics != null && metrics.outOfRange) {
      activityDelegate.goBallistic(0.0);
    }
  }
}
