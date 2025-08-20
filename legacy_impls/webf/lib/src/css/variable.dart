/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';
import 'package:webf/css.dart';

mixin CSSVariableMixin on RenderStyle {
  Map<String, String>? _identifierStorage;
  Map<String, CSSVariable>? _variableStorage;
  final Map<String, List<String>> _propertyDependencies = {};

  void _addDependency(String identifier, String propertyName) {
    List<String>? dep = _propertyDependencies[identifier];
    if (dep == null) {
      _propertyDependencies[identifier] = [propertyName];
    } else if (!dep.contains(propertyName)) {
      dep.add(propertyName);
    }
  }

  @override
  dynamic getCSSVariable(String identifier, String propertyName) {
    CSSVariable? variable = _getRawVariable(identifier);
    _addDependency(identifier, propertyName);
    if (variable != null) {
      identifier = variable.identifier.trim();
    }
    if (_identifierStorage != null && _identifierStorage![identifier] != null) {
      return _identifierStorage![identifier];
    }
    if (variable?.defaultValue != null) {
      return variable!.defaultValue;
    }
    // Inherits from renderStyle tree.
    return parent?.getCSSVariable(identifier, propertyName);
  }

  CSSVariable? _getRawVariable(String identifier) {
    Map<String, CSSVariable>? storage = _variableStorage;
    if (storage == null) {
      return null;
    }
    if (storage[identifier] == null) {
      return null;
    }
    CSSVariable fast = storage[identifier]!;
    CSSVariable slow = storage[identifier]!;
    while (storage[fast.identifier] != null && storage[storage[fast.identifier]!.identifier] != null) {
      fast = storage[storage[fast.identifier]!.identifier]!;
      slow = storage[slow.identifier]!;
      if (fast == slow) {
        return null;
      }
    }
    return storage[fast.identifier] ?? fast;
  }

  // --x: red
  // key: --x
  // value: red
  @override
  void setCSSVariable(String identifier, String value) {
    CSSVariable? variable = CSSVariable.tryParse(this, value);
    if (variable != null) {
      _variableStorage ??= HashMap<String, CSSVariable>();
      _variableStorage![identifier] = variable;
    } else {
      _identifierStorage ??= HashMap<String, String>();
      _identifierStorage![identifier] = value;
    }
    if (_propertyDependencies.containsKey(identifier)) {
      _notifyCSSVariableChanged(identifier, value);
    }
  }

  void _notifyCSSVariableChanged(String identifier,String value) {
    List<String>? propertyNames = _propertyDependencies[identifier];
    propertyNames?.forEach((String propertyName) {
      target.setRenderStyle(propertyName, value);
    });
    visitChildren((CSSRenderStyle childRenderStyle) {
      childRenderStyle._notifyCSSVariableChanged(identifier, value);
    });
  }
}
