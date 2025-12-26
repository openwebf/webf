/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// ignore_for_file: constant_identifier_names

import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/src/css/css_animation.dart';

// aB to a-b
RegExp kebabCaseReg = RegExp(r'[A-Z]');
// a-b to aB
final RegExp _camelCaseReg = RegExp(r'-(\w)');
final RegExp _commaRegExp = RegExp(r',(?![^\(]*\))');
final RegExp _slashRegExp = RegExp(r'\/(?![^(]*\))');
final RegExp _replaceCommaRegExp = RegExp(r'\s*,\s*');
const String _comma = ', ';
const String _0s = '0s';
const String _0 = '0';
const String _1 = '1';
const String _0Percent = '0%';

// aB to a-b
String kebabize(String str) {
  return str.replaceAllMapped(kebabCaseReg, (match) => '-${match[0]!.toLowerCase()}');
}

// a-b -> aB
String camelize(String str) {
  // variables
  if (str.startsWith('--')) {
    return str;
  }
  return str.replaceAllMapped(_camelCaseReg, (match) {
    String subStr = match[0]!.substring(1);
    return subStr.isNotEmpty ? subStr.toUpperCase() : '';
  });
}

// Origin version: https://github.com/jedmao/css-list-helpers/blob/master/src/index.ts
List<String> _splitBySpace(String value) {
  List<String> array = List.empty(growable: true);
  String current = '';
  int func = 0;
  String? quote;
  bool splitMe = false;
  bool escape = false;

  for (int i = 0; i < value.length; i++) {
    String char = value[i];

    if (quote != null) {
      if (escape) {
        escape = false;
      } else if (char == '\\') {
        escape = true;
      } else if (char == quote) {
        quote = null;
      }
    } else if (char == '"' || char == '\'') {
      quote = char;
    } else if (char == '(') {
      func += 1;
    } else if (char == ')') {
      if (func > 0) {
        func -= 1;
      }
    } else if (func == 0) {
      if (char == ' ') {
        splitMe = true;
      }
    }

    if (splitMe) {
      if (current != '') {
        array.add(current.trim());
      }
      current = '';
      splitMe = false;
    } else {
      current += char;
    }
  }

  if (current != '') {
    array.add(current.trim());
  }
  return array;
}

class CSSStyleProperty {
  static void setShorthandPadding(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = getEdgeValues(shorthandValue, isNonNegativeLengthOrPercentage: true);
    if (values == null) return;

    properties[PADDING_TOP] = values[0];
    properties[PADDING_RIGHT] = values[1];
    properties[PADDING_BOTTOM] = values[2];
    properties[PADDING_LEFT] = values[3];
  }

