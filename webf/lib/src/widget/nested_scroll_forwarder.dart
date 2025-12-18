/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'package:flutter/widgets.dart';

/// A widget that provides scroll controllers to descendant widgets to enable
/// nested scroll forwarding.
///
/// This widget creates a chain of scrollable containers where inner scrollables
/// can forward scroll events to outer scrollables when they reach their boundaries.
class NestedScrollForwarder extends InheritedWidget {
  /// The vertical scroll controller to be shared with descendants
  final ScrollController? verticalController;

  /// The horizontal scroll controller to be shared with descendants
  final ScrollController? horizontalController;

  const NestedScrollForwarder({
    super.key,
    this.verticalController,
    this.horizontalController,
    required super.child,
  });

  /// Finds the nearest [NestedScrollForwarder] ancestor in the widget tree
  static NestedScrollForwarder? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NestedScrollForwarder>();
  }

  /// Gets the vertical scroll controller from the nearest ancestor
  static ScrollController? getVerticalController(BuildContext context) {
    return maybeOf(context)?.verticalController;
  }

  /// Gets the horizontal scroll controller from the nearest ancestor
  static ScrollController? getHorizontalController(BuildContext context) {
    return maybeOf(context)?.horizontalController;
  }

  @override
  bool updateShouldNotify(NestedScrollForwarder oldWidget) {
    return oldWidget.verticalController != verticalController ||
           oldWidget.horizontalController != horizontalController;
  }
}

/// A widget that coordinates nested scrolling between a child scrollable and
/// its parent scrollable.
///
/// This widget listens to scroll notifications from its child and forwards
/// unconsumed scroll deltas to the parent when the child reaches its scroll
/// boundaries.
class NestedScrollCoordinator extends StatelessWidget {
  /// The axis this coordinator handles (vertical or horizontal)
  final Axis axis;

  /// The scroll controller of the child scrollable
  final ScrollController controller;

  /// The child widget containing the scrollable
  final Widget child;

  /// Whether nested scrolling is enabled
  final bool enabled;

  const NestedScrollCoordinator({
    super.key,
    required this.axis,
    required this.controller,
    required this.child,
    this.enabled = true,
  });

  /// Checks if the scroll position is at the minimum extent
  bool _isAtMin(ScrollPosition position) {
    return position.pixels <= position.minScrollExtent;
  }

  /// Checks if the scroll position is at the maximum extent
  bool _isAtMax(ScrollPosition position) {
    return position.pixels >= position.maxScrollExtent;
  }

  /// Finds the parent scroll controller from ancestors
  ScrollController? _findParentController(BuildContext context) {
    // First, try to find via NestedScrollForwarder
    final forwarder = NestedScrollForwarder.maybeOf(context);
    if (forwarder != null) {
      final parentController = axis == Axis.vertical
          ? forwarder.verticalController
          : forwarder.horizontalController;

      // Make sure we're not returning our own controller
      if (parentController != null && !identical(parentController, controller)) {
        return parentController;
      }
    }

    // If not found via forwarder, search up the tree for Scrollable widgets
    ScrollController? foundController;
    context.visitAncestorElements((element) {
      if (element.widget is Scrollable) {
        final scrollable = element.widget as Scrollable;
        if (scrollable.controller != null &&
            !identical(scrollable.controller, controller) &&
            scrollable.axis == axis) {
          foundController = scrollable.controller;
          return false; // Stop searching
        }
      }
      return true; // Continue searching
    });

    return foundController;
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Only handle notifications from our direct child
        if (notification.depth != 0) return false;

        // Check if this notification is for our axis
        if (notification.metrics.axis != axis) return false;

        // Find parent controller
        final parentController = _findParentController(context);
        if (parentController == null || !parentController.hasClients) {
          return false;
        }

        // Handle different types of scroll notifications
        if (notification is OverscrollNotification) {
          // Handle overscroll by forwarding to parent
          _handleOverscroll(notification, parentController);
          return true; // Stop propagation
        } else if (notification is ScrollUpdateNotification) {
          // Check if we're at a boundary and trying to scroll further
          if (notification.dragDetails != null) {
            _handleScrollUpdate(notification, parentController);
          }
        }

        return false; // Allow notification to continue
      },
      child: child,
    );
  }

  /// Handles overscroll notifications by forwarding to parent
  void _handleOverscroll(OverscrollNotification notification, ScrollController parentController) {
    final overscroll = notification.overscroll;
    if (overscroll == 0) return;

    final parentPosition = parentController.position;
    final currentPosition = parentPosition.pixels;
    final minPosition = parentPosition.minScrollExtent;
    final maxPosition = parentPosition.maxScrollExtent;

    // Calculate new position
    final newPosition = (currentPosition + overscroll).clamp(minPosition, maxPosition);

    // Apply scroll to parent
    if (newPosition != currentPosition) {
      parentController.jumpTo(newPosition);
    }
  }

  /// Handles scroll update notifications when at boundaries
  void _handleScrollUpdate(ScrollUpdateNotification notification, ScrollController parentController) {
    if (notification.scrollDelta == null || notification.scrollDelta == 0) return;

    final position = controller.position;
    final delta = notification.scrollDelta!;

    // Check if we're at a boundary
    bool shouldForward = false;
    if (delta < 0 && _isAtMin(position)) {
      // Trying to scroll up/left while at minimum
      shouldForward = true;
    } else if (delta > 0 && _isAtMax(position)) {
      // Trying to scroll down/right while at maximum
      shouldForward = true;
    }

    if (!shouldForward) return;

    // Forward to parent
    final parentPosition = parentController.position;
    final currentPosition = parentPosition.pixels;
    final minPosition = parentPosition.minScrollExtent;
    final maxPosition = parentPosition.maxScrollExtent;

    final newPosition = (currentPosition + delta).clamp(minPosition, maxPosition);

    if (newPosition != currentPosition) {
      parentController.jumpTo(newPosition);
    }
  }
}
