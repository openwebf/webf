/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:webf/bridge.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/dom.dart';

// ignore: constant_identifier_names
const SELECT = 'SELECT';
// ignore: constant_identifier_names
const OPTION = 'OPTION';
// ignore: constant_identifier_names
const OPTGROUP = 'OPTGROUP';

class HTMLSelectElement extends Element {
  HTMLSelectElement([super.context]);

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
  void initializeDynamicProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeDynamicProperties(properties);
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

class HTMLOptionElement extends Element {
  HTMLOptionElement([super.context]);

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
  }

  @override
  void initializeDynamicProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeDynamicProperties(properties);
    properties['selected'] = BindingObjectProperty(getter: () => selected, setter: (value) => selected = value);
    properties['disabled'] = BindingObjectProperty(getter: () => disabled, setter: (value) => disabled = value);
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
  }
}

class HTMLOptGroupElement extends Element {
  HTMLOptGroupElement([super.context]);

  bool get disabled => getAttribute('disabled') != null;

  set disabled(dynamic value) {
    if (value == true) {
      internalSetAttribute('disabled', '');
    } else if (attributes.containsKey('disabled')) {
      removeAttribute('disabled');
    }
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
  }

  @override
  void initializeAttributes(Map<String, dom.ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['disabled'] = dom.ElementAttributeProperty(
        getter: () => disabled.toString(),
        setter: (value) => disabled = dom.attributeToProperty<bool>(value),
        deleter: _markPseudoStateDirty);
  }
}