  static void removeShorthandPadding(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(PADDING_LEFT)) style.removeProperty(PADDING_LEFT, isImportant);
    if (style.contains(PADDING_TOP)) style.removeProperty(PADDING_TOP, isImportant);
    if (style.contains(PADDING_RIGHT)) style.removeProperty(PADDING_RIGHT, isImportant);
    if (style.contains(PADDING_BOTTOM)) style.removeProperty(PADDING_BOTTOM, isImportant);
  }

  static void setShorthandMargin(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = getEdgeValues(shorthandValue);
    if (values == null) return;

    properties[MARGIN_TOP] = values[0];
    properties[MARGIN_RIGHT] = values[1];
    properties[MARGIN_BOTTOM] = values[2];
    properties[MARGIN_LEFT] = values[3];
  }

  static void removeShorthandMargin(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(MARGIN_LEFT)) style.removeProperty(MARGIN_LEFT, isImportant);
    if (style.contains(MARGIN_TOP)) style.removeProperty(MARGIN_TOP, isImportant);
    if (style.contains(MARGIN_RIGHT)) style.removeProperty(MARGIN_RIGHT, isImportant);
    if (style.contains(MARGIN_BOTTOM)) style.removeProperty(MARGIN_BOTTOM, isImportant);
  }

  static void setShorthandBackground(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getBackgroundValues(shorthandValue);
    if (values == null) return;

    // Per CSS Backgrounds spec, unspecified subproperties reset to their initial values.
    // Initials: color=transparent, image=none, repeat=repeat, attachment=scroll,
    // position=0% 0%, size=auto, origin=padding-box, clip=border-box.
    final String color = values[0] ?? 'transparent';
    final String image = values[1] ?? 'none';
    final String repeat = values[2] ?? 'repeat';
    final String attachment = values[3] ?? 'scroll';
    final String? positionShorthand = values[4];
    final String size = values[5] ?? 'auto';

    if (DebugFlags.enableBackgroundLogs && shorthandValue.contains('gradient')) {
      cssLogger.finer('[Background] expand shorthand "$shorthandValue" -> '
          'color="${values[0] ?? 'transparent'}" image="${values[1] ?? 'none'}" repeat="${values[2] ?? 'repeat'}" '
          'attachment="${values[3] ?? 'scroll'}" position="${values[4] ?? '<none>'}" size="$size"');
    }

    properties[BACKGROUND_COLOR] = color;
    properties[BACKGROUND_IMAGE] = image;
    properties[BACKGROUND_REPEAT] = repeat;
    properties[BACKGROUND_ATTACHMENT] = attachment;
    if (positionShorthand != null) {
      final List<String> positions = CSSPosition.parsePositionShorthand(positionShorthand);
      if (positions.length >= 2) {
        properties[BACKGROUND_POSITION_X] = positions[0];
        properties[BACKGROUND_POSITION_Y] = positions[1];
      } else {
        cssLogger.warning('[CSSStyleProperty] Failed to parse background-position in shorthand: '
            '"$positionShorthand". Fallback to 0% 0%.');
        properties[BACKGROUND_POSITION_X] = '0%';
        properties[BACKGROUND_POSITION_Y] = '0%';
      }
    } else {
      // Reset to initial when not specified
      properties[BACKGROUND_POSITION_X] = '0%';
      properties[BACKGROUND_POSITION_Y] = '0%';
    }
    properties[BACKGROUND_SIZE] = size;

    // Reset origin/clip to their initial values when using `background` shorthand.
    // Note: We currently don't parse origin/clip tokens from the shorthand itself,
    // but per spec they must be reset when omitted.
    properties[BACKGROUND_ORIGIN] = 'padding-box';
    properties[BACKGROUND_CLIP] = 'border-box';

  }

  static void removeShorthandBackground(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(BACKGROUND_ATTACHMENT)) style.removeProperty(BACKGROUND_ATTACHMENT, isImportant);
    if (style.contains(BACKGROUND_COLOR)) style.removeProperty(BACKGROUND_COLOR, isImportant);
    if (style.contains(BACKGROUND_IMAGE)) style.removeProperty(BACKGROUND_IMAGE, isImportant);
    if (style.contains(BACKGROUND_POSITION)) style.removeProperty(BACKGROUND_POSITION, isImportant);
    if (style.contains(BACKGROUND_SIZE)) style.removeProperty(BACKGROUND_SIZE, isImportant);
    if (style.contains(BACKGROUND_REPEAT)) style.removeProperty(BACKGROUND_REPEAT, isImportant);
    if (style.contains(BACKGROUND_ORIGIN)) style.removeProperty(BACKGROUND_ORIGIN, isImportant);
    if (style.contains(BACKGROUND_CLIP)) style.removeProperty(BACKGROUND_CLIP, isImportant);
  }

  static void setShorthandBackgroundPosition(Map<String, String?> properties, String shorthandValue) {
    cssLogger.fine('[CSSStyleProperty] Expanding background-position: "$shorthandValue"');
    // Only the first layer contributes to longhands; layered painting reads
    // the full comma-separated list directly from style.
    final String firstLayer = shorthandValue.split(_commaRegExp).first.trim();
    final List<String> positions = CSSPosition.parsePositionShorthand(firstLayer);
    if (positions.length >= 2) {
      properties[BACKGROUND_POSITION_X] = positions[0];
      properties[BACKGROUND_POSITION_Y] = positions[1];
    } else {
      cssLogger.severe('[CSSStyleProperty] Invalid background-position, got tokens="$positions" from '
          '"$shorthandValue". Using fallback 0% 0% to avoid crash.');
      properties[BACKGROUND_POSITION_X] = '0%';
      properties[BACKGROUND_POSITION_Y] = '0%';
    }
  }

  static void removeShorthandBackgroundPosition(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(BACKGROUND_POSITION_X)) style.removeProperty(BACKGROUND_POSITION_X, isImportant);
    if (style.contains(BACKGROUND_POSITION_Y)) style.removeProperty(BACKGROUND_POSITION_Y, isImportant);
  }

  static void setShorthandBorderRadius(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getBorderRaidusValues(shorthandValue);

    if (values == null) return;

    properties[BORDER_TOP_LEFT_RADIUS] = values[0];
    properties[BORDER_TOP_RIGHT_RADIUS] = values[1];
    properties[BORDER_BOTTOM_RIGHT_RADIUS] = values[2];
    properties[BORDER_BOTTOM_LEFT_RADIUS] = values[3];
  }

  static void removeShorthandBorderRadius(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(BORDER_TOP_LEFT_RADIUS)) style.removeProperty(BORDER_TOP_LEFT_RADIUS, isImportant);
    if (style.contains(BORDER_TOP_RIGHT_RADIUS)) style.removeProperty(BORDER_TOP_RIGHT_RADIUS, isImportant);
    if (style.contains(BORDER_BOTTOM_RIGHT_RADIUS)) style.removeProperty(BORDER_BOTTOM_RIGHT_RADIUS, isImportant);
    if (style.contains(BORDER_BOTTOM_LEFT_RADIUS)) style.removeProperty(BORDER_BOTTOM_LEFT_RADIUS, isImportant);
  }

  static void setShorthandOverflow(Map<String, String?> properties, String shorthandValue) {
    List<String> values = _splitBySpace(shorthandValue);
    if (values.length == 1) {
      properties[OVERFLOW_Y] = properties[OVERFLOW_X] = values[0];
    } else if (values.length == 2) {
      properties[OVERFLOW_X] = values[0];
      properties[OVERFLOW_Y] = values[1];
    }
  }

  static void removeShorthandOverflow(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(OVERFLOW_X)) style.removeProperty(OVERFLOW_X, isImportant);
    if (style.contains(OVERFLOW_Y)) style.removeProperty(OVERFLOW_Y, isImportant);
  }

  static void setShorthandFont(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getFontValues(shorthandValue);
    if (values == null) return;
    properties[FONT_STYLE] = values[0];
    properties[FONT_VARIANT] = values[1];
    properties[FONT_WEIGHT] = values[2];
    properties[FONT_SIZE] = values[3];
    properties[LINE_HEIGHT] = values[4];
    properties[FONT_FAMILY] = values[5];
  }

  static void removeShorthandFont(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(FONT_STYLE)) style.removeProperty(FONT_STYLE, isImportant);
    if (style.contains(FONT_VARIANT)) style.removeProperty(FONT_VARIANT, isImportant);
    if (style.contains(FONT_WEIGHT)) style.removeProperty(FONT_WEIGHT, isImportant);
    if (style.contains(FONT_SIZE)) style.removeProperty(FONT_SIZE, isImportant);
    if (style.contains(LINE_HEIGHT)) style.removeProperty(LINE_HEIGHT, isImportant);
    if (style.contains(FONT_FAMILY)) style.removeProperty(FONT_FAMILY, isImportant);
  }

  static void setShorthandFlex(Map<String, String?> properties, String shorthandValue) {
    List<String>? values = _getFlexValues(shorthandValue);
    if (values == null) return;
    properties[FLEX_GROW] = values[0];
    properties[FLEX_SHRINK] = values[1];
    properties[FLEX_BASIS] = values[2];
  }

  static void removeShorthandFlex(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(FLEX_GROW)) style.removeProperty(FLEX_GROW, isImportant);
    if (style.contains(FLEX_SHRINK)) style.removeProperty(FLEX_SHRINK, isImportant);
    if (style.contains(FLEX_BASIS)) style.removeProperty(FLEX_BASIS, isImportant);
  }

  static void setShorthandFlexFlow(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getFlexFlowValues(shorthandValue);
    if (values == null) return;
    properties[FLEX_DIRECTION] = values[0];
    properties[FLEX_WRAP] = values[1];
  }

  static void removeShorthandFlexFlow(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(FLEX_DIRECTION)) style.removeProperty(FLEX_DIRECTION, isImportant);
    if (style.contains(FLEX_WRAP)) style.removeProperty(FLEX_WRAP, isImportant);
  }

  static void setShorthandTransition(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getTransitionValues(shorthandValue);
    if (values == null) return;

    properties[TRANSITION_PROPERTY] = values[0];
    properties[TRANSITION_DURATION] = values[1];
    properties[TRANSITION_TIMING_FUNCTION] = values[2];
    properties[TRANSITION_DELAY] = values[3];
  }

  static void removeShorthandTransition(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(TRANSITION_PROPERTY)) style.removeProperty(TRANSITION_PROPERTY, isImportant);
    if (style.contains(TRANSITION_DURATION)) style.removeProperty(TRANSITION_DURATION, isImportant);
    if (style.contains(TRANSITION_TIMING_FUNCTION)) style.removeProperty(TRANSITION_TIMING_FUNCTION, isImportant);
    if (style.contains(TRANSITION_DELAY)) style.removeProperty(TRANSITION_DELAY, isImportant);
  }

  static void setShorthandTextDecoration(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getTextDecorationValues(shorthandValue);
    if (values == null) return;

    properties[TEXT_DECORATION_LINE] = values[0];
    properties[TEXT_DECORATION_COLOR] = values[1];
    properties[TEXT_DECORATION_STYLE] = values[2];
  }

  static void removeShorthandTextDecoration(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(TEXT_DECORATION_LINE)) style.removeProperty(TEXT_DECORATION_LINE, isImportant);
    if (style.contains(TEXT_DECORATION_COLOR)) style.removeProperty(TEXT_DECORATION_COLOR, isImportant);
    if (style.contains(TEXT_DECORATION_STYLE)) style.removeProperty(TEXT_DECORATION_STYLE, isImportant);
  }

  static void removeShorthandAnimation(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(ANIMATION_NAME)) style.removeProperty(ANIMATION_NAME, isImportant);
    if (style.contains(ANIMATION_DURATION)) style.removeProperty(ANIMATION_DURATION, isImportant);
    if (style.contains(ANIMATION_TIMING_FUNCTION)) style.removeProperty(ANIMATION_TIMING_FUNCTION, isImportant);
    if (style.contains(ANIMATION_DELAY)) style.removeProperty(ANIMATION_DELAY, isImportant);
    if (style.contains(ANIMATION_ITERATION_COUNT)) style.removeProperty(ANIMATION_ITERATION_COUNT, isImportant);
    if (style.contains(ANIMATION_DIRECTION)) style.removeProperty(ANIMATION_DIRECTION, isImportant);
    if (style.contains(ANIMATION_FILL_MODE)) style.removeProperty(ANIMATION_FILL_MODE, isImportant);
    if (style.contains(ANIMATION_PLAY_STATE)) style.removeProperty(ANIMATION_PLAY_STATE, isImportant);
  }

  static void setShorthandBorder(Map<String, String?> properties, String property, String shorthandValue) {
    // If the entire shorthand is a single var(...) function, defer parsing to
    // compute time by assigning the same var(...) token to all relevant
    // longhands for the affected edges. Each longhand will later resolve the
    // var to a full shorthand string (e.g., "2px solid red") and extract its
    // own component.
    bool isEntireVarFunction(String s) {
      final String trimmed = s.trimLeft();
      if (!trimmed.startsWith('var(')) return false;
      int start = trimmed.indexOf('(');
      int depth = 0;
      for (int i = start; i < trimmed.length; i++) {
        final int ch = trimmed.codeUnitAt(i);
        if (ch == 40) {
          depth++;
        } else if (ch == 41) {
          depth--;
          if (depth == 0) {
            final rest = trimmed.substring(i + 1).trim();
            return rest.isEmpty;
          }
        }
      }
      return false;
    }

    if (property == BORDER ||
        property == BORDER_TOP ||
        property == BORDER_RIGHT ||
        property == BORDER_BOTTOM ||
        property == BORDER_LEFT ||
        property == BORDER_INLINE_START ||
        property == BORDER_INLINE_END ||
        property == BORDER_BLOCK_START ||
        property == BORDER_BLOCK_END) {
      if (isEntireVarFunction(shorthandValue)) {
        // Apply the same var(...) to width/style/color for the specified edges.
        void applyEdge(String edge) {
          switch (edge) {
            case 'top':
              properties[BORDER_TOP_WIDTH] = shorthandValue;
              properties[BORDER_TOP_STYLE] = shorthandValue;
              properties[BORDER_TOP_COLOR] = shorthandValue;
              break;
            case 'right':
              properties[BORDER_RIGHT_WIDTH] = shorthandValue;
              properties[BORDER_RIGHT_STYLE] = shorthandValue;
              properties[BORDER_RIGHT_COLOR] = shorthandValue;
              break;
            case 'bottom':
              properties[BORDER_BOTTOM_WIDTH] = shorthandValue;
              properties[BORDER_BOTTOM_STYLE] = shorthandValue;
              properties[BORDER_BOTTOM_COLOR] = shorthandValue;
              break;
            case 'left':
              properties[BORDER_LEFT_WIDTH] = shorthandValue;
              properties[BORDER_LEFT_STYLE] = shorthandValue;
              properties[BORDER_LEFT_COLOR] = shorthandValue;
              break;
            case 'inlineStart':
              properties[BORDER_INLINE_START_WIDTH] = shorthandValue;
              properties[BORDER_INLINE_START_STYLE] = shorthandValue;
              properties[BORDER_INLINE_START_COLOR] = shorthandValue;
              break;
            case 'inlineEnd':
              properties[BORDER_INLINE_END_WIDTH] = shorthandValue;
              properties[BORDER_INLINE_END_STYLE] = shorthandValue;
              properties[BORDER_INLINE_END_COLOR] = shorthandValue;
              break;
            case 'blockStart':
              properties[BORDER_BLOCK_START_WIDTH] = shorthandValue;
              properties[BORDER_BLOCK_START_STYLE] = shorthandValue;
              properties[BORDER_BLOCK_START_COLOR] = shorthandValue;
              break;
            case 'blockEnd':
              properties[BORDER_BLOCK_END_WIDTH] = shorthandValue;
              properties[BORDER_BLOCK_END_STYLE] = shorthandValue;
              properties[BORDER_BLOCK_END_COLOR] = shorthandValue;
              break;
          }
        }

        if (property == BORDER || property == BORDER_TOP) applyEdge('top');
        if (property == BORDER || property == BORDER_RIGHT) applyEdge('right');
        if (property == BORDER || property == BORDER_BOTTOM) applyEdge('bottom');
        if (property == BORDER || property == BORDER_LEFT) applyEdge('left');
        if (property == BORDER_INLINE_START) applyEdge('inlineStart');
        if (property == BORDER_INLINE_END) applyEdge('inlineEnd');
        if (property == BORDER_BLOCK_START) applyEdge('blockStart');
        if (property == BORDER_BLOCK_END) applyEdge('blockEnd');
        return;
      }
    }

    String? borderTopColor;
    String? borderRightColor;
    String? borderBottomColor;
    String? borderLeftColor;
    String? borderTopStyle;
    String? borderRightStyle;
    String? borderBottomStyle;
    String? borderLeftStyle;
    String? borderTopWidth;
    String? borderRightWidth;
    String? borderBottomWidth;
    String? borderLeftWidth;
    String? borderInlineStartWidth;
    String? borderInlineStartStyle;
    String? borderInlineStartColor;
    String? borderInlineEndWidth;
    String? borderInlineEndStyle;
    String? borderInlineEndColor;
    String? borderBlockStartWidth;
    String? borderBlockStartStyle;
    String? borderBlockStartColor;
    String? borderBlockEndWidth;
    String? borderBlockEndStyle;
    String? borderBlockEndColor;

    if (property == BORDER ||
        property == BORDER_TOP ||
        property == BORDER_RIGHT ||
        property == BORDER_BOTTOM ||
        property == BORDER_LEFT ||
        property == BORDER_INLINE_START ||
        property == BORDER_INLINE_END ||
        property == BORDER_BLOCK_START ||
        property == BORDER_BLOCK_END) {
      List<String?>? values = CSSStyleProperty._getBorderValues(shorthandValue);
      if (values == null) return;

      if (property == BORDER || property == BORDER_TOP) {
        borderTopWidth = values[0];
        borderTopStyle = values[1];
        borderTopColor = values[2];
      }
      if (property == BORDER || property == BORDER_RIGHT) {
        borderRightWidth = values[0];
        borderRightStyle = values[1];
        borderRightColor = values[2];
      }
      if (property == BORDER || property == BORDER_BOTTOM) {
        borderBottomWidth = values[0];
        borderBottomStyle = values[1];
        borderBottomColor = values[2];
      }
      if (property == BORDER || property == BORDER_LEFT) {
        borderLeftWidth = values[0];
        borderLeftStyle = values[1];
        borderLeftColor = values[2];
      }
      // Logical properties for LTR mode
      if (property == BORDER_INLINE_START) {
        borderInlineStartWidth = values[0];
        borderInlineStartStyle = values[1];
        borderInlineStartColor = values[2];
      }
      if (property == BORDER_INLINE_END) {
        borderInlineEndWidth = values[0];
        borderInlineEndStyle = values[1];
        borderInlineEndColor = values[2];
      }
      if (property == BORDER_BLOCK_START) {
        borderBlockStartWidth = values[0];
        borderBlockStartStyle = values[1];
        borderBlockStartColor = values[2];
      }
      if (property == BORDER_BLOCK_END) {
        borderBlockEndWidth = values[0];
        borderBlockEndStyle = values[1];
        borderBlockEndColor = values[2];
      }
    } else if (property == BORDER_WIDTH) {
      List<String?>? values = getEdgeValues(shorthandValue);
      if (values == null) return;

      borderTopWidth = values[0];
      borderRightWidth = values[1];
      borderBottomWidth = values[2];
      borderLeftWidth = values[3];
    } else if (property == BORDER_STYLE) {
      // @TODO: validate value
      List<String?>? values = getEdgeValues(shorthandValue);
      if (values == null) return;

      borderTopStyle = values[0];
      borderRightStyle = values[1];
      borderBottomStyle = values[2];
      borderLeftStyle = values[3];
    } else if (property == BORDER_COLOR) {
      // @TODO: validate value
      List<String?>? values = getEdgeValues(shorthandValue);
      if (values == null) return;

      borderTopColor = values[0];
      borderRightColor = values[1];
      borderBottomColor = values[2];
      borderLeftColor = values[3];
    }

    if (borderTopColor != null) properties[BORDER_TOP_COLOR] = borderTopColor;
    if (borderRightColor != null) properties[BORDER_RIGHT_COLOR] = borderRightColor;
    if (borderBottomColor != null) properties[BORDER_BOTTOM_COLOR] = borderBottomColor;
    if (borderLeftColor != null) properties[BORDER_LEFT_COLOR] = borderLeftColor;
    if (borderTopStyle != null) properties[BORDER_TOP_STYLE] = borderTopStyle;
    if (borderRightStyle != null) properties[BORDER_RIGHT_STYLE] = borderRightStyle;
    if (borderBottomStyle != null) properties[BORDER_BOTTOM_STYLE] = borderBottomStyle;
    if (borderLeftStyle != null) properties[BORDER_LEFT_STYLE] = borderLeftStyle;
    if (borderTopWidth != null) properties[BORDER_TOP_WIDTH] = borderTopWidth;
    if (borderRightWidth != null) properties[BORDER_RIGHT_WIDTH] = borderRightWidth;
    if (borderBottomWidth != null) properties[BORDER_BOTTOM_WIDTH] = borderBottomWidth;
    if (borderLeftWidth != null) properties[BORDER_LEFT_WIDTH] = borderLeftWidth;

    // Logical properties
    if (borderInlineStartWidth != null) properties[BORDER_INLINE_START_WIDTH] = borderInlineStartWidth;
    if (borderInlineStartStyle != null) properties[BORDER_INLINE_START_STYLE] = borderInlineStartStyle;
    if (borderInlineStartColor != null) properties[BORDER_INLINE_START_COLOR] = borderInlineStartColor;
    if (borderInlineEndWidth != null) properties[BORDER_INLINE_END_WIDTH] = borderInlineEndWidth;
    if (borderInlineEndStyle != null) properties[BORDER_INLINE_END_STYLE] = borderInlineEndStyle;
    if (borderInlineEndColor != null) properties[BORDER_INLINE_END_COLOR] = borderInlineEndColor;
    if (borderBlockStartWidth != null) properties[BORDER_BLOCK_START_WIDTH] = borderBlockStartWidth;
    if (borderBlockStartStyle != null) properties[BORDER_BLOCK_START_STYLE] = borderBlockStartStyle;
    if (borderBlockStartColor != null) properties[BORDER_BLOCK_START_COLOR] = borderBlockStartColor;
    if (borderBlockEndWidth != null) properties[BORDER_BLOCK_END_WIDTH] = borderBlockEndWidth;
    if (borderBlockEndStyle != null) properties[BORDER_BLOCK_END_STYLE] = borderBlockEndStyle;
    if (borderBlockEndColor != null) properties[BORDER_BLOCK_END_COLOR] = borderBlockEndColor;
  }

  static void removeShorthandBorder(CSSStyleDeclaration style, String property, [bool? isImportant]) {
    if (property == BORDER ||
        property == BORDER_TOP ||
        property == BORDER_RIGHT ||
        property == BORDER_BOTTOM ||
        property == BORDER_LEFT ||
        property == BORDER_INLINE_START ||
        property == BORDER_INLINE_END ||
        property == BORDER_BLOCK_START ||
        property == BORDER_BLOCK_END) {
      if (property == BORDER || property == BORDER_TOP) {
        if (style.contains(BORDER_TOP_COLOR)) style.removeProperty(BORDER_TOP_COLOR, isImportant);
        if (style.contains(BORDER_TOP_STYLE)) style.removeProperty(BORDER_TOP_STYLE, isImportant);
        if (style.contains(BORDER_TOP_WIDTH)) style.removeProperty(BORDER_TOP_WIDTH, isImportant);
      }
      if (property == BORDER || property == BORDER_RIGHT) {
        if (style.contains(BORDER_RIGHT_COLOR)) style.removeProperty(BORDER_RIGHT_COLOR, isImportant);
        if (style.contains(BORDER_RIGHT_STYLE)) style.removeProperty(BORDER_RIGHT_STYLE, isImportant);
        if (style.contains(BORDER_RIGHT_WIDTH)) style.removeProperty(BORDER_RIGHT_WIDTH, isImportant);
      }
      if (property == BORDER || property == BORDER_BOTTOM) {
        if (style.contains(BORDER_BOTTOM_COLOR)) style.removeProperty(BORDER_BOTTOM_COLOR, isImportant);
        if (style.contains(BORDER_BOTTOM_STYLE)) style.removeProperty(BORDER_BOTTOM_STYLE, isImportant);
        if (style.contains(BORDER_BOTTOM_WIDTH)) style.removeProperty(BORDER_BOTTOM_WIDTH, isImportant);
      }
      if (property == BORDER || property == BORDER_LEFT) {
        if (style.contains(BORDER_LEFT_COLOR)) style.removeProperty(BORDER_LEFT_COLOR, isImportant);
        if (style.contains(BORDER_LEFT_STYLE)) style.removeProperty(BORDER_LEFT_STYLE, isImportant);
        if (style.contains(BORDER_LEFT_WIDTH)) style.removeProperty(BORDER_LEFT_WIDTH, isImportant);
      }
      if (property == BORDER_INLINE_START) {
        if (style.contains(BORDER_INLINE_START_COLOR)) style.removeProperty(BORDER_INLINE_START_COLOR, isImportant);
        if (style.contains(BORDER_INLINE_START_STYLE)) style.removeProperty(BORDER_INLINE_START_STYLE, isImportant);
        if (style.contains(BORDER_INLINE_START_WIDTH)) style.removeProperty(BORDER_INLINE_START_WIDTH, isImportant);
      }
      if (property == BORDER_INLINE_END) {
        if (style.contains(BORDER_INLINE_END_COLOR)) style.removeProperty(BORDER_INLINE_END_COLOR, isImportant);
        if (style.contains(BORDER_INLINE_END_STYLE)) style.removeProperty(BORDER_INLINE_END_STYLE, isImportant);
        if (style.contains(BORDER_INLINE_END_WIDTH)) style.removeProperty(BORDER_INLINE_END_WIDTH, isImportant);
      }
      if (property == BORDER_BLOCK_START) {
        if (style.contains(BORDER_BLOCK_START_COLOR)) style.removeProperty(BORDER_BLOCK_START_COLOR, isImportant);
        if (style.contains(BORDER_BLOCK_START_STYLE)) style.removeProperty(BORDER_BLOCK_START_STYLE, isImportant);
        if (style.contains(BORDER_BLOCK_START_WIDTH)) style.removeProperty(BORDER_BLOCK_START_WIDTH, isImportant);
      }
      if (property == BORDER_BLOCK_END) {
        if (style.contains(BORDER_BLOCK_END_COLOR)) style.removeProperty(BORDER_BLOCK_END_COLOR, isImportant);
        if (style.contains(BORDER_BLOCK_END_STYLE)) style.removeProperty(BORDER_BLOCK_END_STYLE, isImportant);
        if (style.contains(BORDER_BLOCK_END_WIDTH)) style.removeProperty(BORDER_BLOCK_END_WIDTH, isImportant);
      }
    } else {
      if (property == BORDER_WIDTH) {
        if (style.contains(BORDER_TOP_WIDTH)) style.removeProperty(BORDER_TOP_WIDTH, isImportant);
        if (style.contains(BORDER_RIGHT_WIDTH)) style.removeProperty(BORDER_RIGHT_WIDTH, isImportant);
        if (style.contains(BORDER_BOTTOM_WIDTH)) style.removeProperty(BORDER_BOTTOM_WIDTH, isImportant);
        if (style.contains(BORDER_LEFT_WIDTH)) style.removeProperty(BORDER_LEFT_WIDTH, isImportant);
      } else if (property == BORDER_STYLE) {
        if (style.contains(BORDER_TOP_STYLE)) style.removeProperty(BORDER_TOP_STYLE, isImportant);
        if (style.contains(BORDER_RIGHT_STYLE)) style.removeProperty(BORDER_RIGHT_STYLE, isImportant);
        if (style.contains(BORDER_BOTTOM_STYLE)) style.removeProperty(BORDER_BOTTOM_STYLE, isImportant);
        if (style.contains(BORDER_LEFT_STYLE)) style.removeProperty(BORDER_LEFT_STYLE, isImportant);
      } else if (property == BORDER_COLOR) {
        if (style.contains(BORDER_TOP_COLOR)) style.removeProperty(BORDER_TOP_COLOR, isImportant);
        if (style.contains(BORDER_RIGHT_COLOR)) style.removeProperty(BORDER_RIGHT_COLOR, isImportant);
        if (style.contains(BORDER_BOTTOM_COLOR)) style.removeProperty(BORDER_BOTTOM_COLOR, isImportant);
        if (style.contains(BORDER_LEFT_COLOR)) style.removeProperty(BORDER_LEFT_COLOR, isImportant);
      }
    }
  }

  // all, -moz-specific, sliding; => ['all', '-moz-specific', 'sliding']
  static List<String>? getMultipleValues(String property) {
    if (property.isEmpty) return null;
    return property.split(_commaRegExp).map((e) => e.trim()).toList();
  }

  static List<List<String?>>? getShadowValues(String property) {
    List shadows = property.split(_commaRegExp);
    // The shadow effects are applied front-to-back: the first shadow is on top and
    // the others are layered behind.
    // https://drafts.csswg.org/css-backgrounds-3/#shadow-layers
    Iterable reversedShadows = shadows.reversed;
    List reversedShadowList = reversedShadows.toList();
    List<List<String?>> values = List.empty(growable: true);

    for (String shadow in reversedShadowList as Iterable<String>) {
      if (shadow == NONE) {
        continue;
      }
      List<String> parts = _splitBySpace(shadow.trim());

      String? inset;
      String? color;

      List<String?> lengthValues = List.filled(4, null);
      int i = 0;
      for (String part in parts) {
        if (part == INSET) {
          inset = part;
        } else if (CSSLength.isLength(part)) {
          lengthValues[i++] = part;
        } else if (color == null && CSSColor.isColor(part)) {
          color = part;
        } else {
          return null;
        }
      }

      values.add([
        color,
        lengthValues[0], // offsetX
        lengthValues[1], // offsetY
        lengthValues[2], // blurRadius
        lengthValues[3], // spreadRadius
        inset
      ]);
    }

    return values;
  }

  // Public helper to parse a border shorthand string (e.g., "2px solid red")
  // into [width, style, color] tokens. This mirrors _getBorderValues but is
  // exposed for compute-time parsing of var() expanded shorthands.
  static List<String?>? parseBorderTriple(String shorthandProperty) {
    return _getBorderValues(shorthandProperty);
  }

  static List<String?>? _getBorderRaidusValues(String shorthandProperty) {
    if (shorthandProperty == INHERIT) {
      return [INHERIT, INHERIT, INHERIT, INHERIT];
    }

    if (!shorthandProperty.contains('/')) {
      return getEdgeValues(shorthandProperty, isNonNegativeLengthOrPercentage: true);
    }

    List radius = shorthandProperty.split(_slashRegExp);
    if (radius.length != 2) {
      return null;
    }

    // border-radius: 10px 20px / 20px 25px 30px 35px;
    // =>
    // order-top-left-radius: 10px 20px;
    // border-top-right-radius: 20px 25px;
    // border-bottom-right-radius: 10px 30px;
    // border-bottom-left-radius: 20px 35px;
    String firstRadius = radius[0];
    String secondRadius = radius[1];

    List<String?> firstValues = getEdgeValues(firstRadius, isNonNegativeLengthOrPercentage: true)!;
    List<String?> secondValues = getEdgeValues(secondRadius, isNonNegativeLengthOrPercentage: true)!;

    return [
      '${firstValues[0]} ${secondValues[0]}',
      '${firstValues[1]} ${secondValues[1]}',
      '${firstValues[2]} ${secondValues[2]}',
      '${firstValues[3]} ${secondValues[3]}'
    ];
  }

  // Current not support multiple background layer.
  static List<String?>? _getBackgroundValues(String shorthandProperty) {
    // Convert 40%/10em -> 40% / 10em
    shorthandProperty = shorthandProperty.replaceAll(_slashRegExp, ' / ');
    List<String> tokens = _splitBySpace(shorthandProperty);

    String? color;
    String? image;
    String? repeat;
    String? attachment;

    // Accumulate position tokens before '/'
    final List<String> posTokens = <String>[];
    // Accumulate size tokens after '/'
    final List<String> sizeTokens = <String>[];

    bool isAfterSlash = false;

    bool isPositionToken(String t) {
      // Accept keywords, length/percentage, and var()/calc() functions.
      return CSSBackground.isValidBackgroundPositionValue(t) || CSSFunction.isFunction(t);
    }
    bool isSizeToken(String t) {
      return CSSBackground.isValidBackgroundSizeValue(t) || CSSFunction.isFunction(t);
    }

    for (final String t in tokens) {
      final bool isVarFn = CSSFunction.isFunction(t, functionName: VAR);
      if (t == '/') {
        isAfterSlash = true;
        continue;
      }

      // Color can appear anywhere
      if (color == null && (isVarFn || CSSColor.isColor(t))) {
        color = t;
        continue;
      }
      // Image can appear anywhere
      if (image == null && (isVarFn || CSSBackground.isValidBackgroundImageValue(t))) {
        image = t;
        continue;
      }
      // Repeat can appear anywhere
      if (repeat == null && (isVarFn || CSSBackground.isValidBackgroundRepeatValue(t))) {
        repeat = t;
        continue;
      }
      // Attachment can appear anywhere
      if (attachment == null && (isVarFn || CSSBackground.isValidBackgroundAttachmentValue(t))) {
        attachment = t;
        continue;
      }

      if (!isAfterSlash) {
        // Position tokens only before slash
        if (isPositionToken(t)) {
          posTokens.add(t);
          continue;
        }
        // Unknown token before slash: ignore gracefully
        continue;
      } else {
        // Size tokens only after slash
        if (isSizeToken(t)) {
          sizeTokens.add(t);
          continue;
        }
        // Unknown token after slash: ignore gracefully
        continue;
      }
    }

    // If slash appears, require at least one position token before and one size token after.
    if (tokens.contains('/') && (posTokens.isEmpty || sizeTokens.isEmpty)) {
      return null;
    }

    String? position = posTokens.isNotEmpty ? posTokens.join(' ') : null;
    String? size;
    if (sizeTokens.isNotEmpty) {
      // Allow one or two tokens after slash per spec.
      size = sizeTokens.take(2).join(' ');
    }

    return [color, image, repeat, attachment, position, size];
  }

  static List<String?>? _getFontValues(String shorthandProperty) {
    // Convert 40%/10em => 40% / 10em
    shorthandProperty = shorthandProperty.replaceAll(_slashRegExp, ' / ');
    // Convert "Goudy Bookletter 1911", sans-serif => "Goudy Bookletter 1911",sans-serif
    shorthandProperty = shorthandProperty.replaceAll(_replaceCommaRegExp, ',');
    List<String> values = _splitBySpace(shorthandProperty);

    String? style;
    String? variant;
    String? weight;
    String? size;
    String? lineHeight;
    String? family;

    // Font shorthand has following rules:
    // * it must include values for:
    //    <font-size>
    //    <font-family>
    // * it may optionally include values for:
    //    <font-style>
    //    <font-variant>
    //    <font-weight>
    //    <font-stretch>
    //    <line-height>
    // * font-style, font-variant and font-weight must precede font-size
    // * line-height must immediately follow font-size, preceded by "/", like this: "16px/3"
    // * font-family must be the last value specified.
    //
    // [ [ <'font-style'> || <font-variant-css2> || <'font-weight'> || <font-stretch-css3> ]? <'font-size'> [ / <'line-height'> ]? <'font-family'> ]
    // https://drafts.csswg.org/css-fonts/#font-prop
    for (int i = 0; i < values.length; i++) {
      final String value = values[i];
      final bool isValueVariableFunction = CSSFunction.isFunction(value, functionName: VAR);

      // Per spec, 'normal' may appear in the optional pre-size section to
      // represent the initial value of any of the optional properties; it is
      // effectively ignorable for shorthand parsing.
      final String normalized = isValueVariableFunction ? value : value.toLowerCase();
      if (size == null && normalized == NORMAL) {
        continue;
      }

      if (size == null) {
        if (style == null && (isValueVariableFunction || CSSText.isValidFontStyleValue(normalized))) {
          style = normalized;
          continue;
        }
        if (variant == null && (isValueVariableFunction || CSSText.isValidFontVariantCss21Value(normalized))) {
          variant = normalized;
          continue;
        }
        if (weight == null && (isValueVariableFunction || CSSText.isValidFontWeightValue(normalized))) {
          weight = normalized;
          continue;
        }
        if (isValueVariableFunction || CSSText.isValidFontSizeValue(normalized)) {
          size = normalized;
          continue;
        }
        return null;
      }

      // After <font-size> comes optional /<line-height>, then <font-family>.
      if (value == '/') {
        if (lineHeight != null || i + 1 >= values.length) return null;
        final String lh = values[++i];
        final bool isLhVar = CSSFunction.isFunction(lh, functionName: VAR);
        final String lhNormalized = isLhVar ? lh : lh.toLowerCase();
        if (!(isLhVar || CSSText.isValidLineHeightValue(lhNormalized))) {
          return null;
        }
        lineHeight = lhNormalized;
        continue;
      }

      // The font-family must be the last value specified; preserve original
      // token case so platform font resolution can match system fonts.
      family = values.sublist(i).join(' ');
      break;
    }

    if (size == null || family == null) {
      return null;
    }

    return [style, variant, weight, size, lineHeight, family];
  }

  static List<String?>? _getTextDecorationValues(String shorthandProperty) {
    List<String> tokens = _splitBySpace(shorthandProperty);
    List<String> lines = [];
    String? color;
    String? style;

    for (String token in tokens) {
      if (CSSText.isValidTextTextDecorationLineValue(token)) {
        // 'none' is exclusive per spec; cannot be combined with other values or color/style.
        if (token == 'none') {
          if (lines.isNotEmpty || color != null || style != null) return null;
          lines = ['none'];
        } else {
          if (lines.contains('none')) return null; // mixing with 'none' is invalid
          if (!lines.contains(token)) lines.add(token);
        }
      } else if (color == null && CSSColor.isColor(token)) {
        if (lines.contains('none')) return null; // 'none' must not be combined with color
        color = token;
      } else if (style == null && CSSText.isValidTextTextDecorationStyleValue(token)) {
        if (lines.contains('none')) return null; // 'none' must not be combined with style
        style = token;
      } else {
        // Unknown/invalid token for shorthand; treat as invalid shorthand.
        return null;
      }
    }

    String? line = lines.isNotEmpty ? lines.join(' ') : null;
    return [line, color, style];
  }

  static List<String?>? _getTransitionValues(String shorthandProperty) {
    List<String> transitions = shorthandProperty.split(_commaRegExp);
    List<String?> values = List.filled(4, null);

    for (String transition in transitions) {
      List<String> parts = _splitBySpace(transition.trim());

      String? property;
      String? duration;
      String? timingFunction;
      String? delay;

      for (String part in parts) {
        if (property == null && CSSTransitionMixin.isValidTransitionPropertyValue(part)) {
          property = part;
        } else if (duration == null && CSSTime.isTime(part)) {
          duration = part;
        } else if (timingFunction == null && CSSTransitionMixin.isValidTransitionTimingFunctionValue(part)) {
          timingFunction = part;
        } else if (delay == null && CSSTime.isTime(part)) {
          delay = part;
        } else {
          return null;
        }
      }

      property = property ?? ALL;
      duration = duration ?? _0s;
      timingFunction = timingFunction ?? EASE;
      delay = delay ?? _0s;

      values[0] == null ? values[0] = property : values[0] = values[0]! + (_comma + property);
      values[1] == null ? values[1] = duration : values[1] = values[1]! + (_comma + duration);
      values[2] == null ? values[2] = timingFunction : values[2] = values[2]! + (_comma + timingFunction);
      values[3] == null ? values[3] = delay : values[3] = values[3]! + (_comma + delay);
    }

    return values;
  }

  static List<String?>? _getFlexFlowValues(String shorthandProperty) {
    List<String> values = _splitBySpace(shorthandProperty);

    String? direction;
    String? wrap;

    for (String value in values) {
      final bool isValueVariableFunction = CSSFunction.isFunction(value, functionName: VAR);
      if (direction == null && (isValueVariableFunction || CSSFlex.isValidFlexDirectionValue(value))) {
        direction = value;
      } else if (wrap == null && (isValueVariableFunction || CSSFlex.isValidFlexWrapValue(value))) {
        wrap = value;
      } else {
        return null;
      }
    }

    return [direction, wrap];
  }

  static List<String>? _getFlexValues(String shorthandProperty) {
    List<String> values = _splitBySpace(shorthandProperty);

    // In flex shorthand case it is interpreted as flex: <number> 1 0;
    String? grow;
    String? shrink;
    String? basis;

    for (String value in values) {
      if (values.length == 1) {
        if (value == INITIAL) {
          grow = _0;
          shrink = _1;
          basis = AUTO;
          break;
        } else if (value == AUTO) {
          grow = _1;
          shrink = _1;
          basis = AUTO;
          break;
        } else if (value == NONE) {
          grow = _0;
          shrink = _0;
          basis = AUTO;
          break;
        }
      }

      final bool isValueVariableFunction = CSSFunction.isFunction(value, functionName: VAR);
      if (grow == null && (isValueVariableFunction || CSSNumber.isNumber(value))) {
        grow = value;
      } else if (shrink == null && (isValueVariableFunction || CSSNumber.isNumber(value))) {
        shrink = value;
      } else if (basis == null &&
          ((isValueVariableFunction ||
              CSSLength.isNonNegativeLength(value) ||
              CSSPercentage.isPercentage(value) ||
              value == AUTO))) {
        basis = value;
      } else {
        return null;
      }
    }
    if (basis == null && values.length <= 2) {
      basis = _0Percent;
    }

    return [grow ?? _1, shrink ?? _1, basis ?? _0];
  }

  static List<String?>? _getBorderValues(String shorthandProperty) {
    List<String> values = _splitBySpace(shorthandProperty);

    String? width;
    String? style;
    String? color;

    // NOTE: if one of token is wrong like `1pxxx solid red` that all should not work
    for (String value in values) {
      final bool isValueVariableFunction = CSSFunction.isFunction(value, functionName: VAR);
      if (width == null && (isValueVariableFunction || CSSBorderSide.isValidBorderWidthValue(value))) {
        width = value;
      } else if (style == null && (isValueVariableFunction || CSSBorderSide.isValidBorderStyleValue(value))) {
        style = value;
      } else if (color == null && (isValueVariableFunction || CSSColor.isColor(value))) {
        color = value;
      } else {
        return null;
      }
    }

    return [width, style, color];
  }

  static List<String?>? getEdgeValues(
    String shorthandProperty, {
    bool isLengthOrPercentage = false,
    bool isNonNegativeLengthOrPercentage = false,
    bool isNonNegativeLength = false,
  }) {
    List<String> properties = _splitBySpace(shorthandProperty);

    String? topValue;
    String? rightValue;
    String? bottomValue;
    String? leftValue;

    if (properties.length == 1) {
      topValue = rightValue = bottomValue = leftValue = properties[0];
    } else if (properties.length == 2) {
      topValue = bottomValue = properties[0];
      leftValue = rightValue = properties[1];
    } else if (properties.length == 3) {
      topValue = properties[0];
      rightValue = leftValue = properties[1];
      bottomValue = properties[2];
    } else if (properties.length == 4) {
      topValue = properties[0];
      rightValue = properties[1];
      bottomValue = properties[2];
      leftValue = properties[3];
    }

    if (topValue == null || rightValue == null || bottomValue == null || leftValue == null) {
      return null;
    }

    if (isLengthOrPercentage) {
      if ((!CSSLength.isLength(topValue) && !CSSPercentage.isPercentage(topValue) && !CSSFunction.isFunction(topValue)) ||
          (!CSSLength.isLength(rightValue) && !CSSPercentage.isPercentage(rightValue)  && !CSSFunction.isFunction(rightValue)) ||
          (!CSSLength.isLength(bottomValue) && !CSSPercentage.isPercentage(bottomValue) && !CSSFunction.isFunction(bottomValue)) ||
          (!CSSLength.isLength(leftValue) && !CSSPercentage.isPercentage(leftValue)) && !CSSFunction.isFunction(leftValue)) {
        return null;
      }
    } else if (isNonNegativeLengthOrPercentage) {
      if ((!CSSLength.isNonNegativeLength(topValue) && !CSSPercentage.isNonNegativePercentage(topValue) && !CSSFunction.isFunction(topValue)) ||
          (!CSSLength.isNonNegativeLength(rightValue) && !CSSPercentage.isNonNegativePercentage(rightValue) && !CSSFunction.isFunction(rightValue)) ||
          (!CSSLength.isNonNegativeLength(bottomValue) && !CSSPercentage.isNonNegativePercentage(bottomValue) && !CSSFunction.isFunction(bottomValue)) ||
          (!CSSLength.isNonNegativeLength(leftValue) && !CSSPercentage.isNonNegativePercentage(leftValue) && !CSSFunction.isFunction(leftValue))) {
        return null;
      }
    } else if (isNonNegativeLength) {
      if ((!CSSLength.isNonNegativeLength(topValue) && !CSSFunction.isFunction(topValue)) ||
          (!CSSLength.isNonNegativeLength(rightValue) && !CSSFunction.isFunction(rightValue)) ||
          (!CSSLength.isNonNegativeLength(bottomValue) && !CSSFunction.isFunction(bottomValue)) ||
          (!CSSLength.isNonNegativeLength(leftValue) && !CSSFunction.isFunction(leftValue))) {
        return null;
      }
    }

    // Assume the properties are in the usual order top, right, bottom, left.
    return [topValue, rightValue, bottomValue, leftValue];
  }

  // https://drafts.csswg.org/css-values-4/#typedef-position
  static List<String?> getPositionValues(String shorthandProperty) {
    List<String> properties = _splitBySpace(shorthandProperty.trim());

    String? x;
    String? y;
    if (properties.length == 1) {
      x = y = properties[0];
    } else if (properties.length == 2) {
      x = properties[0];
      y = properties[1];
    }

    return [x, y];
  }

  static List<String?>? _getAnimationValues(String shorthandProperty) {
    List<String> animations = shorthandProperty.split(_commaRegExp);
    List<String?> values = List.filled(8, null);

    for (String animation in animations) {
      List<String> parts = _splitBySpace(animation.trim());

      String? duration;
      String? timingFunction;
      String? delay;
      String? iterationCount;
      String? direction;
      String? fillMode;
      String? playState;
      String? name;

      for (String part in parts) {
        if (duration == null && CSSTime.isTime(part)) {
          duration = part;
        } else if (timingFunction == null && CSSAnimationMixin.isValidTransitionTimingFunctionValue(part)) {
          timingFunction = part;
        } else if (delay == null && CSSTime.isTime(part)) {
          delay = part;
        } else if (iterationCount == null && (CSSNumber.isNumber(part) || part == 'infinite')) {
          iterationCount = part;
        } else if (direction == null && CSSAnimationMixin.isValidAnimationDirectionValue(part)) {
          direction = part;
        } else if (fillMode == null && CSSAnimationMixin.isValidAnimationFillModeValue(part)) {
          fillMode = part;
        } else if (playState == null && CSSAnimationMixin.isValidAnimationPlayStateValue(part)) {
          playState = part;
        } else if (name == null && CSSAnimationMixin.isValidAnimationNameValue(part)) {
          name = part;
        } else {
          continue;
          // return null;
        }
      }

      duration = duration ?? _0s;
      timingFunction = timingFunction ?? EASE;
      delay = delay ?? _0s;
      iterationCount = iterationCount ?? _1;
      direction = direction ?? NORMAL;
      fillMode = fillMode ?? NONE;
      playState = playState ?? RUNNING;
      name = name ?? NONE;

      values[0] == null ? values[0] = duration : values[0] = values[0]! + (_comma + duration);
      values[1] == null ? values[1] = timingFunction : values[1] = values[1]! + (_comma + timingFunction);
      values[2] == null ? values[2] = delay : values[2] = values[2]! + (_comma + delay);
      values[3] == null ? values[3] = iterationCount : values[3] = values[3]! + (_comma + iterationCount);
      values[4] == null ? values[4] = direction : values[4] = values[4]! + (_comma + direction);
      values[5] == null ? values[5] = fillMode : values[5] = values[5]! + (_comma + fillMode);
      values[6] == null ? values[6] = playState : values[6] = values[6]! + (_comma + playState);
      values[7] == null ? values[7] = name : values[7] = values[7]! + (_comma + name);
    }

    return values;
  }

  static void setShorthandGap(Map<String, String?> properties, String shorthandValue) {
    List<String> values = _splitBySpace(shorthandValue);
    if (values.length == 1) {
      // gap: 20px -> row-gap: 20px, column-gap: 20px
      properties[ROW_GAP] = values[0];
      properties[COLUMN_GAP] = values[0];
    } else if (values.length == 2) {
      // gap: 20px 10px -> row-gap: 20px, column-gap: 10px
      properties[ROW_GAP] = values[0];
      properties[COLUMN_GAP] = values[1];
    }
  }

  static void removeShorthandGap(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(ROW_GAP)) style.removeProperty(ROW_GAP, isImportant);
    if (style.contains(COLUMN_GAP)) style.removeProperty(COLUMN_GAP, isImportant);
  }

  static void setShorthandGridRow(Map<String, String?> properties, String shorthandValue) {
    List<String> parts = shorthandValue.split(_slashRegExp);
    String start = parts.isNotEmpty ? parts[0].trim() : '';
    String end = parts.length > 1 ? parts[1].trim() : '';

    if (start.isEmpty) start = 'auto';
    if (end.isEmpty) end = 'auto';

    properties[GRID_ROW_START] = start;
    properties[GRID_ROW_END] = end;
  }

  static void removeShorthandGridRow(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(GRID_ROW_START)) style.removeProperty(GRID_ROW_START, isImportant);
    if (style.contains(GRID_ROW_END)) style.removeProperty(GRID_ROW_END, isImportant);
  }

  static void setShorthandGridColumn(Map<String, String?> properties, String shorthandValue) {
    List<String> parts = shorthandValue.split(_slashRegExp);
    String start = parts.isNotEmpty ? parts[0].trim() : '';
    String end = parts.length > 1 ? parts[1].trim() : '';

    if (start.isEmpty) start = 'auto';
    if (end.isEmpty) end = 'auto';

    properties[GRID_COLUMN_START] = start;
    properties[GRID_COLUMN_END] = end;
  }

  static void removeShorthandGridColumn(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(GRID_COLUMN_START)) style.removeProperty(GRID_COLUMN_START, isImportant);
    if (style.contains(GRID_COLUMN_END)) style.removeProperty(GRID_COLUMN_END, isImportant);
  }

  static void setShorthandGridArea(Map<String, String?> properties, String shorthandValue) {
    List<String> parts = shorthandValue.split(_slashRegExp);

    String rowStart = parts.isNotEmpty ? parts[0].trim() : '';
    String columnStart = parts.length > 1 ? parts[1].trim() : '';
    String rowEnd = parts.length > 2 ? parts[2].trim() : '';
    String columnEnd = parts.length > 3 ? parts[3].trim() : '';

    String normalize(String value) => value.isEmpty ? 'auto' : value;

    properties[GRID_ROW_START] = normalize(rowStart);
    properties[GRID_COLUMN_START] = normalize(columnStart);
    properties[GRID_ROW_END] = normalize(rowEnd);
    properties[GRID_COLUMN_END] = normalize(columnEnd);
    final String trimmed = shorthandValue.trim();
    final bool hasSingleToken = parts.length <= 1;
    if (hasSingleToken && CSSGridParser.isCustomIdent(trimmed)) {
      properties[GRID_AREA_INTERNAL] = trimmed;
    } else {
      properties[GRID_AREA_INTERNAL] = 'auto';
    }
  }

  static void removeShorthandGridArea(CSSStyleDeclaration style, [bool? isImportant]) {
    removeShorthandGridRow(style, isImportant);
    removeShorthandGridColumn(style, isImportant);
    if (style.contains(GRID_AREA_INTERNAL)) {
      style.removeProperty(GRID_AREA_INTERNAL, isImportant);
    }
  }

  /// CSS Grid Level 1 `grid-template` shorthand (partial support).
  ///
  /// Currently supported patterns:
  ///   - `grid-template: none`
  ///   - `grid-template: <'grid-template-rows'> / <'grid-template-columns'>`
  ///   - `grid-template: <template-areas> / <'grid-template-columns'>`
  ///
  /// More advanced track sizing forms (row track sizes following area strings,
  /// subgrid keywords, etc.) are intentionally ignored for now.
  static void setShorthandGridTemplate(Map<String, String?> properties, String shorthandValue) {
    String value = shorthandValue.trim();
    if (value.isEmpty) return;

    final String lower = value.toLowerCase();
    if (lower == 'none') {
      properties[GRID_TEMPLATE_ROWS] = 'none';
      properties[GRID_TEMPLATE_COLUMNS] = 'none';
      properties[GRID_TEMPLATE_AREAS] = 'none';
      return;
    }

    // Template-areas form: one or more quoted rows, optionally followed by
    // `/ <track-list>` for columns. We:
    //   - extract the contiguous quoted region to feed grid-template-areas
    //   - treat the trailing `/ ...` as grid-template-columns when present.
    if (value.contains('"') || value.contains('\'')) {
      // Extract area strings between first and last quote to keep cssText compact.
      final int firstQuote = value.contains('"') ? value.indexOf('"') : value.indexOf('\'');
      final int lastQuote = value.lastIndexOf('"') != -1 ? value.lastIndexOf('"') : value.lastIndexOf('\'');
      if (firstQuote != -1 && lastQuote > firstQuote) {
        final String areasText = value.substring(firstQuote, lastQuote + 1).trim();
        if (areasText.isNotEmpty) {
          properties[GRID_TEMPLATE_AREAS] = areasText;
        }
      }

      final int slashIndex = value.indexOf('/');
      if (slashIndex != -1 && slashIndex + 1 < value.length) {
        final String cols = value.substring(slashIndex + 1).trim();
        if (cols.isNotEmpty) {
          properties[GRID_TEMPLATE_COLUMNS] = cols;
        }
      }
      return;
    }

    // Basic rows/columns form: grid-template: <rows> / <columns>
    final List<String> parts = value.split(_slashRegExp);
    if (parts.length == 2) {
      final String rows = parts[0].trim();
      final String cols = parts[1].trim();
      if (rows.isNotEmpty) {
        properties[GRID_TEMPLATE_ROWS] = rows;
      }
      if (cols.isNotEmpty) {
        properties[GRID_TEMPLATE_COLUMNS] = cols;
      }
    }
  }

  static void removeShorthandGridTemplate(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(GRID_TEMPLATE_ROWS)) style.removeProperty(GRID_TEMPLATE_ROWS, isImportant);
    if (style.contains(GRID_TEMPLATE_COLUMNS)) style.removeProperty(GRID_TEMPLATE_COLUMNS, isImportant);
    if (style.contains(GRID_TEMPLATE_AREAS)) style.removeProperty(GRID_TEMPLATE_AREAS, isImportant);
  }

  /// CSS Grid Level 1 `grid` shorthand (partial support).
  ///
  /// Currently supported patterns:
  ///   - `grid: none`
  ///   - `grid: <'grid-template-rows'> / <'grid-template-columns'>`
  ///   - `grid: auto-flow <'grid-auto-rows'>? / <'grid-template-columns'>`
  ///   - `grid: <'grid-template-rows'> / auto-flow <'grid-auto-columns'>?`
  ///
  /// Complex forms that include template area strings or auto-placement
  /// keywords (e.g. auto-flow branches) are intentionally ignored for now
  /// so that invalid/unsupported shorthands do not corrupt longhands.
  static void setShorthandGrid(Map<String, String?> properties, String shorthandValue) {
    String value = shorthandValue.trim();
    if (value.isEmpty) return;

    final String lower = value.toLowerCase();

    // `grid: none` resets the template and auto tracks to their initial values.
    if (lower == 'none') {
      properties[GRID_TEMPLATE_ROWS] = 'none';
      properties[GRID_TEMPLATE_COLUMNS] = 'none';
      properties[GRID_TEMPLATE_AREAS] = 'none';
      properties[GRID_AUTO_ROWS] = 'auto';
      properties[GRID_AUTO_COLUMNS] = 'auto';
      properties[GRID_AUTO_FLOW] = 'row';
      return;
    }

    // Ignore area-string based syntaxes (e.g. `"a a" "b c" / 1fr 1fr"`) for now.
    // These are covered by explicit longhands (`grid-template-areas`, etc.).
    if (value.contains('"') || value.contains('\'')) {
      return;
    }

    final List<String> parts = value.split(_slashRegExp);
    if (parts.length == 2) {
      final String before = parts[0].trim();
      final String after = parts[1].trim();
      if (before.isEmpty && after.isEmpty) return;

      final List<String> beforeTokens = _splitBySpace(before);
      final List<String> afterTokens = _splitBySpace(after);

      final bool beforeStartsAutoFlow = beforeTokens.isNotEmpty && beforeTokens[0] == 'auto-flow';
      final bool afterStartsAutoFlow = afterTokens.isNotEmpty && afterTokens[0] == 'auto-flow';

      // Form 1: grid: auto-flow <rows>? / <template-columns>
      if (beforeStartsAutoFlow && !afterStartsAutoFlow) {
        final bool dense = beforeTokens.contains('dense');
        String autoFlow = 'row';
        if (dense) autoFlow = 'row dense';
        properties[GRID_AUTO_FLOW] = autoFlow;

        // First non-keyword token becomes grid-auto-rows, if present.
        for (final String token in beforeTokens) {
          if (token == 'auto-flow' || token == 'dense') continue;
          properties[GRID_AUTO_ROWS] = token;
          break;
        }

        if (after.isNotEmpty) {
          properties[GRID_TEMPLATE_COLUMNS] = after;
        }
        properties[GRID_TEMPLATE_ROWS] = 'none';
        properties[GRID_TEMPLATE_AREAS] = 'none';
        return;
      }

      // Form 2: grid: <template-rows> / auto-flow <columns>?
      if (!beforeStartsAutoFlow && afterStartsAutoFlow) {
        if (before.isNotEmpty) {
          properties[GRID_TEMPLATE_ROWS] = before;
        }

        final bool dense = afterTokens.contains('dense');
        String autoFlow = 'column';
        if (dense) autoFlow = 'column dense';
        properties[GRID_AUTO_FLOW] = autoFlow;

        // First non-keyword token becomes grid-auto-columns, if present.
        for (final String token in afterTokens) {
          if (token == 'auto-flow' || token == 'dense') continue;
          properties[GRID_AUTO_COLUMNS] = token;
          break;
        }

        properties[GRID_TEMPLATE_COLUMNS] = 'none';
        properties[GRID_TEMPLATE_AREAS] = 'none';
        return;
      }

      // Basic template rows/columns form: grid: <rows> / <columns>
      if (before.isNotEmpty) {
        properties[GRID_TEMPLATE_ROWS] = before;
      }
      if (after.isNotEmpty) {
        properties[GRID_TEMPLATE_COLUMNS] = after;
      }
    }
  }

  static void removeShorthandGrid(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(GRID_TEMPLATE_ROWS)) style.removeProperty(GRID_TEMPLATE_ROWS, isImportant);
    if (style.contains(GRID_TEMPLATE_COLUMNS)) style.removeProperty(GRID_TEMPLATE_COLUMNS, isImportant);
    if (style.contains(GRID_TEMPLATE_AREAS)) style.removeProperty(GRID_TEMPLATE_AREAS, isImportant);
    if (style.contains(GRID_AUTO_ROWS)) style.removeProperty(GRID_AUTO_ROWS, isImportant);
    if (style.contains(GRID_AUTO_COLUMNS)) style.removeProperty(GRID_AUTO_COLUMNS, isImportant);
    if (style.contains(GRID_AUTO_FLOW)) style.removeProperty(GRID_AUTO_FLOW, isImportant);
  }

  static void setShorthandAnimation(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getAnimationValues(shorthandValue);
    if (values == null) return;

    properties[ANIMATION_DURATION] = values[0]?.toLowerCase();
    properties[ANIMATION_TIMING_FUNCTION] = values[1]?.toLowerCase();
    properties[ANIMATION_DELAY] = values[2]?.toLowerCase();
    properties[ANIMATION_ITERATION_COUNT] = values[3]?.toLowerCase();
    properties[ANIMATION_DIRECTION] = values[4]?.toLowerCase();
    properties[ANIMATION_FILL_MODE] = values[5]?.toLowerCase();
    properties[ANIMATION_PLAY_STATE] = values[6]?.toLowerCase();
    properties[ANIMATION_NAME] = values[7];
  }

  static void setShorthandPlaceContent(Map<String, String?> properties, String shorthandValue) {
    shorthandValue = shorthandValue.replaceAll(_slashRegExp, ' ');
    final List<String> values = _splitBySpace(shorthandValue);
    if (values.isEmpty) return;

    final String align = values[0];
    final String justify = values.length > 1 ? values[1] : align;

    properties[ALIGN_CONTENT] = align;
    properties[JUSTIFY_CONTENT] = justify;
  }

  static void removeShorthandPlaceContent(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(ALIGN_CONTENT)) style.removeProperty(ALIGN_CONTENT, isImportant);
    if (style.contains(JUSTIFY_CONTENT)) style.removeProperty(JUSTIFY_CONTENT, isImportant);
  }

  // place-items shorthand
  // Spec: place-items: <'align-items'> [ / <'justify-items'> ]?
  static void setShorthandPlaceItems(Map<String, String?> properties, String shorthandValue) {
    final ({String align, String justify})? axes = _parsePlaceShorthandAxes(shorthandValue);
    if (axes == null) return;
    properties[ALIGN_ITEMS] = axes.align;
    properties[JUSTIFY_ITEMS] = axes.justify;
  }

  static void removeShorthandPlaceItems(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(ALIGN_ITEMS)) style.removeProperty(ALIGN_ITEMS, isImportant);
    if (style.contains(JUSTIFY_ITEMS)) style.removeProperty(JUSTIFY_ITEMS, isImportant);
  }

  static void setShorthandPlaceSelf(Map<String, String?> properties, String shorthandValue) {
    final ({String align, String justify})? axes = _parsePlaceShorthandAxes(shorthandValue);
    if (axes == null) return;
    properties[ALIGN_SELF] = axes.align;
    properties[JUSTIFY_SELF] = axes.justify;
  }

  static void removeShorthandPlaceSelf(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(ALIGN_SELF)) style.removeProperty(ALIGN_SELF, isImportant);
    if (style.contains(JUSTIFY_SELF)) style.removeProperty(JUSTIFY_SELF, isImportant);
  }
}

