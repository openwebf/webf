/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;

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
      String originalIdentifier = identifier;
      identifier = variable.identifier.trim();
      _addDependency(identifier, originalIdentifier);
    }
    if (_identifierStorage != null && _identifierStorage![identifier] != null) {
      return _identifierStorage![identifier];
    }
    if (variable?.defaultValue != null) {
      return variable!.defaultValue;
    }
    // Inherits from renderStyle tree.
    return getParentRenderStyle()?.getCSSVariable(identifier, propertyName);
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
      // Remove from identifier storage if it was there
      _identifierStorage?.remove(identifier);
    } else {
      _identifierStorage ??= HashMap<String, String>();
      _identifierStorage![identifier] = value;
      // Remove from variable storage if it was there
      _variableStorage?.remove(identifier);
    }
    
    if (_propertyDependencies.containsKey(identifier)) {
      _notifyCSSVariableChanged(identifier, value);
    }
  }

  void _notifyCSSVariableChanged(String identifier, String value) {
    List<String>? propertyNamesWithPattern = _propertyDependencies[identifier];
    propertyNamesWithPattern?.forEach((String propertyNameWithPattern) {
      List<String> group = propertyNameWithPattern.split('_');
      String propertyName = group[0];
      String? variableString;
      if (group.length > 1) {
        variableString = group[1];
      }

      String propertyValue = target.style.getPropertyValue(propertyName);
      if (target.style.contains(propertyName) && CSSVariable.isCSSVariableValue(propertyValue)) {
        String propertyValue = variableString ?? value;
        if (CSSColor.isColor(propertyValue)) {
          CSSColor.clearCachedColorValue(propertyValue);
        }
        target.style.setProperty(propertyName, variableString ?? value);
        target.style.flushPendingProperties();
      }
    });

    notifyCSSVariableChangedRecursive(RenderObject child) {
      if (child is RenderBoxModel && child is! RenderEventListener) {
        child.renderStyle._notifyCSSVariableChanged(identifier, value);
      } else {
        child.visitChildren(notifyCSSVariableChangedRecursive);
      }
    }

    // Notify children through render tree (for elements that have render objects)
    visitChildren(notifyCSSVariableChangedRecursive);

    // Force recalculation for display:none elements through DOM tree
    _forceRecalculateStyleForCSSVariableChange(identifier, value);
  }

  /// Forces style recalculation for CSS variable changes, ensuring elements with
  /// display:none also get updated when CSS variables they depend on change.
  void _forceRecalculateStyleForCSSVariableChange(String identifier, String value) {
    // Check if this element uses the changed CSS variable
    bool elementDependsOnVariable = _propertyDependencies.containsKey(identifier);

    if (elementDependsOnVariable) {
      // Force recalculation even for display:none elements
      target.recalculateStyle(forceRecalculate: true);
    }

    // Recursively update all child elements through DOM tree to handle display:none elements
    target.childNodes.forEach((node) {
      if (node is dom.Element) {
        node.renderStyle._forceRecalculateStyleForCSSVariableChange(identifier, value);
      }
    });
  }

  /// Forces re-evaluation of all CSS variables that this element depends on.
  /// This is useful when an element transitions from display:none to visible
  /// and needs to pick up any CSS variable changes that occurred while hidden.
  void forceReevaluateAllCSSVariables() {
    // Go through all properties that depend on CSS variables and re-evaluate them
    _propertyDependencies.forEach((identifier, propertyNames) {
      // Get the current value of this CSS variable
      String? currentValue = _getCSSVariableValue(identifier);
      if (currentValue != null) {
        // Re-trigger the complete CSS variable change notification to ensure pseudo-elements are updated
        _notifyCSSVariableChanged(identifier, currentValue);
      }
    });

    // Recursively update all child elements
    target.childNodes.forEach((node) {
      if (node is dom.Element) {
        node.renderStyle.forceReevaluateAllCSSVariables();
      }
    });
  }

  /// Helper method to get the current value of a CSS variable
  String? _getCSSVariableValue(String identifier) {
    // First check local storage
    if (_identifierStorage != null && _identifierStorage![identifier] != null) {
      return _identifierStorage![identifier];
    }

    // Then check variable storage
    CSSVariable? variable = _getRawVariable(identifier);
    if (variable?.defaultValue != null) {
      return variable!.defaultValue;
    }

    // Finally check parent using existing getCSSVariable method
    return getParentRenderStyle()?.getCSSVariable(identifier, '');
  }

  /// Selectively clears CSS variables that are no longer valid in the current cascade.
  /// This is a more targeted approach than clearing all variables.
  void clearInvalidCSSVariables(Set<String> validIdentifiers) {
    // Remove identifiers that are no longer valid
    _identifierStorage?.removeWhere((key, value) => !validIdentifiers.contains(key));
    _variableStorage?.removeWhere((key, value) => !validIdentifiers.contains(key));
  }

  /// Clears all CSS variables for this element.
  /// This should only be called in specific scenarios where a complete reset is needed.
  void clearCSSVariables() {
    _identifierStorage?.clear();
    _variableStorage?.clear();
    // Note: We don't clear _propertyDependencies as they track which properties 
    // use variables, not the variable values themselves
  }
}
