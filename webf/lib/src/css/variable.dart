/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';
import 'package:webf/css.dart';

mixin CSSVariableMixin on RenderStyle {
  Map<String, dynamic>? _storage;
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

    Map<String, dynamic>? storage = _storage;
    _addDependency(identifier, propertyName);

    if (storage != null && storage[identifier] != null) {
      final variable = storage[identifier];
      if (variable != null && variable is CSSVariable) {
        final id = variable.identifier.trim();
        if (storage[id] != null && id != identifier) {
          return getCSSVariable(id, propertyName);
        }
        if (variable.defaultValue != null) {
          return variable.defaultValue;
        }
        return null;
      } else {
        return storage[identifier];
      }
    } else {
      // Inherits from renderStyle tree.
      return parent?.getCSSVariable(identifier, propertyName);
    }
  }

  bool _checkStorageLoop(String identifier) {
    Map<String, dynamic>? storage = _storage;
    if (storage == null) {
      return false;
    }
    if (storage[identifier] == null) {
      return false;
    }
    if (storage[identifier] is! CSSVariable) {
      return false;
    }
    CSSVariable fast = storage[identifier]!;
    CSSVariable slow = storage[identifier]!;
    while (storage[fast.identifier] != null &&
        storage[fast.identifier] is CSSVariable &&
        storage[storage[fast.identifier]!.identifier] != null &&
        storage[storage[fast.identifier]!.identifier] is CSSVariable) {
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
    _storage ??= HashMap<String, dynamic>();
    _storage![identifier] = CSSVariable.tryParse(this, value) ?? value;

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
