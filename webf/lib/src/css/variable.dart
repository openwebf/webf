/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:collection';
import 'package:webf/foundation.dart';
import 'package:webf/dom.dart';
import 'package:webf/css.dart';

// Local matcher for var(...) occurrences (supports simple nesting patterns).
final RegExp _inlineVarFnRegExp = RegExp(r'var\(([^()]*\(.*?\)[^()]*)\)|var\(([^()]*)\)');

mixin CSSVariableMixin on RenderStyle {
  Map<String, String>? _identifierStorage;
  Map<String, CSSVariable>? _variableStorage;
  final Map<String, List<String>> _propertyDependencies = {};

  void _addDependency(String identifier, String propertyName) {
    // Avoid recording empty dependency keys (produced by some expansion paths),
    // which can pollute the map and complicate later notifications.
    if (propertyName.isEmpty) return;
    List<String>? dep = _propertyDependencies[identifier];
    if (dep == null) {
      _propertyDependencies[identifier] = [propertyName];
      final String p = propertyName.contains('_') ? propertyName.split('_').first : propertyName;
      if (DebugFlags.enableCssVarDependencyLogs && DebugFlags.shouldLogTransitionForProp(p)) {
        cssLogger.info('[var][dep] id=$identifier +$propertyName');
      }
    } else if (!dep.contains(propertyName)) {
      dep.add(propertyName);
      final String p = propertyName.contains('_') ? propertyName.split('_').first : propertyName;
      if (DebugFlags.enableCssVarDependencyLogs && DebugFlags.shouldLogTransitionForProp(p)) {
        cssLogger.info('[var][dep] id=$identifier +$propertyName');
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

    }
    if (_identifierStorage != null && _identifierStorage![identifier] != null) {

      return _identifierStorage![identifier];
    }
    if (variable?.defaultValue != null) {

      return variable!.defaultValue;
    }

    final parent = getAttachedRenderParentRenderStyle();
    final dyn = parent?.getCSSVariable(identifier, propertyName);

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
    final List<String>? deps = _propertyDependencies[identifier];
    if (DebugFlags.shouldLogCssVar(identifier, deps)) {
      cssLogger.info('[var][set] id=$identifier new="$value" target=${target.tagName}');
    }
    if (DebugFlags.enableBackgroundLogs && identifier.startsWith('--tw-gradient-')) {
      // Tailwind gradients rely heavily on custom properties. Log these at a low
      // verbosity gate so we can diagnose bad tokenization (e.g., stray ';').
      cssLogger.finer('[Background][var][set] id=$identifier value="$value"');
    }
    // Snapshot old value before mutation for transition heuristics.
    // Prefer the exact prior token text, including alias var(...) if present.
    String? prevRaw = _identifierStorage != null ? _identifierStorage![identifier] : null;
    if (prevRaw == null && _variableStorage != null && _variableStorage![identifier] != null) {
      // Preserve the alias token form, e.g., 'var(--a[, fallback])'.
      prevRaw = _variableStorage![identifier]!.toString();
    }

    if (isSingleVarFunction(value)) {
      CSSVariable? variable = CSSVariable.tryParse(this, value);
      if (variable != null) {
        _variableStorage ??= HashMap<String, CSSVariable>();
        _variableStorage![identifier] = variable;
        if (DebugFlags.shouldLogCssVar(identifier, deps)) {
          cssLogger.info('[var][set] id=$identifier stored-as=alias prev=${prevRaw ?? 'null'}');
        }

      } else {
        _identifierStorage ??= HashMap<String, String>();
        _identifierStorage![identifier] = value;
        if (DebugFlags.shouldLogCssVar(identifier, deps)) {
          cssLogger.info('[var][set] id=$identifier stored-as=raw prev=${prevRaw ?? 'null'}');
        }

      }
    } else {
      _identifierStorage ??= HashMap<String, String>();
      _identifierStorage![identifier] = value;
      if (DebugFlags.shouldLogCssVar(identifier, deps)) {
        cssLogger.info('[var][set] id=$identifier stored-as=raw prev=${prevRaw ?? 'null'}');
      }

    }
    if (_propertyDependencies.containsKey(identifier)) {
      if (DebugFlags.shouldLogCssVar(identifier, _propertyDependencies[identifier])) {
        cssLogger.info('[var][notify] id=$identifier deps=${_propertyDependencies[identifier]?.join(',') ?? '[]'}');
      }

      _notifyCSSVariableChanged(identifier, value, prevRaw);
    } else {
      // No dependencies recorded yet (e.g., first parse may have used a cached color string).
      // Clear common color cache keys so next parse recomputes with the new variable value.
      _clearColorCacheForVariable(identifier);
      if (DebugFlags.shouldLogCssVar(identifier)) {
        cssLogger.info('[var][notify] id=$identifier no-deps; cleared-color-cache-only');
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
      if (addLeftSpace) rep = ' $rep';
      if (addRightSpace) rep = '$rep ';
      return rep;
    });
    return result;
  }

  // Expand all var(...) occurrences in the input using current renderStyle
  // variable values, preserving token boundaries to avoid accidental
  // retokenization when adjacent to identifiers.
  String _expandAllVars(String input, {String? depContext}) {
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
        final String ctx = depContext ?? '';
        final dynamic raw = getCSSVariable(variable.identifier, ctx);
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
        if (addLeftSpace) rep = ' $rep';
        if (addRightSpace) rep = '$rep ';
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
    if (DebugFlags.shouldLogCssVar(identifier, propertyNamesWithPattern)) {
      cssLogger.info('[var][notify] id=$identifier target=${target.tagName} new="$value" prev=${prevVarValue ?? 'null'}');
    }
    for (final String propertyNameWithPattern in propertyNamesWithPattern) {
      List<String> group = propertyNameWithPattern.split('_');
      String propertyName = group[0];
      // Retrieve current CSS text for the property. If it still contains var(),
      // re-apply the exact same CSS text to trigger recomputation with the
      // updated variable value, preserving dependency on the variable.
      final String cssText = target.style.getPropertyValue(propertyName);
      final bool containsProp = target.style.contains(propertyName);
      final bool hasVarFn = CSSVariable.isCSSVariableValue(cssText);
      if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
        cssLogger.info('[var][notify] -> property=$propertyName contains=$containsProp hasVar=$hasVarFn cssText="$cssText"');
      }
      if (containsProp && hasVarFn) {
        // If transitions are configured and this property is animatable, schedule a
        // transition from the previous var-resolved value to the new one.
        bool handledByTransition = false;
        // Proactively clear color cache entries for previously-resolved values
        // like hsl(<prev>) / hsla(<prev>) / rgb(<prev>) / rgba(<prev>) to avoid
        // stale cache hits when a var() inside a color function changes.
        if (prevVarValue != null) {
          final List<String> priorColorKeys = <String>[
            'hsl($prevVarValue)',
            'hsla($prevVarValue)',
            'rgb($prevVarValue)',
            'rgba($prevVarValue)',
          ];
          for (final key in priorColorKeys) {
            if (CSSColor.isColor(key)) {
              CSSColor.clearCachedColorValue(key);
            }
          }
        }
        if (prevVarValue != null && this is CSSRenderStyle && cssTransitionHandlers[propertyName] != null) {
          try {
            final CSSRenderStyle rs = this as CSSRenderStyle;
            // Raw configured check (current behavior)
            final bool configuredRaw = rs.effectiveTransitions.containsKey(propertyName) || rs.effectiveTransitions.containsKey(ALL);
            // Canonical key check to mirror transitions behavior for shorthands
            String canonicalKey = propertyName;
            // Canonicalize longhands to their shorthands so transition-property: <shorthand>
            // covers the corresponding longhand updates driven by var(...).
            if (propertyName == BACKGROUND_POSITION_X || propertyName == BACKGROUND_POSITION_Y) {
              canonicalKey = BACKGROUND_POSITION;
            } else if (propertyName == BORDER_TOP_COLOR || propertyName == BORDER_RIGHT_COLOR ||
                propertyName == BORDER_BOTTOM_COLOR || propertyName == BORDER_LEFT_COLOR) {
              canonicalKey = BORDER_COLOR;
            } else if (propertyName == BORDER_TOP_WIDTH || propertyName == BORDER_RIGHT_WIDTH ||
                propertyName == BORDER_BOTTOM_WIDTH || propertyName == BORDER_LEFT_WIDTH) {
              canonicalKey = BORDER_WIDTH;
            } else if (propertyName == BORDER_TOP_STYLE || propertyName == BORDER_RIGHT_STYLE ||
                propertyName == BORDER_BOTTOM_STYLE || propertyName == BORDER_LEFT_STYLE) {
              canonicalKey = BORDER_STYLE;
            } else if (propertyName == BORDER_TOP_LEFT_RADIUS || propertyName == BORDER_TOP_RIGHT_RADIUS ||
                propertyName == BORDER_BOTTOM_RIGHT_RADIUS || propertyName == BORDER_BOTTOM_LEFT_RADIUS) {
              canonicalKey = BORDER_RADIUS;
            } else if (propertyName == PADDING_LEFT || propertyName == PADDING_RIGHT ||
                propertyName == PADDING_TOP || propertyName == PADDING_BOTTOM) {
              canonicalKey = 'padding';
            } else if (propertyName == MARGIN_LEFT || propertyName == MARGIN_RIGHT ||
                propertyName == MARGIN_TOP || propertyName == MARGIN_BOTTOM) {
              canonicalKey = 'margin';
            }
            final bool configuredCanonical = rs.effectiveTransitions.containsKey(canonicalKey) || rs.effectiveTransitions.containsKey(ALL);
            if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
              cssLogger.info('[var][notify] property=$propertyName configuredRaw=$configuredRaw canonicalKey=$canonicalKey configuredCanonical=$configuredCanonical');
            }
            // Option A: If the property is configured for transition (raw or canonical),
            // schedule the transition regardless of whether duration is currently non-zero.
            // The queued transition drains post-frame, after transition-* properties flush,
            // so it will see the final effectiveTransitions.
            if (configuredRaw || configuredCanonical) {
              // Resolve begin and end to numeric strings so transform transitions
              // have stable matrices for forward and backward animations.
              final String prevText = _expandAllVars(
                  _expandVarWithOverride(cssText, identifier, prevVarValue),
                  depContext: '${propertyName}_$cssText',
              );
              final String endText = _expandAllVars(
                  cssText,
                  depContext: '${propertyName}_$cssText',
              );
              if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
                cssLogger.info('[var][transition] property=$propertyName prevText="$prevText" endText="$endText"');
              }
              if (prevText != endText) {
                if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
                  cssLogger.info('[var][transition] schedule property=$propertyName');
                }
                target.scheduleRunTransitionAnimations(propertyName, prevText, endText);
                handledByTransition = true;
              } else {
                if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
                  cssLogger.info('[var][transition] skip-equal property=$propertyName');
                }
              }
            }
          } catch (_) {}
        }

        if (handledByTransition) {
          if (DebugFlags.shouldLogTransitionForProp(propertyName)) {
            cssLogger.info('[var][notify] property=$propertyName handledByTransition=true; continue dependencies');
          }
          continue; // schedule next dependent property as well
        }
        // Clear color cache conservatively when the CSS value is a bare color.
        // For var(...) patterns, fallback cache clears below handle it.
        if (CSSColor.isColor(cssText)) {
          CSSColor.clearCachedColorValue(cssText);
        }
        // Apply directly to computed style to avoid re-entrant pending queue issues.
        // For color-bearing properties, eagerly expand all var(...) before applying to
        // bypass stale color cache hits for hsl()/rgb() strings that still contain var().
        String cssTextToApply = cssText;
        bool isColorProperty = propertyName == COLOR ||
            propertyName == BACKGROUND_COLOR ||
            propertyName == TEXT_DECORATION_COLOR ||
            propertyName == BORDER_LEFT_COLOR ||
            propertyName == BORDER_TOP_COLOR ||
            propertyName == BORDER_RIGHT_COLOR ||
            propertyName == BORDER_BOTTOM_COLOR;
        if (isColorProperty && cssTextToApply.contains('var(')) {
          cssTextToApply = _expandAllVars(
            cssTextToApply,
            depContext: '${propertyName}_$cssText',
          );
        }
        final String? baseHref = target.style.getPropertyBaseHref(propertyName);

        if (DebugFlags.enableCssVarAndTransitionLogs) {
          cssLogger.info('[var][notify] property=$propertyName direct-set value="$cssTextToApply" baseHref=${baseHref ?? 'null'}');
        }
        target.setRenderStyle(propertyName, cssTextToApply, baseHref: baseHref);

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
        CSSColor.clearCachedColorValue(key);
      }
    }

    // Propagate via DOM tree instead of render tree so display:none descendants
    // (which have no render objects) also receive variable updates.
    target.visitChildren((Node node) {
      if (node is Element) {
        node.renderStyle._notifyCSSVariableChanged(identifier, value, prevVarValue);
      }
    });
  }
}
