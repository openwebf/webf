/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'badge_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadBadge].
///
/// Exposed as `<flutter-shadcn-badge>` in the DOM.
class FlutterShadcnBadge extends FlutterShadcnBadgeBindings {
  FlutterShadcnBadge(super.context);

  String _variant = 'default';

  @override
  String get variant => _variant;

  @override
  set variant(value) {
    final newValue = value?.toString() ?? 'default';
    if (newValue != _variant) {
      _variant = newValue;
      state?.requestUpdateState(() {});
    }
  }

  ShadBadgeVariant get badgeVariant {
    switch (_variant.toLowerCase()) {
      case 'secondary':
        return ShadBadgeVariant.secondary;
      case 'destructive':
        return ShadBadgeVariant.destructive;
      case 'outline':
        return ShadBadgeVariant.outline;
      default:
        return ShadBadgeVariant.primary;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnBadgeState(this);
}

class FlutterShadcnBadgeState extends WebFWidgetElementState {
  FlutterShadcnBadgeState(super.widgetElement);

  @override
  FlutterShadcnBadge get widgetElement =>
      super.widgetElement as FlutterShadcnBadge;

  /// Extract text content from a list of nodes recursively.
  String _extractTextContent(Iterable<Node> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is TextNode) {
        buffer.write(node.data);
      } else if (node.childNodes.isNotEmpty) {
        buffer.write(_extractTextContent(node.childNodes));
      }
    }
    return buffer.toString().trim();
  }

  /// Get the foreground color for the badge based on its variant.
  Color? _getForegroundColor(BuildContext context) {
    final theme = ShadTheme.of(context);
    final ShadBadgeTheme badgeTheme;

    switch (widgetElement.badgeVariant) {
      case ShadBadgeVariant.primary:
        badgeTheme = theme.primaryBadgeTheme;
        break;
      case ShadBadgeVariant.secondary:
        badgeTheme = theme.secondaryBadgeTheme;
        break;
      case ShadBadgeVariant.destructive:
        badgeTheme = theme.destructiveBadgeTheme;
        break;
      case ShadBadgeVariant.outline:
        badgeTheme = theme.outlineBadgeTheme;
        break;
    }

    return badgeTheme.foregroundColor;
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = _getForegroundColor(context);

    Widget? childWidget;
    if (widgetElement.childNodes.isNotEmpty) {
      final textContent = _extractTextContent(widgetElement.childNodes);
      if (textContent.isNotEmpty) {
        childWidget = Text(
          textContent,
          style: TextStyle(color: foregroundColor),
        );
      }
    }

    childWidget ??= const SizedBox.shrink();

    // Use named constructors based on variant
    switch (widgetElement.badgeVariant) {
      case ShadBadgeVariant.secondary:
        return ShadBadge.secondary(child: childWidget);
      case ShadBadgeVariant.destructive:
        return ShadBadge.destructive(child: childWidget);
      case ShadBadgeVariant.outline:
        return ShadBadge.outline(child: childWidget);
      default:
        return ShadBadge(child: childWidget);
    }
  }
}
