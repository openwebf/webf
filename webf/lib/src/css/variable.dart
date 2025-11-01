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

// Local matcher for var(...) occurrences (supports simple nesting patterns).
final RegExp _inlineVarFnRegExp = RegExp(r'var\(([^()]*\(.*?\)[^()]*)\)|var\(([^()]*)\)');

mixin CSSVariableMixin on RenderStyle {
  Map<String, String>? _identifierStorage;
  Map<String, CSSVariable>? _variableStorage;
  final Map<String, List<String>> _propertyDependencies = {};

  void _addDependency(String identifier, String propertyName) {
    List<String>? dep = _propertyDependencies[identifier];
    if (dep == null) {
      _propertyDependencies[identifier] = [propertyName];
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[var] dep add: ' + identifier + ' <- ' + propertyName);
      }
    } else if (!dep.contains(propertyName)) {
      dep.add(propertyName);
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[var] dep add: ' + identifier + ' <- ' + propertyName);
      }
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
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[var] miss local: ' + identifier + ' (prop=' + propertyName + '), bubble to parent');
    }
    final parent = getParentRenderStyle();
    final dyn = parent?.getCSSVariable(identifier, propertyName);
    if (kDebugMode && DebugFlags.enableCssLogs) {
      cssLogger.fine('[var] parent ' + (parent == null ? 'none' : 'hit') + ': ' + identifier + ' = ' + (dyn?.toString() ?? 'null'));
    }
    return dyn;
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
        if (kDebugMode && DebugFlags.enableCssLogs) {
          cssLogger.warning('[var] cycle detected for: ' + identifier);
        }
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
      _notifyCSSVariableChanged(identifier, value, prevRaw);
    } else {
      // No dependencies recorded yet (e.g., first parse may have used a cached color string).
      // Clear common color cache keys so next parse recomputes with the new variable value.
      _clearColorCacheForVariable(identifier);
      if (kDebugMode && DebugFlags.enableCssLogs) {
        cssLogger.fine('[var] no deps tracked for: ' + identifier + ' (cleared color caches)');
      }
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

  // Expand only the target variable identifier to the provided override value,
  // preserving token boundaries so neighboring identifiers do not merge.
  String _expandVarWithOverride(String input, String identifier, String override) {
    if (!input.contains('var(')) return input;
    String result = input;
    final before = result;
    result = result.replaceAllMapped(_inlineVarFnRegExp, (Match match) {
      final String? varString = match[0];
      if (varString == null) return '';
      final CSSVariable? variable = CSSVariable.tryParse(this, varString);
      if (variable == null) return varString;
      if (variable.identifier != identifier) return varString;

      bool isIdentCode(int c) {
        return (c >= 48 && c <= 57) || // 0-9
            (c >= 65 && c <= 90) || // A-Z
            (c >= 97 && c <= 122) || // a-z
            c == 45 || // '-'
            c == 95; // '_'
      }
      final int start = match.start;
      final int end = match.end;
      final int? leftChar = start > 0 ? before.codeUnitAt(start - 1) : null;
      final int? rightChar = end < before.length ? before.codeUnitAt(end) : null;
      String rep = override;
      String trimmed = rep.trim();
      final int? repFirst = trimmed.isNotEmpty ? trimmed.codeUnitAt(0) : null;
      final int? repLast = trimmed.isNotEmpty ? trimmed.codeUnitAt(trimmed.length - 1) : null;
      final bool addLeftSpace = leftChar != null && repFirst != null && isIdentCode(leftChar) && isIdentCode(repFirst);
      final bool addRightSpace = rightChar != null && repLast != null && isIdentCode(repLast) && isIdentCode(rightChar);
      if (addLeftSpace) rep = ' ' + rep;
      if (addRightSpace) rep = rep + ' ';
      return rep;
    });
    return result;
  }

  // Expand all var(...) occurrences in the input using current renderStyle
  // variable values, preserving token boundaries to avoid accidental
  // retokenization when adjacent to identifiers.
  String _expandAllVars(String input) {
    if (!input.contains('var(')) return input;
    String result = input;
    int guard = 0;
    while (result.contains('var(') && guard++ < 8) {
      final before = result;
      result = result.replaceAllMapped(_inlineVarFnRegExp, (Match match) {
        final String? varString = match[0];
        if (varString == null) return '';
        final CSSVariable? variable = CSSVariable.tryParse(this, varString);
        if (variable == null) return varString;
        final dynamic raw = getCSSVariable(variable.identifier, '');
        if (raw == null || raw == INITIAL) {
          final fallback = variable.defaultValue;
          if (fallback == null) return varString; // keep unresolved if no fallback
          return fallback.toString();
        }
        // Insert spaces when replacement touches ident-like neighbors
        bool isIdentCode(int c) {
          return (c >= 48 && c <= 57) || // 0-9
              (c >= 65 && c <= 90) || // A-Z
              (c >= 97 && c <= 122) || // a-z
              c == 45 || // '-'
              c == 95; // '_'
        }
        final int start = match.start;
        final int end = match.end;
        final int? leftChar = start > 0 ? before.codeUnitAt(start - 1) : null;
        final int? rightChar = end < before.length ? before.codeUnitAt(end) : null;
        String rep = raw.toString();
        String trimmed = rep.trim();
        final int? repFirst = trimmed.isNotEmpty ? trimmed.codeUnitAt(0) : null;
        final int? repLast = trimmed.isNotEmpty ? trimmed.codeUnitAt(trimmed.length - 1) : null;
        final bool addLeftSpace = leftChar != null && repFirst != null && isIdentCode(leftChar) && isIdentCode(repFirst);
        final bool addRightSpace = rightChar != null && repLast != null && isIdentCode(repLast) && isIdentCode(rightChar);
        if (addLeftSpace) rep = ' ' + rep;
        if (addRightSpace) rep = rep + ' ';
        return rep;
      });
      if (result == before) break;
    }
    return result;
  }

  void _notifyCSSVariableChanged(String identifier, String value, [String? prevVarValue]) {
    // Snapshot to avoid concurrent modification if dependencies mutate during iteration.
    final List<String> propertyNamesWithPattern = _propertyDependencies[identifier] != null
        ? List<String>.from(_propertyDependencies[identifier]!)
        : const <String>[];
    for (final String propertyNameWithPattern in propertyNamesWithPattern) {
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
        // If transitions are configured and this property is animatable, schedule a
        // transition from the previous var-resolved value to the new one.
        bool handledByTransition = false;
        if (prevVarValue != null && this is CSSRenderStyle && CSSTransitionHandlers[propertyName] != null) {
          try {
            final CSSRenderStyle rs = this as CSSRenderStyle;
            final bool configured = rs.effectiveTransitions.containsKey(propertyName) || rs.effectiveTransitions.containsKey(ALL);
            if (configured) {
              // Resolve begin and end to numeric strings so transform transitions
              // have stable matrices for forward and backward animations.
              final String prevText = _expandAllVars(_expandVarWithOverride(cssText, identifier, prevVarValue));
              final String endText = _expandAllVars(cssText);
              if (prevText != endText) {
                if (kDebugMode && DebugFlags.enableTransitionLogs) {
                  final prevComputed = getProperty(propertyName);
                  final prospective = resolveValue(propertyName, endText);
                  cssLogger.fine('[transition][var] property=' + propertyName +
                      ' prev=' + (prevComputed?.toString() ?? 'null') +
                      ' next=' + (prospective?.toString() ?? 'null') +
                      ' configured=true note=schedule');
                }
                target.scheduleRunTransitionAnimations(propertyName, prevText, endText);
                handledByTransition = true;
              } else {
                if (kDebugMode && DebugFlags.enableTransitionLogs) {
                  cssLogger.fine('[transition][var] property=' + propertyName + ' note=skip-schedule-same-begin-end');
                }
              }
            }
          } catch (_) {}
        }
        if (handledByTransition) {
          return; // let the scheduled transition apply updates
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
    }

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
        child.renderStyle._notifyCSSVariableChanged(identifier, value, prevVarValue);
      } else {
        child.visitChildren(notifyCSSVariableChangedRecursive);
      }
    }

    visitChildren(notifyCSSVariableChangedRecursive);
  }
}
