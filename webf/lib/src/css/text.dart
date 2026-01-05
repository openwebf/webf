/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';

final RegExp _commaRegExp = RegExp(r'\s*,\s*');

typedef TextPainterCallback = Paint? Function(Rect bounds);

class _FontFeatureSupportKey {
  final String primaryFamily;
  final int weightIndex;
  final FontStyle fontStyle;
  final String tag;

  const _FontFeatureSupportKey({
    required this.primaryFamily,
    required this.weightIndex,
    required this.fontStyle,
    required this.tag,
  });

  @override
  bool operator ==(Object other) {
    return other is _FontFeatureSupportKey &&
        other.primaryFamily == primaryFamily &&
        other.weightIndex == weightIndex &&
        other.fontStyle == fontStyle &&
        other.tag == tag;
  }

  @override
  int get hashCode => Object.hash(primaryFamily, weightIndex, fontStyle, tag);
}

enum FontVariantCapsSynthesis {
  none,
  lowercaseOnly,
  allLetters,
}

// CSS Text: https://drafts.csswg.org/css-text-3/
// CSS Text Decoration: https://drafts.csswg.org/css-text-decor-3/
// CSS Box Alignment: https://drafts.csswg.org/css-align/
mixin CSSTextMixin on RenderStyle {
  static FontWeight _effectiveFontWeight(CSSRenderStyle renderStyle) {
    final FontWeight base = renderStyle.fontWeight;
    if (!renderStyle.boldText) return base;
    // Match Flutter's "boldText" accessibility behavior by forcing at least bold.
    return base.index < FontWeight.w700.index ? FontWeight.w700 : base;
  }

  bool get hasColor => _color != null;

  @override
  CSSColor get currentColor => color;

  Color? _color;

  @override
  CSSColor get color {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_color == null && parent != null) {
      return parent!.color;
    }

    // The root element has no color, and the color is initial.
    return CSSColor(_color ?? CSSColor.initial);
  }

  set color(CSSColor? value) {
    if (_color == value?.value) return;
    _color = value?.value;

    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, COLOR);
  }

  // Current not update the dependent property relative to the color.
  final Map<String, bool> _colorRelativeProperties = {};

  @override
  void addColorRelativeProperty(String propertyName) {
    _colorRelativeProperties[propertyName] = true;
  }

  void updateColorRelativeProperty() {
    if (_colorRelativeProperties.isEmpty) return;
    _colorRelativeProperties.forEach((String propertyName, _) {
      // TODO: use css color abstraction avoid re-parse the property string.
      target.setRenderStyle(propertyName, target.style.getPropertyValue(propertyName));
    });
  }

  TextDecoration? _textDecorationLine;

  TextDecoration get textDecorationLine => _textDecorationLine ?? TextDecoration.none;

  set textDecorationLine(TextDecoration? value) {
    if (_textDecorationLine == value) return;
    _textDecorationLine = value;
    // Non inheritable style change should only update text node in direct children.
    markNeedsLayout();
  }

  CSSColor? _textDecorationColor;

  // Per CSS Text Decoration spec, the initial value of text-decoration-color
  // is currentColor. If not explicitly specified on the element, use the
  // element's currentColor so decorations have a visible color by default
  // (instead of falling back to null/engine-defaults).
  CSSColor? get textDecorationColor {
    return _textDecorationColor ?? currentColor;
  }

  set textDecorationColor(CSSColor? value) {
    if (_textDecorationColor == value) return;
    _textDecorationColor = value;
    // Non inheritable style change should only update text node in direct children.
    _markTextNeedsLayout();
  }

  TextDecorationStyle? _textDecorationStyle;

  TextDecorationStyle? get textDecorationStyle {
    return _textDecorationStyle;
  }

  set textDecorationStyle(TextDecorationStyle? value) {
    if (_textDecorationStyle == value) return;
    _textDecorationStyle = value;
    // Non inheritable style change should only update text node in direct children.
    _markTextNeedsLayout();
  }

  FontWeight? _fontWeight;

  @override
  FontWeight get fontWeight {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_fontWeight == null && parent != null) {
      return parent!.fontWeight;
    }

    // The root element has no fontWeight, and the fontWeight is initial.
    return _fontWeight ?? FontWeight.w400;
  }

  set fontWeight(FontWeight? value) {
    if (_fontWeight == value) return;
    _fontWeight = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, FONT_WEIGHT);
  }

  FontStyle? _fontStyle;

  @override
  FontStyle get fontStyle {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_fontStyle == null && parent != null) {
      return parent!.fontStyle;
    }

    // The root element has no fontWeight, and the fontWeight is initial.
    return _fontStyle ?? FontStyle.normal;
  }

  set fontStyle(FontStyle? value) {
    if (_fontStyle == value) return;
    _fontStyle = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, FONT_STYLE);
  }

  String? _fontVariant;

  @override
  String get fontVariant {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_fontVariant == null && parent != null) {
      return parent!.fontVariant;
    }

    return _fontVariant ?? NORMAL;
  }

  set fontVariant(String? value) {
    if (_fontVariant == value) return;
    _fontVariant = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, FONT_VARIANT);
  }

  List<String>? _fontFamily;

  @override
  List<String>? get fontFamily {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_fontFamily == null && parent != null) {
      return parent!.fontFamily;
    }
    return _fontFamily ?? CSSText.defaultFontFamilyFallback;
  }

  set fontFamily(List<String>? value) {
    if (_fontFamily == value) return;
    _fontFamily = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, FONT_FAMILY);
  }

  bool get hasFontSize => _fontSize != null;

  CSSLengthValue? _fontSize;

  @override
  CSSLengthValue get fontSize {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_fontSize == null && parent != null) {
      return parent!.fontSize;
    }
    return _fontSize ?? CSSText.defaultFontSize;
  }

  // Update font-size may affect following style:
  // 1. Nested children text size due to style inheritance.
  // 2. Em unit: style of own element with em unit and nested children with no font-size set due to style inheritance.
  // 3. Rem unit: nested children with rem set.
  set fontSize(CSSLengthValue? value) {
    if (_fontSize == value) return;
    _fontSize = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, FONT_SIZE);
  }

  // Current not update the dependent property relative to the font-size.
  final Map<String, bool> _fontRelativeProperties = {};
  final Map<String, bool> _rootFontRelativeProperties = {};

  @override
  void addFontRelativeProperty(String propertyName) {
    _fontRelativeProperties[propertyName] = true;
  }

  void updateFontRelativeLength() {
    if (_fontRelativeProperties.isEmpty) return;
    markNeedsLayout();
    if (isSelfBoxModelSizeTight()) {
      markParentNeedsLayout();
    }
  }

  @override
  void addRootFontRelativeProperty(String propertyName) {
    _rootFontRelativeProperties[propertyName] = true;
  }

  void updateRootFontRelativeLength() {
    if (_rootFontRelativeProperties.isEmpty) return;
    markNeedsLayout();
    if (isSelfBoxModelSizeTight()) {
      markParentNeedsLayout();
    }
  }

  CSSLengthValue? _lineHeight;

  @override
  CSSLengthValue get lineHeight {
    if (_lineHeight == null && parent != null) {
      // Inherit from parent. For percentage-specified line-height, freeze to the
      // parent’s used value (absolute px) so nested elements don’t amplify spacing
      // when their font-size differs. Unitless numbers (EM here) continue to inherit
      // as a multiplier to match CSS behavior.
      final CSSLengthValue parentLengthValue = parent!.lineHeight;
      if (parentLengthValue.type == CSSLengthType.PERCENTAGE) {
        // Resolve percentage against the parent’s own font-size, then inherit as px.
        final double usedPx = parentLengthValue.computedValue;
        return CSSLengthValue(
            usedPx, CSSLengthType.PX, this, parentLengthValue.propertyName, parentLengthValue.axisType);
      }
      return CSSLengthValue(parentLengthValue.value, parentLengthValue.type, this, parentLengthValue.propertyName,
          parentLengthValue.axisType);
    }

    return _lineHeight ?? CSSText.defaultLineHeight;
  }

  set lineHeight(CSSLengthValue? value) {
    if (_lineHeight == value) return;
    _lineHeight = value;
    // Update all the children layout and text with specified style property not set due to style inheritance.
    _markNestChildrenTextAndLayoutNeedsLayout(this, LINE_HEIGHT);
  }

  CSSLengthValue? _letterSpacing;

  @override
  CSSLengthValue? get letterSpacing {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_letterSpacing == null && parent != null) {
      return parent!.letterSpacing;
    }
    return _letterSpacing;
  }

  set letterSpacing(CSSLengthValue? value) {
    if (_letterSpacing == value) return;
    _letterSpacing = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, LETTER_SPACING);
  }

  CSSLengthValue? _wordSpacing;

  @override
  CSSLengthValue? get wordSpacing {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_wordSpacing == null && parent != null) {
      return parent!.wordSpacing;
    }
    return _wordSpacing;
  }

  set wordSpacing(CSSLengthValue? value) {
    if (_wordSpacing == value) return;
    _wordSpacing = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, WORD_SPACING);
  }

  // text-indent (inherited)
  CSSLengthValue? _textIndent;

  CSSLengthValue get textIndent {
    if (_textIndent == null && parent != null) {
      return (parent as CSSRenderStyle).textIndent;
    }
    return _textIndent ?? CSSLengthValue.zero;
  }

  set textIndent(CSSLengthValue? value) {
    if (_textIndent == value) return;
    _textIndent = value;
    _markChildrenTextNeedsLayout(this, TEXT_INDENT);
  }

  List<Shadow>? _textShadow;

  @override
  List<Shadow>? get textShadow {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_textShadow == null && parent != null) {
      return parent!.textShadow;
    }
    return _textShadow;
  }

  // text-transform (inherited)
  TextTransform? _textTransform;

  TextTransform get textTransform {
    if (_textTransform == null && parent != null) {
      return (parent as CSSRenderStyle).textTransform;
    }
    return _textTransform ?? TextTransform.none;
  }

  set textTransform(TextTransform? value) {
    if (_textTransform == value) return;
    _textTransform = value;
    // Inherited: update descendants’ text layout
    _markChildrenTextNeedsLayout(this, TEXT_TRANSFORM);
  }

  set textShadow(List<Shadow>? value) {
    if (_textShadow == value) return;
    _textShadow = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, TEXT_SHADOW);
  }

  // word-break (inherited)
  WordBreak? _wordBreak;

  @override
  WordBreak get wordBreak {
    if (_wordBreak == null && parent != null) {
      return parent!.wordBreak;
    }
    return _wordBreak ?? WordBreak.normal;
  }

  set wordBreak(WordBreak? value) {
    if (_wordBreak == value) return;
    _wordBreak = value;
    // Text-related inherited property affects text layout of descendants
    _markChildrenTextNeedsLayout(this, 'wordBreak');
  }

  WhiteSpace? _whiteSpace;

  @override
  WhiteSpace get whiteSpace {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_whiteSpace == null && parent != null) {
      return parent!.whiteSpace;
    }
    return _whiteSpace ?? WhiteSpace.normal;
  }

  set whiteSpace(WhiteSpace? value) {
    if (_whiteSpace == value) return;
    _whiteSpace = value;
    // Update all the children layout and text with specified style property not set due to style inheritance.
    _markNestChildrenTextAndLayoutNeedsLayout(this, WHITE_SPACE);
  }

  TextOverflow _textOverflow = TextOverflow.clip;

  @override
  TextOverflow get textOverflow {
    return _textOverflow;
  }

  set textOverflow(TextOverflow? value) {
    if (_textOverflow == value) return;
    _textOverflow = value ?? TextOverflow.clip;
    // Non inheritable style change should only update text node in direct children.
    _markTextNeedsLayout();
  }

  // text-overflow is affect by the value of line-clamp,overflow and white-space styles,
  // get the real working style of text-overflow after other style is set.
  TextOverflow get effectiveTextOverflow {
    // Set line-clamp to number makes text-overflow ellipsis which takes priority over text-overflow style.
    if (lineClamp != null && lineClamp! > 0) {
      return TextOverflow.ellipsis;
    }

    // text-overflow only works when overflow is not visible and white-space is nowrap.
    if (effectiveOverflowX == CSSOverflowType.visible || whiteSpace != WhiteSpace.nowrap) {
      // TextOverflow.visible value does not exist in CSS spec, use it to specify the case
      // when text overflow its container and not clipped.
      return TextOverflow.visible;
    }

    return textOverflow;
  }

  int? _lineClamp;

  @override
  int? get lineClamp {
    return _lineClamp;
  }

  set lineClamp(int? value) {
    if (_lineClamp == value) return;
    _lineClamp = value;
    // Non inheritable style change should only update text node in direct children.
    _markTextNeedsLayout();
  }

  TextAlign? _textAlign;

  @override
  TextAlign get textAlign {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_textAlign == null && getAttachedRenderParentRenderStyle() != null) {
      return getAttachedRenderParentRenderStyle()!.textAlign;
    }
    return _textAlign ?? TextAlign.start;
  }

  set textAlign(TextAlign? value) {
    if (_textAlign == value) return;
    _textAlign = value;
    // Update all the children flow layout with specified style property not set due to style inheritance.
    _markNestFlowLayoutNeedsLayout(this, TEXT_ALIGN);
  }

  TextDirection? _direction;

  @override
  TextDirection get direction {
    // CSS 'direction' is inherited via the DOM parent chain. For out-of-flow
    // render reparenting (e.g., positioned elements), prefer the DOM parent’s
    // renderStyle over the render tree parent to ensure correct inheritance.
    if (_direction != null) return _direction!;
    final dom.Element? domParent = target.parentElement;
    if (domParent != null) {
      return domParent.renderStyle.direction;
    }
    // Fallback to render parent when DOM parent is unavailable (e.g., root).
    final RenderStyle? renderParent = parent;
    if (renderParent != null) return renderParent.direction;
    return TextDirection.ltr;
  }

  set direction(TextDirection? value) {
    if (_direction == value) return;
    _direction = value;
    // Update all the children text and flow layout with specified style property not set due to style inheritance.
    _markNestChildrenTextAndLayoutNeedsLayout(this, DIRECTION);
  }

  double? _tabSize;

  double get tabSize {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_tabSize == null && parent != null) {
      if (parent is CSSTextMixin) {
        return (parent as CSSRenderStyle).tabSize;
      }
    }
    // Default tab size is 8 space characters
    return _tabSize ?? 8.0;
  }

  set tabSize(double? value) {
    if (_tabSize == value) return;
    _tabSize = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenTextNeedsLayout(this, TAB_SIZE);
  }

  // Mark flow layout and all the children flow layout with specified style property not set needs layout.
  void _markNestFlowLayoutNeedsLayout(RenderStyle renderStyle, String styleProperty) {
    if (renderStyle.isSelfRenderFlowLayout()) {
      renderStyle.markNeedsLayout();
      visitor(RenderObject child) {
        if (child is RenderFlowLayout && child is! RenderEventListener) {
          // Only need to layout when the specified style property is not set.
          if (child.renderStyle.target.style[styleProperty].isEmpty) {
            _markNestFlowLayoutNeedsLayout(child.renderStyle, styleProperty);
          }
        } else {
          child.visitChildren(visitor);
        }
      }

      renderStyle.visitChildren(visitor);
    }
  }

  // Mark all nested layout and text children as needs layout when properties that will affect both
  // text and layout (line-height, white-space) changes.
  void _markNestChildrenTextAndLayoutNeedsLayout(RenderStyle renderStyle, String styleProperty) {
    if (renderStyle.isSelfRenderLayoutBox()) {
      renderStyle.markNeedsLayout();

      visitor(RenderObject child) {
        if (child is RenderLayoutBox && child is! RenderEventListener) {
          // Only need to layout when the specified style property is not set.
          if (child.renderStyle.target.style[styleProperty].isEmpty) {
            _markNestChildrenTextAndLayoutNeedsLayout(child.renderStyle, styleProperty);
          }
        } else {
          child.visitChildren(visitor);
        }
      }

      renderStyle.visitChildren(visitor);
    }
  }

  // Mark direct children text as needs layout.
  // None inheritable style change should only loop direct children to update text node with specified
  // style property not set in its parent.
  void _markTextNeedsLayout() {
    visitor(RenderObject child) {
      if (child is RenderTextBox) {
        child.renderStyle.markNeedsLayout();
      } else {
        child.visitChildren(visitor);
      }
    }

    visitChildren(visitor);
  }

  // Mark nested children text as needs layout.
  // Inheritable style change should loop nest children to update text node with specified style property
  // not set in its parent.
  void _markChildrenTextNeedsLayout(RenderStyle renderStyle, String styleProperty) {
    visitor(dom.Node child) {
      if (child is dom.TextNode) {
        child.parentElement!.attachedRenderer?.markNeedsLayout();
      }

      if (child is dom.Element && child.style[styleProperty].isEmpty) {
        child.visitChildren(visitor);
      }
    }

    renderStyle.target.visitChildren(visitor);
  }

  static TextAlign? resolveTextAlign(String value) {
    // CSS mapping: left/right are physical; start/end are logical.
    switch (value) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'start':
        return TextAlign.start;
      case 'end':
        return TextAlign.end;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

  static TextDirection? resolveDirection(String value) {
    switch (value) {
      case 'rtl':
        return TextDirection.rtl;
      case 'ltr':
        return TextDirection.ltr;
      default:
        return null;
    }
  }

  static TextStyle createTextStyle(CSSRenderStyle renderStyle, {double? height, Color? color}) {
    // Creates a new TextStyle object.
    //   color: The color to use when painting the text. If this is specified, foreground must be null.
    //   decoration: The decorations to paint near the text (e.g., an underline).
    //   decorationColor: The color in which to paint the text decorations.
    //   decorationStyle: The style in which to paint the text decorations (e.g., dashed).
    //   fontWeight: The typeface thickness to use when painting the text (e.g., bold).
    //   fontStyle: The typeface variant to use when drawing the letters (e.g., italics).
    //   fontSize: The size of glyphs (in logical pixels) to use when painting the text.
    //   letterSpacing: The amount of space (in logical pixels) to add between each letter.
    //   wordSpacing: The amount of space (in logical pixels) to add at each sequence of white-space (i.e. between /// each word).
    //   textBaseline: The common baseline that should be aligned between this text span and its parent text span, /// or, for the root text spans, with the line box.
    //   height: The height of this text span, as a multiple of the font size.
    //   locale: The locale used to select region-specific glyphs.
    //   background: The paint drawn as a background for the text.
    //   foreground: The paint used to draw the text. If this is specified, color must be null.
    // Respect visibility:hidden: do not paint text or its decorations but keep layout.
    final bool hidden = renderStyle.isVisibilityHidden;
    final Color? effectiveColor = hidden
        ? const Color(0x00000000)
        : (renderStyle.backgroundClip != CSSBackgroundBoundary.text ? color ?? renderStyle.color.value : null);

    final variant = CSSText.resolveFontFeaturesForVariant(renderStyle);
    final FontWeight effectiveFontWeight = _effectiveFontWeight(renderStyle);
    final double nonNegativeFontSize = math.max(0.0, renderStyle.fontSize.computedValue);
    TextStyle textStyle = TextStyle(
        color: effectiveColor,
        decoration: hidden ? TextDecoration.none : renderStyle.textDecorationLine,
        decorationColor: hidden ? const Color(0x00000000) : renderStyle.textDecorationColor?.value,
        decorationStyle: renderStyle.textDecorationStyle,
        fontWeight: effectiveFontWeight,
        fontStyle: renderStyle.fontStyle,
        fontFeatures: variant.features.isNotEmpty ? variant.features : null,
        fontFamily: (renderStyle.fontFamily != null && renderStyle.fontFamily!.isNotEmpty)
            ? renderStyle.fontFamily!.first
            : null,
        fontFamilyFallback: renderStyle.fontFamily,
        fontSize: nonNegativeFontSize,
        letterSpacing: renderStyle.letterSpacing?.computedValue,
        wordSpacing: renderStyle.wordSpacing?.computedValue,
        shadows: renderStyle.textShadow,
        textBaseline: CSSText.getTextBaseLine(),
        package: CSSText.getFontPackage(),
        locale: CSSText.getLocale(),
        background: CSSText.getBackground(),
        foreground: CSSText.getForeground(),
        height: height);
    return textStyle;
  }

  static TextSpan createTextSpan(
    String? text,
    CSSRenderStyle renderStyle, {
    Color? color,
    double? height,
    TextSpan? oldTextSpan,
  }) {
    // Ensure font is loaded for the specific weight before creating TextStyle
    List<String>? fontFamilies = renderStyle.fontFamily;
    if (fontFamilies != null && fontFamilies.isNotEmpty) {
      String primaryFontFamily = fontFamilies[0];
      // Fire and forget - the font will be available for the next frame
      CSSFontFace.ensureFontLoaded(primaryFontFamily, _effectiveFontWeight(renderStyle), renderStyle);
    }

    TextStyle textStyle = createTextStyle(renderStyle, height: height, color: color);
    if (oldTextSpan != null && oldTextSpan.text == text && oldTextSpan.style == textStyle) {
      return oldTextSpan;
    }
    return TextSpan(text: text, style: textStyle, children: []);
  }
}

