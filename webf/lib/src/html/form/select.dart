/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Element;
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/dom.dart';
import 'package:webf/src/accessibility/semantics.dart';
import 'package:webf/widget.dart';

import 'form_element_base.dart';

// ignore: constant_identifier_names
const SELECT = 'SELECT';
// ignore: constant_identifier_names
const OPTION = 'OPTION';
// ignore: constant_identifier_names
const OPTGROUP = 'OPTGROUP';

const Map<String, dynamic> _selectDefaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '2px solid rgb(118, 118, 118)',
  COLOR: '#000',
};

class _SelectMenuEntry {
  final HTMLOptionElement? option;
  final int? optionIndex;
  final String? groupLabel;
  final bool disabled;

  const _SelectMenuEntry.option(this.option, this.optionIndex, {required this.disabled})
      : groupLabel = null;

  const _SelectMenuEntry.group(this.groupLabel)
      : option = null,
        optionIndex = null,
        disabled = true;

  bool get isGroupLabel => groupLabel != null;
}

class HTMLSelectElement extends WidgetElement implements FormElementBase {
  HTMLSelectElement([super.context]);

  bool _pendingFocus = false;

  @override
  Map<String, dynamic> get defaultStyle => _selectDefaultStyle;

  @override
  FlutterSelectElementState? get state => super.state as FlutterSelectElementState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterSelectElementState(this);
  }

  @override
  String get type => multiple ? 'select-multiple' : 'select-one';

  bool get disabled => _hasAttributeIgnoreCase('disabled');

  set disabled(dynamic value) {
    _setBooleanAttribute('disabled', value == true);
  }

  bool get multiple => _hasAttributeIgnoreCase('multiple');

  set multiple(dynamic value) {
    _setBooleanAttribute('multiple', value == true);
  }

  bool get required => _hasAttributeIgnoreCase('required');

  set required(dynamic value) {
    _setBooleanAttribute('required', _coerceBooleanAttribute(value));
  }

  @override
  String get value {
    final HTMLOptionElement? option = _resolveSelectedOption();
    if (option == null) return '';
    return option.value;
  }

  @override
  set value(dynamic v) {
    _setValue(v?.toString() ?? '');
  }

  int get selectedIndex {
    final List<HTMLOptionElement> options = _collectOptions();
    for (int i = 0; i < options.length; i++) {
      if (options[i].selected) return i;
    }
    return -1;
  }

  set selectedIndex(dynamic index) {
    if (index == null) {
      _clearAllSelections();
      return;
    }
    int? parsed;
    if (index is num) {
      parsed = index.toInt();
    } else {
      parsed = int.tryParse(index.toString());
    }
    if (parsed == null) return;
    _setSelectedIndex(parsed);
  }

  bool _coerceBooleanAttribute(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return true;
    return value == true;
  }

  void _setBooleanAttribute(String name, bool enabled) {
    if (enabled) {
      internalSetAttribute(name, '');
    } else if (attributes.containsKey(name)) {
      removeAttribute(name);
    }
    _markPseudoStateDirty();
  }

  HTMLOptionElement? _resolveSelectedOption() {
    final List<HTMLOptionElement> options = _collectOptions();
    for (final HTMLOptionElement option in options) {
      if (option.selected) return option;
    }
    return null;
  }

  String _optionLabel(HTMLOptionElement option) {
    final String? labelAttr = option.getAttribute('label');
    if (labelAttr != null && labelAttr.isNotEmpty) return labelAttr;
    return option.text;
  }

  String get _displayLabel {
    final List<HTMLOptionElement> options = _collectOptions();
    if (options.isEmpty) return '';

    if (multiple) {
      final List<HTMLOptionElement> selected =
          options.where((option) => option.selected).toList();
      final List<HTMLOptionElement> visible =
          selected.isEmpty ? <HTMLOptionElement>[options.first] : selected;
      return visible.map(_optionLabel).join(', ');
    }

    final HTMLOptionElement? option = _resolveSelectedOption();
    if (option == null) return '';
    return _optionLabel(option);
  }

  void _setValue(String nextValue) {
    final List<HTMLOptionElement> options = _collectOptions();
    for (final HTMLOptionElement option in options) {
      if (option.value == nextValue) {
        option.selected = true;
        _notifyOptionsChanged();
        return;
      }
    }
  }

  void _setSelectedIndex(int index) {
    final List<HTMLOptionElement> options = _collectOptions();
    if (index < 0 || index >= options.length) {
      _clearAllSelections();
      return;
    }
    options[index].selected = true;
    _notifyOptionsChanged();
  }

  void _clearAllSelections() {
    final List<HTMLOptionElement> options = _collectOptions();
    for (final HTMLOptionElement option in options) {
      if (option.attributes.containsKey('selected')) {
        option.removeAttribute('selected');
      }
    }
    _notifyOptionsChanged();
  }

  List<HTMLOptionElement> _collectOptions() {
    final List<HTMLOptionElement> options = <HTMLOptionElement>[];
    void visit(Element element) {
      for (final Node child in element.childNodes) {
        if (child is HTMLOptionElement) {
          options.add(child);
        }
        if (child is Element) {
          visit(child);
        }
      }
    }
    visit(this);
    return options;
  }

  void _notifyOptionsChanged() {
    state?.requestUpdateState();
  }

  void _markPendingFocus() {
    _pendingFocus = true;
  }

  bool _hasAttributeIgnoreCase(String name) {
    if (attributes.containsKey(name)) return true;
    final String lower = name.toLowerCase();
    for (final String key in attributes.keys) {
      if (key.toLowerCase() == lower) return true;
    }
    return false;
  }

  void _markPseudoStateDirty() {
    final Element? root = ownerDocument.documentElement;
    if (root != null) {
      ownerDocument.markElementStyleDirty(root, reason: 'childList-pseudo');
    } else {
      ownerDocument.markElementStyleDirty(this, reason: 'childList-pseudo');
    }
  }

  @override
  void initializeDynamicMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeDynamicMethods(methods);
    methods['focus'] = BindingObjectMethodSync(call: (List args) {
      if (disabled) return;
      if (state != null) {
        state?.focus();
      } else {
        _markPendingFocus();
      }
      ownerDocument.updateFocusTarget(this);
    });
    methods['blur'] = BindingObjectMethodSync(call: (List args) {
      state?.blur();
      ownerDocument.clearFocusTarget(this);
    });
  }

  @override
  void initializeDynamicProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeDynamicProperties(properties);
    properties['value'] = BindingObjectProperty(getter: () => value, setter: (value) => this.value = value);
    properties['selectedIndex'] =
        BindingObjectProperty(getter: () => selectedIndex, setter: (value) => selectedIndex = value);
    properties['disabled'] = BindingObjectProperty(getter: () => disabled, setter: (value) => disabled = value);
    properties['multiple'] = BindingObjectProperty(getter: () => multiple, setter: (value) => multiple = value);
    properties['required'] = BindingObjectProperty(getter: () => required, setter: (value) => required = value);
  }

  @override
  void initializeAttributes(Map<String, dom.ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['disabled'] = dom.ElementAttributeProperty(
        getter: () => disabled.toString(),
        setter: (value) => disabled = dom.attributeToProperty<bool>(value),
        deleter: _markPseudoStateDirty);
    attributes['multiple'] = dom.ElementAttributeProperty(
        getter: () => multiple.toString(),
        setter: (value) => multiple = dom.attributeToProperty<bool>(value),
        deleter: _markPseudoStateDirty);
    attributes['required'] = dom.ElementAttributeProperty(
        getter: () => required.toString(),
        setter: (value) => required = dom.attributeToProperty<bool>(value),
        deleter: _markPseudoStateDirty);
  }
}

