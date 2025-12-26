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

typedef StyleChangeListener = void Function(String property, String? original, String present, {String? baseHref});
typedef StyleFlushedListener = void Function(List<String> properties);

const Map<String, bool> _cssShorthandProperty = {
  MARGIN: true,
  PADDING: true,
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

RegExp _kebabCaseReg = RegExp(r'[A-Z]');

final LinkedLruHashMap<String, Map<String, String?>> _cachedExpandedShorthand = LinkedLruHashMap(maximumSize: 500);

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
class CSSStyleDeclaration extends DynamicBindingObject with StaticDefinedBindingObject {
  Element? target;

  // TODO(yuanyan): defaultStyle should be longhand properties.
  Map<String, dynamic>? defaultStyle;
  StyleChangeListener? onStyleChanged;
  StyleFlushedListener? onStyleFlushed;

  CSSStyleDeclaration? _pseudoBeforeStyle;
  CSSStyleDeclaration? get pseudoBeforeStyle => _pseudoBeforeStyle;
  set pseudoBeforeStyle(CSSStyleDeclaration? newStyle) {
    _pseudoBeforeStyle = newStyle;
    target?.markBeforePseudoElementNeedsUpdate();
  }

  CSSStyleDeclaration? _pseudoAfterStyle;
  CSSStyleDeclaration? get pseudoAfterStyle => _pseudoAfterStyle;
  set pseudoAfterStyle(CSSStyleDeclaration? newStyle) {
    _pseudoAfterStyle = newStyle;
    target?.markAfterPseudoElementNeedsUpdate();
  }

  // ::first-letter pseudo style (applies to the first typographic letter)
  CSSStyleDeclaration? _pseudoFirstLetterStyle;
  CSSStyleDeclaration? get pseudoFirstLetterStyle => _pseudoFirstLetterStyle;
  set pseudoFirstLetterStyle(CSSStyleDeclaration? newStyle) {
    _pseudoFirstLetterStyle = newStyle;
    // Trigger a layout rebuild so IFC can re-shape text for first-letter styling
    target?.markFirstLetterPseudoNeedsUpdate();
  }

  // ::first-line pseudo style (applies to only the first formatted line)
  CSSStyleDeclaration? _pseudoFirstLineStyle;
  CSSStyleDeclaration? get pseudoFirstLineStyle => _pseudoFirstLineStyle;
  set pseudoFirstLineStyle(CSSStyleDeclaration? newStyle) {
    _pseudoFirstLineStyle = newStyle;
    target?.markFirstLinePseudoNeedsUpdate();
  }

  CSSStyleDeclaration([super.context]);

  // ignore: prefer_initializing_formals
  CSSStyleDeclaration.computedStyle(this.target, this.defaultStyle, this.onStyleChanged, [this.onStyleFlushed]);

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
      css += '${_kebabize(property)}: $value ${_importants.containsKey(property) ? '!important' : ''};';
    });
    return css;
  }

  /// Whether the given property is marked as `!important` on this declaration.
  ///
  /// Exposed for components (e.g., CSS variable resolver) that need to
  /// preserve importance when updating dependent properties.
  bool isImportant(String propertyName) {
    return _importants[propertyName] == true;
  }

  bool get hasInheritedPendingProperty {
    return _pendingProperties.keys.any((key) => isInheritedPropertyString(_kebabize(key)));
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
    // Get the latest pending value first.
    return _pendingProperties[propertyName]?.value ?? _properties[propertyName]?.value ?? EMPTY_STRING;
  }

  /// Returns the baseHref associated with a property value if available.
  String? getPropertyBaseHref(String propertyName) {
    return _pendingProperties[propertyName]?.baseHref ?? _properties[propertyName]?.baseHref;
  }

  /// Removes a property from the CSS declaration.
  void removeProperty(String propertyName, [bool? isImportant]) {
    switch (propertyName) {
      case PADDING:
        return CSSStyleProperty.removeShorthandPadding(this, isImportant);
      case MARGIN:
        return CSSStyleProperty.removeShorthandMargin(this, isImportant);
      case BACKGROUND:
        return CSSStyleProperty.removeShorthandBackground(this, isImportant);
      case BACKGROUND_POSITION:
        return CSSStyleProperty.removeShorthandBackgroundPosition(this, isImportant);
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
        return CSSStyleProperty.removeShorthandBorder(this, propertyName, isImportant);
      case TRANSITION:
        return CSSStyleProperty.removeShorthandTransition(this, isImportant);
      case TEXT_DECORATION:
        return CSSStyleProperty.removeShorthandTextDecoration(this, isImportant);
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
    if (isNullOrEmptyValue(present) && defaultStyle != null && defaultStyle!.containsKey(propertyName)) {
      present = defaultStyle![propertyName];
    }

    // If there is still no value, fall back to the CSS initial value for
    // this property. To preserve inheritance semantics, we only do this for
    // non-inherited properties. For inherited ones we prefer leaving the
    // value empty so [RenderStyle] can pull from the parent instead.
    if (isNullOrEmptyValue(present) && cssInitialValues.containsKey(propertyName)) {
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
          CSSStyleProperty.setShorthandPadding(longhandProperties, normalizedValue);
          break;
        case MARGIN:
          CSSStyleProperty.setShorthandMargin(longhandProperties, normalizedValue);
          break;
        case BACKGROUND:
          // Expand shorthand into longhands for this declaration block only.
          // Do not mutate target.inlineStyle here: stylesheet declarations must
          // never overwrite author inline styles.
          CSSStyleProperty.setShorthandBackground(longhandProperties, normalizedValue);

          break;
        case BACKGROUND_POSITION:
          // Expand to X/Y longhands for computed usage, but also preserve the raw
          // comma-separated value so layered painters can retrieve per-layer positions.
          CSSStyleProperty.setShorthandBackgroundPosition(longhandProperties, normalizedValue);
          // Preserve original list for layered backgrounds (not consumed by renderStyle).
          // Store directly to pending map during expansion to avoid recursive shorthand handling.
          _pendingProperties[BACKGROUND_POSITION] = CSSPropertyValue(normalizedValue, baseHref: baseHref);
          break;
      case BORDER_RADIUS:
        CSSStyleProperty.setShorthandBorderRadius(longhandProperties, normalizedValue);
        break;
      case GRID_TEMPLATE:
        CSSStyleProperty.setShorthandGridTemplate(longhandProperties, normalizedValue);
        break;
      case GRID:
        CSSStyleProperty.setShorthandGrid(longhandProperties, normalizedValue);
        break;
      case PLACE_CONTENT:
        CSSStyleProperty.setShorthandPlaceContent(longhandProperties, normalizedValue);
        break;
        case PLACE_ITEMS:
          CSSStyleProperty.setShorthandPlaceItems(longhandProperties, normalizedValue);
          break;
        case PLACE_SELF:
          CSSStyleProperty.setShorthandPlaceSelf(longhandProperties, normalizedValue);
          break;
        case OVERFLOW:
          CSSStyleProperty.setShorthandOverflow(longhandProperties, normalizedValue);
          break;
        case FONT:
          CSSStyleProperty.setShorthandFont(longhandProperties, normalizedValue);
          break;
        case FLEX:
          CSSStyleProperty.setShorthandFlex(longhandProperties, normalizedValue);
          break;
        case FLEX_FLOW:
          CSSStyleProperty.setShorthandFlexFlow(longhandProperties, normalizedValue);
          break;
        case GAP:
          CSSStyleProperty.setShorthandGap(longhandProperties, normalizedValue);
          break;
        case GRID_ROW:
          CSSStyleProperty.setShorthandGridRow(longhandProperties, normalizedValue);
          break;
        case GRID_COLUMN:
          CSSStyleProperty.setShorthandGridColumn(longhandProperties, normalizedValue);
          break;
        case GRID_AREA:
          CSSStyleProperty.setShorthandGridArea(longhandProperties, normalizedValue);
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
          CSSStyleProperty.setShorthandBorder(longhandProperties, propertyName, normalizedValue);
          break;
        case TRANSITION:
          CSSStyleProperty.setShorthandTransition(longhandProperties, normalizedValue);
          break;
        case TEXT_DECORATION:
          CSSStyleProperty.setShorthandTextDecoration(longhandProperties, normalizedValue);
          break;
        case ANIMATION:
          CSSStyleProperty.setShorthandAnimation(longhandProperties, normalizedValue);
          break;
      }
      _cachedExpandedShorthand[cacheKey] = longhandProperties;
    }

    if (longhandProperties.isNotEmpty) {
      longhandProperties.forEach((String propertyName, String? value) {
        // Preserve the baseHref from the originating declaration so any
        // url(...) in expanded longhands (e.g., background-image) resolve
        // relative to the stylesheet that contained the shorthand.
        setProperty(propertyName, value, isImportant: isImportant, baseHref: baseHref, validate: validate);
      });
    }
  }

  String _replacePattern(String string, String lowerCase, String startString, String endString, [int start = 0]) {
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
          lowerCase = _replacePattern(string, lowerCase, startString, endString, endIndex);
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
    final bool isIntrinsicSizeKeyword =
        lowerValue == 'min-content' || lowerValue == 'max-content' || lowerValue == 'fit-content';

    // Validate value.
    switch (propertyName) {
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
        if (!CSSBackground.isValidBackgroundImageValue(normalizedValue)) return false;
        break;
      case BACKGROUND_REPEAT:
        // Accept single token or comma-separated list of repeat keywords for layered backgrounds.
        if (normalizedValue.contains(',')) {
          final parts = normalizedValue.split(',');
          for (final p in parts) {
            final token = p.trim();
            if (token.isEmpty || !CSSBackground.isValidBackgroundRepeatValue(token)) return false;
          }
        } else {
          if (!CSSBackground.isValidBackgroundRepeatValue(normalizedValue)) return false;
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
        final bool isNonNegPct = CSSPercentage.isNonNegativePercentage(normalizedValue);
        final bool isKeyword = CSSText.isValidFontSizeValue(normalizedValue);
        if (!(isVar || isFunc || isNonNegLen || isNonNegPct || isKeyword)) return false;
        break;
      case FONT_VARIANT:
        // CSS2.1 font-variant accepts 'normal' or 'small-caps'.
        final bool isVarFontVariant = CSSVariable.isCSSVariableValue(normalizedValue);
        final bool isFuncFontVariant = CSSFunction.isFunction(normalizedValue);
        final bool isKeywordFontVariant = CSSText.isValidFontVariantValue(normalizedValue);
        if (!(isVarFontVariant || isFuncFontVariant || isKeywordFontVariant)) return false;
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
    propertyName = propertyName.trim();

    // Null or empty value means should be removed.
    if (isNullOrEmptyValue(value)) {
      removeProperty(propertyName, isImportant);
      return;
    }

    String normalizedValue = _toLowerCase(propertyName, value.toString().trim());

    if (validate && !_isValidValue(propertyName, normalizedValue)) return;

    if (_cssShorthandProperty[propertyName] != null) {
      return _expandShorthand(propertyName, normalizedValue, isImportant, baseHref: baseHref, validate: validate);
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
    if (normalizedValue == prevValue && (!CSSVariable.isCSSVariableValue(normalizedValue))) return;

    _pendingProperties[propertyName] = CSSPropertyValue(normalizedValue, baseHref: baseHref);
  }

  void flushDisplayProperties() {
    Element? target = this.target;
    // If style target element not exists, no need to do flush operation.
    if (target == null) return;

    if (_pendingProperties.containsKey(DISPLAY) &&
        target.isConnected) {
      CSSPropertyValue? prevValue = _properties[DISPLAY];
      CSSPropertyValue currentValue = _pendingProperties[DISPLAY]!;
      _properties[DISPLAY] = currentValue;
      _pendingProperties.remove(DISPLAY);

      _emitPropertyChanged(DISPLAY, prevValue?.value, currentValue.value, baseHref: currentValue.baseHref);
    }
  }

  void flushPendingProperties() {
    Element? target = this.target;
    // If style target element not exists, no need to do flush operation.
    if (target == null) return;

    // Display change from none to other value that the renderBoxModel is null.
    if (_pendingProperties.containsKey(DISPLAY) &&
        target.isConnected) {
      CSSPropertyValue? prevValue = _properties[DISPLAY];
      CSSPropertyValue currentValue = _pendingProperties[DISPLAY]!;
      _properties[DISPLAY] = currentValue;
      _pendingProperties.remove(DISPLAY);
      _emitPropertyChanged(DISPLAY, prevValue?.value, currentValue.value, baseHref: currentValue.baseHref);
    }

    if (_pendingProperties.isEmpty) {
      return;
    }

    Map<String, CSSPropertyValue> pendingProperties = _pendingProperties;
    // Reset first avoid set property in flush stage.
    _pendingProperties = {};

    List<String> propertyNames = pendingProperties.keys.toList();
    for (String propertyName in _propertyOrders) {
      int index = propertyNames.indexOf(propertyName);
      if (index > -1) {
        propertyNames.removeAt(index);
        propertyNames.insert(0, propertyName);
      }
    }

    Map<String, CSSPropertyValue?> prevValues = {};
    for (String propertyName in propertyNames) {
      // Update the prevValue to currentValue.
      prevValues[propertyName] = _properties[propertyName];
      _properties[propertyName] = pendingProperties[propertyName]!;
    }

    propertyNames.sort((left, right) {
      final isVariableLeft = CSSVariable.isCSSSVariableProperty(left) ? 1 : 0;
      final isVariableRight = CSSVariable.isCSSSVariableProperty(right) ? 1 : 0;
      if (isVariableLeft == 1 || isVariableRight == 1) {
        return isVariableRight - isVariableLeft;
      }
      return 0;
    });



    for (String propertyName in propertyNames) {
      CSSPropertyValue? prevValue = prevValues[propertyName];
      CSSPropertyValue currentValue = pendingProperties[propertyName]!;
      _emitPropertyChanged(propertyName, prevValue?.value, currentValue.value, baseHref: currentValue.baseHref);
    }

    onStyleFlushed?.call(propertyNames);

  }

  // Set a style property on a pseudo element (before/after/first-letter/first-line) for this element.
  // Values set here are treated as inline on the pseudo element and marked important
  // to override stylesheet rules when applicable.
  void setPseudoProperty(String type, String propertyName, String value, {String? baseHref, bool validate = true}) {
    switch (type) {
      case 'before':
        pseudoBeforeStyle ??= CSSStyleDeclaration();
        pseudoBeforeStyle!.setProperty(propertyName, value, isImportant: true, baseHref: baseHref, validate: validate);
        target?.markBeforePseudoElementNeedsUpdate();
        break;
      case 'after':
        pseudoAfterStyle ??= CSSStyleDeclaration();
        pseudoAfterStyle!.setProperty(propertyName, value, isImportant: true, baseHref: baseHref, validate: validate);
        target?.markAfterPseudoElementNeedsUpdate();
        break;
      case 'first-letter':
        pseudoFirstLetterStyle ??= CSSStyleDeclaration();
        pseudoFirstLetterStyle!.setProperty(propertyName, value, isImportant: true, baseHref: baseHref, validate: validate);
        target?.markFirstLetterPseudoNeedsUpdate();
        break;
      case 'first-line':
        pseudoFirstLineStyle ??= CSSStyleDeclaration();
        pseudoFirstLineStyle!.setProperty(propertyName, value, isImportant: true, baseHref: baseHref, validate: validate);
        target?.markFirstLinePseudoNeedsUpdate();
        break;
    }
  }

  // Remove a style property from a pseudo element (before/after/first-letter/first-line) for this element.
  void removePseudoProperty(String type, String propertyName) {
    switch (type) {
      case 'before':
        if (pseudoBeforeStyle != null) {
          // Remove the inline override; fall back to stylesheet value if present.
          pseudoBeforeStyle!.removeProperty(propertyName, true);
        }
        target?.markBeforePseudoElementNeedsUpdate();
        break;
      case 'after':
        if (pseudoAfterStyle != null) {
          pseudoAfterStyle!.removeProperty(propertyName, true);
        }
        target?.markAfterPseudoElementNeedsUpdate();
        break;
      case 'first-letter':
        if (pseudoFirstLetterStyle != null) {
          pseudoFirstLetterStyle!.removeProperty(propertyName, true);
        }
        target?.markFirstLetterPseudoNeedsUpdate();
        break;
      case 'first-line':
        if (pseudoFirstLineStyle != null) {
          pseudoFirstLineStyle!.removeProperty(propertyName, true);
        }
        target?.markFirstLinePseudoNeedsUpdate();
        break;
    }
  }

  void clearPseudoStyle(String type) {
    switch(type) {
      case 'before':
        pseudoBeforeStyle = null;
        target?.markBeforePseudoElementNeedsUpdate();
        break;
      case 'after':
        pseudoAfterStyle = null;
        target?.markAfterPseudoElementNeedsUpdate();
        break;
      case 'first-letter':
        pseudoFirstLetterStyle = null;
        target?.markFirstLetterPseudoNeedsUpdate();
        break;
      case 'first-line':
        pseudoFirstLineStyle = null;
        target?.markFirstLinePseudoNeedsUpdate();
        break;
    }
  }

  // Inserts the style of the given Declaration into the current Declaration.
  void union(CSSStyleDeclaration declaration) {
    Map<String, CSSPropertyValue> properties = {}
      ..addAll(_properties)
      ..addAll(_pendingProperties);

    for (String propertyName in declaration._pendingProperties.keys) {
      bool currentIsImportant = _importants[propertyName] ?? false;
      bool otherIsImportant = declaration._importants[propertyName] ?? false;
      CSSPropertyValue? currentValue = properties[propertyName];
      CSSPropertyValue? otherValue = declaration._pendingProperties[propertyName];
      if ((otherIsImportant || !currentIsImportant) && currentValue != otherValue) {
        // Add property.
        if (otherValue != null) {
          _pendingProperties[propertyName] = otherValue;
        } else {
          _pendingProperties.remove(propertyName);
        }
        if (otherIsImportant) {
          _importants[propertyName] = true;
        }
      }
    }
  }

  void handlePseudoRules(Element parentElement, List<CSSStyleRule> rules) {
    if (rules.isEmpty) return;

    List<CSSStyleRule> beforeRules = [];
    List<CSSStyleRule> afterRules = [];
    List<CSSStyleRule> firstLetterRules = [];
    List<CSSStyleRule> firstLineRules = [];

    for (CSSStyleRule style in rules) {
      for (Selector selector in style.selectorGroup.selectors) {
        for (SimpleSelectorSequence sequence in selector.simpleSelectorSequences) {
          if (sequence.simpleSelector is PseudoElementSelector) {
            if (sequence.simpleSelector.name == 'before') {
              beforeRules.add(style);
            } else if (sequence.simpleSelector.name == 'after') {
              afterRules.add(style);
            } else if (sequence.simpleSelector.name == 'first-letter') {
              firstLetterRules.add(style);
            } else if (sequence.simpleSelector.name == 'first-line') {
              firstLineRules.add(style);
            }
          }
        }
      }
    }

    int sortRules(leftRule, rightRule) {
      int isCompare = leftRule.selectorGroup.matchSpecificity.compareTo(rightRule.selectorGroup.matchSpecificity);
      if (isCompare == 0) {
        return leftRule.position.compareTo(rightRule.position);
      }
      return isCompare;
    }

    // sort selector
    beforeRules.sort(sortRules);
    afterRules.sort(sortRules);
    firstLetterRules.sort(sortRules);
    firstLineRules.sort(sortRules);

    if (beforeRules.isNotEmpty) {
      pseudoBeforeStyle ??= CSSStyleDeclaration();
      // Merge all the rules
      for (CSSStyleRule rule in beforeRules) {
        pseudoBeforeStyle!.union(rule.declaration);
      }
      parentElement.markBeforePseudoElementNeedsUpdate();
    } else if (beforeRules.isEmpty && pseudoBeforeStyle != null) {
      pseudoBeforeStyle = null;
    }

    if (afterRules.isNotEmpty) {
      pseudoAfterStyle ??= CSSStyleDeclaration();
      for (CSSStyleRule rule in afterRules) {
        pseudoAfterStyle!.union(rule.declaration);
      }
      parentElement.markAfterPseudoElementNeedsUpdate();
    } else if (afterRules.isEmpty && pseudoAfterStyle != null) {
      pseudoAfterStyle = null;
    }

    if (firstLetterRules.isNotEmpty) {
      pseudoFirstLetterStyle ??= CSSStyleDeclaration();
      for (CSSStyleRule rule in firstLetterRules) {
        pseudoFirstLetterStyle!.union(rule.declaration);
      }
      parentElement.markFirstLetterPseudoNeedsUpdate();
    } else if (firstLetterRules.isEmpty && pseudoFirstLetterStyle != null) {
      pseudoFirstLetterStyle = null;
    }

    if (firstLineRules.isNotEmpty) {
      pseudoFirstLineStyle ??= CSSStyleDeclaration();
      for (CSSStyleRule rule in firstLineRules) {
        pseudoFirstLineStyle!.union(rule.declaration);
      }
      parentElement.markFirstLinePseudoNeedsUpdate();
    } else if (firstLineRules.isEmpty && pseudoFirstLineStyle != null) {
      pseudoFirstLineStyle = null;
    }
  }

  // Merge the difference between the declarations and return the updated status
  bool merge(CSSStyleDeclaration other) {
    Map<String, CSSPropertyValue> properties = {}
      ..addAll(_properties)
      ..addAll(_pendingProperties);
    bool updateStatus = false;
    for (String propertyName in properties.keys) {
      CSSPropertyValue? prevValue = properties[propertyName];
      CSSPropertyValue? currentValue = other._pendingProperties[propertyName];
      bool currentImportant = other._importants[propertyName] ?? false;

      if (isNullOrEmptyValue(prevValue) && isNullOrEmptyValue(currentValue)) {
        continue;
      } else if (!isNullOrEmptyValue(prevValue) && isNullOrEmptyValue(currentValue)) {
        // Remove property.
        removeProperty(propertyName, currentImportant);
        updateStatus = true;
      } else if (prevValue != currentValue) {
        // Update property.
        setProperty(propertyName, currentValue?.value, isImportant: currentImportant, baseHref: currentValue?.baseHref);
        updateStatus = true;
      }
    }

    for (String propertyName in other._pendingProperties.keys) {
      CSSPropertyValue? prevValue = properties[propertyName];
      CSSPropertyValue? currentValue = other._pendingProperties[propertyName];
      bool currentImportant = other._importants[propertyName] ?? false;

      if (isNullOrEmptyValue(prevValue) && !isNullOrEmptyValue(currentValue)) {
        // Add property.
        setProperty(propertyName, currentValue?.value, isImportant: currentImportant, baseHref: currentValue?.baseHref);
        updateStatus = true;
      }
    }

    // Merge pseudo-element styles. Ensure target side is initialized so rules from
    // 'other' are not dropped when this side is null.
    if (other.pseudoBeforeStyle != null) {
      pseudoBeforeStyle ??= CSSStyleDeclaration();
      pseudoBeforeStyle!.merge(other.pseudoBeforeStyle!);
    }
    if (other.pseudoAfterStyle != null) {
      pseudoAfterStyle ??= CSSStyleDeclaration();
      pseudoAfterStyle!.merge(other.pseudoAfterStyle!);
    }
    if (other.pseudoFirstLetterStyle != null) {
      pseudoFirstLetterStyle ??= CSSStyleDeclaration();
      pseudoFirstLetterStyle!.merge(other.pseudoFirstLetterStyle!);
    }
    if (other.pseudoFirstLineStyle != null) {
      pseudoFirstLineStyle ??= CSSStyleDeclaration();
      pseudoFirstLineStyle!.merge(other.pseudoFirstLineStyle!);
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

  void _emitPropertyChanged(String property, String? original, String present, {String? baseHref}) {
    if (original == present && (!CSSVariable.isCSSVariableValue(present))) return;

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
  String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) => 'CSSStyleDeclaration($cssText)';

  @override
  int get hashCode => cssText.hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }


  @override
  Iterator<MapEntry<String, CSSPropertyValue>> get iterator {
    return _properties.entries.followedBy(_pendingProperties.entries).iterator;
  }
}

// aB to a-b
String _kebabize(String str) {
  return str.replaceAllMapped(_kebabCaseReg, (match) => '-${match[0]!.toLowerCase()}');
}
