/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'context_menu_bindings_generated.dart';

const Map<String, dynamic> _contextMenuDefaultStyle = {
  DISPLAY: BLOCK,
  WIDTH: '100%',
};

/// Helper to extract text content from nodes recursively.
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

class _ParsedShortcut {
  const _ParsedShortcut({
    required this.meta,
    required this.control,
    required this.alt,
    required this.shift,
    this.logicalKey,
    this.keyLabel,
  });

  final bool meta;
  final bool control;
  final bool alt;
  final bool shift;

  final LogicalKeyboardKey? logicalKey;
  final String? keyLabel;

  bool matches(KeyDownEvent event) {
    final keyboard = HardwareKeyboard.instance;

    if (keyboard.isMetaPressed != meta) return false;
    if (keyboard.isControlPressed != control) return false;
    if (keyboard.isAltPressed != alt) return false;
    if (keyboard.isShiftPressed != shift) return false;

    if (logicalKey != null) return event.logicalKey == logicalKey;
    final expectedLabel = keyLabel?.toUpperCase().trim();
    if (expectedLabel == null || expectedLabel.isEmpty) return false;
    return event.logicalKey.keyLabel.toUpperCase().trim() == expectedLabel;
  }
}

_ParsedShortcut? _parseShortcut(String? rawShortcut) {
  var shortcut = rawShortcut?.trim();
  if (shortcut == null || shortcut.isEmpty) return null;

  var meta = false;
  var control = false;
  var alt = false;
  var shift = false;

  String? keyToken;

  if (shortcut.contains('+')) {
    final parts = shortcut
        .split('+')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty);

    for (final part in parts) {
      final normalized = part.toLowerCase();
      if (normalized == 'cmd' ||
          normalized == 'command' ||
          normalized == 'meta' ||
          normalized == 'win' ||
          normalized == 'super') {
        meta = true;
      } else if (normalized == 'ctrl' || normalized == 'control') {
        control = true;
      } else if (normalized == 'alt' || normalized == 'option') {
        alt = true;
      } else if (normalized == 'shift') {
        shift = true;
      } else {
        keyToken = part;
      }
    }
  } else {
    if (shortcut.contains('⌘')) {
      meta = true;
      shortcut = shortcut.replaceAll('⌘', '');
    }
    if (shortcut.contains('⌃')) {
      control = true;
      shortcut = shortcut.replaceAll('⌃', '');
    }
    if (shortcut.contains('⌥')) {
      alt = true;
      shortcut = shortcut.replaceAll('⌥', '');
    }
    if (shortcut.contains('⇧')) {
      shift = true;
      shortcut = shortcut.replaceAll('⇧', '');
    }
    keyToken = shortcut.trim();
  }

  final isApplePlatform = defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS;
  if (meta && !isApplePlatform) {
    // shadcn/ui docs often show ⌘ for macOS; on other platforms treat it as Ctrl.
    meta = false;
    control = true;
  }

  final key = keyToken?.trim();
  if (key == null || key.isEmpty) return null;

  final normalizedKey = key.toUpperCase();
  final LogicalKeyboardKey? logicalKey = switch (normalizedKey) {
    '⌫' || 'BACKSPACE' => LogicalKeyboardKey.backspace,
    'DEL' || 'DELETE' => LogicalKeyboardKey.delete,
    'ESC' || 'ESCAPE' => LogicalKeyboardKey.escape,
    'ENTER' || 'RETURN' || '⏎' => LogicalKeyboardKey.enter,
    'TAB' => LogicalKeyboardKey.tab,
    'SPACE' || '␣' => LogicalKeyboardKey.space,
    _ => null,
  };

  return _ParsedShortcut(
    meta: meta,
    control: control,
    alt: alt,
    shift: shift,
    logicalKey: logicalKey,
    keyLabel: logicalKey == null ? normalizedKey : null,
  );
}

class _ShortcutBinding {
  const _ShortcutBinding(this.shortcut, this.item);

  final _ParsedShortcut shortcut;
  final FlutterShadcnContextMenuItem item;
}

