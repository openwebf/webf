/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/foundation.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';
import 'package:webf/html.dart';
import 'package:quiver/collection.dart';

typedef StyleChangeListener = void Function(
    String property, String? original, String present,
    {String? baseHref});
typedef StyleFlushedListener = void Function(List<String> properties);

const Map<String, bool> _cssShorthandProperty = {
  MARGIN: true,
  PADDING: true,
  INSET: true,
  BACKGROUND: true,
  BACKGROUND_POSITION: true,
  BORDER_RADIUS: true,
  BORDER: true,
  BORDER_COLOR: true,
  BORDER_WIDTH: true,
  BORDER_STYLE: true,
  BORDER_LEFT: true,
  BORDER_RIGHT: true,
  BORDER_TOP: true,
  BORDER_BOTTOM: true,
  BORDER_INLINE_START: true,
  BORDER_INLINE_END: true,
  BORDER_BLOCK_START: true,
  BORDER_BLOCK_END: true,
  FONT: true,
  FLEX: true,
  FLEX_FLOW: true,
  GAP: true,
  GRID_TEMPLATE: true,
  GRID: true,
  // WebF shorthand: maps to align-items + justify-content
  PLACE_CONTENT: true,
  PLACE_ITEMS: true,
  PLACE_SELF: true,
  GRID_ROW: true,
  GRID_COLUMN: true,
  GRID_AREA: true,
  OVERFLOW: true,
  TRANSITION: true,
  TEXT_DECORATION: true,
  ANIMATION: true,
};

// Reorder the properties for control render style init order, the last is the largest.
List<String> _propertyOrders = [
  // Ensure direction is resolved before logical properties mapping
  DIRECTION,
  LINE_CLAMP,
  WHITE_SPACE,
  FONT_SIZE,
  COLOR,
  TRANSITION_DURATION,
  TRANSITION_PROPERTY,
  TRANSITION_TIMING_FUNCTION,
  TRANSITION_DELAY,
  OVERFLOW_X,
  OVERFLOW_Y,
  WIDTH,
  HEIGHT
];

final List<String> _propertyFlushPriorityOrder =
    List<String>.unmodifiable(_propertyOrders.reversed);
final Map<String, int> _propertyFlushPriorityRanks = <String, int>{
  for (int i = 0; i < _propertyFlushPriorityOrder.length; i++)
    _propertyFlushPriorityOrder[i]: i,
};

final LinkedLruHashMap<String, Map<String, String?>> _cachedExpandedShorthand =
    LinkedLruHashMap(maximumSize: 500);

class CSSPropertyValue {
  String? baseHref;
  String value;

  CSSPropertyValue(this.value, {this.baseHref});

  @override
  String toString() {
    return value;
  }
}

// CSS Object Model: https://drafts.csswg.org/cssom/#the-cssstyledeclaration-interface

