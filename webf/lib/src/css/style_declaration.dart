/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart';
import 'package:quiver/collection.dart';

typedef StyleChangeListener = void Function(String property, String? original, String present, {String? baseHref});
typedef StyleFlushedListener = void Function(List<String> properties);

const Map<String, bool> _CSSShorthandProperty = {
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
  FONT: true,
  FLEX: true,
  FLEX_FLOW: true,
  OVERFLOW: true,
  TRANSITION: true,
  TEXT_DECORATION: true,
  ANIMATION: true,
};

// Reorder the properties for control render style init order, the last is the largest.
List<String> _propertyOrders = [
  LINE_CLAMP,
  WHITE_SPACE,
  FONT_SIZE,
  COLOR,
  TRANSITION_DURATION,
  TRANSITION_PROPERTY,
  TRANSITION_TIMING_FUNCTION,
  TRANSITION_DELAY,
  OVERFLOW_X,
  OVERFLOW_Y
];

RegExp _kebabCaseReg = RegExp(r'[A-Z]');

final LinkedLruHashMap<String, Map<String, String?>> _cachedExpandedShorthand = LinkedLruHashMap(maximumSize: 500);

class CSSPropertyValue {
  String? baseHref;
  String value;

  CSSPropertyValue(this.value, {this.baseHref});
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
class CSSStyleDeclaration extends BindingObject {
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

  CSSStyleDeclaration([BindingContext? context]): super(context);

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
      case OVERFLOW:
        return CSSStyleProperty.removeShorthandOverflow(this, isImportant);
      case FONT:
        return CSSStyleProperty.removeShorthandFont(this, isImportant);
      case FLEX:
        return CSSStyleProperty.removeShorthandFlex(this, isImportant);
      case FLEX_FLOW:
        return CSSStyleProperty.removeShorthandFlexFlow(this, isImportant);
      case BORDER:
      case BORDER_TOP:
      case BORDER_RIGHT:
      case BORDER_BOTTOM:
      case BORDER_LEFT:
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

    // Fallback to default style.
    if (isNullOrEmptyValue(present) && defaultStyle != null && defaultStyle!.containsKey(propertyName)) {
      present = defaultStyle![propertyName];
    }

    // Update removed value by flush pending properties.
    _pendingProperties[propertyName] = CSSPropertyValue(present);
  }

  void _expandShorthand(String propertyName, String normalizedValue, bool? isImportant) {
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
          CSSStyleProperty.setShorthandBackground(longhandProperties, normalizedValue);
          break;
        case BACKGROUND_POSITION:
          CSSStyleProperty.setShorthandBackgroundPosition(longhandProperties, normalizedValue);
          break;
        case BORDER_RADIUS:
          CSSStyleProperty.setShorthandBorderRadius(longhandProperties, normalizedValue);
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
        case BORDER:
        case BORDER_TOP:
        case BORDER_RIGHT:
        case BORDER_BOTTOM:
        case BORDER_LEFT:
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
        setProperty(propertyName, value, isImportant: isImportant);
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

    if (propertyName == CONTENT) {
      return string;
    }

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

    // Validate value.
    switch (propertyName) {
      case WIDTH:
      case HEIGHT:
        // Validation length type
        if (!CSSLength.isNonNegativeLength(normalizedValue) &&
            !CSSLength.isAuto(normalizedValue) &&
            !CSSPercentage.isNonNegativePercentage(normalizedValue) &&
            // SVG width need to support number type
            !CSSNumber.isNumber(normalizedValue)) {
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
            !CSSPercentage.isNonNegativePercentage(normalizedValue)) {
          return false;
        }
        break;
      case MIN_WIDTH:
      case MIN_HEIGHT:
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
        if (!CSSBackground.isValidBackgroundRepeatValue(normalizedValue)) return false;
        break;
      case FONT_SIZE:
        CSSLengthValue parsedFontSize = CSSLength.parseLength(normalizedValue, null);
        if (parsedFontSize == CSSLengthValue.unknown && !CSSText.isValidFontSizeValue(normalizedValue)) return false;
        break;
    }
    return true;
  }

  /// Modifies an existing CSS property or creates a new CSS property in
  /// the declaration block.
  void setProperty(String propertyName, String? value, {bool? isImportant, String? baseHref}) {
    propertyName = propertyName.trim();

    // Null or empty value means should be removed.
    if (isNullOrEmptyValue(value)) {
      removeProperty(propertyName, isImportant);
      return;
    }

    String normalizedValue = _toLowerCase(propertyName, value.toString().trim());

    if (!_isValidValue(propertyName, normalizedValue)) return;

    if (_CSSShorthandProperty[propertyName] != null) {
      return _expandShorthand(propertyName, normalizedValue, isImportant);
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
    if (normalizedValue == prevValue) return;

    _pendingProperties[propertyName] = CSSPropertyValue(normalizedValue, baseHref: baseHref);
  }

  void flushPendingProperties() {
    Element? _target = target;
    // If style target element not exists, no need to do flush operation.
    if (_target == null) return;

    // Display change from none to other value that the renderBoxModel is null.
    if (_pendingProperties.containsKey(DISPLAY) &&
        _target.isConnected &&
        _target.parentElement?.renderStyle.display != CSSDisplay.sliver) {
      CSSPropertyValue? prevValue = _properties[DISPLAY];
      CSSPropertyValue currentValue = _pendingProperties[DISPLAY]!;
      _properties[DISPLAY] = currentValue;
      _pendingProperties.remove(DISPLAY);
      _emitPropertyChanged(DISPLAY, prevValue?.value, currentValue.value, baseHref: currentValue.baseHref);
    }

    // If target has no renderer attached, no need to flush.
    if (!_target.isRendererAttached) return;

    RenderBoxModel? renderBoxModel = _target.renderBoxModel;
    if (_pendingProperties.isEmpty || renderBoxModel == null) {
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
      final isVariableLeft = CSSVariable.isVariable(left) ? 1 : 0;
      final isVariableRight = CSSVariable.isVariable(right) ? 1 : 0;
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

    for (CSSStyleRule style in rules) {
      for (Selector selector in style.selectorGroup.selectors) {
        for (SimpleSelectorSequence sequence in selector.simpleSelectorSequences) {
          if (sequence.simpleSelector is PseudoElementSelector) {
            if (sequence.simpleSelector.name == 'before') {
              beforeRules.add(style);
            } else if (sequence.simpleSelector.name == 'after') {
              afterRules.add(style);
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

    if (other.pseudoBeforeStyle != null) {
      pseudoBeforeStyle?.merge(other.pseudoBeforeStyle!);
    }
    if (other.pseudoAfterStyle != null) {
      pseudoAfterStyle?.merge(other.pseudoAfterStyle!);
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
    if (original == present) return;

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
  String toString() => 'CSSStyleDeclaration($cssText)';

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

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {}

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {}
}

// aB to a-b
String _kebabize(String str) {
  return str.replaceAllMapped(_kebabCaseReg, (match) => '-${match[0]!.toLowerCase()}');
}