class CSSText {
  static final Map<_FontFeatureSupportKey, bool> _featureSupportCache = {};

  static bool isValidFontStyleValue(String value) {
    return value == 'normal' || value == 'italic' || value == 'oblique';
  }

  static bool isValidFontVariantValue(String value) {
    if (value.isEmpty) return false;
    final String normalized = value.trim().toLowerCase();
    if (normalized == 'normal' || normalized == 'none') return true;

    final List<String> tokens = normalized.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return false;
    if (tokens.contains('normal') || tokens.contains('none')) return false;

    for (final t in tokens) {
      if (!_isValidFontVariantKeyword(t)) return false;
    }
    return true;
  }

  static bool isValidFontVariantCss21Value(String value) {
    // The CSS2.1 font-variant property used in the `font` shorthand only accepts
    // 'normal' or 'small-caps'.
    return value == 'normal' || value == 'small-caps';
  }

  static bool _isValidFontVariantKeyword(String t) {
    switch (t) {
      // Caps
      case 'small-caps':
      case 'all-small-caps':
      case 'petite-caps':
      case 'all-petite-caps':
      case 'unicase':
      case 'titling-caps':
      // Ligatures
      case 'common-ligatures':
      case 'no-common-ligatures':
      case 'discretionary-ligatures':
      case 'no-discretionary-ligatures':
      case 'historical-ligatures':
      case 'no-historical-ligatures':
      case 'contextual':
      case 'no-contextual':
      case 'historical-forms':
      // Numeric
      case 'lining-nums':
      case 'oldstyle-nums':
      case 'proportional-nums':
      case 'tabular-nums':
      case 'diagonal-fractions':
      case 'stacked-fractions':
      case 'slashed-zero':
      case 'ordinal':
      // East Asian
      case 'jis78':
      case 'jis83':
      case 'jis90':
      case 'jis04':
      case 'simplified':
      case 'traditional':
      case 'full-width':
      case 'proportional-width':
      case 'ruby':
      // Position
      case 'sub':
      case 'super':
        return true;
      default:
        return false;
    }
  }