class _ContextMenuSubmenuTrigger extends StatefulWidget {
  const _ContextMenuSubmenuTrigger({
    super.key,
    required this.label,
    required this.items,
    required this.inset,
    required this.enabled,
    required this.isNestedSubmenu,
  });

  final String label;
  final List<Widget> items;
  final bool inset;
  final bool enabled;
  final bool isNestedSubmenu;

  @override
  State<_ContextMenuSubmenuTrigger> createState() =>
      _ContextMenuSubmenuTriggerState();
}

class _ContextMenuSubmenuTriggerState extends State<_ContextMenuSubmenuTrigger> {
  final ShadContextMenuController _controller = ShadContextMenuController();
  final Object _groupId = Object();
  bool _insideTrigger = false;
  bool _insidePopover = false;
  Timer? _closeTimer;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleCloseIfNeeded() {
    _closeTimer?.cancel();
    if (!_controller.isOpen) return;
    if (_insideTrigger || _insidePopover) return;

    _closeTimer = Timer(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      if (_insideTrigger || _insidePopover) return;
      _controller.hide();
    });
  }

  void _onTriggerHoverChanged(bool inside) {
    _insideTrigger = inside;
    if (!widget.enabled) return;
    if (inside) {
      _controller.show();
    } else {
      _scheduleCloseIfNeeded();
    }
  }

  void _onPopoverHoverChanged(bool inside) {
    _insidePopover = inside;
    if (!widget.enabled) return;
    if (inside) {
      _controller.show();
    } else {
      _scheduleCloseIfNeeded();
    }
  }

  void _toggleOpen() {
    if (!widget.enabled) return;
    if (_controller.isOpen) {
      _controller.hide();
    } else {
      _controller.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final effectiveItemPadding = theme.contextMenuTheme.itemPadding ??
        const EdgeInsets.symmetric(horizontal: 4);

    final defaultInsetPadding = widget.inset
        ? const EdgeInsetsDirectional.only(start: 32, end: 8)
        : const EdgeInsets.symmetric(horizontal: 8);

    final effectiveInsetPadding =
        theme.contextMenuTheme.insetPadding ?? defaultInsetPadding;

    final effectiveTrailingPadding = theme.contextMenuTheme.trailingPadding ??
        const EdgeInsetsDirectional.only(start: 8);

    final effectiveHeight = theme.contextMenuTheme.height ?? 32;

    final effectiveButtonVariant =
        theme.contextMenuTheme.buttonVariant ?? ShadButtonVariant.ghost;

    final effectiveDecoration = const ShadDecoration(
      secondaryBorder: ShadBorder.none,
      secondaryFocusedBorder: ShadBorder.none,
    ).merge(theme.contextMenuTheme.itemDecoration);

    final effectiveTextStyle =
        (theme.contextMenuTheme.textStyle ??
                theme.textTheme.small.copyWith(fontWeight: FontWeight.normal))
            .fallback(color: theme.colorScheme.foreground);

    final effectiveSelectedBackgroundColor =
        theme.contextMenuTheme.selectedBackgroundColor ?? theme.colorScheme.accent;
    final effectiveBackgroundColor = theme.contextMenuTheme.backgroundColor;

    final effectiveAnchor = theme.contextMenuTheme.anchor ??
        ShadAnchorAuto(
          offset: Offset(-8, widget.isNestedSubmenu ? -5 : -3),
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.bottomRight,
        );

    final popoverContent = MouseRegion(
      onEnter: (_) => _onPopoverHoverChanged(true),
      onExit: (_) => _onPopoverHoverChanged(false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.items,
      ),
    );

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final selected = _insideTrigger || _insidePopover || _controller.isOpen;
        return ShadContextMenu(
          controller: _controller,
          anchor: effectiveAnchor,
          groupId: _groupId,
          // Prefer built-in MouseRegion hover (works without ShadMouseAreaSurface),
          // but keep this for when shadcn's hover surface is available.
          onHoverArea: (hovered) =>
              hovered ? _onTriggerHoverChanged(true) : _onTriggerHoverChanged(false),
          items: [popoverContent],
          child: MouseRegion(
            onEnter: (_) => _onTriggerHoverChanged(true),
            onExit: (_) => _onTriggerHoverChanged(false),
            child: Padding(
              padding: effectiveItemPadding,
              child: ShadButton.raw(
                height: effectiveHeight,
                enabled: widget.enabled,
                variant: effectiveButtonVariant,
                decoration: effectiveDecoration,
                width: double.infinity,
                padding: effectiveInsetPadding,
                backgroundColor: selected
                    ? effectiveSelectedBackgroundColor
                    : effectiveBackgroundColor,
                hoverBackgroundColor: effectiveSelectedBackgroundColor,
                onPressed: _toggleOpen,
                child: Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: DefaultTextStyle(
                          style: effectiveTextStyle,
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ),
                      Padding(
                        padding: effectiveTrailingPadding,
                        child: const Icon(LucideIcons.chevronRight, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// WebF custom element for context menus.
///
/// Exposed as `<flutter-shadcn-context-menu>` in the DOM.
class FlutterShadcnContextMenu extends FlutterShadcnContextMenuBindings {
  FlutterShadcnContextMenu(super.context);

  bool _open = false;

  @override
  Map<String, dynamic> get defaultStyle => _contextMenuDefaultStyle;

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
  WebFWidgetElementState createState() => FlutterShadcnContextMenuState(this);
}

class FlutterShadcnContextMenuState extends WebFWidgetElementState {
  FlutterShadcnContextMenuState(super.widgetElement);

  final ShadContextMenuController _contextMenuController =
      ShadContextMenuController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'WebFShadcnContextMenu');

  List<_ShortcutBinding> _shortcutBindings = const [];

  @override
  FlutterShadcnContextMenu get widgetElement =>
      super.widgetElement as FlutterShadcnContextMenu;

  void _onControllerChanged() {
    final isOpen = _contextMenuController.isOpen;

    if (isOpen && !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }

    // Reflect native open/close state back to JS and emit events.
    if (widgetElement.open != isOpen) {
      widgetElement.open = isOpen;
    }
  }

  @override
  void initState() {
    super.initState();
    _contextMenuController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _contextMenuController.removeListener(_onControllerChanged);
    _contextMenuController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  FlutterShadcnContextMenuTrigger? _findTrigger() {
    return widgetElement.childNodes
        .firstWhereOrNull((node) => node is FlutterShadcnContextMenuTrigger)
        as FlutterShadcnContextMenuTrigger?;
  }

  FlutterShadcnContextMenuContent? _findContent() {
    return widgetElement.childNodes
        .firstWhereOrNull((node) => node is FlutterShadcnContextMenuContent)
        as FlutterShadcnContextMenuContent?;
  }

  List<Widget> _buildMenuItems(
    Iterable<Node> nodes,
    List<_ShortcutBinding> shortcutBindings, {
    String? radioGroupValue,
    FlutterShadcnContextMenuRadioGroup? radioGroup,
    bool isSubMenu = false,
  }) {
    final items = <Widget>[];
    for (final node in nodes) {
      if (node is FlutterShadcnContextMenuItem) {
        final text = _extractTextContent(node.childNodes);
        // Read shortcut and inset from property or attribute
        final shortcut = node.shortcut ?? node.getAttribute('shortcut');
        final isInset = node.inset || node.getAttribute('inset') == 'true' || node.getAttribute('inset') == '';

        // Build trailing widget for shortcut display
        Widget? trailingWidget;
        if (shortcut != null && shortcut.isNotEmpty) {
          trailingWidget = Text(shortcut);
        }

        final parsedShortcut = _parseShortcut(shortcut);
        if (parsedShortcut != null) {
          shortcutBindings.add(_ShortcutBinding(parsedShortcut, node));
        }

        if (isInset) {
          items.add(
            ShadContextMenuItem.inset(
              enabled: !node.disabled,
              trailing: trailingWidget,
              onPressed: () {
                node.dispatchEvent(Event('click'));
              },
              child: Text(text),
            ),
          );
        } else {
          items.add(
            ShadContextMenuItem(
              enabled: !node.disabled,
              trailing: trailingWidget,
              onPressed: () {
                node.dispatchEvent(Event('click'));
              },
              child: Text(text),
            ),
          );
        }
      } else if (node is FlutterShadcnContextMenuSeparator) {
        items.add(const ShadSeparator.horizontal(
          margin: EdgeInsets.symmetric(vertical: 4),
        ));
      } else if (node is FlutterShadcnContextMenuLabel) {
        final text = _extractTextContent(node.childNodes);
        items.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 8, 8, 8),
            child: Builder(
              builder: (context) {
                final theme = ShadTheme.of(context);
                return Text(text, style: theme.textTheme.small);
              },
            ),
          ),
        );
      } else if (node is FlutterShadcnContextMenuSub) {
        // Find trigger and content within the sub element
        FlutterShadcnContextMenuSubTrigger? trigger;
        FlutterShadcnContextMenuSubContent? subContent;

        for (final child in node.childNodes) {
          if (child is FlutterShadcnContextMenuSubTrigger) {
            trigger = child;
          } else if (child is FlutterShadcnContextMenuSubContent) {
            subContent = child;
          }
        }

        if (trigger != null) {
          final text = _extractTextContent(trigger.childNodes);
          final isInset = trigger.inset || trigger.getAttribute('inset') == 'true' || trigger.getAttribute('inset') == '';
          final subItems = subContent != null
              ? _buildMenuItems(
                  subContent.childNodes,
                  shortcutBindings,
                  isSubMenu: true,
                )
              : <Widget>[];

          items.add(
            _ContextMenuSubmenuTrigger(
              key: ObjectKey(node),
              label: text,
              inset: isInset,
              enabled: !trigger.disabled,
              isNestedSubmenu: isSubMenu,
              items: subItems,
            ),
          );
        }
      } else if (node is FlutterShadcnContextMenuCheckboxItem) {
        final text = _extractTextContent(node.childNodes);
        final shortcut = node.shortcut ?? node.getAttribute('shortcut');

        Widget? trailingWidget;
        if (shortcut != null && shortcut.isNotEmpty) {
          trailingWidget = Text(shortcut);
        }

        items.add(
          ShadContextMenuItem(
            enabled: !node.disabled,
            leading: node.checked
                ? const Icon(LucideIcons.check, size: 16)
                : const SizedBox(width: 16),
            trailing: trailingWidget,
            onPressed: () {
              node._checked = !node._checked;
              node.dispatchEvent(Event('change'));
              node._notifyMenuNeedsRebuild();
            },
            child: Text(text),
          ),
        );
      } else if (node is FlutterShadcnContextMenuRadioGroup) {
        // Process radio group children with the group's value
        final groupItems = _buildMenuItems(
          node.childNodes,
          shortcutBindings,
          radioGroupValue: node.value,
          radioGroup: node,
          isSubMenu: isSubMenu,
        );
        items.addAll(groupItems);
      } else if (node is FlutterShadcnContextMenuRadioItem) {
        final text = _extractTextContent(node.childNodes);
        final shortcut = node.shortcut ?? node.getAttribute('shortcut');
        final isSelected = radioGroupValue != null && node.value == radioGroupValue;

        Widget? trailingWidget;
        if (shortcut != null && shortcut.isNotEmpty) {
          trailingWidget = Text(shortcut);
        }

        items.add(
          ShadContextMenuItem(
            enabled: !node.disabled,
            leading: isSelected
                ? SizedBox.square(
                    dimension: 16,
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: 16),
            trailing: trailingWidget,
            onPressed: () {
              if (radioGroup != null && node.value != null) {
                radioGroup._value = node.value;
                radioGroup.dispatchEvent(CustomEvent('change', detail: {'value': node.value}));
                radioGroup._notifyMenuNeedsRebuild();
              }
              node.dispatchEvent(Event('click'));
            },
            child: Text(text),
          ),
        );
      }
    }
    return items;
  }

  KeyEventResult _handleKeyEvent(FocusNode _, KeyEvent event) {
    if (!_contextMenuController.isOpen) return KeyEventResult.ignored;
    if (event is KeyRepeatEvent) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    for (final binding in _shortcutBindings) {
      if (!binding.item.disabled && binding.shortcut.matches(event)) {
        binding.item.dispatchEvent(Event('click'));
        _contextMenuController.hide();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final trigger = _findTrigger();
    final content = _findContent();

    if (trigger == null) {
      return const SizedBox.shrink();
    }

    // Allow programmatic close from JS: `open = false`.
    if (!widgetElement.open && _contextMenuController.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _contextMenuController.hide();
      });
    }

    // Build trigger widget
    final triggerWidget = WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'DIV',
        controller: widgetElement.ownerDocument.controller,
        parentElement: trigger,
        children: trigger.childNodes.toWidgetList(),
      ),
    );

    // Build items once, outside of ListenableBuilder to preserve hover state
    final shortcutBindings = <_ShortcutBinding>[];
    final items = content != null
        ? _buildMenuItems(content.childNodes, shortcutBindings)
        : <Widget>[];
    _shortcutBindings = shortcutBindings;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: ShadContextMenuRegion(
        controller: _contextMenuController,
        items: items,
        child: triggerWidget,
      ),
    );
  }
}

/// WebF custom element for context menu trigger.
class FlutterShadcnContextMenuTrigger extends WidgetElement {
  FlutterShadcnContextMenuTrigger(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuTriggerState(this);
}

class FlutterShadcnContextMenuTriggerState extends WebFWidgetElementState {
  FlutterShadcnContextMenuTriggerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for context menu content.
class FlutterShadcnContextMenuContent extends WidgetElement {
  FlutterShadcnContextMenuContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuContentState(this);
}

class FlutterShadcnContextMenuContentState extends WebFWidgetElementState {
  FlutterShadcnContextMenuContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for context menu item.
class FlutterShadcnContextMenuItem extends WidgetElement {
  FlutterShadcnContextMenuItem(super.context);

  bool _disabled = false;
  String? _shortcut;
  bool _inset = false;

  void _notifyMenuNeedsRebuild() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnContextMenu) {
        current.state?.requestUpdateState(() {});
        return;
      }
      current = current.parentNode;
    }
  }

  bool get disabled => _disabled;

  set disabled(value) {
    final bool v = value == true;
    if (v != _disabled) {
      _disabled = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  String? get shortcut => _shortcut;

  set shortcut(value) {
    final String? v = value?.toString();
    if (v != _shortcut) {
      _shortcut = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  bool get inset => _inset;

  set inset(value) {
    final bool v = value == true;
    if (v != _inset) {
      _inset = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => disabled.toString(),
      setter: (val) => disabled = val == 'true' || val == '',
      deleter: () => disabled = false
    );
    attributes['shortcut'] = ElementAttributeProperty(
      getter: () => shortcut,
      setter: (val) => shortcut = val,
      deleter: () => shortcut = null
    );
    attributes['inset'] = ElementAttributeProperty(
      getter: () => inset.toString(),
      setter: (val) => inset = val == 'true' || val == '',
      deleter: () => inset = false
    );
  }

  static StaticDefinedBindingPropertyMap flutterShadcnContextMenuItemProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuItem>(element).disabled,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuItem>(element).disabled = value,
    ),
    'shortcut': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuItem>(element).shortcut,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuItem>(element).shortcut = value,
    ),
    'inset': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuItem>(element).inset,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuItem>(element).inset = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
    ...super.properties,
    flutterShadcnContextMenuItemProperties,
  ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuItemState(this);
}

class FlutterShadcnContextMenuItemState extends WebFWidgetElementState {
  FlutterShadcnContextMenuItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for context menu separator.
class FlutterShadcnContextMenuSeparator extends WidgetElement {
  FlutterShadcnContextMenuSeparator(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuSeparatorState(this);
}

class FlutterShadcnContextMenuSeparatorState extends WebFWidgetElementState {
  FlutterShadcnContextMenuSeparatorState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for context menu label (group header).
class FlutterShadcnContextMenuLabel extends WidgetElement {
  FlutterShadcnContextMenuLabel(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuLabelState(this);
}

class FlutterShadcnContextMenuLabelState extends WebFWidgetElementState {
  FlutterShadcnContextMenuLabelState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for context menu sub-menu.
///
/// Contains nested menu items that appear when hovering over the parent item.
class FlutterShadcnContextMenuSub extends WidgetElement {
  FlutterShadcnContextMenuSub(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuSubState(this);
}

class FlutterShadcnContextMenuSubState extends WebFWidgetElementState {
  FlutterShadcnContextMenuSubState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for context menu sub-menu trigger.
class FlutterShadcnContextMenuSubTrigger extends WidgetElement {
  FlutterShadcnContextMenuSubTrigger(super.context);

  bool _disabled = false;
  bool _inset = false;

  bool get disabled => _disabled;

  set disabled(value) {
    final bool v = value == true;
    if (v != _disabled) {
      _disabled = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  bool get inset => _inset;

  set inset(value) {
    final bool v = value == true;
    if (v != _inset) {
      _inset = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  void _notifyMenuNeedsRebuild() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnContextMenu) {
        current.state?.requestUpdateState(() {});
        return;
      }
      current = current.parentNode;
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => disabled.toString(),
      setter: (val) => disabled = val == 'true' || val == '',
      deleter: () => disabled = false
    );
    attributes['inset'] = ElementAttributeProperty(
      getter: () => inset.toString(),
      setter: (val) => inset = val == 'true' || val == '',
      deleter: () => inset = false
    );
  }

  static StaticDefinedBindingPropertyMap flutterShadcnContextMenuSubTriggerProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuSubTrigger>(element).disabled,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuSubTrigger>(element).disabled = value,
    ),
    'inset': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuSubTrigger>(element).inset,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuSubTrigger>(element).inset = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
    ...super.properties,
    flutterShadcnContextMenuSubTriggerProperties,
  ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuSubTriggerState(this);
}

class FlutterShadcnContextMenuSubTriggerState extends WebFWidgetElementState {
  FlutterShadcnContextMenuSubTriggerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for context menu sub-menu content.
class FlutterShadcnContextMenuSubContent extends WidgetElement {
  FlutterShadcnContextMenuSubContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuSubContentState(this);
}

class FlutterShadcnContextMenuSubContentState extends WebFWidgetElementState {
  FlutterShadcnContextMenuSubContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for checkbox-style context menu item.
class FlutterShadcnContextMenuCheckboxItem extends WidgetElement {
  FlutterShadcnContextMenuCheckboxItem(super.context);

  bool _disabled = false;
  bool _checked = false;
  String? _shortcut;

  void _notifyMenuNeedsRebuild() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnContextMenu) {
        current.state?.requestUpdateState(() {});
        return;
      }
      current = current.parentNode;
    }
  }

  bool get disabled => _disabled;

  set disabled(value) {
    final bool v = value == true;
    if (v != _disabled) {
      _disabled = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  bool get checked => _checked;

  set checked(value) {
    final bool v = value == true;
    if (v != _checked) {
      _checked = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  String? get shortcut => _shortcut;

  set shortcut(value) {
    final String? v = value?.toString();
    if (v != _shortcut) {
      _shortcut = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => disabled.toString(),
      setter: (val) => disabled = val == 'true' || val == '',
      deleter: () => disabled = false
    );
    attributes['checked'] = ElementAttributeProperty(
      getter: () => checked.toString(),
      setter: (val) => checked = val == 'true' || val == '',
      deleter: () => checked = false
    );
    attributes['shortcut'] = ElementAttributeProperty(
      getter: () => shortcut,
      setter: (val) => shortcut = val,
      deleter: () => shortcut = null
    );
  }

  static StaticDefinedBindingPropertyMap flutterShadcnContextMenuCheckboxItemProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuCheckboxItem>(element).disabled,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuCheckboxItem>(element).disabled = value,
    ),
    'checked': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuCheckboxItem>(element).checked,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuCheckboxItem>(element).checked = value,
    ),
    'shortcut': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuCheckboxItem>(element).shortcut,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuCheckboxItem>(element).shortcut = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
    ...super.properties,
    flutterShadcnContextMenuCheckboxItemProperties,
  ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuCheckboxItemState(this);
}

class FlutterShadcnContextMenuCheckboxItemState extends WebFWidgetElementState {
  FlutterShadcnContextMenuCheckboxItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for radio-style context menu item.
class FlutterShadcnContextMenuRadioItem extends WidgetElement {
  FlutterShadcnContextMenuRadioItem(super.context);

  bool _disabled = false;
  String? _value;
  String? _shortcut;

  void _notifyMenuNeedsRebuild() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnContextMenu) {
        current.state?.requestUpdateState(() {});
        return;
      }
      current = current.parentNode;
    }
  }

  bool get disabled => _disabled;

  set disabled(value) {
    final bool v = value == true;
    if (v != _disabled) {
      _disabled = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  String? get value => _value;

  set value(val) {
    final String? v = val?.toString();
    if (v != _value) {
      _value = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  String? get shortcut => _shortcut;

  set shortcut(value) {
    final String? v = value?.toString();
    if (v != _shortcut) {
      _shortcut = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => disabled.toString(),
      setter: (val) => disabled = val == 'true' || val == '',
      deleter: () => disabled = false
    );
    attributes['value'] = ElementAttributeProperty(
      getter: () => value,
      setter: (val) => value = val,
      deleter: () => value = null
    );
    attributes['shortcut'] = ElementAttributeProperty(
      getter: () => shortcut,
      setter: (val) => shortcut = val,
      deleter: () => shortcut = null
    );
  }

  static StaticDefinedBindingPropertyMap flutterShadcnContextMenuRadioItemProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuRadioItem>(element).disabled,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuRadioItem>(element).disabled = value,
    ),
    'value': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuRadioItem>(element).value,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuRadioItem>(element).value = value,
    ),
    'shortcut': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuRadioItem>(element).shortcut,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuRadioItem>(element).shortcut = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
    ...super.properties,
    flutterShadcnContextMenuRadioItemProperties,
  ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuRadioItemState(this);
}

class FlutterShadcnContextMenuRadioItemState extends WebFWidgetElementState {
  FlutterShadcnContextMenuRadioItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}

/// WebF custom element for radio group in context menu.
class FlutterShadcnContextMenuRadioGroup extends WidgetElement {
  FlutterShadcnContextMenuRadioGroup(super.context);

  String? _value;

  void _notifyMenuNeedsRebuild() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnContextMenu) {
        current.state?.requestUpdateState(() {});
        return;
      }
      current = current.parentNode;
    }
  }

  String? get value => _value;

  set value(val) {
    final String? v = val?.toString();
    if (v != _value) {
      _value = v;
      _notifyMenuNeedsRebuild();
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['value'] = ElementAttributeProperty(
      getter: () => value,
      setter: (val) => value = val,
      deleter: () => value = null
    );
  }

  static StaticDefinedBindingPropertyMap flutterShadcnContextMenuRadioGroupProperties = {
    'value': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnContextMenuRadioGroup>(element).value,
      setter: (element, value) =>
      castToType<FlutterShadcnContextMenuRadioGroup>(element).value = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
    ...super.properties,
    flutterShadcnContextMenuRadioGroupProperties,
  ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnContextMenuRadioGroupState(this);
}

class FlutterShadcnContextMenuRadioGroupState extends WebFWidgetElementState {
  FlutterShadcnContextMenuRadioGroupState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This is processed by the parent context menu
    return const SizedBox.shrink();
  }
}
