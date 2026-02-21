/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'popover_bindings_generated.dart';

/// Converts a placement string (e.g. 'top', 'bottom-start') to a
/// [ShadAnchorAuto] anchor for the popover.
ShadAnchorBase _placementToAnchor(String placement, String align) {
  // Parse combined placement like "top-start", "bottom-end"
  String side = placement;
  String resolvedAlign = align;
  if (placement.contains('-')) {
    final parts = placement.split('-');
    side = parts[0];
    if (resolvedAlign == 'center') {
      resolvedAlign = parts[1];
    }
  }

  switch (side) {
    case 'top':
      return ShadAnchorAuto(
        offset: const Offset(0, -4),
        followerAnchor: _alignToFollower('top', resolvedAlign),
        targetAnchor: _alignToTarget('top', resolvedAlign),
      );
    case 'left':
      return ShadAnchorAuto(
        offset: const Offset(-4, 0),
        followerAnchor: _alignToFollower('left', resolvedAlign),
        targetAnchor: _alignToTarget('left', resolvedAlign),
      );
    case 'right':
      return ShadAnchorAuto(
        offset: const Offset(4, 0),
        followerAnchor: _alignToFollower('right', resolvedAlign),
        targetAnchor: _alignToTarget('right', resolvedAlign),
      );
    case 'bottom':
    default:
      return ShadAnchorAuto(
        offset: const Offset(0, 4),
        followerAnchor: _alignToFollower('bottom', resolvedAlign),
        targetAnchor: _alignToTarget('bottom', resolvedAlign),
      );
  }
}

Alignment _alignToFollower(String side, String align) {
  switch (side) {
    case 'top':
      return switch (align) {
        'start' => Alignment.topLeft,
        'end' => Alignment.topRight,
        _ => Alignment.topCenter,
      };
    case 'bottom':
      return switch (align) {
        'start' => Alignment.bottomLeft,
        'end' => Alignment.bottomRight,
        _ => Alignment.bottomCenter,
      };
    case 'left':
      return switch (align) {
        'start' => Alignment.topLeft,
        'end' => Alignment.bottomLeft,
        _ => Alignment.centerLeft,
      };
    case 'right':
      return switch (align) {
        'start' => Alignment.topRight,
        'end' => Alignment.bottomRight,
        _ => Alignment.centerRight,
      };
    default:
      return Alignment.bottomCenter;
  }
}

Alignment _alignToTarget(String side, String align) {
  switch (side) {
    case 'top':
      return switch (align) {
        'start' => Alignment.topLeft,
        'end' => Alignment.topRight,
        _ => Alignment.topCenter,
      };
    case 'bottom':
      return switch (align) {
        'start' => Alignment.bottomLeft,
        'end' => Alignment.bottomRight,
        _ => Alignment.bottomCenter,
      };
    case 'left':
      return switch (align) {
        'start' => Alignment.topLeft,
        'end' => Alignment.bottomLeft,
        _ => Alignment.centerLeft,
      };
    case 'right':
      return switch (align) {
        'start' => Alignment.topRight,
        'end' => Alignment.bottomRight,
        _ => Alignment.centerRight,
      };
    default:
      return Alignment.bottomCenter;
  }
}

/// WebF custom element that wraps shadcn_ui [ShadPopover].
///
/// Exposed as `<flutter-shadcn-popover>` in the DOM.
class FlutterShadcnPopover extends FlutterShadcnPopoverBindings {
  FlutterShadcnPopover(super.context);

  bool _open = false;
  String _placement = 'bottom';
  String _align = 'center';
  bool _closeOnOutsideClick = true;

  @override
  bool get open => _open;

