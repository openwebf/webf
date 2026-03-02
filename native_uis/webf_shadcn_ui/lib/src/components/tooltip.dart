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
      return const ShadAnchorAuto(
        offset: Offset(0, 4),
        followerAnchor: Alignment.bottomCenter,
        targetAnchor: Alignment.bottomCenter,
      );
    case 'left':
      return const ShadAnchorAuto(
        offset: Offset(-4, 0),
        followerAnchor: Alignment.centerLeft,
        targetAnchor: Alignment.centerLeft,
      );
    case 'right':
      return const ShadAnchorAuto(
        offset: Offset(4, 0),
        followerAnchor: Alignment.centerRight,
        targetAnchor: Alignment.centerRight,
      );
    case 'top':
    default:
      return const ShadAnchorAuto(
        offset: Offset(0, -4),
        followerAnchor: Alignment.topCenter,
        targetAnchor: Alignment.topCenter,
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
  final _tooltipController = ShadTooltipController();
  Timer? _showTimer;
  Timer? _hideTimer;
  Offset? _tapDownPosition;

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
    _tooltipController.show();
  }

  void _hideTooltipNow() {
    _showTimer?.cancel();
    _showTimer = null;
    _tooltipController.hide();
  }

  void _scheduleShow() {
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
    final delay = Duration(milliseconds: widgetElement._hideDelay);
    final effectiveDelay = delay > Duration.zero
        ? delay
        : (fallbackDelay ?? Duration.zero);
    if (effectiveDelay > Duration.zero) {
      _hideTimer = Timer(effectiveDelay, _hideTooltipNow);
    } else {
      _hideTooltipNow();
    }
  }

  void _toggleFromTap() {
    if (_tooltipController.isOpen) {
      _hideTooltipNow();
      return;
    }
    _showTooltipNow();
    // Keep tooltip visible briefly on touch interactions when hide-delay is 0.
    _scheduleHide(fallbackDelay: const Duration(milliseconds: 1500));
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
      onExit: (_) => _scheduleHide(),
      child: Listener(
        behavior: HitTestBehavior.opaque,
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

    return ShadTooltip(
      builder: (context) => Text(widgetElement.content!),
      waitDuration: Duration(milliseconds: widgetElement._showDelay),
      showDuration: Duration(milliseconds: widgetElement._hideDelay),
      anchor: _placementToAnchor(widgetElement.placement),
      controller: _tooltipController,
      child: interactiveTrigger,
    );
  }
}