  static bool supportsSmallCapsFontFeature(CSSRenderStyle renderStyle) {
    return supportsFontFeature(renderStyle, 'smcp');
  }

  static bool supportsFontFeature(CSSRenderStyle renderStyle, String tag) {
    final List<String>? families = renderStyle.fontFamily;
    final String primary = (families != null && families.isNotEmpty) ? families.first : '';
    final FontWeight effectiveWeight = CSSTextMixin._effectiveFontWeight(renderStyle);
    final _FontFeatureSupportKey key = _FontFeatureSupportKey(
      primaryFamily: primary,
      weightIndex: effectiveWeight.index,
      fontStyle: renderStyle.fontStyle,
      tag: tag,
    );

    final bool? cached = _featureSupportCache[key];
    if (cached != null) return cached;

    // Ensure primary font is requested before probing.
    if (primary.isNotEmpty) {
      CSSFontFace.ensureFontLoaded(primary, effectiveWeight, renderStyle);
    }

    // Probe by measuring if enabling a feature changes layout metrics; when the
    // font doesn't support it, metrics should remain identical (heuristic).
    Size measure(String text, {List<FontFeature>? features}) {
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: primary.isNotEmpty ? primary : null,
            fontFamilyFallback: families,
            fontWeight: effectiveWeight,
            fontStyle: renderStyle.fontStyle,
            fontSize: math.max(0.0, renderStyle.fontSize.computedValue),
            fontFeatures: features,
          ),
        ),
        textScaler: renderStyle.textScaler,
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.size;
    }

    const samples = ['a', 'abcxyz', 'mixedCapsAa'];
    bool supported = false;
    for (final s in samples) {
      final Size base = measure(s);
      final Size feat = measure(s, features: [FontFeature.enable(tag)]);
      final double dw = (feat.width - base.width).abs();
      final double dh = (feat.height - base.height).abs();
      if (dw > 0.1 || dh > 0.1) {
        supported = true;
        break;
      }
    }

    _featureSupportCache[key] = supported;
    return supported;
  }

  static bool isValidFontWeightValue(String value) {
    double? weight = CSSNumber.parseNumber(value);
    if (weight != null) {
      return weight >= 1 && weight <= 1000;
    } else {
      return value == 'normal' || value == 'bold' || value == 'lighter' || value == 'bolder';
    }
  }

  static bool isValidFontSizeValue(String value) {
    return CSSLength.isNonNegativeLength(value) ||
        CSSPercentage.isNonNegativePercentage(value) ||
        value == 'xx-small' ||
        value == 'x-small' ||
        value == 'small' ||
        value == 'medium' ||
        value == 'large' ||
        value == 'x-large' ||
        value == 'xx-large' ||
        value == 'xxx-large' ||
        value == 'larger' ||
        value == 'smaller';
  }

  static bool isValidLineHeightValue(String value) {
    return CSSLength.isNonNegativeLength(value) ||
        CSSPercentage.isNonNegativePercentage(value) ||
        value == 'normal' ||
        double.tryParse(value) != null;
  }

  static bool isValidTextTextDecorationLineValue(String value) {
    return value == 'underline' || value == 'overline' || value == 'line-through' || value == 'none';
  }

  static bool isValidTextTextDecorationStyleValue(String value) {
    return value == 'solid' || value == 'double' || value == 'dotted' || value == 'dashed' || value == 'wavy';
  }

  static CSSLengthValue defaultLineHeight = CSSLengthValue.normal;

  static CSSLengthValue? resolveLineHeight(String value, RenderStyle renderStyle, String propertyName) {
    if (value.isNotEmpty) {
      if (CSSLength.isNonNegativeLength(value) || CSSPercentage.isNonNegativePercentage(value)) {
        CSSLengthValue lineHeight = CSSLength.parseLength(value, renderStyle, propertyName);
        // Per CSS Inline spec, line-height accepts non-negative values. Zero is valid.
        if (lineHeight.computedValue != double.infinity && lineHeight.computedValue >= 0) {
          return lineHeight;
        }
      } else if (value == NORMAL) {
        return CSSLengthValue.normal;
      } else if (CSSNumber.isNumber(value)) {
        double? multipliedNumber = double.tryParse(value);
        if (multipliedNumber != null) {
          return CSSLengthValue(multipliedNumber, CSSLengthType.EM, renderStyle, propertyName);
        }
      }
    }
    return null;
  }

  /// In CSS2.1, text-decoration determin the type of text decoration,
  /// but in CSS3, which is text-decoration-line. This resolver accepts
  /// multiple space-separated line keywords and combines them.
  static TextDecoration resolveTextDecorationLine(String present) {
    if (present.isEmpty) return TextDecoration.none;
    final parts = present.trim().split(RegExp(r"\s+"));
    // If 'none' is present with any other token, treat as none.
    if (parts.contains('none')) return TextDecoration.none;

    final List<TextDecoration> lines = [];
    for (final p in parts) {
      switch (p) {
        case 'line-through':
          if (!lines.contains(TextDecoration.lineThrough)) lines.add(TextDecoration.lineThrough);
          break;
        case 'overline':
          if (!lines.contains(TextDecoration.overline)) lines.add(TextDecoration.overline);
          break;
        case 'underline':
          if (!lines.contains(TextDecoration.underline)) lines.add(TextDecoration.underline);
          break;
        // Ignore unknown tokens; they make the longhand invalid in strict CSS,
        // but our resolver defaults to none if nothing valid is found.
        default:
          break;
      }
    }

    if (lines.isEmpty) return TextDecoration.none;
    if (lines.length == 1) return lines.first;
    return TextDecoration.combine(lines);
  }

  static WhiteSpace resolveWhiteSpace(String value) {
    switch (value) {
      case 'nowrap':
        return WhiteSpace.nowrap;
      case 'pre':
        return WhiteSpace.pre;
      case 'pre-wrap':
        return WhiteSpace.preWrap;
      case 'pre-line':
        return WhiteSpace.preLine;
      case 'break-spaces':
        return WhiteSpace.breakSpaces;
      case 'normal':
      default:
        return WhiteSpace.normal;
    }
  }

  static int? parseLineClamp(String value) {
    return CSSLength.toInt(value);
  }

  static TextOverflow resolveTextOverflow(String value) {
    // Always get text overflow from style cause it is affected by white-space and overflow.
    switch (value) {
      case 'ellipsis':
        return TextOverflow.ellipsis;
      case 'fade':
        return TextOverflow.fade;
      case 'clip':
      default:
        return TextOverflow.clip;
    }
  }

  static TextTransform resolveTextTransform(String value) {
    switch (value) {
      case 'uppercase':
        return TextTransform.uppercase;
      case 'lowercase':
        return TextTransform.lowercase;
      case 'capitalize':
        return TextTransform.capitalize;
      case 'none':
      default:
        return TextTransform.none;
    }
  }

  // CSS word-break
  static WordBreak resolveWordBreak(String value) {
    switch (value) {
      case 'break-all':
        return WordBreak.breakAll;
      case 'keep-all':
        return WordBreak.keepAll;
      case 'break-word':
        return WordBreak.breakWord;
      case 'normal':
      default:
        return WordBreak.normal;
    }
  }

  static String applyTextTransform(String input, TextTransform transform) {
    if (input.isEmpty || transform == TextTransform.none) return input;
    switch (transform) {
      case TextTransform.uppercase:
        return input.toUpperCase();
      case TextTransform.lowercase:
        return input.toLowerCase();
      case TextTransform.capitalize:
        return _capitalize(input);
      case TextTransform.none:
        return input;
    }
  }

  // Visible for inline builder to preserve capitalization across inline boundaries.
  static (String, bool) applyTextTransformWithCarry(String input, TextTransform transform, bool atWordStart) {
    if (input.isEmpty || transform == TextTransform.none) return (input, atWordStart);
    switch (transform) {
      case TextTransform.uppercase:
        final out = input.toUpperCase();
        return (out, out.isNotEmpty ? isWordBoundary(out.codeUnitAt(out.length - 1)) : atWordStart);
      case TextTransform.lowercase:
        final out = input.toLowerCase();
        return (out, out.isNotEmpty ? isWordBoundary(out.codeUnitAt(out.length - 1)) : atWordStart);
      case TextTransform.capitalize:
        final sb = StringBuffer();
        bool aws = atWordStart;
        for (int i = 0; i < input.length; i++) {
          final cu = input.codeUnitAt(i);
          final ch = String.fromCharCode(cu);
          if (aws) {
            sb.write(ch.toUpperCase());
            aws = false;
          } else {
            sb.write(ch);
          }
          if (isWordBoundary(cu)) aws = true;
        }
        final out = sb.toString();
        return (out, aws);
      case TextTransform.none:
        return (input, atWordStart);
    }
  }

  // Expose boundary check for builder carry logic.
  static bool isWordBoundary(int codeUnit) => _isWordBoundary(codeUnit);

  static bool _isWordBoundary(int codeUnit) {
    // Treat whitespace, NBSP, and common punctuation/hyphen as word boundaries.
    const nbsp = 0x00A0;
    if (codeUnit == nbsp) return true;
    final ch = String.fromCharCode(codeUnit);
    const seps = ' \t\r\n\f\v\u2028\u2029';
    if (seps.contains(ch)) return true;
    const punct = '-\u2011_.,:;!?()[]{}"\'&';
    return punct.contains(ch);
  }

  static String _capitalize(String s) {
    final sb = StringBuffer();
    bool atWordStart = true;
    for (int i = 0; i < s.length; i++) {
      final cu = s.codeUnitAt(i);
      if (atWordStart) {
        final ch = String.fromCharCode(cu);
        sb.write(ch.toUpperCase());
        atWordStart = false;
      } else {
        sb.writeCharCode(cu);
      }
      if (_isWordBoundary(cu)) {
        atWordStart = true;
      }
    }
    return sb.toString();
  }

  static TextDecorationStyle resolveTextDecorationStyle(String present) {
    switch (present) {
      case 'double':
        return TextDecorationStyle.double;
      case 'dotted':
        return TextDecorationStyle.dotted;
      case 'dashed':
        return TextDecorationStyle.dashed;
      case 'wavy':
        return TextDecorationStyle.wavy;
      case 'solid':
      default:
        return TextDecorationStyle.solid;
    }
  }

  static FontWeight resolveFontWeight(String? fontWeight) {
    switch (fontWeight) {
      case 'lighter':
        return FontWeight.w200;
      case 'normal':
        return FontWeight.w400;
      case 'bold':
        return FontWeight.w700;
      case 'bolder':
        return FontWeight.w900;
      default:
        int? fontWeightValue;
        if (fontWeight != null) {
          fontWeightValue = int.tryParse(fontWeight);
        }
        // See: https://drafts.csswg.org/css-fonts-4/#font-weight-numeric-values
        // Only values greater than or equal to 1, and less than or equal to 1000, are valid,
        // and all other values are invalid.
        if (fontWeightValue == null || fontWeightValue > 1000 || fontWeightValue <= 0) {
          return FontWeight.w400;
        } else if (fontWeightValue >= 900) {
          return FontWeight.w900;
        } else if (fontWeightValue >= 800) {
          return FontWeight.w800;
        } else if (fontWeightValue >= 700) {
          return FontWeight.w700;
        } else if (fontWeightValue >= 600) {
          return FontWeight.w600;
        } else if (fontWeightValue >= 500) {
          return FontWeight.w500;
        } else if (fontWeightValue >= 400) {
          return FontWeight.w400;
        } else if (fontWeightValue >= 300) {
          return FontWeight.w300;
        } else if (fontWeightValue >= 200) {
          return FontWeight.w200;
        } else {
          return FontWeight.w100;
        }
    }
  }

  // https://drafts.csswg.org/css-fonts/#absolute-size-mapping
  static CSSLengthValue resolveFontSize(String fontSize, RenderStyle renderStyle, String propertyName) {
    switch (fontSize) {
      case 'xx-small':
        return CSSLengthValue(3 / 5 * 16, CSSLengthType.PX);
      case 'x-small':
        return CSSLengthValue(3 / 4 * 16, CSSLengthType.PX);
      case 'small':
        return CSSLengthValue(8 / 9 * 16, CSSLengthType.PX);
      case 'medium':
        return CSSLengthValue(16, CSSLengthType.PX);
      case 'large':
        return CSSLengthValue(6 / 5 * 16, CSSLengthType.PX);
      case 'x-large':
        return CSSLengthValue(3 / 2 * 16, CSSLengthType.PX);
      case 'xx-large':
        return CSSLengthValue(2 / 1 * 16, CSSLengthType.PX);
      case 'xxx-large':
        return CSSLengthValue(3 / 1 * 16, CSSLengthType.PX);
      case 'smaller':
        return CSSLengthValue(5 / 6, CSSLengthType.EM, renderStyle, propertyName);
      case 'larger':
        return CSSLengthValue(6 / 5, CSSLengthType.EM, renderStyle, propertyName);
      default:
        // Parse lengths/percentages/functions (e.g., calc()).
        final CSSLengthValue parsed = CSSLength.parseLength(fontSize, renderStyle, propertyName);
        // If parsing failed, treat as invalid (ignore declaration).
        if (identical(parsed, CSSLengthValue.unknown)) {
          // Keep previous value unchanged (ignore invalid declaration).
          return renderStyle.fontSize;
        }
        // Per CSS, font-size must be non-negative; negative <length>/<percentage> declarations are invalid and ignored.
        // Keep calc() results as-is (including negative) for computed style queries; layout code must clamp.
        if (parsed.calcValue == null && parsed.computedValue < 0) {
          return renderStyle.fontSize;
        }
        // Preserve calc() results (including negative) for computed style queries.
        // Some integration tests expect negative computed values from calc() for font-size
        // (e.g., calc(30% - 40px) relative to a 40px parent resolves to -28px).
        // Return the parsed value directly; any layout-time handling can clamp if needed.
        return parsed;
    }
  }

  static FontStyle resolveFontStyle(String? fontStyle) {
    switch (fontStyle) {
      case 'oblique':
      case 'italic':
        return FontStyle.italic;
      case 'normal':
      default:
        return FontStyle.normal;
    }
  }

  static String? resolveFontVariant(String? fontVariant) {
    if (fontVariant == null) return null;
    final String normalized = fontVariant.trim().toLowerCase();
    if (!isValidFontVariantValue(normalized)) return null;
    // Normalize whitespace.
    return normalized.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).join(' ');
  }

  static ({List<ui.FontFeature> features, FontVariantCapsSynthesis synth}) resolveFontFeaturesForVariant(
      CSSRenderStyle renderStyle) {
    final String v = renderStyle.fontVariant;
    if (v.isEmpty || v == 'normal') {
      return (features: const <ui.FontFeature>[], synth: FontVariantCapsSynthesis.none);
    }

    if (v == 'none') {
      // Treat as disabling common/contextual/discretionary/historical ligatures.
      return (
        features: const <ui.FontFeature>[
          ui.FontFeature('liga', 0),
          ui.FontFeature('clig', 0),
          ui.FontFeature('calt', 0),
          ui.FontFeature('dlig', 0),
          ui.FontFeature('hlig', 0),
        ],
        synth: FontVariantCapsSynthesis.none
      );
    }

    final tokens = v.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final List<ui.FontFeature> features = <ui.FontFeature>[];
    FontVariantCapsSynthesis synth = FontVariantCapsSynthesis.none;

    final bool hasAllSmallCaps = tokens.contains('all-small-caps');
    final bool hasSmallCaps = tokens.contains('small-caps');
    final bool hasAllPetiteCaps = tokens.contains('all-petite-caps');
    final bool hasPetiteCaps = tokens.contains('petite-caps');

    if (hasAllSmallCaps || hasSmallCaps) {
      final bool hasSmcp = supportsFontFeature(renderStyle, 'smcp');
      final bool hasC2sc = hasAllSmallCaps ? supportsFontFeature(renderStyle, 'c2sc') : true;
      if (hasAllSmallCaps && hasSmcp && hasC2sc) {
        features.add(const ui.FontFeature.enable('smcp'));
        features.add(const ui.FontFeature.enable('c2sc'));
      } else if (!hasAllSmallCaps && hasSmcp) {
        features.add(const ui.FontFeature.enable('smcp'));
      } else {
        synth = hasAllSmallCaps ? FontVariantCapsSynthesis.allLetters : FontVariantCapsSynthesis.lowercaseOnly;
      }
    } else if (hasAllPetiteCaps || hasPetiteCaps) {
      final bool hasPcap = supportsFontFeature(renderStyle, 'pcap');
      final bool hasC2pc = hasAllPetiteCaps ? supportsFontFeature(renderStyle, 'c2pc') : true;
      if (hasAllPetiteCaps && hasPcap && hasC2pc) {
        features.add(const ui.FontFeature.enable('pcap'));
        features.add(const ui.FontFeature.enable('c2pc'));
      } else if (!hasAllPetiteCaps && hasPcap) {
        features.add(const ui.FontFeature.enable('pcap'));
      } else {
        synth = hasAllPetiteCaps ? FontVariantCapsSynthesis.allLetters : FontVariantCapsSynthesis.lowercaseOnly;
      }
    } else if (tokens.contains('unicase')) {
      features.add(const ui.FontFeature.enable('unic'));
    } else if (tokens.contains('titling-caps')) {
      features.add(const ui.FontFeature.enable('titl'));
    }

    for (final t in tokens) {
      switch (t) {
        // Ligatures
        case 'common-ligatures':
          features.add(const ui.FontFeature.enable('liga'));
          features.add(const ui.FontFeature.enable('clig'));
          break;
        case 'no-common-ligatures':
          features.add(const ui.FontFeature('liga', 0));
          features.add(const ui.FontFeature('clig', 0));
          break;
        case 'discretionary-ligatures':
          features.add(const ui.FontFeature.enable('dlig'));
          break;
        case 'no-discretionary-ligatures':
          features.add(const ui.FontFeature('dlig', 0));
          break;
        case 'historical-ligatures':
          features.add(const ui.FontFeature.enable('hlig'));
          break;
        case 'no-historical-ligatures':
          features.add(const ui.FontFeature('hlig', 0));
          break;
        case 'contextual':
          features.add(const ui.FontFeature.enable('calt'));
          break;
        case 'no-contextual':
          features.add(const ui.FontFeature('calt', 0));
          break;
        case 'historical-forms':
          features.add(const ui.FontFeature.enable('hist'));
          break;

        // Numeric
        case 'lining-nums':
          features.add(const ui.FontFeature.enable('lnum'));
          break;
        case 'oldstyle-nums':
          features.add(const ui.FontFeature.enable('onum'));
          break;
        case 'proportional-nums':
          features.add(const ui.FontFeature.enable('pnum'));
          break;
        case 'tabular-nums':
          features.add(const ui.FontFeature.enable('tnum'));
          break;
        case 'diagonal-fractions':
          features.add(const ui.FontFeature.enable('frac'));
          break;
        case 'stacked-fractions':
          features.add(const ui.FontFeature.enable('afrc'));
          break;
        case 'slashed-zero':
          features.add(const ui.FontFeature.enable('zero'));
          break;
        case 'ordinal':
          features.add(const ui.FontFeature.enable('ordn'));
          break;

        // East Asian
        case 'jis78':
          features.add(const ui.FontFeature.enable('jp78'));
          break;
        case 'jis83':
          features.add(const ui.FontFeature.enable('jp83'));
          break;
        case 'jis90':
          features.add(const ui.FontFeature.enable('jp90'));
          break;
        case 'jis04':
          features.add(const ui.FontFeature.enable('jp04'));
          break;
        case 'simplified':
          features.add(const ui.FontFeature.enable('smpl'));
          break;
        case 'traditional':
          features.add(const ui.FontFeature.enable('trad'));
          break;
        case 'full-width':
          features.add(const ui.FontFeature.enable('fwid'));
          break;
        case 'proportional-width':
          features.add(const ui.FontFeature.enable('pwid'));
          break;
        case 'ruby':
          features.add(const ui.FontFeature.enable('ruby'));
          break;

        // Position
        case 'sub':
          features.add(const ui.FontFeature.enable('subs'));
          break;
        case 'super':
          features.add(const ui.FontFeature.enable('sups'));
          break;
        default:
          break;
      }
    }

    return (features: features, synth: synth);
  }

  static String? toCharacterBreakStr(String? word) {
    if (word == null || word.isEmpty) {
      return null;
    }
    String breakWord = '';
    for (var element in word.runes) {
      breakWord += String.fromCharCode(element);
      breakWord += '\u200B';
    }
    return breakWord;
  }

  static TextBaseline getTextBaseLine() {
    return TextBaseline.alphabetic; // @TODO: impl vertical-align
  }

  static String? builtinFontPackage;

  static String? getFontPackage() {
    return builtinFontPackage;
  }

  static List<String>? defaultFontFamilyFallback;

  static List<String> resolveFontFamilyFallback(String? fontFamily) {
    fontFamily = fontFamily ?? 'sans-serif';
    List<String> values = fontFamily.split(_commaRegExp);
    List<String> resolvedFamily = List.empty(growable: true);

    for (int i = 0; i < values.length; i++) {
      String familyName = values[i];
      // Remove wrapping quotes: "Gill Sans" -> Gill Sans
      if (familyName[0] == '"' || familyName[0] == '\'') {
        familyName = familyName.substring(1, familyName.length - 1);
      }

      final String familyKey = familyName.toLowerCase();
      switch (familyKey) {
        case 'sans-serif':
          // Default sans-serif font in iOS (9 and newer)and iPadOS: Helvetica
          // Default sans-serif font in Android (4.0+): Roboto
          resolvedFamily.addAll(['Helvetica', 'Roboto', 'PingFang SC', 'PingFang TC']);
          break;
        case 'serif':
          // Default serif font in iOS and iPadOS: Times
          // Default serif font in Android (4.0+): Noto Serif
          resolvedFamily.addAll([
            'Times',
            'Times New Roman',
            'Noto Serif',
            'Songti SC',
            'Songti TC',
            'Hiragino Mincho ProN',
            'AppleMyungjo',
            'Apple SD Gothic Neo'
          ]);
          break;
        case 'monospace':
          // Default monospace font in iOS and iPadOS: Courier
          resolvedFamily.addAll(['Menlo', 'Courier', 'Courier New', 'DroidSansMono', 'Monaco', 'Heiti SC', 'Heiti TC']);
          break;
        case 'cursive':
          // Default cursive font in iOS and iPadOS: Apple Chancery
          resolvedFamily.addAll(['Apple Chancery', 'Snell Roundhand', 'DancingScript', 'Comic Sans MS']);
          break;
        case 'fantasy':
          // Default fantasy font in iOS and iPadOS:
          // Default fantasy font in MacOS: Papyrus
          resolvedFamily.addAll(['Papyrus', 'Impact']);
          break;
        case '-apple-system':
        case 'system-ui':
          // Default system-ui font in iOS and iPadOS: .SF UI Display
          // Default system-ui font in Android (4.0+): Roboto
          resolvedFamily.addAll(['Roboto', '.SF UI Display', '.SF UI Text']);
          break;
        default:
          resolvedFamily.add(familyName);
      }
    }

    // Only for internal use.
    if (resolvedFamily.isEmpty && CSSText.defaultFontFamilyFallback != null) {
      return CSSText.defaultFontFamilyFallback!;
    }
    return resolvedFamily;
  }

  static CSSLengthValue defaultFontSize = CSSLengthValue(16.0, CSSLengthType.PX);

  static CSSLengthValue resolveSpacing(String spacing, RenderStyle renderStyle, String property) {
    if (spacing == NORMAL) return CSSLengthValue.zero;

    return CSSLength.parseLength(spacing, renderStyle, property);
  }

  static Locale? getLocale() {
    // TODO: impl locale for text decoration.
    return null;
  }

  static Paint? getBackground() {
    // TODO: Reserved port for customize text decoration background.
    return null;
  }

  static Paint? getForeground() {
    // TODO: Reserved port for customize text decoration foreground.
    return null;
  }

  static List<Shadow> resolveTextShadow(String value, RenderStyle renderStyle, String propertyName) {
    List<Shadow> textShadows = [];

    var shadows = CSSStyleProperty.getShadowValues(value);
    if (shadows != null) {
      for (var shadowDefinitions in shadows) {
        String shadowColor = shadowDefinitions[0] ?? CURRENT_COLOR;
        // Specifies the color of the shadow. If the color is absent, it defaults to currentColor.
        CSSColor? color = CSSColor.resolveColor(shadowColor, renderStyle, propertyName);
        double offsetX = CSSLength.parseLength(shadowDefinitions[1]!, renderStyle, propertyName).computedValue;
        double offsetY = CSSLength.parseLength(shadowDefinitions[2]!, renderStyle, propertyName).computedValue;
        String? blurRadiusStr = shadowDefinitions[3];
        // Blur-radius defaults to 0 if not specified.
        double blurRadius =
            blurRadiusStr != null ? CSSLength.parseLength(blurRadiusStr, renderStyle, propertyName).computedValue : 0;
        if (color != null) {
          textShadows.add(Shadow(
            offset: Offset(offsetX, offsetY),
            blurRadius: blurRadius,
            color: color.value,
          ));
        }
      }
    }

    return textShadows;
  }
}

enum TextTransform { none, capitalize, uppercase, lowercase }
