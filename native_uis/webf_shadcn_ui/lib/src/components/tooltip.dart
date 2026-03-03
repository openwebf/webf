/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'tooltip_bindings_generated.dart';

ShadAnchorBase _placementToAnchor(String placement) {
  switch (placement) {
    case 'bottom':
      return const ShadAnchor(
        offset: Offset(0, 4),
        childAlignment: Alignment.topCenter,
        overlayAlignment: Alignment.bottomCenter,
      );
    case 'left':
      return const ShadAnchor(
        offset: Offset(-4, 0),
        childAlignment: Alignment.centerRight,
        overlayAlignment: Alignment.centerLeft,
      );
    case 'right':
      return const ShadAnchor(
        offset: Offset(4, 0),
        childAlignment: Alignment.centerLeft,
        overlayAlignment: Alignment.centerRight,
      );
    case 'top':
    default:
      return const ShadAnchor(
        offset: Offset(0, -4),
        childAlignment: Alignment.bottomCenter,
        overlayAlignment: Alignment.topCenter,
      );
  }
}

/// WebF custom element that wraps shadcn_ui [ShadTooltip].
///
/// Exposed as `<flutter-shadcn-tooltip>` in the DOM.
class FlutterShadcnTooltip extends FlutterShadcnTooltipBindings {
  FlutterShadcnTooltip(super.context);

  String? _content;
  int _showDelay = 200;
  int _hideDelay = 0;
  String _placement = 'top';

  @override
  String? get content => _content;

  @override
  set content(value) {
    final newValue = value?.toString();
    if (newValue != _content) {
      _content = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get showDelay => _showDelay.toString();

  @override
  set showDelay(value) {
    final newValue = int.tryParse(value?.toString() ?? '') ?? 200;
    if (newValue != _showDelay) {
      _showDelay = newValue;
    }
  }

  @override
  String get hideDelay => _hideDelay.toString();

  @override
  set hideDelay(value) {
    final newValue = int.tryParse(value?.toString() ?? '') ?? 0;
    if (newValue != _hideDelay) {
      _hideDelay = newValue;
    }
  }

  @override
  String get placement => _placement;

  @override
  set placement(value) {
    final newValue = value?.toString() ?? 'top';
    if (newValue != _placement) {
      _placement = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnTooltipState(this);
}

class FlutterShadcnTooltipState extends WebFWidgetElementState {
  FlutterShadcnTooltipState(super.widgetElement);
  final _tooltipController = ShadPopoverController();
  Timer? _showTimer;
  Timer? _hideTimer;
  Offset? _tapDownPosition;
  DateTime? _lastShownAt;
  bool _openedByTap = false;

  @override
  FlutterShadcnTooltip get widgetElement =>
      super.widgetElement as FlutterShadcnTooltip;

  void _cancelTimers() {
    _showTimer?.cancel();
    _showTimer = null;
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _showTooltipNow() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _lastShownAt = DateTime.now();
    _tooltipController.show();
  }

  void _hideTooltipNow() {
    _showTimer?.cancel();
    _showTimer = null;
    _openedByTap = false;
    _tooltipController.hide();
  }

  void _scheduleShow() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _showTimer?.cancel();
    final delay = Duration(milliseconds: widgetElement._showDelay);
    if (delay > Duration.zero) {
      _showTimer = Timer(delay, _showTooltipNow);
    } else {
      _showTooltipNow();
    }
  }

  void _scheduleHide({Duration? fallbackDelay}) {
    _hideTimer?.cancel();
    final configuredDelay = Duration(milliseconds: widgetElement._hideDelay);
    var effectiveDelay = configuredDelay > Duration.zero
        ? configuredDelay
        : (fallbackDelay ?? Duration.zero);

    if (_lastShownAt != null) {
      const minVisible = Duration(milliseconds: 280);
      final elapsed = DateTime.now().difference(_lastShownAt!);
      if (elapsed < minVisible) {
        final remaining = minVisible - elapsed;
        if (remaining > effectiveDelay) {
          effectiveDelay = remaining;
        }
      }
    }

    if (effectiveDelay > Duration.zero) {
      _hideTimer = Timer(effectiveDelay, _hideTooltipNow);
    } else {
      _hideTooltipNow();
    }
  }

  void _toggleFromTap() {
    if (_tooltipController.isOpen && _openedByTap) {
      _hideTooltipNow();
      return;
    }
    _openedByTap = true;
    _showTooltipNow();
    if (widgetElement._hideDelay <= 0) {
      _scheduleHide(fallbackDelay: const Duration(milliseconds: 2000));
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? childWidget;
    if (widgetElement.childNodes.isNotEmpty) {
      childWidget = WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'SPAN',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          inlineStyle: const {'display': 'inline-block'},
          children: widgetElement.childNodes.toWidgetList(),
        ),
      );
    }

    if (widgetElement.content == null || childWidget == null) {
      return childWidget ?? const SizedBox.shrink();
    }

    final interactiveTrigger = MouseRegion(
      onEnter: (_) => _scheduleShow(),
      onHover: (_) => _scheduleShow(),
      onExit: (_) {
        if (_openedByTap) return;
        _scheduleHide(fallbackDelay: const Duration(milliseconds: 350));
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerHover: (_) => _scheduleShow(),
        onPointerMove: (_) => _scheduleShow(),
        onPointerDown: (event) {
          _tapDownPosition = event.position;
        },
        onPointerUp: (event) {
          if (_tapDownPosition == null) return;
          final distance = (event.position - _tapDownPosition!).distance;
          _tapDownPosition = null;
          if (distance < 20) {
            _toggleFromTap();
          }
        },
        onPointerCancel: (_) {
          _tapDownPosition = null;
        },
        child: childWidget,
      ),
    );

    final theme = ShadTheme.of(context);
    final tooltipTheme = theme.tooltipTheme;

    return ShadPopover(
      controller: _tooltipController,
      anchor: _placementToAnchor(widgetElement.placement),
      closeOnTapOutside: true,
      effects: tooltipTheme.effects,
      reverseDuration: tooltipTheme.reverseDuration,
      padding: tooltipTheme.padding,
      decoration: tooltipTheme.decoration,
      popover: (_) => Text(
        widgetElement.content!,
        style: theme.textTheme.muted.copyWith(
          color: theme.colorScheme.popoverForeground,
        ),
      ),
      child: interactiveTrigger,
    );
  }
}