class FlutterSelectElementState extends WebFWidgetElementState {
  FlutterSelectElementState(super.widgetElement);

  @override
  HTMLSelectElement get widgetElement => super.widgetElement as HTMLSelectElement;

  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode ??= FocusNode();
    _focusNode!.addListener(_handleFocusChange);
    if (widgetElement._pendingFocus) {
      scheduleMicrotask(() {
        if (mounted) focus();
      });
      widgetElement._pendingFocus = false;
    }
  }

  void focus() {
    _focusNode?.requestFocus();
  }

  void blur() {
    _focusNode?.unfocus();
  }

  void _handleFocusChange() {
    if (_focusNode?.hasFocus ?? false) {
      widgetElement.ownerDocument.updateFocusTarget(widgetElement);
      scheduleMicrotask(() {
        widgetElement.dispatchEvent(dom.FocusEvent(dom.EVENT_FOCUS, relatedTarget: widgetElement));
      });
    } else {
      widgetElement.ownerDocument.clearFocusTarget(widgetElement);
      scheduleMicrotask(() {
        widgetElement.dispatchEvent(dom.FocusEvent(dom.EVENT_BLUR, relatedTarget: widgetElement));
      });
    }
  }

  Future<void> _openOptionsMenu(BuildContext context) async {
    if (widgetElement.disabled) return;

    final List<_SelectMenuEntry> entries = _collectMenuEntries();
    final List<HTMLOptionElement> options = widgetElement._collectOptions();
    if (options.isEmpty) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final OverlayState? overlay = Overlay.of(context);
    final RenderBox? overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    if (box == null || overlayBox == null) return;

    final Offset topLeft = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final Offset bottomRight =
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlayBox);

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(topLeft, bottomRight),
      Offset.zero & overlayBox.size,
    );

    final TextStyle textStyle = _textStyle();
    final int currentIndex = widgetElement.selectedIndex;

    final int? result = await showMenu<int>(
      context: context,
      position: position,
      items: [
        for (final _SelectMenuEntry entry in entries)
          if (entry.isGroupLabel)
            PopupMenuItem<int>(
              value: -1,
              enabled: false,
              child: Text(
                entry.groupLabel ?? '',
                style: textStyle.copyWith(
                  color: textStyle.color?.withOpacity(0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            PopupMenuItem<int>(
              value: entry.optionIndex ?? -1,
              enabled: !entry.disabled,
              child: Row(
                children: [
                  if (entry.optionIndex == currentIndex)
                    Icon(
                      Icons.check,
                      size: (textStyle.fontSize ?? 14) + 2,
                      color: entry.disabled ? (textStyle.color?.withOpacity(0.5)) : textStyle.color,
                    )
                  else
                    SizedBox(width: (textStyle.fontSize ?? 14) + 2),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widgetElement._optionLabel(entry.option!),
                      style: entry.disabled ? textStyle.copyWith(color: textStyle.color?.withOpacity(0.5)) : textStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );

    if (result == null || result < 0) return;
    if (result == currentIndex) return;

    widgetElement.selectedIndex = result;
    widgetElement.dispatchEvent(dom.InputEvent(inputType: 'select', data: widgetElement.value));
    widgetElement.dispatchEvent(dom.Event('change'));
  }

  TextStyle _textStyle() {
    final double fs = widgetElement.renderStyle.fontSize.computedValue;
    final double nonNegativeFontSize = fs.isFinite && fs >= 0 ? fs : 0.0;
    double? height;
    if (widgetElement.renderStyle.lineHeight != CSSText.defaultLineHeight) {
      double lineHeight =
          widgetElement.renderStyle.lineHeight.computedValue / widgetElement.renderStyle.fontSize.computedValue;
      if (widgetElement.renderStyle.height.isNotAuto) {
        lineHeight = math.min(
            lineHeight,
            widgetElement.renderStyle.height.computedValue /
                widgetElement.renderStyle.fontSize.computedValue);
      }
      if (lineHeight >= 1) {
        height = lineHeight;
      }
    }
    return TextStyle(
      color: widgetElement.renderStyle.color.value,
      fontSize: nonNegativeFontSize,
      height: height,
      fontWeight: widgetElement.renderStyle.fontWeight,
      fontFamily: widgetElement.renderStyle.fontFamily?.join(' '),
    );
  }

  List<_SelectMenuEntry> _collectMenuEntries() {
    final List<_SelectMenuEntry> entries = <_SelectMenuEntry>[];
    int optionIndex = 0;

    void visit(Element element, {bool groupDisabled = false}) {
      if (element.tagName.toUpperCase() == OPTGROUP) {
        final HTMLOptGroupElement? group =
            element is HTMLOptGroupElement ? element : null;
        final String label = group?.label ?? '';
        if (label.isNotEmpty) {
          entries.add(_SelectMenuEntry.group(label));
        }
        final bool disabled = groupDisabled || (group?.disabled ?? false);
        for (final Node child in element.childNodes) {
          if (child is Element) {
            visit(child, groupDisabled: disabled);
          }
        }
        return;
      }

      if (element is HTMLOptionElement) {
        final bool disabled = groupDisabled || element.disabled;
        entries.add(_SelectMenuEntry.option(element, optionIndex, disabled: disabled));
        optionIndex += 1;
        return;
      }

      for (final Node child in element.childNodes) {
        if (child is Element) {
          visit(child, groupDisabled: groupDisabled);
        }
      }
    }

    visit(widgetElement);
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = _textStyle();
    final TextDirection textDirection = widgetElement.renderStyle.direction;
    final String label = widgetElement._displayLabel;
    final bool shouldShowArrow =
        widgetElement.renderStyle.borderTopWidth?.computedValue != 0 ||
            widgetElement.renderStyle.borderRightWidth?.computedValue != 0 ||
            widgetElement.renderStyle.borderBottomWidth?.computedValue != 0 ||
            widgetElement.renderStyle.borderLeftWidth?.computedValue != 0;

    final bool constrainLabel =
        widgetElement.renderStyle.width.isNotAuto ||
            widgetElement.renderStyle.maxWidth.isNotNone;
    Widget labelWidget = Text(
      label,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      textAlign: widgetElement.renderStyle.textAlign,
      textDirection: textDirection,
    );
    if (constrainLabel) {
      labelWidget = Flexible(fit: FlexFit.loose, child: labelWidget);
    }
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        labelWidget,
        if (shouldShowArrow)
          Icon(
            Icons.arrow_drop_down,
            size: (textStyle.fontSize ?? 14) + 6,
            color: widgetElement.renderStyle.color.value,
          ),
      ],
    );

    Widget widget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widgetElement.disabled
          ? null
          : () async {
              focus();
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final Offset globalOffset = box.globalToLocal(Offset.zero);
                widgetElement.dispatchEvent(dom.MouseEvent(dom.EVENT_CLICK,
                    clientX: globalOffset.dx, clientY: globalOffset.dy, view: widgetElement.ownerDocument.defaultView));
              } else {
                widgetElement.dispatchEvent(dom.MouseEvent(dom.EVENT_CLICK, view: widgetElement.ownerDocument.defaultView));
              }
              await _openOptionsMenu(context);
            },
      child: content,
    );

    widget = Focus(
      focusNode: _focusNode,
      child: widget,
    );

    final String? semanticsLabel = WebFAccessibility.computeAccessibleName(widgetElement);
    final String? semanticsHint = WebFAccessibility.computeAccessibleDescription(widgetElement);
    if ((semanticsLabel != null && semanticsLabel.isNotEmpty) || (semanticsHint != null && semanticsHint.isNotEmpty)) {
      widget = Semantics(
        container: true,
        label: (semanticsLabel != null && semanticsLabel.isNotEmpty) ? semanticsLabel : null,
        hint: (semanticsHint != null && semanticsHint.isNotEmpty) ? semanticsHint : null,
        textDirection: widgetElement.renderStyle.direction,
        child: widget,
      );
    }

    return Directionality(textDirection: textDirection, child: widget);
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_handleFocusChange);
    _focusNode?.dispose();
    super.dispose();
  }
}

class HTMLOptionElement extends Element {
  HTMLOptionElement([super.context]);

  String get value {
    final String? attr = _attributeValueIgnoreCase('value');
    if (attr != null) return attr;
    return text;
  }

  set value(dynamic v) {
    internalSetAttribute('value', v?.toString() ?? '');
    _markPseudoStateDirty();
  }

  String get text => _collectTextContent(this);

  set text(String v) {
    _setTextContent(v);
    _markPseudoStateDirty();
  }

  bool get selected => _isSelected();

  set selected(dynamic value) {
    _setSelected(value == true);
  }

  bool get disabled => _hasAttributeIgnoreCase('disabled');

  set disabled(dynamic value) {
    _setBooleanAttribute('disabled', value == true);
  }

  void _setBooleanAttribute(String name, bool enabled) {
    if (enabled) {
      internalSetAttribute(name, '');
    } else if (attributes.containsKey(name)) {
      removeAttribute(name);
    }
    _markPseudoStateDirty();
  }

  void _setSelected(bool value) {
    final bool previous = _isSelected();
    if (value) {
      internalSetAttribute('selected', '');
      _clearOtherSelectedIfNeeded();
    } else if (_hasAttributeIgnoreCase('selected')) {
      _removeAttributeIgnoreCase(this, 'selected');
    }
    if (previous != _isSelected()) {
      _markPseudoStateDirty();
    }
  }

  bool _isSelected() {
    if (_hasAttributeIgnoreCase('selected')) {
      return true;
    }
    final Element? select = _findSelectAncestor();
    if (select == null) {
      return false;
    }
    if (_selectAllowsMultiple(select)) {
      return false;
    }
    final List<Element> options = _collectOptions(select);
    if (options.isEmpty) {
      return false;
    }
    final bool anyExplicit = options.any((option) => _elementHasAttributeIgnoreCase(option, 'selected'));
    if (anyExplicit) {
      return false;
    }
    return identical(options.first, this);
  }

  Element? _findSelectAncestor() {
    Element? current = parentElement;
    while (current != null) {
      if (current.tagName.toUpperCase() == SELECT) {
        return current;
      }
      current = current.parentElement;
    }
    return null;
  }

  bool _selectAllowsMultiple(Element select) {
    return _elementHasAttributeIgnoreCase(select, 'multiple');
  }

  List<Element> _collectOptions(Element root) {
    final List<Element> options = <Element>[];
    void visit(Element element) {
      if (element.tagName.toUpperCase() == OPTION) {
        options.add(element);
      }
      for (final Element child in element.children) {
        visit(child);
      }
    }
    visit(root);
    return options;
  }

  void _clearOtherSelectedIfNeeded() {
    final Element? select = _findSelectAncestor();
    if (select == null || _selectAllowsMultiple(select)) {
      return;
    }
    final List<Element> options = _collectOptions(select);
    for (final Element option in options) {
      if (identical(option, this)) {
        continue;
      }
      _removeAttributeIgnoreCase(option, 'selected');
    }
  }

  bool _hasAttributeIgnoreCase(String name) =>
      _elementHasAttributeIgnoreCase(this, name);

  bool _elementHasAttributeIgnoreCase(Element element, String name) {
    if (element.attributes.containsKey(name)) return true;
    final String lower = name.toLowerCase();
    for (final String key in element.attributes.keys) {
      if (key.toLowerCase() == lower) return true;
    }
    return false;
  }

  void _removeAttributeIgnoreCase(Element element, String name) {
    final String? key = _findAttributeKeyIgnoreCase(element, name);
    if (key != null) {
      element.removeAttribute(key);
    }
  }

  String? _findAttributeKeyIgnoreCase(Element element, String name) {
    if (element.attributes.containsKey(name)) return name;
    final String lower = name.toLowerCase();
    for (final String key in element.attributes.keys) {
      if (key.toLowerCase() == lower) return key;
    }
    return null;
  }

  void _markPseudoStateDirty() {
    final Element? root = ownerDocument.documentElement;
    if (root != null) {
      ownerDocument.markElementStyleDirty(root, reason: 'childList-pseudo');
    } else {
      ownerDocument.markElementStyleDirty(this, reason: 'childList-pseudo');
    }
    _notifySelect();
  }

  void _notifySelect() {
    final Element? select = _findSelectAncestor();
    if (select is HTMLSelectElement) {
      select._notifyOptionsChanged();
    }
  }

  String _collectTextContent(Element root) {
    final StringBuffer buffer = StringBuffer();
    void visit(Node node) {
      if (node is TextNode) {
        buffer.write(node.data);
      }
      if (node is Element) {
        for (final Node child in node.childNodes) {
          visit(child);
        }
      }
    }
    visit(root);
    return buffer.toString();
  }

  void _setTextContent(String value) {
    // Replace existing text nodes with a single text node.
    List<TextNode> textNodes = [];
    Node? cursor = firstChild;
    while (cursor != null) {
      if (cursor is TextNode) textNodes.add(cursor);
      cursor = cursor.nextSibling;
    }

    if (textNodes.isNotEmpty) {
      TextNode keep = textNodes.first;
      keep.data = value;
      for (final tn in textNodes) {
        if (!identical(tn, keep)) {
          removeChild(tn);
        }
      }
    } else {
      appendChild(TextNode(value));
    }
  }

  @override
  void initializeDynamicProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeDynamicProperties(properties);
    properties['selected'] = BindingObjectProperty(getter: () => selected, setter: (value) => selected = value);
    properties['disabled'] = BindingObjectProperty(getter: () => disabled, setter: (value) => disabled = value);
    properties['value'] = BindingObjectProperty(getter: () => value, setter: (value) => this.value = value);
    properties['text'] = BindingObjectProperty(getter: () => text, setter: (value) => text = value?.toString() ?? '');
  }

  @override
  void initializeAttributes(Map<String, dom.ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['selected'] = dom.ElementAttributeProperty(
        getter: () => selected.toString(),
        setter: (value) => selected = dom.attributeToProperty<bool>(value),
        deleter: _markPseudoStateDirty);
    attributes['disabled'] = dom.ElementAttributeProperty(
        getter: () => disabled.toString(),
        setter: (value) => disabled = dom.attributeToProperty<bool>(value),
        deleter: _markPseudoStateDirty);
    attributes['value'] = dom.ElementAttributeProperty(
        getter: () => _attributeValueIgnoreCase('value') ?? '',
        setter: (value) => this.value = value,
        deleter: _markPseudoStateDirty);
    attributes['label'] = dom.ElementAttributeProperty(
        getter: () => _attributeValueIgnoreCase('label') ?? '',
        setter: (value) {
          // Attribute map will be updated by Element.setAttribute; just notify.
          _markPseudoStateDirty();
        },
        deleter: _markPseudoStateDirty);
  }

  String? _attributeValueIgnoreCase(String name) {
    if (attributes.containsKey(name)) return attributes[name];
    final String lower = name.toLowerCase();
    for (final String key in attributes.keys) {
      if (key.toLowerCase() == lower) return attributes[key];
    }
    return null;
  }
}

