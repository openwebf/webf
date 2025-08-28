/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Provides ancestor scroll controllers to descendants to enable nested scrolling.
///
/// Wrap each scrollable created for CSS overflow with this widget so inner
/// scrollables can find the nearest parent scroll controller on the same axis
/// and forward unconsumed deltas to it when reaching bounds.
class NestedScrollForwarder extends InheritedWidget {
  final ScrollController? vertical;
  final ScrollController? horizontal;

  const NestedScrollForwarder({
    super.key,
    this.vertical,
    this.horizontal,
    required super.child,
  });

  static NestedScrollForwarder? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NestedScrollForwarder>();
  }

  @override
  bool updateShouldNotify(NestedScrollForwarder oldWidget) {
    return oldWidget.vertical != vertical || oldWidget.horizontal != horizontal;
  }
}

/// Listens to scroll notifications from a child Scrollable and forwards
/// leftover deltas to the nearest ancestor scrollable on the same axis.
class NestedScrollCoordinator extends StatelessWidget {
  final Axis axis;
  final ScrollController controller;
  final Widget child;
  final bool enabled;

  const NestedScrollCoordinator({
    super.key,
    required this.axis,
    required this.controller,
    required this.child,
    this.enabled = true,
  });

  bool _atMin(ScrollPosition pos) => pos.pixels <= pos.minScrollExtent && !pos.outOfRange;
  bool _atMax(ScrollPosition pos) => pos.pixels >= pos.maxScrollExtent && !pos.outOfRange;

  NestedScrollForwarder? _findAncestorForwarder(BuildContext context) {
    NestedScrollForwarder? found;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is NestedScrollForwarder) {
        final candidate = axis == Axis.vertical ? widget.vertical : widget.horizontal;
        if (candidate != null && !identical(candidate, controller)) {
          found = widget;
          return false; // stop visiting
        }
      }
      return true; // continue
    });
    return found;
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    double? lastDelta; // cache last non-zero delta

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Only care about notifications from our child scrollable and matching axis.
        if (notification.metrics.axis == Axis.horizontal && axis != Axis.horizontal) return false;
        if (notification.metrics.axis == Axis.vertical && axis != Axis.vertical) return false;

        // Find the nearest ancestor forwarder that is not bound to our own controller.
        final parent = _findAncestorForwarder(context) ?? NestedScrollForwarder.maybeOf(context);
        if (parent == null) return false;

        final ScrollController? parentController =
            axis == Axis.vertical ? parent.vertical : parent.horizontal;

        if (parentController == null) return false;
        if (identical(parentController, controller)) return false;

        if (notification is ScrollUpdateNotification && notification.dragDetails == null) {
          return false;
        }
        if (notification is OverscrollNotification && notification.dragDetails == null) {
          return false;
        }

        if (notification is ScrollUpdateNotification) {
          if (notification.scrollDelta != null && notification.scrollDelta!.abs() > 0.0) {
            lastDelta = notification.scrollDelta;
          }
        }

        double? delta;
        if (notification is OverscrollNotification) {
          delta = notification.overscroll;
        } else if (notification is UserScrollNotification) {
          final ScrollDirection dir = notification.direction;
          final AxisDirection axisDir = notification.metrics.axisDirection;
          final double signFactor = (axisDir == AxisDirection.down || axisDir == AxisDirection.right) ? 1.0 : -1.0;
          final bool isForward = dir == ScrollDirection.forward;
          final double intendedSign = isForward ? signFactor : -signFactor;
          final bool atMin = _atMin(controller.position);
          final bool atMax = _atMax(controller.position);
          if ((atMin && intendedSign > 0) || (atMax && intendedSign < 0)) {
            final double mag = (lastDelta?.abs() ?? 20.0);
            delta = intendedSign * mag;
          }
        } else {
          return false;
        }

        if (delta == null || delta == 0.0) return false;
        //
        final pos = controller.position;
        final atMin = _atMin(pos);
        final atMax = _atMax(pos);
        final bool tryingUpwards = delta < 0.0; // up/left
        final bool tryingDownwards = delta > 0.0; // down/right

        // Forward only when this scrollable can't consume more in that direction.
        bool shouldForward = (tryingUpwards && atMin) || (tryingDownwards && atMax);
        if (!shouldForward) return false;

        final parentPos = parentController.position;
        final double before = parentPos.pixels;
        final double minE = parentPos.minScrollExtent;
        final double maxE = parentPos.maxScrollExtent;
        final target = (before + delta)
            .clamp(parentPos.minScrollExtent, parentPos.maxScrollExtent)
            .toDouble();
        try {
          // Use jumpTo for synchronous handoff during drag.
          parentController.jumpTo(target);
        } catch (_) {
          // Ignore if parent not attached yet.
        }

        // Stop bubbling so only the nearest ancestor handles this.
        return true;
      },
      child: child,
    );
  }
}