({String align, String justify})? _parsePlaceShorthandAxes(String shorthandValue) {
  final String trimmed = shorthandValue.trim();
  if (trimmed.isEmpty) return null;

  final List<String> slashParts = trimmed
      .split(_slashRegExp)
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (slashParts.length >= 2) {
    return (align: slashParts[0], justify: slashParts[1]);
  }

  final List<String> tokens = _splitBySpace(trimmed)
      .map((token) => token.trim())
      .where((token) => token.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return null;

  ({String value, int next}) parseAxisValue(int start) {
    if (start >= tokens.length) return (value: '', next: start);
    final String first = tokens[start];
    final String lower = first.toLowerCase();

    if (start + 1 < tokens.length) {
      final String second = tokens[start + 1];
      final String lowerSecond = second.toLowerCase();

      if ((lower == 'first' || lower == 'last') && lowerSecond == 'baseline') {
        return (value: '$first $second', next: start + 2);
      }
      if ((lower == 'safe' || lower == 'unsafe')) {
        return (value: '$first $second', next: start + 2);
      }
    }

    return (value: first, next: start + 1);
  }

  final ({String value, int next}) first = parseAxisValue(0);
  String align = first.value;
  int index = first.next;

  String justify = align;
  if (index < tokens.length) {
    final ({String value, int next}) second = parseAxisValue(index);
    justify = second.value;
    index = second.next;
    if (index < tokens.length) {
      justify = (<String>[justify, ...tokens.sublist(index)]).join(' ');
    }
  }

  return (align: align, justify: justify);
}