class HTMLOptGroupElement extends Element {
  HTMLOptGroupElement([super.context]);

  bool get disabled => _attributeValueIgnoreCase('disabled') != null;

  set disabled(dynamic value) {
    if (value == true) {
      internalSetAttribute('disabled', '');
    } else if (attributes.containsKey('disabled')) {
      removeAttribute('disabled');
    }
    _markPseudoStateDirty();
  }

  String get label => _attributeValueIgnoreCase('label') ?? '';

  set label(dynamic value) {
    internalSetAttribute('label', value?.toString() ?? '');
    _markPseudoStateDirty();
  }

  void _markPseudoStateDirty() {
    final Element? root = ownerDocument.documentElement;
    if (root != null) {
      ownerDocument.markElementStyleDirty(root, reason: 'childList-pseudo');
    } else {
      ownerDocument.markElementStyleDirty(this, reason: 'childList-pseudo');
    }
  }

  @override
  void initializeDynamicProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeDynamicProperties(properties);
    properties['disabled'] = BindingObjectProperty(getter: () => disabled, setter: (value) => disabled = value);
    properties['label'] = BindingObjectProperty(getter: () => label, setter: (value) => label = value);
  }

  @override
  void initializeAttributes(Map<String, dom.ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['disabled'] = dom.ElementAttributeProperty(
        getter: () => disabled.toString(),
        setter: (value) => disabled = dom.attributeToProperty<bool>(value),
        deleter: _markPseudoStateDirty);
    attributes['label'] = dom.ElementAttributeProperty(
        getter: () => _attributeValueIgnoreCase('label') ?? '',
        setter: (value) => label = value,
        deleter: _markPseudoStateDirty);
  }

  String? _attributeValueIgnoreCase(String name) {
    if (attributes.containsKey(name)) return attributes[name];
    final String lower = name.toLowerCase();
    for (final String key in attributes.keys) {
      if (key.toLowerCase() == lower) return attributes[key];
    }
    return null;
  }
}