  @override
  set open(value) {
    final bool v = value == true;
    if (v != _open) {
      _open = v;
      if (_open) {
        dispatchEvent(Event('open'));
      } else {
        dispatchEvent(Event('close'));
      }
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get placement => _placement;

  @override
  set placement(value) {
    final String newValue = value?.toString() ?? 'bottom';
    if (newValue != _placement) {
      _placement = newValue;
      state?.requestUpdateState(() {});
    }
  }

  String get align => _align;

  set align(value) {
    final String newValue = value?.toString() ?? 'center';
    if (newValue != _align) {
      _align = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get closeOnOutsideClick => _closeOnOutsideClick;

  @override
  set closeOnOutsideClick(value) {
    final bool v = value == true;
    if (v != _closeOnOutsideClick) {
      _closeOnOutsideClick = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['align'] = ElementAttributeProperty(
      getter: () => align,
      setter: (val) => align = val,
      deleter: () => align = 'center',
    );
  }

  static StaticDefinedBindingPropertyMap flutterShadcnPopoverExtraProperties = {
    'align': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnPopover>(element).align,
      setter: (element, value) =>
          castToType<FlutterShadcnPopover>(element).align = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
    ...super.properties,
    flutterShadcnPopoverExtraProperties,
  ];

  @override
  WebFWidgetElementState createState() => FlutterShadcnPopoverState(this);
}

class FlutterShadcnPopoverState extends WebFWidgetElementState {
  FlutterShadcnPopoverState(super.widgetElement);

  final _popoverController = ShadPopoverController();
  Offset? _tapDownPosition;

  @override
  FlutterShadcnPopover get widgetElement =>
      super.widgetElement as FlutterShadcnPopover;

  void _onControllerChanged() {
    final isOpen = _popoverController.isOpen;
    // Sync native open/close state back to JS and emit events.
    if (widgetElement.open != isOpen) {
      widgetElement.open = isOpen;
    }
  }

  @override
  void initState() {
    super.initState();
    _popoverController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _popoverController.removeListener(_onControllerChanged);
    _popoverController.dispose();
    super.dispose();
  }

  Widget? _findSlot<T>() {
    final node =
        widgetElement.childNodes.firstWhereOrNull((node) => node is T);
    if (node != null) {
      return WebFWidgetElementChild(child: node.toWidget());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final trigger = _findSlot<FlutterShadcnPopoverTrigger>();
    final content = _findSlot<FlutterShadcnPopoverContent>();

    if (trigger == null) {
      return const SizedBox.shrink();
    }

    // Sync controller with open state
    if (widgetElement.open && !_popoverController.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _popoverController.show();
      });
    } else if (!widgetElement.open && _popoverController.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _popoverController.hide();
      });
    }

    final anchor = _placementToAnchor(
      widgetElement.placement,
      widgetElement.align,
    );

    return ShadPopover(
      controller: _popoverController,
      anchor: anchor,
      closeOnTapOutside: widgetElement.closeOnOutsideClick,
      popover: (context) => content ?? const SizedBox.shrink(),
      // Use Listener instead of GestureDetector to avoid gesture arena
      // conflicts with interactive child widgets (e.g. ShadButton).
      // Listener receives raw pointer events without competing in the arena.
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          _tapDownPosition = event.position;
        },
        onPointerUp: (event) {
          if (_tapDownPosition != null) {
            final distance = (event.position - _tapDownPosition!).distance;
            _tapDownPosition = null;
            if (distance < 20) {
              widgetElement.open = !widgetElement.open;
            }
          }
        },
        onPointerCancel: (_) {
          _tapDownPosition = null;
        },
        child: trigger,
      ),
    );
  }
}

/// WebF custom element for popover trigger.
class FlutterShadcnPopoverTrigger extends WidgetElement {
  FlutterShadcnPopoverTrigger(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnPopoverTriggerState(this);
}

class FlutterShadcnPopoverTriggerState extends WebFWidgetElementState {
  FlutterShadcnPopoverTriggerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'DIV',
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}

/// WebF custom element for popover content.
class FlutterShadcnPopoverContent extends WidgetElement {
  FlutterShadcnPopoverContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnPopoverContentState(this);
}

class FlutterShadcnPopoverContentState extends WebFWidgetElementState {
  FlutterShadcnPopoverContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'DIV',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}
