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
        cssLogger.fine('[var] indirection: ' + originalIdentifier + ' -> ' + identifier);
      }
    }
    if (_identifierStorage != null && _identifierStorage![identifier] != null) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[var] hit: ' + identifier + ' = ' + _identifierStorage![identifier]!);
      }
      return _identifierStorage![identifier];
    }
    if (variable?.defaultValue != null) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[var] default: ' + identifier + ' = ' + variable!.defaultValue!);
      }
      return variable!.defaultValue;
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

  // Only treat as an alias when the value is exactly a single outer var(...) wrapper
  // with no extra tokens outside. This preserves comma-separated lists like
  //   --tw-gradient-stops: var(--from), var(--to)
  // as raw strings.
  bool isSingleVarFunction(String v) {
    int i = 0;
    final s = v.trimLeft();
    // Must begin with 'var('
    if (!s.startsWith('var(')) return false;
    // Find the position of the opening '(' after 'var'
    int start = s.indexOf('(');
    int depth = 0;
    for (i = start; i < s.length; i++) {
      final ch = s.codeUnitAt(i);
      if (ch == 40) { // '('
        depth++;
      } else if (ch == 41) { // ')'
        depth--;
        if (depth == 0) {
          // i is the matching closing ')'. Ensure the rest is only whitespace.
          final rest = s.substring(i + 1).trim();
          return rest.isEmpty;
        }
      }
    }
    return false;
  }

  // --x: red
  // key: --x
  // value: red
  @override
  void setCSSVariable(String identifier, String value) {
    // Snapshot old value before mutation for transition heuristics.
    String? prevRaw = _identifierStorage != null ? _identifierStorage![identifier] : null;

    if (isSingleVarFunction(value)) {
      CSSVariable? variable = CSSVariable.tryParse(this, value);
      if (variable != null) {
        _variableStorage ??= HashMap<String, CSSVariable>();
        _variableStorage![identifier] = variable;
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[var] set: ' + identifier + ' = CSSVariable(' + variable.identifier + (variable.defaultValue != null ? (',' + variable.defaultValue!) : '') + ')');
        }
      } else {
        _identifierStorage ??= HashMap<String, String>();
        _identifierStorage![identifier] = value;
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[var] set: ' + identifier + ' = ' + value);
        }
      }
    } else {
      _identifierStorage ??= HashMap<String, String>();
      _identifierStorage![identifier] = value;
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[var] set: ' + identifier + ' = ' + value);
      }
    }
    if (_propertyDependencies.containsKey(identifier)) {
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[var] notify deps: ' + identifier + ' -> ' + _propertyDependencies[identifier]!.join(','));
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
          cssLogger.fine('[var] update property due to var change: ' + propertyName + ' <- ' + cssText + ' (variable=' + identifier + ')');
        }
        // Clear color cache conservatively when the CSS value is a bare color.
        // For var(...) patterns, fallback cache clears below handle it.
        if (CSSColor.isColor(cssText)) {
          if (kDebugMode && DebugFlags.enableCssLogs) {
            cssLogger.fine('[var] clear color cache: ' + cssText);
          }
          CSSColor.clearCachedColorValue(cssText);
        }
        // Apply directly to computed style to avoid re-entrant pending queue issues.
        // This guarantees immediate recomputation using latest var values.
        final String? baseHref = target.style.getPropertyBaseHref(propertyName);
        target.setRenderStyle(propertyName, cssText, baseHref: baseHref);
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[var] applied var-affected property via setRenderStyle: ' + propertyName);
        }
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
          cssLogger.fine('[var] fallback clear color cache: $key');
        }
        CSSColor.clearCachedColorValue(key);
      }
    }

    notifyCSSVariableChangedRecursive(RenderObject child) {
      if (child is RenderBoxModel && child is! RenderEventListener) {
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.fine('[var] propagate to child: ' + child.renderStyle.target.tagName);
        }
        child.renderStyle._notifyCSSVariableChanged(identifier, value);
      } else {
        child.visitChildren(notifyCSSVariableChangedRecursive);
      }
    }

    visitChildren(notifyCSSVariableChangedRecursive);
  }
}
