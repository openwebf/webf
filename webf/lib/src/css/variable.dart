/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/src/foundation/debug_flags.dart';

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
    if (kDebugMode && DebugFlags.enableCssLogs) {
      debugPrint('[webf][var] add dep: ' + identifier + ' -> ' + propertyName);
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
      if (kDebugMode && DebugFlags.enableCssLogs) {
        debugPrint('[webf][var] indirection: ' + originalIdentifier + ' -> ' + identifier);
      }
    }
    if (_identifierStorage != null && _identifierStorage![identifier] != null) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        debugPrint('[webf][var] hit: ' + identifier + ' = ' + _identifierStorage![identifier]!);
      }
      return _identifierStorage![identifier];
    }
    if (variable?.defaultValue != null) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        debugPrint('[webf][var] default: ' + identifier + ' = ' + variable!.defaultValue!);
      }
      return variable!.defaultValue;
    }
    // Inherits from renderStyle tree.
    if (kDebugMode && DebugFlags.enableCssLogs) {
      debugPrint('[webf][var] inherit: ' + identifier + ' (from parent)');
    }
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
      if (kDebugMode && DebugFlags.enableCssLogs) {
        debugPrint('[webf][var] set: ' + identifier + ' = CSSVariable(' + variable.identifier + (variable.defaultValue != null ? (',' + variable.defaultValue!) : '') + ')');
      }
    } else {
      _identifierStorage ??= HashMap<String, String>();
      _identifierStorage![identifier] = value;
      if (kDebugMode && DebugFlags.enableCssLogs) {
        debugPrint('[webf][var] set: ' + identifier + ' = ' + value);
      }
    }
    if (_propertyDependencies.containsKey(identifier)) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        debugPrint('[webf][var] notify deps: ' + identifier + ' -> ' + _propertyDependencies[identifier]!.join(','));
      }
      _notifyCSSVariableChanged(identifier, value);
    } else {
      // No dependencies recorded yet (e.g., first parse may have used a cached color string).
      // Clear common color cache keys so next parse recomputes with the new variable value.
      _clearColorCacheForVariable(identifier);
    }
  }

  void _clearColorCacheForVariable(String identifier) {
    List<String> maybeColorKeys = <String>[
      'var($identifier)',
      'rgba(var($identifier))',
      'rgb(var($identifier))',
      'hsla(var($identifier))',
      'hsl(var($identifier))',
    ];
    for (final key in maybeColorKeys) {
      if (CSSColor.isColor(key)) {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[var] fallback clear color cache (set): ' + key);
        }
        CSSColor.clearCachedColorValue(key);
      }
    }
  }

  void _notifyCSSVariableChanged(String identifier, String value) {
    List<String>? propertyNamesWithPattern = _propertyDependencies[identifier];
    propertyNamesWithPattern?.forEach((String propertyNameWithPattern) {
      List<String> group = propertyNameWithPattern.split('_');
      String propertyName = group[0];
      // Retrieve current CSS text for the property. If it still contains var(),
      // re-apply the exact same CSS text to trigger recomputation with the
      // updated variable value, preserving dependency on the variable.
      final String cssText = target.style.getPropertyValue(propertyName);
      if (target.style.contains(propertyName) && CSSVariable.isCSSVariableValue(cssText)) {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          debugPrint('[webf][var] update property due to var change: ' + propertyName + ' <- ' + cssText + ' (variable=' + identifier + ')');
        }
        // Clear color cache conservatively when the CSS value is a bare color.
        // For var(...) patterns, fallback cache clears below handle it.
        if (CSSColor.isColor(cssText)) {
          if (kDebugMode && DebugFlags.enableCssLogs) {
            debugPrint('[webf][var] clear color cache: ' + cssText);
          }
          CSSColor.clearCachedColorValue(cssText);
        }
        target.style.setProperty(propertyName, cssText);
        target.style.flushPendingProperties();
      }
    });

    // Fallback: clear common color cache patterns for this variable to avoid stale cache hits
    // even if we failed to record explicit dependencies (e.g., due to prior cache hits).
    List<String> maybeColorKeys = [
      'var($identifier)',
      'rgba(var($identifier))',
      'rgb(var($identifier))',
      'hsla(var($identifier))',
      'hsl(var($identifier))',
    ];
    for (final key in maybeColorKeys) {
      if (CSSColor.isColor(key)) {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          debugPrint('[webf][var] fallback clear color cache: $key');
        }
        CSSColor.clearCachedColorValue(key);
      }
    }

    notifyCSSVariableChangedRecursive(RenderObject child) {
      if (child is RenderBoxModel && child is! RenderEventListener) {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          debugPrint('[webf][var] propagate to child: ' + child.renderStyle.target.tagName);
        }
        child.renderStyle._notifyCSSVariableChanged(identifier, value);
      } else {
        child.visitChildren(notifyCSSVariableChangedRecursive);
      }
    }

    visitChildren(notifyCSSVariableChangedRecursive);
  }
}
