/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';

const Map<String, dynamic> _menubarDefaultStyle = {
  DISPLAY: INLINE_FLEX,
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
  final FlutterShadcnMenubarItem item;
}

class _MenubarSubmenuTrigger extends StatefulWidget {
  const _MenubarSubmenuTrigger({
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
  State<_MenubarSubmenuTrigger> createState() => _MenubarSubmenuTriggerState();
}

class _MenubarSubmenuTriggerState extends State<_MenubarSubmenuTrigger> {
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

// ---------------------------------------------------------------------------
// Main Menubar element
// ---------------------------------------------------------------------------

/// WebF custom element for the menubar container.
///
/// Exposed as `<flutter-shadcn-menubar>` in the DOM.
class FlutterShadcnMenubar extends WidgetElement {
  FlutterShadcnMenubar(super.context);

  @override
  Map<String, dynamic> get defaultStyle => _menubarDefaultStyle;

  @override
  WebFWidgetElementState createState() => FlutterShadcnMenubarState(this);
}

class FlutterShadcnMenubarState extends WebFWidgetElementState {
  FlutterShadcnMenubarState(super.widgetElement);

  @override
  FlutterShadcnMenubar get widgetElement =>
      super.widgetElement as FlutterShadcnMenubar;

  List<Widget> _buildMenuItems(
    Iterable<Node> nodes,
    List<_ShortcutBinding> shortcutBindings, {
    String? radioGroupValue,
    FlutterShadcnMenubarRadioGroup? radioGroup,
    bool isSubMenu = false,
  }) {
    final items = <Widget>[];
    for (final node in nodes) {
      if (node is FlutterShadcnMenubarItem) {
        final text = _extractTextContent(node.childNodes);
        final shortcut = node.shortcut ?? node.getAttribute('shortcut');
        final isInset = node.inset ||
            node.getAttribute('inset') == 'true' ||
            node.getAttribute('inset') == '';

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
      } else if (node is FlutterShadcnMenubarSeparator) {
        items.add(const ShadSeparator.horizontal(
          margin: EdgeInsets.symmetric(vertical: 4),
        ));
      } else if (node is FlutterShadcnMenubarLabel) {
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
      } else if (node is FlutterShadcnMenubarSub) {
        FlutterShadcnMenubarSubTrigger? trigger;
        FlutterShadcnMenubarSubContent? subContent;

        for (final child in node.childNodes) {
          if (child is FlutterShadcnMenubarSubTrigger) {
            trigger = child;
          } else if (child is FlutterShadcnMenubarSubContent) {
            subContent = child;
          }
        }

        if (trigger != null) {
          final text = _extractTextContent(trigger.childNodes);
          final isInset = trigger.inset ||
              trigger.getAttribute('inset') == 'true' ||
              trigger.getAttribute('inset') == '';
          final subItems = subContent != null
              ? _buildMenuItems(
                  subContent.childNodes,
                  shortcutBindings,
                  isSubMenu: true,
                )
              : <Widget>[];

          items.add(
            _MenubarSubmenuTrigger(
              key: ObjectKey(node),
              label: text,
              inset: isInset,
              enabled: !trigger.disabled,
              isNestedSubmenu: isSubMenu,
              items: subItems,
            ),
          );
        }
      } else if (node is FlutterShadcnMenubarCheckboxItem) {
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
      } else if (node is FlutterShadcnMenubarRadioGroup) {
        final groupItems = _buildMenuItems(
          node.childNodes,
          shortcutBindings,
          radioGroupValue: node.value,
          radioGroup: node,
          isSubMenu: isSubMenu,
        );
        items.addAll(groupItems);
      } else if (node is FlutterShadcnMenubarRadioItem) {
        final text = _extractTextContent(node.childNodes);
        final shortcut = node.shortcut ?? node.getAttribute('shortcut');
        final isSelected =
            radioGroupValue != null && node.value == radioGroupValue;

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
                radioGroup.dispatchEvent(
                    CustomEvent('change', detail: {'value': node.value}));
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

  @override
  Widget build(BuildContext context) {
    final menuWidgets = <Widget>[];

    for (final child in widgetElement.childNodes) {
      if (child is FlutterShadcnMenubarMenu) {
        FlutterShadcnMenubarTrigger? trigger;
        FlutterShadcnMenubarContent? content;

        for (final menuChild in child.childNodes) {
          if (menuChild is FlutterShadcnMenubarTrigger) {
            trigger = menuChild;
          } else if (menuChild is FlutterShadcnMenubarContent) {
            content = menuChild;
          }
        }

        if (trigger != null) {
          final triggerText = _extractTextContent(trigger.childNodes);
          final shortcutBindings = <_ShortcutBinding>[];
          final items = content != null
              ? _buildMenuItems(content.childNodes, shortcutBindings)
              : <Widget>[];

          menuWidgets.add(
            ShadMenubarItem(
              items: items,
              child: Text(triggerText),
            ),
          );
        }
      }
    }

    return ShadMenubar(items: menuWidgets);
  }
}

// ---------------------------------------------------------------------------
// Menubar Menu (groups trigger + content)
// ---------------------------------------------------------------------------

/// WebF custom element for a single menu in the menubar.
class FlutterShadcnMenubarMenu extends WidgetElement {
  FlutterShadcnMenubarMenu(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarMenuState(this);
}

class FlutterShadcnMenubarMenuState extends WebFWidgetElementState {
  FlutterShadcnMenubarMenuState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Trigger
// ---------------------------------------------------------------------------

/// WebF custom element for the menubar trigger label.
class FlutterShadcnMenubarTrigger extends WidgetElement {
  FlutterShadcnMenubarTrigger(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarTriggerState(this);
}

class FlutterShadcnMenubarTriggerState extends WebFWidgetElementState {
  FlutterShadcnMenubarTriggerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Content
// ---------------------------------------------------------------------------

/// WebF custom element for the menubar dropdown content.
class FlutterShadcnMenubarContent extends WidgetElement {
  FlutterShadcnMenubarContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarContentState(this);
}

class FlutterShadcnMenubarContentState extends WebFWidgetElementState {
  FlutterShadcnMenubarContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Item
// ---------------------------------------------------------------------------

/// WebF custom element for a menubar menu item.
class FlutterShadcnMenubarItem extends WidgetElement {
  FlutterShadcnMenubarItem(super.context);

  bool _disabled = false;
  String? _shortcut;
  bool _inset = false;

  void _notifyMenuNeedsRebuild() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnMenubar) {
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
        deleter: () => disabled = false);
    attributes['shortcut'] = ElementAttributeProperty(
        getter: () => shortcut,
        setter: (val) => shortcut = val,
        deleter: () => shortcut = null);
    attributes['inset'] = ElementAttributeProperty(
        getter: () => inset.toString(),
        setter: (val) => inset = val == 'true' || val == '',
        deleter: () => inset = false);
  }

  static StaticDefinedBindingPropertyMap
      flutterShadcnMenubarItemProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarItem>(element).disabled,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarItem>(element).disabled = value,
    ),
    'shortcut': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarItem>(element).shortcut,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarItem>(element).shortcut = value,
    ),
    'inset': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarItem>(element).inset,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarItem>(element).inset = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
        ...super.properties,
        flutterShadcnMenubarItemProperties,
      ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarItemState(this);
}

class FlutterShadcnMenubarItemState extends WebFWidgetElementState {
  FlutterShadcnMenubarItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Separator
// ---------------------------------------------------------------------------

/// WebF custom element for a menubar separator.
class FlutterShadcnMenubarSeparator extends WidgetElement {
  FlutterShadcnMenubarSeparator(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarSeparatorState(this);
}

class FlutterShadcnMenubarSeparatorState extends WebFWidgetElementState {
  FlutterShadcnMenubarSeparatorState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Label
// ---------------------------------------------------------------------------

/// WebF custom element for a menubar label (group header).
class FlutterShadcnMenubarLabel extends WidgetElement {
  FlutterShadcnMenubarLabel(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarLabelState(this);
}

class FlutterShadcnMenubarLabelState extends WebFWidgetElementState {
  FlutterShadcnMenubarLabelState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Sub (submenu container)
// ---------------------------------------------------------------------------

/// WebF custom element for a menubar sub-menu.
class FlutterShadcnMenubarSub extends WidgetElement {
  FlutterShadcnMenubarSub(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarSubState(this);
}

class FlutterShadcnMenubarSubState extends WebFWidgetElementState {
  FlutterShadcnMenubarSubState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Sub Trigger
// ---------------------------------------------------------------------------

/// WebF custom element for a menubar sub-menu trigger.
class FlutterShadcnMenubarSubTrigger extends WidgetElement {
  FlutterShadcnMenubarSubTrigger(super.context);

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
      if (current is FlutterShadcnMenubar) {
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
        deleter: () => disabled = false);
    attributes['inset'] = ElementAttributeProperty(
        getter: () => inset.toString(),
        setter: (val) => inset = val == 'true' || val == '',
        deleter: () => inset = false);
  }

  static StaticDefinedBindingPropertyMap
      flutterShadcnMenubarSubTriggerProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarSubTrigger>(element).disabled,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarSubTrigger>(element).disabled = value,
    ),
    'inset': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarSubTrigger>(element).inset,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarSubTrigger>(element).inset = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
        ...super.properties,
        flutterShadcnMenubarSubTriggerProperties,
      ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarSubTriggerState(this);
}

class FlutterShadcnMenubarSubTriggerState extends WebFWidgetElementState {
  FlutterShadcnMenubarSubTriggerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Sub Content
// ---------------------------------------------------------------------------

/// WebF custom element for menubar sub-menu content.
class FlutterShadcnMenubarSubContent extends WidgetElement {
  FlutterShadcnMenubarSubContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarSubContentState(this);
}

class FlutterShadcnMenubarSubContentState extends WebFWidgetElementState {
  FlutterShadcnMenubarSubContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Checkbox Item
// ---------------------------------------------------------------------------

/// WebF custom element for a menubar checkbox item.
class FlutterShadcnMenubarCheckboxItem extends WidgetElement {
  FlutterShadcnMenubarCheckboxItem(super.context);

  bool _disabled = false;
  bool _checked = false;
  String? _shortcut;

  void _notifyMenuNeedsRebuild() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnMenubar) {
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
        deleter: () => disabled = false);
    attributes['checked'] = ElementAttributeProperty(
        getter: () => checked.toString(),
        setter: (val) => checked = val == 'true' || val == '',
        deleter: () => checked = false);
    attributes['shortcut'] = ElementAttributeProperty(
        getter: () => shortcut,
        setter: (val) => shortcut = val,
        deleter: () => shortcut = null);
  }

  static StaticDefinedBindingPropertyMap
      flutterShadcnMenubarCheckboxItemProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarCheckboxItem>(element).disabled,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarCheckboxItem>(element).disabled =
              value,
    ),
    'checked': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarCheckboxItem>(element).checked,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarCheckboxItem>(element).checked = value,
    ),
    'shortcut': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarCheckboxItem>(element).shortcut,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarCheckboxItem>(element).shortcut =
              value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
        ...super.properties,
        flutterShadcnMenubarCheckboxItemProperties,
      ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarCheckboxItemState(this);
}

class FlutterShadcnMenubarCheckboxItemState extends WebFWidgetElementState {
  FlutterShadcnMenubarCheckboxItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Radio Group
// ---------------------------------------------------------------------------

/// WebF custom element for a menubar radio group.
class FlutterShadcnMenubarRadioGroup extends WidgetElement {
  FlutterShadcnMenubarRadioGroup(super.context);

  String? _value;

  void _notifyMenuNeedsRebuild() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnMenubar) {
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
        deleter: () => value = null);
  }

  static StaticDefinedBindingPropertyMap
      flutterShadcnMenubarRadioGroupProperties = {
    'value': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarRadioGroup>(element).value,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarRadioGroup>(element).value = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
        ...super.properties,
        flutterShadcnMenubarRadioGroupProperties,
      ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarRadioGroupState(this);
}

class FlutterShadcnMenubarRadioGroupState extends WebFWidgetElementState {
  FlutterShadcnMenubarRadioGroupState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Menubar Radio Item
// ---------------------------------------------------------------------------

/// WebF custom element for a menubar radio item.
class FlutterShadcnMenubarRadioItem extends WidgetElement {
  FlutterShadcnMenubarRadioItem(super.context);

  bool _disabled = false;
  String? _value;
  String? _shortcut;

  void _notifyMenuNeedsRebuild() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnMenubar) {
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
        deleter: () => disabled = false);
    attributes['value'] = ElementAttributeProperty(
        getter: () => value,
        setter: (val) => value = val,
        deleter: () => value = null);
    attributes['shortcut'] = ElementAttributeProperty(
        getter: () => shortcut,
        setter: (val) => shortcut = val,
        deleter: () => shortcut = null);
  }

  static StaticDefinedBindingPropertyMap
      flutterShadcnMenubarRadioItemProperties = {
    'disabled': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarRadioItem>(element).disabled,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarRadioItem>(element).disabled = value,
    ),
    'value': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarRadioItem>(element).value,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarRadioItem>(element).value = value,
    ),
    'shortcut': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnMenubarRadioItem>(element).shortcut,
      setter: (element, value) =>
          castToType<FlutterShadcnMenubarRadioItem>(element).shortcut = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
        ...super.properties,
        flutterShadcnMenubarRadioItemProperties,
      ];

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnMenubarRadioItemState(this);
}

class FlutterShadcnMenubarRadioItemState extends WebFWidgetElementState {
  FlutterShadcnMenubarRadioItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
