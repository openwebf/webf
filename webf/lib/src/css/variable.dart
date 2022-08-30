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
    if (_checkStorageLoop(identifier)) {
      return null;
    }
    _addDependency(identifier, propertyName);
    if (_variableStorage != null && _variableStorage![identifier] != null) {
      CSSVariable variable = _variableStorage![identifier]!;
      final id = variable.identifier.trim();
      if (_variableStorage![id] != null && id != identifier) {
        return getCSSVariable(id, propertyName);
      }
      if (variable.defaultValue != null) {
        return variable.defaultValue;
      }
      return null;
    } else if (_identifierStorage != null && _identifierStorage![identifier] != null) {
      return _identifierStorage![identifier];
    } else {
      // Inherits from renderStyle tree.
      return parent?.getCSSVariable(identifier, propertyName);
    }
  }

  bool _checkStorageLoop(String identifier) {
    Map<String, dynamic>? storage = _variableStorage;
    if (storage == null) {
      return false;
    }
    if (storage[identifier] == null) {
      return false;
    }
    CSSVariable fast = storage[identifier]!;
    CSSVariable slow = storage[identifier]!;
    while (storage[fast.identifier] != null && storage[storage[fast.identifier]!.identifier] != null) {
      fast = storage[storage[fast.identifier]!.identifier]!;
      slow = storage[slow.identifier]!;
      if (fast == slow) {
        return true;
      }
    }
    return false;
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
      _notifyCSSVariableChanged(_propertyDependencies[identifier]!, value);
    }
  }

  void _notifyCSSVariableChanged(List<String> propertyNames, String value) {
    propertyNames.forEach((String propertyName) {
      target.setRenderStyle(propertyName, value);
      visitChildren((CSSRenderStyle childRenderStyle) {
        childRenderStyle._notifyCSSVariableChanged(propertyNames, value);
      });
    });
  }
}