/// The [CSSStyleDeclaration] interface represents an object that is a CSS
/// declaration block, and exposes style information and various style-related
/// methods and properties.
///
/// A [CSSStyleDeclaration] object can be exposed using three different APIs:
/// 1. Via [HTMLElement.style], which deals with the inline styles of a single
///    element (e.g., <div style="...">).
/// 2. Via the [CSSStyleSheet] API. For example,
///    document.styleSheets[0].cssRules[0].style returns a [CSSStyleDeclaration]
///    object on the first CSS rule in the document's first stylesheet.
/// 3. Via [Window.getComputedStyle()], which exposes the [CSSStyleDeclaration]
///    object as a read-only interface.
class CSSStyleDeclaration extends DynamicBindingObject
    with StaticDefinedBindingObject {
  Element? target;

  // TODO(yuanyan): defaultStyle should be longhand properties.
  Map<String, dynamic>? defaultStyle;
  StyleChangeListener? onStyleChanged;
  StyleFlushedListener? onStyleFlushed;

  CSSStyleDeclaration? _pseudoBeforeStyle;
  CSSStyleDeclaration? _inlinePseudoBeforeStyle;
  CSSStyleDeclaration? get pseudoBeforeStyle => _pseudoBeforeStyle;
  set pseudoBeforeStyle(CSSStyleDeclaration? newStyle) {
    _pseudoBeforeStyle = newStyle;
    target?.markBeforePseudoElementNeedsUpdate();
  }

  CSSStyleDeclaration? get resolvedPseudoBeforeStyle =>
      _resolvePseudoStyle(_pseudoBeforeStyle, _inlinePseudoBeforeStyle);

  CSSStyleDeclaration? _pseudoAfterStyle;
  CSSStyleDeclaration? _inlinePseudoAfterStyle;
  CSSStyleDeclaration? get pseudoAfterStyle => _pseudoAfterStyle;
  set pseudoAfterStyle(CSSStyleDeclaration? newStyle) {
    _pseudoAfterStyle = newStyle;
    target?.markAfterPseudoElementNeedsUpdate();
  }

  CSSStyleDeclaration? get resolvedPseudoAfterStyle =>
      _resolvePseudoStyle(_pseudoAfterStyle, _inlinePseudoAfterStyle);

  // ::first-letter pseudo style (applies to the first typographic letter)
  CSSStyleDeclaration? _pseudoFirstLetterStyle;
  CSSStyleDeclaration? _inlinePseudoFirstLetterStyle;
  CSSStyleDeclaration? get pseudoFirstLetterStyle => _pseudoFirstLetterStyle;
  set pseudoFirstLetterStyle(CSSStyleDeclaration? newStyle) {
    _pseudoFirstLetterStyle = newStyle;
    // Trigger a layout rebuild so IFC can re-shape text for first-letter styling
    target?.markFirstLetterPseudoNeedsUpdate();
  }

  CSSStyleDeclaration? get resolvedPseudoFirstLetterStyle =>
      _resolvePseudoStyle(
          _pseudoFirstLetterStyle, _inlinePseudoFirstLetterStyle);

  // ::first-line pseudo style (applies to only the first formatted line)
  CSSStyleDeclaration? _pseudoFirstLineStyle;
  CSSStyleDeclaration? _inlinePseudoFirstLineStyle;
  CSSStyleDeclaration? get pseudoFirstLineStyle => _pseudoFirstLineStyle;
  set pseudoFirstLineStyle(CSSStyleDeclaration? newStyle) {
    _pseudoFirstLineStyle = newStyle;
    target?.markFirstLinePseudoNeedsUpdate();
  }

  CSSStyleDeclaration? get resolvedPseudoFirstLineStyle =>
      _resolvePseudoStyle(_pseudoFirstLineStyle, _inlinePseudoFirstLineStyle);

  bool _didProcessPseudoRules = false;

  CSSStyleDeclaration? _resolvePseudoStyle(
      CSSStyleDeclaration? ruleStyle, CSSStyleDeclaration? inlineStyle) {
    if (ruleStyle == null) return inlineStyle;
    if (inlineStyle == null) return ruleStyle;
    final CSSStyleDeclaration resolved = CSSStyleDeclaration();
    resolved.union(ruleStyle);
    resolved.union(inlineStyle);
    return resolved;
  }

  CSSStyleDeclaration([super.context]);

  // ignore: prefer_initializing_formals
  CSSStyleDeclaration.computedStyle(
      this.target, this.defaultStyle, this.onStyleChanged,
      [this.onStyleFlushed]);

  /// An empty style declaration.
  static CSSStyleDeclaration empty = CSSStyleDeclaration();

  /// When some property changed, corresponding [StyleChangeListener] will be
  /// invoked in synchronous.
  final List<StyleChangeListener> _styleChangeListeners = [];

  final Map<String, CSSPropertyValue> _properties = {};
  Map<String, CSSPropertyValue> _pendingProperties = {};
  final Map<String, bool> _importants = {};
  final Map<String, dynamic> _sheetStyle = {};

  /// Textual representation of the declaration block.
  /// Setting this attribute changes the style.
  String get cssText {
    String css = EMPTY_STRING;
    _properties.forEach((property, value) {
      if (css.isNotEmpty) css += ' ';
      css +=
          '${_kebabize(property)}: $value ${_importants.containsKey(property) ? '!important' : ''};';
    });
    return css;
  }

  /// Whether the given property is marked as `!important` on this declaration.
  ///
  /// Exposed for components (e.g., CSS variable resolver) that need to
  /// preserve importance when updating dependent properties.
  bool isImportant(String propertyName) {
    return _importants[_normalizePropertyName(propertyName)] == true;
  }

  bool get hasImportantDeclarations => _importants.isNotEmpty;

  bool get hasPendingProperties => _pendingProperties.isNotEmpty;

  bool get hasInheritedPendingProperty {
    return _pendingProperties.keys
        .any((key) => isInheritedPropertyString(_kebabize(key)));
  }

  // @TODO: Impl the cssText setter.

  /// The number of properties.
  @override
  int get length => _properties.length;

  /// Returns a property name.
  String item(int index) {
    return _properties.keys.elementAt(index);
  }

  /// Returns the property value given a property name.
  /// value is a String containing the value of the property.
  /// If not set, returns the empty string.
  String getPropertyValue(String propertyName) {
    propertyName = _normalizePropertyName(propertyName);
    return _getPropertyValueByNormalizedName(propertyName);
  }

  String _getPropertyValueByNormalizedName(String propertyName) {
    // Get the latest pending value first.
    return _pendingProperties[propertyName]?.value ??
        _properties[propertyName]?.value ??
        EMPTY_STRING;
  }

  /// Returns the baseHref associated with a property value if available.
  String? getPropertyBaseHref(String propertyName) {
    propertyName = _normalizePropertyName(propertyName);
    return _getPropertyBaseHrefByNormalizedName(propertyName);
  }

  String? _getPropertyBaseHrefByNormalizedName(String propertyName) {
    return _pendingProperties[propertyName]?.baseHref ??
        _properties[propertyName]?.baseHref;
  }

  CSSPropertyValue? _effectiveProperty(String propertyName) {
    return _pendingProperties[propertyName] ?? _properties[propertyName];
  }

  bool _hasEffectiveProperty(String propertyName) {
    final CSSPropertyValue? value = _effectiveProperty(propertyName);
    return value != null && value.value.isNotEmpty;
  }

  String _removedPropertyFallbackValue(String propertyName,
      [bool? isImportant]) {
    String present = EMPTY_STRING;
    if (isImportant == true) {
      _importants.remove(propertyName);
      final String? value = _sheetStyle[propertyName];
      if (!isNullOrEmptyValue(value)) {
        present = value!;
      }
    } else if (isImportant == false) {
      _sheetStyle.remove(propertyName);
    }

    if (isNullOrEmptyValue(present) &&
        defaultStyle != null &&
        defaultStyle!.containsKey(propertyName)) {
      present = defaultStyle![propertyName];
    }

    if (isNullOrEmptyValue(present) &&
        cssInitialValues.containsKey(propertyName)) {
      final String kebabName = _kebabize(propertyName);
      final bool isInherited = isInheritedPropertyString(kebabName);
      if (!isInherited) {
        present = cssInitialValues[propertyName];
      }
    }

    return present;
  }

  bool _queueMergedPropertyValue(String propertyName, CSSPropertyValue value,
      {required bool important}) {
    if (!important) {
      _sheetStyle[propertyName] = value.value;
    }

    if (!important && _importants[propertyName] == true) {
      return false;
    }

    if (important) {
      _importants[propertyName] = true;
    }

    _pendingProperties[propertyName] = value;
    return true;
  }

  bool get _isEffectivelyEmpty =>
      _properties.isEmpty && _pendingProperties.isEmpty && _importants.isEmpty;

  void _adoptEffectivePropertiesFrom(CSSStyleDeclaration declaration) {
    if (declaration._properties.isEmpty) {
      if (declaration._pendingProperties.isNotEmpty) {
        _pendingProperties =
            Map<String, CSSPropertyValue>.of(declaration._pendingProperties);
      }
      if (declaration._importants.isNotEmpty) {
        _importants.addAll(declaration._importants);
      }
      return;
    }

    final CSSStyleDeclaration cloned = declaration.cloneEffective();
    if (cloned._pendingProperties.isNotEmpty) {
      _pendingProperties = cloned._pendingProperties;
    }
    if (cloned._importants.isNotEmpty) {
      _importants.addAll(cloned._importants);
    }
  }

  CSSStyleDeclaration cloneEffective() {
    final CSSStyleDeclaration cloned = CSSStyleDeclaration();

    if (_properties.isEmpty) {
      if (_pendingProperties.isNotEmpty) {
        cloned._pendingProperties =
            Map<String, CSSPropertyValue>.of(_pendingProperties);
      }
      if (_importants.isNotEmpty) {
        cloned._importants.addAll(_importants);
      }
      return cloned;
    }

    for (final String propertyName in _properties.keys) {
      if (_pendingProperties.containsKey(propertyName)) continue;
      final CSSPropertyValue? value = _properties[propertyName];
      if (value == null || value.value.isEmpty) continue;
      cloned._pendingProperties[propertyName] = value;
      if (_importants[propertyName] == true) {
        cloned._importants[propertyName] = true;
      }
    }

    for (final String propertyName in _pendingProperties.keys) {
      final CSSPropertyValue value = _pendingProperties[propertyName]!;
      if (value.value.isEmpty) continue;
      cloned._pendingProperties[propertyName] = value;
      if (_importants[propertyName] == true) {
        cloned._importants[propertyName] = true;
      }
    }

    return cloned;
  }

  List<String> _structuralPropertyNames() {
    final Set<String> propertyNames = <String>{}
      ..addAll(_properties.keys)
      ..addAll(_pendingProperties.keys)
      ..addAll(_importants.keys);
    propertyNames
        .removeWhere((propertyName) => getPropertyValue(propertyName).isEmpty);
    final List<String> sorted = propertyNames.toList(growable: false);
    sorted.sort();
    return sorted;
  }

  int get structuralHashCode {
    final List<String> propertyNames = _structuralPropertyNames();
    return Object.hashAll(propertyNames.map((propertyName) => Object.hash(
          propertyName,
          _getPropertyValueByNormalizedName(propertyName),
          _getPropertyBaseHrefByNormalizedName(propertyName),
          _importants[propertyName] == true,
        )));
  }

  bool structurallyEquals(CSSStyleDeclaration other) {
    if (identical(this, other)) return true;

    final List<String> propertyNames = _structuralPropertyNames();
    final List<String> otherPropertyNames = other._structuralPropertyNames();
    if (propertyNames.length != otherPropertyNames.length) return false;

    for (int index = 0; index < propertyNames.length; index++) {
      final String propertyName = propertyNames[index];
      if (propertyName != otherPropertyNames[index]) return false;
      if (_getPropertyValueByNormalizedName(propertyName) !=
          other._getPropertyValueByNormalizedName(propertyName)) {
        return false;
      }
      if (_getPropertyBaseHrefByNormalizedName(propertyName) !=
          other._getPropertyBaseHrefByNormalizedName(propertyName)) {
        return false;
      }
      if ((_importants[propertyName] == true) !=
          (other._importants[propertyName] == true)) {
        return false;
      }
    }

    return true;
  }

  /// Removes a property from the CSS declaration.
  void removeProperty(String propertyName, [bool? isImportant]) {
    propertyName = _normalizePropertyName(propertyName);
    switch (propertyName) {
      case PADDING:
        return CSSStyleProperty.removeShorthandPadding(this, isImportant);
      case MARGIN:
        return CSSStyleProperty.removeShorthandMargin(this, isImportant);
      case INSET:
        return CSSStyleProperty.removeShorthandInset(this, isImportant);
      case BACKGROUND:
        return CSSStyleProperty.removeShorthandBackground(this, isImportant);
      case BACKGROUND_POSITION:
        return CSSStyleProperty.removeShorthandBackgroundPosition(
            this, isImportant);
      case BORDER_RADIUS:
        return CSSStyleProperty.removeShorthandBorderRadius(this, isImportant);
      case GRID_TEMPLATE:
        return CSSStyleProperty.removeShorthandGridTemplate(this, isImportant);
      case GRID:
        return CSSStyleProperty.removeShorthandGrid(this, isImportant);
      case PLACE_CONTENT:
        return CSSStyleProperty.removeShorthandPlaceContent(this, isImportant);
      case PLACE_ITEMS:
        return CSSStyleProperty.removeShorthandPlaceItems(this, isImportant);
      case PLACE_SELF:
        return CSSStyleProperty.removeShorthandPlaceSelf(this, isImportant);
      case OVERFLOW:
        return CSSStyleProperty.removeShorthandOverflow(this, isImportant);
      case FONT:
        return CSSStyleProperty.removeShorthandFont(this, isImportant);
      case FLEX:
        return CSSStyleProperty.removeShorthandFlex(this, isImportant);
      case FLEX_FLOW:
        return CSSStyleProperty.removeShorthandFlexFlow(this, isImportant);
      case GAP:
        return CSSStyleProperty.removeShorthandGap(this, isImportant);
      case GRID_ROW:
        return CSSStyleProperty.removeShorthandGridRow(this, isImportant);
      case GRID_COLUMN:
        return CSSStyleProperty.removeShorthandGridColumn(this, isImportant);
      case GRID_AREA:
        return CSSStyleProperty.removeShorthandGridArea(this, isImportant);
      case BORDER:
      case BORDER_TOP:
      case BORDER_RIGHT:
      case BORDER_BOTTOM:
      case BORDER_LEFT:
      case BORDER_INLINE_START:
      case BORDER_INLINE_END:
      case BORDER_BLOCK_START:
      case BORDER_BLOCK_END:
      case BORDER_COLOR:
      case BORDER_STYLE:
      case BORDER_WIDTH:
        return CSSStyleProperty.removeShorthandBorder(
            this, propertyName, isImportant);
      case TRANSITION:
        return CSSStyleProperty.removeShorthandTransition(this, isImportant);
      case TEXT_DECORATION:
        return CSSStyleProperty.removeShorthandTextDecoration(
            this, isImportant);
      case ANIMATION:
        return CSSStyleProperty.removeShorthandAnimation(this, isImportant);
    }

    String present = EMPTY_STRING;
    if (isImportant == true) {
      _importants.remove(propertyName);
      // Fallback to css style.
      String? value = _sheetStyle[propertyName];
      if (!isNullOrEmptyValue(value)) {
        present = value!;
      }
    } else if (isImportant == false) {
      _sheetStyle.remove(propertyName);
    }

    // Fallback to default style (UA / element default).
    if (isNullOrEmptyValue(present) &&
        defaultStyle != null &&
        defaultStyle!.containsKey(propertyName)) {
      present = defaultStyle![propertyName];
    }

    // If there is still no value, fall back to the CSS initial value for
    // this property. To preserve inheritance semantics, we only do this for
    // non-inherited properties. For inherited ones we prefer leaving the
    // value empty so [RenderStyle] can pull from the parent instead.
    if (isNullOrEmptyValue(present) &&
        cssInitialValues.containsKey(propertyName)) {
      final String kebabName = _kebabize(propertyName);
      final bool isInherited = isInheritedPropertyString(kebabName);
      if (!isInherited) {
        present = cssInitialValues[propertyName];
      }
    }

    // Update removed value by flush pending properties.
    _pendingProperties[propertyName] = CSSPropertyValue(present);
  }

  void _expandShorthand(
    String propertyName,
    String normalizedValue,
    bool? isImportant, {
    String? baseHref,
    bool validate = true,
  }) {
    Map<String, String?> longhandProperties;
    String cacheKey = '$propertyName:$normalizedValue';
    if (_cachedExpandedShorthand.containsKey(cacheKey)) {
      longhandProperties = _cachedExpandedShorthand[cacheKey]!;
    } else {
      longhandProperties = {};

      switch (propertyName) {
        case PADDING:
          CSSStyleProperty.setShorthandPadding(
              longhandProperties, normalizedValue);
          break;
        case MARGIN:
          CSSStyleProperty.setShorthandMargin(
              longhandProperties, normalizedValue);
          break;
        case INSET:
          CSSStyleProperty.setShorthandInset(
              longhandProperties, normalizedValue);
          break;
        case BACKGROUND:
          // Expand shorthand into longhands for this declaration block only.
          // Do not mutate target.inlineStyle here: stylesheet declarations must
          // never overwrite author inline styles.
          CSSStyleProperty.setShorthandBackground(
              longhandProperties, normalizedValue);

          break;
        case BACKGROUND_POSITION:
          // Expand to X/Y longhands for computed usage, but also preserve the raw
          // comma-separated value so layered painters can retrieve per-layer positions.
          CSSStyleProperty.setShorthandBackgroundPosition(
              longhandProperties, normalizedValue);
          // Preserve original list for layered backgrounds (not consumed by renderStyle).
          // Store directly to pending map during expansion to avoid recursive shorthand handling.
          _pendingProperties[BACKGROUND_POSITION] =
              CSSPropertyValue(normalizedValue, baseHref: baseHref);
          break;
        case BORDER_RADIUS:
          CSSStyleProperty.setShorthandBorderRadius(
              longhandProperties, normalizedValue);
          break;
        case GRID_TEMPLATE:
          CSSStyleProperty.setShorthandGridTemplate(
              longhandProperties, normalizedValue);
          break;
        case GRID:
          CSSStyleProperty.setShorthandGrid(
              longhandProperties, normalizedValue);
          break;
        case PLACE_CONTENT:
          CSSStyleProperty.setShorthandPlaceContent(
              longhandProperties, normalizedValue);
          break;
        case PLACE_ITEMS:
          CSSStyleProperty.setShorthandPlaceItems(
              longhandProperties, normalizedValue);
          break;
        case PLACE_SELF:
          CSSStyleProperty.setShorthandPlaceSelf(
              longhandProperties, normalizedValue);
          break;
        case OVERFLOW:
          CSSStyleProperty.setShorthandOverflow(
              longhandProperties, normalizedValue);
          break;
        case FONT:
          CSSStyleProperty.setShorthandFont(
              longhandProperties, normalizedValue);
          break;
        case FLEX:
          CSSStyleProperty.setShorthandFlex(
              longhandProperties, normalizedValue);
          break;
        case FLEX_FLOW:
          CSSStyleProperty.setShorthandFlexFlow(
              longhandProperties, normalizedValue);
          break;
        case GAP:
          CSSStyleProperty.setShorthandGap(longhandProperties, normalizedValue);
          break;
        case GRID_ROW:
          CSSStyleProperty.setShorthandGridRow(
              longhandProperties, normalizedValue);
          break;
        case GRID_COLUMN:
          CSSStyleProperty.setShorthandGridColumn(
              longhandProperties, normalizedValue);
          break;
        case GRID_AREA:
          CSSStyleProperty.setShorthandGridArea(
              longhandProperties, normalizedValue);
          break;
        case BORDER:
        case BORDER_TOP:
        case BORDER_RIGHT:
        case BORDER_BOTTOM:
        case BORDER_LEFT:
        case BORDER_INLINE_START:
        case BORDER_INLINE_END:
        case BORDER_BLOCK_START:
        case BORDER_BLOCK_END:
        case BORDER_COLOR:
        case BORDER_STYLE:
        case BORDER_WIDTH:
          CSSStyleProperty.setShorthandBorder(
              longhandProperties, propertyName, normalizedValue);
          break;
        case TRANSITION:
          CSSStyleProperty.setShorthandTransition(
              longhandProperties, normalizedValue);
          break;
        case TEXT_DECORATION:
          CSSStyleProperty.setShorthandTextDecoration(
              longhandProperties, normalizedValue);
          break;
        case ANIMATION:
          CSSStyleProperty.setShorthandAnimation(
              longhandProperties, normalizedValue);
          break;
      }
      _cachedExpandedShorthand[cacheKey] = longhandProperties;
    }

    if (longhandProperties.isNotEmpty) {
      longhandProperties.forEach((String propertyName, String? value) {
        // Preserve the baseHref from the originating declaration so any
        // url(...) in expanded longhands (e.g., background-image) resolve
        // relative to the stylesheet that contained the shorthand.
        setProperty(propertyName, value,
            isImportant: isImportant, baseHref: baseHref, validate: validate);
      });
    }
  }

  String _replacePattern(
      String string, String lowerCase, String startString, String endString,
      [int start = 0]) {
    int startIndex = lowerCase.indexOf(startString, start);
    if (startIndex >= 0) {
      int? endIndex;
      int startStringLength = startString.length;
      startIndex = startIndex + startStringLength;
      for (int i = startIndex; i < string.length; i++) {
        if (string[i] == endString) endIndex = i;
      }
      if (endIndex != null) {
        var replacement = string.substring(startIndex, endIndex);
        lowerCase = lowerCase.replaceRange(startIndex, endIndex, replacement);
        if (endIndex < string.length - 1) {
          lowerCase = _replacePattern(
              string, lowerCase, startString, endString, endIndex);
        }
      }
    }
    return lowerCase;
  }

  String _toLowerCase(String propertyName, String string) {
    // ignore animation case sensitive
    if (propertyName.startsWith(ANIMATION) || propertyName == D) {
      return string;
    }

    // Preserve font family names and font shorthand values to avoid breaking
    // platform font resolution (Flutter font families can be case-sensitive).
    if (propertyName == FONT_FAMILY || propertyName == FONT) {
      return string;
    }

    if (propertyName == CONTENT) {
      return string;
    }

    // Fast path: most CSS values are already lowercase. Avoid allocating
    // a new string via `toLowerCase()` when not needed.
    bool hasUppercase = false;
    for (int i = 0; i < string.length; i++) {
      final int codeUnit = string.codeUnitAt(i);
      if (codeUnit >= 65 && codeUnit <= 90) {
        hasUppercase = true;
        break;
      }
    }
    if (!hasUppercase) return string;

    // Like url("http://path") declared with quotation marks and
    // custom property names are case sensitive.
    String lowerCase = string.toLowerCase();
    lowerCase = _replacePattern(string, lowerCase, 'env(', ')');
    lowerCase = _replacePattern(string, lowerCase, 'url(', ')');
    // var(--my-color) will be treated as a separate custom property to var(--My-color).
    lowerCase = _replacePattern(string, lowerCase, 'var(', ')');
    return lowerCase;
  }

  bool _isValidValue(String propertyName, String normalizedValue) {
    // Illegal value like '   ' after trimming is '' should do nothing.
    if (normalizedValue.isEmpty) return false;

    // Always return true if is CSS function notation, for value is
    // lazy calculated.
    // Eg. var(--x), calc(1 + 1)
    if (CSSFunction.isFunction(normalizedValue)) return true;

    if (CSSLength.isInitial(normalizedValue)) return true;
    // CSS-wide keyword: allow `inherit` for all properties so per-property
    // parsers (e.g. CSSLength.parseLength) can resolve it correctly.
    if (normalizedValue == INHERIT) return true;

    final String lowerValue = normalizedValue.toLowerCase();
    final bool isIntrinsicSizeKeyword = lowerValue == 'min-content' ||
        lowerValue == 'max-content' ||
        lowerValue == 'fit-content';

    // Validate value.
    switch (propertyName) {
      case GAP:
        {
          final List<String> tokens =
              splitByAsciiWhitespacePreservingGroups(normalizedValue);
          if (tokens.isEmpty || tokens.length > 2) return false;
          for (final token in tokens) {
            if (!CSSGap.isValidGapValue(token)) return false;
          }
          break;
        }
      case ROW_GAP:
      case COLUMN_GAP:
        if (!CSSGap.isValidGapValue(normalizedValue)) return false;
        break;
      case WIDTH:
      case HEIGHT:
        // Validation length type
        if (!CSSLength.isNonNegativeLength(normalizedValue) &&
            !CSSLength.isAuto(normalizedValue) &&
            !CSSPercentage.isNonNegativePercentage(normalizedValue) &&
            // SVG width need to support number type
            !CSSNumber.isNumber(normalizedValue) &&
            !isIntrinsicSizeKeyword) {
          return false;
        }
        break;
      case TOP:
      case LEFT:
      case RIGHT:
      case BOTTOM:
      case MARGIN_TOP:
      case MARGIN_LEFT:
      case MARGIN_RIGHT:
      case MARGIN_BOTTOM:
        // Validation length type
        if (!CSSLength.isLength(normalizedValue) &&
            !CSSLength.isAuto(normalizedValue) &&
            !CSSPercentage.isPercentage(normalizedValue)) {
          return false;
        }
        break;
      case MAX_WIDTH:
      case MAX_HEIGHT:
        if (normalizedValue != NONE &&
            !CSSLength.isNonNegativeLength(normalizedValue) &&
            !CSSPercentage.isNonNegativePercentage(normalizedValue) &&
            !isIntrinsicSizeKeyword) {
          return false;
        }
        break;
      case MIN_WIDTH:
      case MIN_HEIGHT:
        if (!CSSLength.isNonNegativeLength(normalizedValue) &&
            !CSSLength.isAuto(normalizedValue) &&
            !CSSPercentage.isNonNegativePercentage(normalizedValue) &&
            !isIntrinsicSizeKeyword) {
          return false;
        }
        break;
      case PADDING_TOP:
      case PADDING_LEFT:
      case PADDING_BOTTOM:
      case PADDING_RIGHT:
        if (!CSSLength.isNonNegativeLength(normalizedValue) &&
            !CSSPercentage.isNonNegativePercentage(normalizedValue)) {
          return false;
        }
        break;
      case BORDER_BOTTOM_WIDTH:
      case BORDER_TOP_WIDTH:
      case BORDER_LEFT_WIDTH:
      case BORDER_RIGHT_WIDTH:
        break;
      case COLOR:
      case BACKGROUND_COLOR:
      case BORDER_BOTTOM_COLOR:
      case BORDER_TOP_COLOR:
      case BORDER_LEFT_COLOR:
      case BORDER_RIGHT_COLOR:
      case TEXT_DECORATION_COLOR:
        // Validation color type
        if (!CSSColor.isColor(normalizedValue)) return false;
        break;
      case BACKGROUND_IMAGE:
        if (!CSSBackground.isValidBackgroundImageValue(normalizedValue))
          return false;
        break;
      case BACKGROUND_REPEAT:
        // Accept single token or comma-separated list of repeat keywords for layered backgrounds.
        if (normalizedValue.contains(',')) {
          final parts = normalizedValue.split(',');
          for (final p in parts) {
            final token = p.trim();
            if (token.isEmpty ||
                !CSSBackground.isValidBackgroundRepeatValue(token))
              return false;
          }
        } else {
          if (!CSSBackground.isValidBackgroundRepeatValue(normalizedValue))
            return false;
        }
        break;
      case FONT_SIZE:
        // font-size does not allow negative values.
        // Allow:
        //  - non-negative <length>
        //  - non-negative <percentage>
        //  - keywords (absolute/relative sizes)
        //  - var()/calc() functions (validated at resolve-time)
        final bool isVar = CSSVariable.isCSSVariableValue(normalizedValue);
        final bool isFunc = CSSFunction.isFunction(normalizedValue);
        final bool isNonNegLen = CSSLength.isNonNegativeLength(normalizedValue);
        final bool isNonNegPct =
            CSSPercentage.isNonNegativePercentage(normalizedValue);
        final bool isKeyword = CSSText.isValidFontSizeValue(normalizedValue);
        if (!(isVar || isFunc || isNonNegLen || isNonNegPct || isKeyword))
          return false;
        break;
      case FONT_VARIANT:
        // CSS2.1 font-variant accepts 'normal' or 'small-caps'.
        final bool isVarFontVariant =
            CSSVariable.isCSSVariableValue(normalizedValue);
        final bool isFuncFontVariant = CSSFunction.isFunction(normalizedValue);
        final bool isKeywordFontVariant =
            CSSText.isValidFontVariantValue(normalizedValue);
        if (!(isVarFontVariant || isFuncFontVariant || isKeywordFontVariant))
          return false;
        break;
    }
    return true;
  }

  /// Modifies an existing CSS property or creates a new CSS property in
  /// the declaration block.
  void setProperty(
    String propertyName,
    String? value, {
    bool? isImportant,
    String? baseHref,
    bool validate = true,
  }) {
    propertyName = _normalizePropertyName(propertyName);

    // Null or empty value means should be removed.
    if (isNullOrEmptyValue(value)) {
      removeProperty(propertyName, isImportant);
      return;
    }

    final String rawValue = value.toString();
    final bool isCustomProperty =
        CSSVariable.isCSSSVariableProperty(propertyName);
    String normalizedValue = isCustomProperty
        ? rawValue
        : _toLowerCase(propertyName, rawValue.trim());

    if (validate && !_isValidValue(propertyName, normalizedValue)) return;

    if (_cssShorthandProperty[propertyName] != null) {
      return _expandShorthand(propertyName, normalizedValue, isImportant,
          baseHref: baseHref, validate: validate);
    }

    // From style sheet mark the property important as false.
    if (isImportant == false) {
      _sheetStyle[propertyName] = normalizedValue;
    }

    // If the important property is already set, we should ignore it.
    if (isImportant != true && _importants[propertyName] == true) {
      return;
    }

    if (isImportant == true) {
      _importants[propertyName] = true;
    }

    String? prevValue = getPropertyValue(propertyName);
    if (normalizedValue == prevValue &&
        (!CSSVariable.isCSSVariableValue(normalizedValue))) return;

    _pendingProperties[propertyName] =
        CSSPropertyValue(normalizedValue, baseHref: baseHref);
  }

  void flushDisplayProperties() {
    Element? target = this.target;
    // If style target element not exists, no need to do flush operation.
    if (target == null) return;

    if (_pendingProperties.containsKey(DISPLAY) && target.isConnected) {
      CSSPropertyValue? prevValue = _properties[DISPLAY];
      CSSPropertyValue currentValue = _pendingProperties[DISPLAY]!;
      _properties[DISPLAY] = currentValue;
      _pendingProperties.remove(DISPLAY);

      _emitPropertyChanged(DISPLAY, prevValue?.value, currentValue.value,
          baseHref: currentValue.baseHref);
    }
  }

  void flushPendingProperties() {
    Element? target = this.target;
    // If style target element not exists, no need to do flush operation.
    if (target == null) return;

    // Display change from none to other value that the renderBoxModel is null.
    if (_pendingProperties.containsKey(DISPLAY) && target.isConnected) {
      CSSPropertyValue? prevValue = _properties[DISPLAY];
      CSSPropertyValue currentValue = _pendingProperties[DISPLAY]!;
      _properties[DISPLAY] = currentValue;
      _pendingProperties.remove(DISPLAY);
      _emitPropertyChanged(DISPLAY, prevValue?.value, currentValue.value,
          baseHref: currentValue.baseHref);
    }

    if (_pendingProperties.isEmpty) {
      return;
    }

    Map<String, CSSPropertyValue> pendingProperties = _pendingProperties;
    // Reset first avoid set property in flush stage.
    _pendingProperties = {};

    if (pendingProperties.length == 1) {
      final MapEntry<String, CSSPropertyValue> entry =
          pendingProperties.entries.first;
      final String propertyName = entry.key;
      final CSSPropertyValue currentValue = entry.value;
      final CSSPropertyValue? prevValue = _properties[propertyName];
      _properties[propertyName] = currentValue;
      _emitPropertyChanged(propertyName, prevValue?.value, currentValue.value,
          baseHref: currentValue.baseHref);
      onStyleFlushed?.call(<String>[propertyName]);
      return;
    }

    final List<String> variablePropertyNames = <String>[];
    final List<CSSPropertyValue?> variablePrevValues =
        <CSSPropertyValue?>[];
    final List<String?> prioritizedPropertyNames =
        List<String?>.filled(_propertyFlushPriorityOrder.length, null);
    final List<CSSPropertyValue?> prioritizedPrevValues =
        List<CSSPropertyValue?>.filled(_propertyFlushPriorityOrder.length, null);
    final List<String> regularPropertyNames = <String>[];
    final List<CSSPropertyValue?> regularPrevValues = <CSSPropertyValue?>[];

    for (final MapEntry<String, CSSPropertyValue> entry
        in pendingProperties.entries) {
      final String propertyName = entry.key;
      final CSSPropertyValue currentValue = entry.value;
      final CSSPropertyValue? prevValue = _properties[propertyName];
      _properties[propertyName] = currentValue;

      if (CSSVariable.isCSSSVariableProperty(propertyName)) {
        variablePropertyNames.add(propertyName);
        variablePrevValues.add(prevValue);
        continue;
      }

      final int? priorityRank = _propertyFlushPriorityRanks[propertyName];
      if (priorityRank != null) {
        prioritizedPropertyNames[priorityRank] = propertyName;
        prioritizedPrevValues[priorityRank] = prevValue;
        continue;
      }

      regularPropertyNames.add(propertyName);
      regularPrevValues.add(prevValue);
    }

    final StyleFlushedListener? styleFlushed = onStyleFlushed;
    final List<String>? flushedPropertyNames =
        styleFlushed == null ? null : <String>[];

    _flushOrderedPendingProperties(variablePropertyNames, variablePrevValues,
        pendingProperties, flushedPropertyNames);
    _flushPrioritizedPendingProperties(prioritizedPropertyNames,
        prioritizedPrevValues, pendingProperties, flushedPropertyNames);
    _flushOrderedPendingProperties(regularPropertyNames, regularPrevValues,
        pendingProperties, flushedPropertyNames);

    if (flushedPropertyNames != null) {
      styleFlushed!(flushedPropertyNames);
    }
  }

  void _flushOrderedPendingProperties(
      List<String> propertyNames,
      List<CSSPropertyValue?> prevValues,
      Map<String, CSSPropertyValue> pendingProperties,
      List<String>? flushedPropertyNames) {
    for (int i = 0; i < propertyNames.length; i++) {
      final String propertyName = propertyNames[i];
      final CSSPropertyValue? prevValue = prevValues[i];
      final CSSPropertyValue currentValue = pendingProperties[propertyName]!;
      _emitPropertyChanged(propertyName, prevValue?.value, currentValue.value,
          baseHref: currentValue.baseHref);
      flushedPropertyNames?.add(propertyName);
    }
  }

  void _flushPrioritizedPendingProperties(
      List<String?> propertyNames,
      List<CSSPropertyValue?> prevValues,
      Map<String, CSSPropertyValue> pendingProperties,
      List<String>? flushedPropertyNames) {
    for (int i = 0; i < propertyNames.length; i++) {
      final String? propertyName = propertyNames[i];
      if (propertyName == null) continue;
      final CSSPropertyValue? prevValue = prevValues[i];
      final CSSPropertyValue currentValue = pendingProperties[propertyName]!;
      _emitPropertyChanged(propertyName, prevValue?.value, currentValue.value,
          baseHref: currentValue.baseHref);
      flushedPropertyNames?.add(propertyName);
    }
  }

  // Set a style property on a pseudo element (before/after/first-letter/first-line) for this element.
  // Values set here are treated as inline on the pseudo element and marked important
  // to override stylesheet rules when applicable.
  void setPseudoProperty(String type, String propertyName, String value,
      {String? baseHref, bool validate = true}) {
    switch (type) {
      case 'before':
        _inlinePseudoBeforeStyle ??= CSSStyleDeclaration();
        _inlinePseudoBeforeStyle!.setProperty(propertyName, value,
            isImportant: true, baseHref: baseHref, validate: validate);
        target?.markBeforePseudoElementNeedsUpdate();
        break;
      case 'after':
        _inlinePseudoAfterStyle ??= CSSStyleDeclaration();
        _inlinePseudoAfterStyle!.setProperty(propertyName, value,
            isImportant: true, baseHref: baseHref, validate: validate);
        target?.markAfterPseudoElementNeedsUpdate();
        break;
      case 'first-letter':
        _inlinePseudoFirstLetterStyle ??= CSSStyleDeclaration();
        _inlinePseudoFirstLetterStyle!.setProperty(propertyName, value,
            isImportant: true, baseHref: baseHref, validate: validate);
        target?.markFirstLetterPseudoNeedsUpdate();
        break;
      case 'first-line':
        _inlinePseudoFirstLineStyle ??= CSSStyleDeclaration();
        _inlinePseudoFirstLineStyle!.setProperty(propertyName, value,
            isImportant: true, baseHref: baseHref, validate: validate);
        target?.markFirstLinePseudoNeedsUpdate();
        break;
    }
  }

  // Remove a style property from a pseudo element (before/after/first-letter/first-line) for this element.
  void removePseudoProperty(String type, String propertyName) {
    switch (type) {
      case 'before':
        if (_inlinePseudoBeforeStyle != null) {
          // Remove the inline override; fall back to stylesheet value if present.
          _inlinePseudoBeforeStyle!.removeProperty(propertyName, true);
        }
        target?.markBeforePseudoElementNeedsUpdate();
        break;
      case 'after':
        if (_inlinePseudoAfterStyle != null) {
          _inlinePseudoAfterStyle!.removeProperty(propertyName, true);
        }
        target?.markAfterPseudoElementNeedsUpdate();
        break;
      case 'first-letter':
        if (_inlinePseudoFirstLetterStyle != null) {
          _inlinePseudoFirstLetterStyle!.removeProperty(propertyName, true);
        }
        target?.markFirstLetterPseudoNeedsUpdate();
        break;
      case 'first-line':
        if (_inlinePseudoFirstLineStyle != null) {
          _inlinePseudoFirstLineStyle!.removeProperty(propertyName, true);
        }
        target?.markFirstLinePseudoNeedsUpdate();
        break;
    }
  }

  void clearPseudoStyle(String type) {
    switch (type) {
      case 'before':
        _inlinePseudoBeforeStyle = null;
        target?.markBeforePseudoElementNeedsUpdate();
        break;
      case 'after':
        _inlinePseudoAfterStyle = null;
        target?.markAfterPseudoElementNeedsUpdate();
        break;
      case 'first-letter':
        _inlinePseudoFirstLetterStyle = null;
        target?.markFirstLetterPseudoNeedsUpdate();
        break;
      case 'first-line':
        _inlinePseudoFirstLineStyle = null;
        target?.markFirstLinePseudoNeedsUpdate();
        break;
    }
  }

  // Inserts the style of the given Declaration into the current Declaration.
  void union(CSSStyleDeclaration declaration) {
    final Map<String, CSSPropertyValue> incomingPending =
        declaration._pendingProperties;
    if (incomingPending.isEmpty && declaration._properties.isEmpty) {
      return;
    }

    if (_isEffectivelyEmpty) {
      _adoptEffectivePropertiesFrom(declaration);
      return;
    }

    if (_properties.isEmpty &&
        _importants.isEmpty &&
        declaration._properties.isEmpty &&
        declaration._importants.isEmpty) {
      _pendingProperties.addAll(incomingPending);
      return;
    }

    for (final MapEntry<String, CSSPropertyValue> entry in incomingPending.entries) {
      final String propertyName = entry.key;
      final bool currentIsImportant = _importants[propertyName] ?? false;
      final bool otherIsImportant = declaration._importants[propertyName] ?? false;
      final CSSPropertyValue? currentValue =
          _pendingProperties[propertyName] ?? _properties[propertyName];
      final CSSPropertyValue otherValue = entry.value;
      if ((otherIsImportant || !currentIsImportant) &&
          currentValue != otherValue) {
        _pendingProperties[propertyName] = otherValue;
        if (otherIsImportant) {
          _importants[propertyName] = true;
        }
      }
    }
  }

  /// Like [union], but only applies declarations matching [important].
  ///
  /// This is used by cascade layers where `!important` reverses layer order.
  void unionByImportance(CSSStyleDeclaration declaration,
      {required bool important}) {
    final Map<String, CSSPropertyValue> incomingPending =
        declaration._pendingProperties;
    if (incomingPending.isEmpty) {
      return;
    }

    for (final MapEntry<String, CSSPropertyValue> entry in incomingPending.entries) {
      final String propertyName = entry.key;
      final bool otherIsImportant = declaration._importants[propertyName] ?? false;
      if (otherIsImportant != important) continue;

      final bool currentIsImportant = _importants[propertyName] ?? false;
      final CSSPropertyValue? currentValue =
          _pendingProperties[propertyName] ?? _properties[propertyName];
      final CSSPropertyValue otherValue = entry.value;

      if ((otherIsImportant || !currentIsImportant) &&
          currentValue != otherValue) {
        _pendingProperties[propertyName] = otherValue;
        if (otherIsImportant) {
          _importants[propertyName] = true;
        }
      }
    }
  }

  void handlePseudoRules(Element parentElement, List<CSSStyleRule> rules) {
    _didProcessPseudoRules = true;
    if (rules.isEmpty) {
      if (pseudoBeforeStyle != null) {
        pseudoBeforeStyle = null;
        parentElement.markBeforePseudoElementNeedsUpdate();
      }
      if (pseudoAfterStyle != null) {
        pseudoAfterStyle = null;
        parentElement.markAfterPseudoElementNeedsUpdate();
      }
      if (pseudoFirstLetterStyle != null) {
        pseudoFirstLetterStyle = null;
        parentElement.markFirstLetterPseudoNeedsUpdate();
      }
      if (pseudoFirstLineStyle != null) {
        pseudoFirstLineStyle = null;
        parentElement.markFirstLinePseudoNeedsUpdate();
      }
      return;
    }

    List<CSSStyleRule>? beforeRules;
    List<CSSStyleRule>? afterRules;
    List<CSSStyleRule>? firstLetterRules;
    List<CSSStyleRule>? firstLineRules;

    for (CSSStyleRule style in rules) {
      final int pseudoElementMask = style.selectorGroup.pseudoElementMask;
      if ((pseudoElementMask & kPseudoElementMaskBefore) != 0) {
        (beforeRules ??= <CSSStyleRule>[]).add(style);
      }
      if ((pseudoElementMask & kPseudoElementMaskAfter) != 0) {
        (afterRules ??= <CSSStyleRule>[]).add(style);
      }
      if ((pseudoElementMask & kPseudoElementMaskFirstLetter) != 0) {
        (firstLetterRules ??= <CSSStyleRule>[]).add(style);
      }
      if ((pseudoElementMask & kPseudoElementMaskFirstLine) != 0) {
        (firstLineRules ??= <CSSStyleRule>[]).add(style);
      }
    }

    if (beforeRules != null) {
      pseudoBeforeStyle = cascadeMatchedStyleRules(beforeRules,
          cacheVersion: parentElement.ownerDocument.ruleSetVersion,
          copyResult: true);
    } else if (pseudoBeforeStyle != null) {
      pseudoBeforeStyle = null;
    }

    if (afterRules != null) {
      pseudoAfterStyle = cascadeMatchedStyleRules(afterRules,
          cacheVersion: parentElement.ownerDocument.ruleSetVersion,
          copyResult: true);
    } else if (pseudoAfterStyle != null) {
      pseudoAfterStyle = null;
    }

    if (firstLetterRules != null) {
      pseudoFirstLetterStyle = cascadeMatchedStyleRules(firstLetterRules,
          cacheVersion: parentElement.ownerDocument.ruleSetVersion,
          copyResult: true);
    } else if (pseudoFirstLetterStyle != null) {
      pseudoFirstLetterStyle = null;
    }

    if (firstLineRules != null) {
      pseudoFirstLineStyle = cascadeMatchedStyleRules(firstLineRules,
          cacheVersion: parentElement.ownerDocument.ruleSetVersion,
          copyResult: true);
    } else if (pseudoFirstLineStyle != null) {
      pseudoFirstLineStyle = null;
    }
  }

  // Merge the difference between the declarations and return the updated status
  bool merge(CSSStyleDeclaration other) {
    bool updateStatus = false;
    final Map<String, CSSPropertyValue> otherPendingProperties =
        other._pendingProperties;
    final Map<String, CSSPropertyValue> otherProperties = other._properties;
    final Map<String, bool> otherImportants = other._importants;

    void mergePseudoStyle({
      required CSSStyleDeclaration? currentStyle,
      required CSSStyleDeclaration? incomingStyle,
      required void Function(CSSStyleDeclaration? value) assign,
      required VoidCallback markNeedsUpdate,
      required bool clearWhenMissing,
    }) {
      if (incomingStyle != null) {
        if (currentStyle == null) {
          assign(incomingStyle.cloneEffective());
        } else if (currentStyle.merge(incomingStyle)) {
          markNeedsUpdate();
        }
      } else if (clearWhenMissing && currentStyle != null) {
        assign(null);
      }
    }

    void mergeProperty(String propertyName,
        {CSSPropertyValue? prevValue,
        CSSPropertyValue? currentValue,
        required bool currentImportant}) {
      prevValue ??= _effectiveProperty(propertyName);
      currentValue ??=
          otherPendingProperties[propertyName] ?? otherProperties[propertyName];

      if ((prevValue == null || prevValue.value.isEmpty) &&
          (currentValue == null || currentValue.value.isEmpty)) {
        return;
      }

      if (prevValue != null &&
          prevValue.value.isNotEmpty &&
          (currentValue == null || currentValue.value.isEmpty)) {
        // Remove property.
        _pendingProperties[propertyName] =
            CSSPropertyValue(_removedPropertyFallbackValue(
          propertyName,
          currentImportant,
        ));
        updateStatus = true;
        return;
      }

      if (currentValue == null || currentValue.value.isEmpty) {
        return;
      }

      final bool sameSerializedValue =
          prevValue != null && prevValue.value == currentValue.value;
      if (sameSerializedValue &&
          !CSSVariable.isCSSVariableValue(currentValue.value)) {
        return;
      }

      if (_queueMergedPropertyValue(propertyName, currentValue,
          important: currentImportant)) {
        // Update property.
        updateStatus = true;
      }
    }

    if (otherProperties.isEmpty) {
      for (final String propertyName in _pendingProperties.keys.toList()) {
        mergeProperty(propertyName,
            prevValue: _pendingProperties[propertyName],
            currentValue: otherPendingProperties[propertyName],
            currentImportant: otherImportants[propertyName] == true);
      }
      for (final MapEntry<String, CSSPropertyValue> entry in _properties.entries) {
        final String propertyName = entry.key;
        if (_pendingProperties.containsKey(propertyName)) continue;
        mergeProperty(propertyName,
            prevValue: entry.value,
            currentValue: otherPendingProperties[propertyName],
            currentImportant: otherImportants[propertyName] == true);
      }
      for (final MapEntry<String, CSSPropertyValue> entry
          in otherPendingProperties.entries) {
        final String propertyName = entry.key;
        if (_pendingProperties.containsKey(propertyName) ||
            _properties.containsKey(propertyName)) {
          continue;
        }
        mergeProperty(propertyName,
            currentValue: entry.value,
            currentImportant: otherImportants[propertyName] == true);
      }
    } else {
      for (final String propertyName in _pendingProperties.keys.toList()) {
        mergeProperty(propertyName,
            currentImportant: otherImportants[propertyName] == true);
      }
      for (final String propertyName in _properties.keys) {
        if (_pendingProperties.containsKey(propertyName)) continue;
        mergeProperty(propertyName,
            currentImportant: otherImportants[propertyName] == true);
      }
      for (final String propertyName in otherPendingProperties.keys) {
        if (_hasEffectiveProperty(propertyName)) continue;
        mergeProperty(propertyName,
            currentImportant: otherImportants[propertyName] == true);
      }
      for (final String propertyName in otherProperties.keys) {
        if (otherPendingProperties.containsKey(propertyName) ||
            _hasEffectiveProperty(propertyName)) {
          continue;
        }
        mergeProperty(propertyName,
            currentImportant: otherImportants[propertyName] == true);
      }
    }

    // Merge pseudo-element styles. Ensure target side is initialized so rules from
    // 'other' are not dropped when this side is null. When pseudo rules were
    // processed on the other side, clear stale pseudo styles if no rule matches.
    if (other._didProcessPseudoRules) {
      mergePseudoStyle(
        currentStyle: pseudoBeforeStyle,
        incomingStyle: other.pseudoBeforeStyle,
        assign: (value) => pseudoBeforeStyle = value,
        markNeedsUpdate: () => target?.markBeforePseudoElementNeedsUpdate(),
        clearWhenMissing: true,
      );
      mergePseudoStyle(
        currentStyle: pseudoAfterStyle,
        incomingStyle: other.pseudoAfterStyle,
        assign: (value) => pseudoAfterStyle = value,
        markNeedsUpdate: () => target?.markAfterPseudoElementNeedsUpdate(),
        clearWhenMissing: true,
      );
      mergePseudoStyle(
        currentStyle: pseudoFirstLetterStyle,
        incomingStyle: other.pseudoFirstLetterStyle,
        assign: (value) => pseudoFirstLetterStyle = value,
        markNeedsUpdate: () => target?.markFirstLetterPseudoNeedsUpdate(),
        clearWhenMissing: true,
      );
      mergePseudoStyle(
        currentStyle: pseudoFirstLineStyle,
        incomingStyle: other.pseudoFirstLineStyle,
        assign: (value) => pseudoFirstLineStyle = value,
        markNeedsUpdate: () => target?.markFirstLinePseudoNeedsUpdate(),
        clearWhenMissing: true,
      );
    } else {
      mergePseudoStyle(
        currentStyle: pseudoBeforeStyle,
        incomingStyle: other.pseudoBeforeStyle,
        assign: (value) => pseudoBeforeStyle = value,
        markNeedsUpdate: () => target?.markBeforePseudoElementNeedsUpdate(),
        clearWhenMissing: false,
      );
      mergePseudoStyle(
        currentStyle: pseudoAfterStyle,
        incomingStyle: other.pseudoAfterStyle,
        assign: (value) => pseudoAfterStyle = value,
        markNeedsUpdate: () => target?.markAfterPseudoElementNeedsUpdate(),
        clearWhenMissing: false,
      );
      mergePseudoStyle(
        currentStyle: pseudoFirstLetterStyle,
        incomingStyle: other.pseudoFirstLetterStyle,
        assign: (value) => pseudoFirstLetterStyle = value,
        markNeedsUpdate: () => target?.markFirstLetterPseudoNeedsUpdate(),
        clearWhenMissing: false,
      );
      mergePseudoStyle(
        currentStyle: pseudoFirstLineStyle,
        incomingStyle: other.pseudoFirstLineStyle,
        assign: (value) => pseudoFirstLineStyle = value,
        markNeedsUpdate: () => target?.markFirstLinePseudoNeedsUpdate(),
        clearWhenMissing: false,
      );
    }

    return updateStatus;
  }

  operator [](String property) => getPropertyValue(property);
  operator []=(String property, value) {
    setProperty(property, value);
  }

  /// Check a css property is valid.
  @override
  bool contains(Object? property) {
    if (property != null && property is String) {
      return getPropertyValue(property).isNotEmpty;
    }
    return super.contains(property);
  }

  void addStyleChangeListener(StyleChangeListener listener) {
    _styleChangeListeners.add(listener);
  }

  void removeStyleChangeListener(StyleChangeListener listener) {
    _styleChangeListeners.remove(listener);
  }

  void _emitPropertyChanged(String property, String? original, String present,
      {String? baseHref}) {
    if (original == present && (!CSSVariable.isCSSVariableValue(present)))
      return;

    if (onStyleChanged != null) {
      onStyleChanged!(property, original, present, baseHref: baseHref);
    }

    for (int i = 0; i < _styleChangeListeners.length; i++) {
      StyleChangeListener listener = _styleChangeListeners[i];
      listener(property, original, present, baseHref: baseHref);
    }
  }

  void reset() {
    _properties.clear();
    _pendingProperties.clear();
    _importants.clear();
    _sheetStyle.clear();
    _pseudoBeforeStyle = null;
    _pseudoAfterStyle = null;
    _pseudoFirstLetterStyle = null;
    _pseudoFirstLineStyle = null;
    _inlinePseudoBeforeStyle = null;
    _inlinePseudoAfterStyle = null;
    _inlinePseudoFirstLetterStyle = null;
    _inlinePseudoFirstLineStyle = null;
    _didProcessPseudoRules = false;
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    target = null;
    _styleChangeListeners.clear();
    reset();
  }

  static bool isNullOrEmptyValue(value) {
    return value == null || value == EMPTY_STRING;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'CSSStyleDeclaration($cssText)';

  @override
  Iterator<MapEntry<String, CSSPropertyValue>> get iterator {
    return _properties.entries.followedBy(_pendingProperties.entries).iterator;
  }
}

// aB to a-b
String _kebabize(String str) {
  return kebabizeCamelCase(str);
}

String _normalizePropertyName(String propertyName) {
  final String trimmed = propertyName.trim();
  if (trimmed.isEmpty || trimmed.startsWith('--')) {
    return trimmed;
  }
  if (trimmed.contains('-')) {
    return camelize(trimmed.toLowerCase());
  }
  return trimmed;
}
