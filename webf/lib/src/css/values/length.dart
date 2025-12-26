/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/src/foundation/logger.dart';
import 'package:webf/src/foundation/debug_flags.dart';
import 'package:webf/rendering.dart';
import 'package:quiver/collection.dart';

// https://drafts.csswg.org/css-values-3/#absolute-lengths
const _1in = 96; // 1in = 2.54cm = 96px
const _1cm = _1in / 2.54; // 1cm = 96px/2.54
const _1mm = _1cm / 10; // 1mm = 1/10th of 1cm
const _1Q = _1cm / 40; // 1Q = 1/40th of 1cm
const _1pc = _1in / 6; // 1pc = 1/6th of 1in
const _1pt = _1in / 72; // 1pt = 1/72th of 1in
// Approximate x-height ratio to em when font metrics are not available.
// Many UAs approximate 1ex ≈ 0.5em for generic fonts.
const double _exToEmFallbackRatio = 0.5;
// Approximate 1ch when glyph metrics are not available.
// Many UAs approximate 1ch ≈ 0.5em for common fonts.
const double _chToEmFallbackRatio = 0.5;

final String _unitRegStr = '(px|rpx|vw|vh|vmin|vmax|rem|em|ex|ch|in|cm|mm|pc|pt|q)';
final _lengthRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?' + _unitRegStr + r'$', caseSensitive: false);
final _negativeZeroRegExp = RegExp(r'^-(0+)?(\.0+)?' + _unitRegStr + r'$', caseSensitive: false);
final _nonNegativeLengthRegExp = RegExp(r'^[+]?(\d+)?(\.\d+)?' + _unitRegStr + r'$', caseSensitive: false);

enum CSSLengthType {
  // absolute units
  PX, // px
  RPX,
  // relative units
  EM, // em,
  EX, // ex (x-height of the element's font)
  CH, // ch (advance measure of '0' glyph)
  REM, // rem
  VH, // vh
  VW, // vw
  VMIN, // vmin
  VMAX, // vmax
  PERCENTAGE, // %
  // unknown
  UNKNOWN,
  // auto
  AUTO,
  // none
  NONE,
  // normal
  NORMAL,
  INITIAL,
  // flex-basis: content keyword (CSS Sizing-3)
  CONTENT,
  // intrinsic sizing keywords (CSS Sizing-3)
  MIN_CONTENT,
  MAX_CONTENT,
  FIT_CONTENT,
}

class CSSLengthValue {
  final CSSCalcValue? calcValue;
  final double? value;
  final CSSLengthType type;

  CSSLengthValue.calc(this.calcValue, this.renderStyle, this.propertyName)
      : value = null,
        type = CSSLengthType.PX;

  CSSLengthValue(this.value, this.type, [this.renderStyle, this.propertyName, this.axisType]) : calcValue = null {
    if (propertyName != null) {
      if (type == CSSLengthType.EM) {
        renderStyle!.addFontRelativeProperty(propertyName!);
      } else if (type == CSSLengthType.EX) {
        renderStyle!.addFontRelativeProperty(propertyName!);
      } else if (type == CSSLengthType.CH) {
        renderStyle!.addFontRelativeProperty(propertyName!);
      } else if (type == CSSLengthType.REM) {
        renderStyle!.addRootFontRelativeProperty(propertyName!);
      }
    }

    if (isViewportSizeRelatedLength()) {
      renderStyle?.addViewportSizeRelativeProperty();
    }
  }

  bool isViewportSizeRelatedLength() {
    return type == CSSLengthType.VH || type == CSSLengthType.VW;
  }

  String cssText() {
    switch (type) {
      case CSSLengthType.PX:
      case CSSLengthType.EM:
      case CSSLengthType.EX:
      case CSSLengthType.CH:
        return '${computedValue.cssText()}px';
      case CSSLengthType.REM:
        return '${value?.cssText()}rem';
      case CSSLengthType.VH:
        return '${value?.cssText()}vh';
      case CSSLengthType.VW:
        return '${value?.cssText()}vw';
      case CSSLengthType.VMIN:
        return '${value?.cssText()}vmin';
      case CSSLengthType.VMAX:
        return '${value?.cssText()}vmax';
      case CSSLengthType.PERCENTAGE:
        return '${(value! * 100).cssText()}%';
      case CSSLengthType.RPX:
        return '${value?.cssText()}rpx';
      case CSSLengthType.UNKNOWN:
      case CSSLengthType.AUTO:
        return 'auto';
      case CSSLengthType.NONE:
      case CSSLengthType.NORMAL:
      case CSSLengthType.INITIAL:
        break;
      case CSSLengthType.CONTENT:
        return 'content';
      case CSSLengthType.MIN_CONTENT:
        return 'min-content';
      case CSSLengthType.MAX_CONTENT:
        return 'max-content';
      case CSSLengthType.FIT_CONTENT:
        return 'fit-content';
    }
    return '';
  }

  static final CSSLengthValue zero = CSSLengthValue(0, CSSLengthType.PX);
  static final CSSLengthValue auto = CSSLengthValue(null, CSSLengthType.AUTO);
  static final CSSLengthValue initial = CSSLengthValue(null, CSSLengthType.INITIAL);
  static final CSSLengthValue unknown = CSSLengthValue(null, CSSLengthType.UNKNOWN);

  // Used in https://www.w3.org/TR/css-inline-3/#valdef-line-height-normal
  static final CSSLengthValue normal = CSSLengthValue(null, CSSLengthType.NORMAL);
  static final CSSLengthValue none = CSSLengthValue(null, CSSLengthType.NONE);

  // Length is applied in horizontal or vertical direction.
  Axis? axisType;

  RenderStyle? renderStyle;
  String? propertyName;
  double? _computedValue;

  static bool _isPercentageRelativeContainerRenderStyle(RenderStyle renderStyle) {
    // Use effectiveDisplay so that blockification/inlinification is respected
    // per CSS Display spec. In particular, absolutely/fixed positioned boxes
    // are blockified and should act as percentage containers for their
    // positioned descendants.
    final CSSDisplay eff = renderStyle.effectiveDisplay;

    // Block-level containers establish percentage reference sizes.
    final bool isBlockLevelBox = eff == CSSDisplay.block || eff == CSSDisplay.flex;

    // Inline-block/inline-flex with explicit width also establish a percentage container.
    final bool isInlineWithExplicitSize =
        (eff == CSSDisplay.inlineBlock || eff == CSSDisplay.inlineFlex) && renderStyle.width.value != null;

    // Inline-block/inline-flex with auto width still establish a containing block;
    // percentages resolve against the available inline size determined by ancestors.
    final bool isInlineBlockAutoWidth =
        (eff == CSSDisplay.inlineBlock || eff == CSSDisplay.inlineFlex) && renderStyle.width.isAuto;

    return isBlockLevelBox || isInlineWithExplicitSize || isInlineBlockAutoWidth;
  }

  // Whether the container has a definite inline (horizontal) size that
  // percentages can resolve against. Avoid depending solely on contentConstraints,
  // which may be null on the first layout. Instead, use contentMaxConstraintsWidth
  // which falls back to the nearest ancestor with a computed logical width, or
  // check explicit non-percentage width on the element.
  static bool _hasDefiniteInlineSize(RenderStyle rs) {
    if (rs is CSSRenderStyle) {
      final double cmw = rs.contentMaxConstraintsWidth;
      if (cmw != double.infinity) return true;
      // As a fallback, treat explicit non-percentage width as definite.
      if (rs.width.isNotAuto && !rs.width.isPercentage) return true;
    }
    return false;
  }

  // Note return value of double.infinity means the value is resolved as the initial value
  // which can not be computed to a specific value, eg. percentage height is sometimes parsed
  // to be auto due to parent height not defined.
  double get computedValue {
    if (calcValue != null) {
      _computedValue = calcValue!.computedValue(propertyName ?? '') ?? 0;
      return _computedValue!;
    }

    // Use cached value if type is not percentage which may needs 2 layout passes to resolve the
    // final computed value.
    if (renderStyle?.hasRenderBox() == true &&
        propertyName != null &&
        type != CSSLengthType.PERCENTAGE) {
      double? cachedValue = getCachedComputedValue(renderStyle!, propertyName!);
      if (cachedValue != null) {
        return cachedValue;
      }
    }

    final realPropertyName = propertyName?.split('_').first ?? propertyName;
    switch (type) {
      case CSSLengthType.PX:
        _computedValue = value;
        break;
      case CSSLengthType.RPX:
        FlutterView window = renderStyle!.currentFlutterView;
        _computedValue = value! / 750.0 * window.physicalSize.width / window.devicePixelRatio;
        break;
      case CSSLengthType.EM:
        // Font size of the parent, in the case of typographical properties like font-size,
        // and font size of the element itself, in the case of other properties like width.
        if (realPropertyName == FONT_SIZE) {
          // If root element set fontSize as em unit.
          if (renderStyle!.getAttachedRenderParentRenderStyle() == null) {
            _computedValue = value! * 16;
          } else {
            _computedValue = value! * renderStyle!.getAttachedRenderParentRenderStyle()!.fontSize.computedValue;
          }
        } else {
          _computedValue = value! * renderStyle!.fontSize.computedValue;
        }
        break;
      case CSSLengthType.EX:
        // Approximate 1ex via a 0.5em fallback. For font-size itself, resolve
        // against the parent font size to avoid recursion (per CSS: em/ex in
        // font-size are relative to the inherited font-size).
        double baseEmPx;
        if (realPropertyName == FONT_SIZE) {
          if (renderStyle!.getAttachedRenderParentRenderStyle() == null) {
            baseEmPx = 16; // default root font size baseline
          } else {
            baseEmPx = renderStyle!.getAttachedRenderParentRenderStyle()!.fontSize.computedValue;
          }
        } else {
          baseEmPx = renderStyle!.fontSize.computedValue;
        }
        _computedValue = value! * (baseEmPx * _exToEmFallbackRatio);
        break;
      case CSSLengthType.CH:
        // The `ch` unit is defined as the advance measure of the "0" glyph in the element's font.
        // When font metrics are not available, approximate via 0.5em.
        double oneChPx;

        // Avoid recursion when resolving `font-size` in terms of `ch` by measuring against the
        // inherited font style instead of the element's own (yet-to-be-computed) font size.
        RenderStyle? metricBaseStyle = renderStyle;
        if (realPropertyName == FONT_SIZE) {
          metricBaseStyle = renderStyle!.getAttachedRenderParentRenderStyle();
        }

        double baseEmPx;
        if (realPropertyName == FONT_SIZE) {
          if (metricBaseStyle == null) {
            baseEmPx = 16;
          } else {
            baseEmPx = metricBaseStyle.fontSize.computedValue;
          }
        } else {
          baseEmPx = renderStyle!.fontSize.computedValue;
        }
        oneChPx = baseEmPx * _chToEmFallbackRatio;

        if (metricBaseStyle is CSSRenderStyle) {
          try {
            final TextStyle style = CSSTextMixin.createTextStyle(metricBaseStyle);
            final TextPainter tp = TextPainter(
              text: TextSpan(text: '0', style: style),
              textScaler: metricBaseStyle.textScaler,
              textDirection: metricBaseStyle.direction,
              maxLines: 1,
            )..layout(minWidth: 0, maxWidth: double.infinity);
            if (tp.width > 0) {
              oneChPx = tp.width;
            }
          } catch (_) {}
        }

        _computedValue = value! * oneChPx;
        break;
      case CSSLengthType.REM:
        // If root element set fontSize as rem unit.
        if (renderStyle!.getAttachedRenderParentRenderStyle() == null) {
          _computedValue = value! * 16;
        } else {
          // Font rem is calculated against the root element's font size.
          _computedValue = value! * renderStyle!.rootFontSize;
        }
        break;
      case CSSLengthType.VH:
        _computedValue = value! * (renderStyle!.getCurrentViewportBox()?.boxSize ?? renderStyle!.viewportSize).height;
        break;
      case CSSLengthType.VW:
        _computedValue = value! * (renderStyle!.getCurrentViewportBox()?.boxSize ?? renderStyle!.viewportSize).width;
        break;
      // 1% of viewport's smaller (vw or vh) dimension.
      // If the height of the viewport is less than its width, 1vmin will be equivalent to 1vh.
      // If the width of the viewport is less than it’s height, 1vmin is equvialent to 1vw.
      case CSSLengthType.VMIN:
        _computedValue = value! * renderStyle!.viewportSize.shortestSide;
        break;
      case CSSLengthType.VMAX:
        _computedValue = value! * renderStyle!.viewportSize.longestSide;
        break;
      case CSSLengthType.PERCENTAGE:
        CSSPositionType positionType = renderStyle!.position;
        bool isPositioned = positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed;
        RenderStyle? currentRenderStyle = renderStyle;

        RenderStyle? parentRenderStyle = isPositioned
            ? currentRenderStyle?.target.getContainingBlockElement()?.renderStyle
            : currentRenderStyle?.getAttachedRenderParentRenderStyle();

        // Should access the renderStyle of renderBoxModel parent but not renderStyle parent
        // cause the element of renderStyle parent may not equal to containing block.
        // RenderObject? containerRenderBox = renderBoxModel?.parent;
        // CSSRenderStyle? parentRenderStyle;
        while (parentRenderStyle != null) {
          if (parentRenderStyle.isBoxModel() && (_isPercentageRelativeContainerRenderStyle(parentRenderStyle))) {
            break;
          }
          parentRenderStyle = parentRenderStyle.getAttachedRenderParentRenderStyle();
        }

        RenderWidgetElementChild? renderWidgetElementChild =
            currentRenderStyle?.target.attachedRenderer?.findWidgetElementChild();
        bool shouldInheritRenderWidgetElementConstraintsWidth =
            parentRenderStyle?.isSelfRenderWidget() == true && renderWidgetElementChild != null;
        double? parentWidgetConstraintWidth;
        bool shouldInheritRenderWidgetElementConstraintsHeight = false;
        double? parentWidgetConstraintHeight;
        try {
          parentWidgetConstraintWidth = renderWidgetElementChild?.constraints.maxWidth;
          shouldInheritRenderWidgetElementConstraintsHeight = parentRenderStyle?.isSelfRenderWidget() == true &&
              renderWidgetElementChild != null &&
              renderWidgetElementChild.constraints.maxHeight.isFinite &&
              renderWidgetElementChild.constraints.maxHeight !=
                  currentRenderStyle!.target.ownerView.currentViewport!.boxSize!.height;
          parentWidgetConstraintHeight = renderWidgetElementChild?.constraints.maxHeight;
        } catch (_) {}

        // Percentage relative width priority: RenderWidgetChild's constraints > logical width > renderer width
        double? parentPaddingBoxWidth = parentRenderStyle?.paddingBoxLogicalWidth ?? parentRenderStyle?.paddingBoxWidth;
        double? parentContentBoxWidth = parentRenderStyle?.contentBoxLogicalWidth ?? parentRenderStyle?.contentBoxWidth;

        // Override the contentBoxWidth
        if (shouldInheritRenderWidgetElementConstraintsWidth) {
          parentContentBoxWidth = parentWidgetConstraintWidth;
        }

        // Percentage relative height priority: logical height > renderer height.
        // For positioned elements, allow resolving against the parent's rendered
        // padding-box height even when the parent is in a relayout pass; this
        // mirrors the horizontal behavior and ensures overlays like
        // `top:0; height:100%` can track auto-height containers.
        double? parentPaddingBoxHeight = parentRenderStyle?.paddingBoxLogicalHeight;
        if (parentPaddingBoxHeight == null) {
          if (isPositioned) {
            parentPaddingBoxHeight = parentRenderStyle?.paddingBoxHeight;
          } else if (parentRenderStyle?.isSelfNeedsRelayout() != true) {
            parentPaddingBoxHeight = parentRenderStyle?.paddingBoxHeight;
          }
        }
        double? parentContentBoxHeight = parentRenderStyle?.contentBoxLogicalHeight ??
            (parentRenderStyle?.isSelfNeedsRelayout() == true ? null : parentRenderStyle?.contentBoxHeight);
        double? parentContentBoxLogicalHeight = parentRenderStyle?.contentBoxLogicalHeight;

        if (shouldInheritRenderWidgetElementConstraintsHeight) {
          parentContentBoxHeight = parentWidgetConstraintHeight;
          parentContentBoxLogicalHeight = parentWidgetConstraintHeight;
        }

        // Positioned element is positioned relative to the padding box of its containing block
        // while the others relative to the content box.
        double? relativeParentWidth = isPositioned ? parentPaddingBoxWidth : parentContentBoxWidth;

        switch (realPropertyName) {
          case FONT_SIZE:
            // Relative to the parent font size.
            if (renderStyle!.getAttachedRenderParentRenderStyle() == null) {
              _computedValue = value! * 16;
            } else {
              _computedValue = value! * renderStyle!.getAttachedRenderParentRenderStyle()!.fontSize.computedValue;
            }
            break;
          case TEXT_INDENT:
            // Percentages for text-indent refer to the width of the containing block.
            // Use the parent content box width for in-flow elements.
            if (relativeParentWidth != null && relativeParentWidth.isFinite) {
              _computedValue = value! * relativeParentWidth;
            } else if (parentRenderStyle != null) {
              double? cbLogicalW = parentRenderStyle.contentBoxLogicalWidth;
              if (cbLogicalW != null && cbLogicalW.isFinite) {
                _computedValue = value! * cbLogicalW;
              } else {
                // Fallback to constraints or viewport width if needed.
                final rbox = parentRenderStyle.attachedRenderBoxModel;
                if (rbox != null && rbox.hasSize && rbox.constraints.maxWidth.isFinite) {
                  _computedValue = value! * rbox.constraints.maxWidth;
                } else {
                  _computedValue = value! * renderStyle!.viewportSize.width;
                }
              }
            } else {
              // Root-level: resolve against viewport.
              _computedValue = value! * renderStyle!.viewportSize.width;
            }
            break;
          case LINE_HEIGHT:
            // Relative to the font size of the element itself.
            _computedValue = value! * renderStyle!.fontSize.computedValue;
            break;
          case WIDTH:
          case MIN_WIDTH:
          case MAX_WIDTH:
            // Only resolve percent widths when the containing block has a definite inline size.
            if (!isPositioned && parentRenderStyle != null && !_hasDefiniteInlineSize(parentRenderStyle)) {
              _computedValue = double.infinity;
              break;
            }
            // For inline-block (or inline-flex) with width:auto (shrink-to-fit), the containing block
            // inline size is not yet definite for in-flow children. Per CSS, percentage widths here
            // compute to auto. However, once the inline-block’s shrink-to-fit content width becomes
            // definite, percentage widths of descendants MUST resolve against that width.
            if (!isPositioned &&
                parentRenderStyle != null &&
                (parentRenderStyle.effectiveDisplay == CSSDisplay.inlineBlock ||
                    parentRenderStyle.effectiveDisplay == CSSDisplay.inlineFlex) &&
                parentRenderStyle.width.isAuto) {
              // Treat as indefinite only if the parent has no definite logical content width yet.
              final double? cbLogicalW = (parentRenderStyle is CSSRenderStyle)
                  ? (parentRenderStyle).contentBoxLogicalWidth
                  : parentRenderStyle.contentBoxLogicalWidth;
              if (cbLogicalW == null) {
                _computedValue = double.infinity;
                break;
              }
            }
            if (relativeParentWidth != null) {
              _computedValue = value! * relativeParentWidth;
              // Do not upscale replaced elements inside shrink-to-fit inline-block containers.
              if (!isPositioned &&
                  parentRenderStyle != null &&
                  parentRenderStyle.effectiveDisplay == CSSDisplay.inlineBlock &&
                  parentRenderStyle.width.isAuto &&
                  renderStyle != null &&
                  renderStyle!.isSelfRenderReplaced() &&
                  _computedValue != null) {
                final double iw = renderStyle!.intrinsicWidth;
                if (iw > 0 && _computedValue! > iw) {
                  _computedValue = iw;
                }
              }
            } else {
              // Attempt to force parent width computation before giving up
              if (parentRenderStyle != null && parentRenderStyle is CSSRenderStyle) {
                // Ensure parent's layout width is computed
                (parentRenderStyle).computeContentBoxLogicalWidth();
                // Try to get parent width again after computation
                double? recomputedParentWidth =
                    isPositioned ? parentRenderStyle.paddingBoxLogicalWidth : parentRenderStyle.contentBoxLogicalWidth;

                  if (recomputedParentWidth != null) {
                    _computedValue = value! * recomputedParentWidth;
                  if (!isPositioned &&
                      parentRenderStyle.effectiveDisplay == CSSDisplay.inlineBlock &&
                      parentRenderStyle.width.isAuto &&
                      renderStyle != null &&
                      renderStyle!.isSelfRenderReplaced() &&
                      _computedValue != null) {
                    final double iw = renderStyle!.intrinsicWidth;
                      if (iw > 0 && _computedValue! > iw) {
                        _computedValue = iw;
                      }
                    }
                  } else {
                  // Last resort: use available constraint width or mark for relayout
                  RenderBox? parentRenderBox = parentRenderStyle.attachedRenderBoxModel;
                  if (parentRenderBox != null && parentRenderBox.hasSize) {
                    double constraintWidth = parentRenderBox.constraints.maxWidth;
                    if (constraintWidth != double.infinity) {
                      _computedValue = value! * constraintWidth;
                      if (!isPositioned &&
                          parentRenderStyle.effectiveDisplay == CSSDisplay.inlineBlock &&
                          parentRenderStyle.width.isAuto &&
                          renderStyle != null &&
                          renderStyle!.isSelfRenderReplaced() &&
                          _computedValue != null) {
                        final double iw = renderStyle!.intrinsicWidth;
                        if (iw > 0 && _computedValue! > iw) {
                          _computedValue = iw;
                        }
                      }
                    } else {
                      // Avoid spurious relayout loops for shrink-to-fit inline-block cycles
                      renderStyle?.markParentNeedsRelayout();
                      _computedValue = double.infinity;
                    }
                  } else {
                    // Parent not laid out yet; mark once and return auto for now
                    renderStyle?.markParentNeedsRelayout();
                    _computedValue = double.infinity;
                  }
                }
              } else {
                _computedValue = double.infinity;
              }
            }
            break;
          case HEIGHT:
          case MIN_HEIGHT:
          case MAX_HEIGHT:
            // The percentage of height is calculated with respect to the height of the generated box's containing block.
            // If the height of the containing block is not specified explicitly (i.e., it depends on content height),
            // and this element is not absolutely positioned, the value computes to 'auto'.
            // https://www.w3.org/TR/CSS2/visudet.html#propdef-height
            // There are two exceptions when percentage height is resolved against actual render height of parent:
            // 1. positioned element
            // 2. parent is flex item
            RenderStyle? grandParentRenderStyle = parentRenderStyle?.getAttachedRenderParentRenderStyle();
            bool isGrandParentFlexLayout = grandParentRenderStyle?.display == CSSDisplay.flex ||
                grandParentRenderStyle?.display == CSSDisplay.inlineFlex;

            // The percentage height of positioned element and flex item resolves against the rendered height
            // of parent, mark parent as needs relayout if rendered height is not ready yet.
            if (isPositioned || isGrandParentFlexLayout) {
              double? relativeParentHeight = isPositioned ? parentPaddingBoxHeight : parentContentBoxHeight;
              if (relativeParentHeight != null) {
                _computedValue = value! * relativeParentHeight;
              } else {
                // Mark parent to relayout to get renderer height of parent.
                renderStyle?.markParentNeedsRelayout();
                _computedValue = double.infinity;
              }
            } else {
              double? relativeParentHeight = parentContentBoxLogicalHeight;
              if (relativeParentHeight != null) {
                _computedValue = value! * relativeParentHeight;
              } else {
                // Resolves height as auto if parent has no height specified.
                _computedValue = double.infinity;
              }
            }
            break;
          case PADDING_TOP:
          case PADDING_RIGHT:
          case PADDING_BOTTOM:
          case PADDING_LEFT:
          case MARGIN_LEFT:
          case MARGIN_RIGHT:
          case MARGIN_TOP:
          case MARGIN_BOTTOM:
            // https://www.w3.org/TR/css-box-3/#padding-physical
            // Percentage refer to logical width of containing block
            if (relativeParentWidth != null) {
              _computedValue = value! * relativeParentWidth;
            } else {
              // Mark parent to relayout to get renderer height of parent.
              renderStyle?.markParentNeedsRelayout();
              _computedValue = 0;
            }
            break;
          case FLEX_BASIS:
            // Flex-basis computation is called in RenderFlexLayout which
            // will ensure parent exists.
            RenderStyle? parentRenderStyle = renderStyle!.getAttachedRenderParentRenderStyle();
            if (parentRenderStyle == null) {
              _computedValue = 0;
              break;
            }
            double? mainContentSize =
                parentRenderStyle.flexDirection == FlexDirection.row ? parentContentBoxWidth : parentContentBoxHeight;
            if (mainContentSize != null) {
              _computedValue = mainContentSize * value!;
            } else {
              // Resolves as 0 when parent's inner main size is not specified.
              _computedValue = 0;
            }
            // Refer to the flex container's inner main size.
            break;

          // https://www.w3.org/TR/css-position-3/#valdef-top-percentage
          // The inset is a percentage relative to the containing block’s size in the corresponding
          // axis (e.g. width for left or right, height for top and bottom). For sticky positioned boxes,
          // the inset is instead relative to the relevant scrollport’s size. Negative values are allowed.
          case TOP:
          case BOTTOM:
            // Offset of positioned element starts from the edge of padding box of containing block.
            if (parentPaddingBoxHeight != null) {
              _computedValue = value! * parentPaddingBoxHeight;
            } else {
              // Mark parent to relayout to get renderer height of parent.
              renderStyle?.markParentNeedsRelayout();
              // Set as initial value, use infinity as auto value.
              _computedValue = double.infinity;
            }
            break;
          case LEFT:
          case RIGHT:
            // Offset of positioned element starts from the edge of padding box of containing block.
            if (parentPaddingBoxWidth != null) {
              _computedValue = value! * parentPaddingBoxWidth;
            } else {
              // Mark parent to relayout to get renderer height of parent.
              renderStyle?.markParentNeedsRelayout();
              _computedValue = double.infinity;
            }
            break;

          case TRANSLATE:
          case BACKGROUND_SIZE:
          case BORDER_TOP_LEFT_RADIUS:
          case BORDER_TOP_RIGHT_RADIUS:
          case BORDER_BOTTOM_LEFT_RADIUS:
          case BORDER_BOTTOM_RIGHT_RADIUS:
            // Percentages for the horizontal axis refer to the width of the box.
            // Percentages for the vertical axis refer to the height of the box.
            // Prefer actual laid-out border box size in order to stay consistent with
            // positioned offset calculations performed during layout. Fallback to
            // logical sizes when layout size is not yet available (e.g., pre-layout).
            double? borderBoxWidth = renderStyle!.borderBoxWidth ?? renderStyle!.borderBoxLogicalWidth;
            double? borderBoxHeight = renderStyle!.borderBoxHeight ?? renderStyle!.borderBoxLogicalHeight;
            double? borderBoxDimension = axisType == Axis.horizontal ? borderBoxWidth : borderBoxHeight;

              if (borderBoxDimension != null) {
                _computedValue = value! * borderBoxDimension;
              } else {
                _computedValue = propertyName == TRANSLATE
                    // Transform will be cached once resolved, so avoid resolve if width not defined.
                    // Use double.infinity to indicate percentage not resolved.
                    ? double.infinity
                    : 0;

            }
            break;
          case BACKGROUND_POSITION_X:
            double? borderBoxWidth = renderStyle!.borderBoxWidth ?? renderStyle!.borderBoxLogicalWidth;
            if (isPercentage && borderBoxWidth != null) {
              final destinationWidth = renderStyle?.getRenderBoxValueByType(RenderObjectGetType.self,
                      (renderBox, _) => renderBox.boxPainter?.backgroundImageSize?.width.toDouble()) ??
                  0;
              _computedValue = (borderBoxWidth - destinationWidth) * value!;
              if (DebugFlags.enableBackgroundLogs) {
                renderingLogger.finer('[Background] resolve BACKGROUND_POSITION_X: containerW=' '${borderBoxWidth.toStringAsFixed(2)} destW=${destinationWidth.toStringAsFixed(2)} pct=${(value! * 100).toStringAsFixed(1)}% -> ${_computedValue!.toStringAsFixed(2)}');
              }
            } else {
              _computedValue = value!;
            }
            break;
          case BACKGROUND_POSITION_Y:
            double? borderBoxHeight = renderStyle!.borderBoxHeight ?? renderStyle!.borderBoxLogicalHeight;
            if (isPercentage && borderBoxHeight != null) {
              final destinationHeight = renderStyle?.getRenderBoxValueByType(RenderObjectGetType.self,
                      (renderBox, _) => renderBox.boxPainter?.backgroundImageSize?.height.toDouble()) ??
                  0;
              _computedValue = (borderBoxHeight - destinationHeight) * value!;
              if (DebugFlags.enableBackgroundLogs) {
                renderingLogger.finer('[Background] resolve BACKGROUND_POSITION_Y: containerH=' '${borderBoxHeight.toStringAsFixed(2)} destH=${destinationHeight.toStringAsFixed(2)} pct=${(value! * 100).toStringAsFixed(1)}% -> ${_computedValue!.toStringAsFixed(2)}');
              }
            } else {
              _computedValue = value!;
            }
            break;

          case GAP:
          case ROW_GAP:
          case COLUMN_GAP:
            // Gap percentages resolve against the content area of the container itself
            // For row-gap: against the container's height
            // For column-gap: against the container's width
            // For gap (shorthand): against width for horizontal, height for vertical
            double? containerContentWidth = renderStyle!.contentBoxWidth ?? renderStyle!.contentBoxLogicalWidth;
            double? containerContentHeight = renderStyle!.contentBoxHeight ?? renderStyle!.contentBoxLogicalHeight;

            if (realPropertyName == ROW_GAP) {
              // Row gap resolves against container height
              if (containerContentHeight != null && containerContentHeight > 0) {
                _computedValue = value! * containerContentHeight;
              } else {
                _computedValue = 0;
              }
            } else if (realPropertyName == COLUMN_GAP) {
              // Column gap resolves against container width
              if (containerContentWidth != null && containerContentWidth > 0) {
                _computedValue = value! * containerContentWidth;
              } else {
                _computedValue = 0;
              }
            } else {
              // GAP shorthand - resolve against width (like column-gap for now)
              if (containerContentWidth != null && containerContentWidth > 0) {
                _computedValue = value! * containerContentWidth;
              } else {
                _computedValue = 0;
              }
            }
            break;
        }
        break;
      case CSSLengthType.CONTENT:
        // The 'content' keyword is only valid for certain properties like flex-basis.
        // Defer resolution to the layout algorithm; treat as 0 length here so callers
        // that incorrectly query computedValue don't crash. Layout code must special-case.
        _computedValue = 0;
        break;
      case CSSLengthType.MIN_CONTENT:
      case CSSLengthType.MAX_CONTENT:
      case CSSLengthType.FIT_CONTENT:
        // Intrinsic sizing keywords can't be resolved to a fixed length without
        // layout context; treat as 0 here and let layout algorithms special-case.
        _computedValue = 0;
        break;
      default:
        // @FIXME: Type AUTO not always resolves to 0, in cases such as `margin: auto`, `width: auto`.
        _computedValue = 0;
    }

    // Ensure _computedValue is never null
    _computedValue ??= 0;

    // CSS padding values are non-negative; clamp invalid negative values to 0
    // to match spec behavior and avoid negative EdgeInsets during layout.
    if (realPropertyName == PADDING_TOP ||
        realPropertyName == PADDING_RIGHT ||
        realPropertyName == PADDING_BOTTOM ||
        realPropertyName == PADDING_LEFT ||
        realPropertyName == PADDING_INLINE_START ||
        realPropertyName == PADDING_INLINE_END ||
        realPropertyName == PADDING_BLOCK_START ||
        realPropertyName == PADDING_BLOCK_END) {
      final double v = _computedValue!;
      _computedValue = (!v.isFinite || v < 0) ? 0 : v;
    }

    // Cache computed value.
    if (renderStyle?.hasRenderBox() == true && propertyName != null && type != CSSLengthType.PERCENTAGE) {
      cacheComputedValue(renderStyle!, propertyName!, _computedValue!);
    }
    return _computedValue!;
  }

  bool get isAuto {
    if (calcValue != null) {
      if (calcValue!.expression == null) {
        return true;
      }
    }
    switch (propertyName) {
      // Length is considered as auto of following properties
      // if it computes to double.infinity in cases of percentage.
      // The percentage of height is calculated with respect to the height of the generated box's containing block.
      // If the height of the containing block is not specified explicitly (i.e., it depends on content height),
      // and this element is not absolutely positioned, the value computes to 'auto'.
      // https://www.w3.org/TR/CSS2/visudet.html#propdef-height
      case WIDTH:
      case MIN_WIDTH:
      case MAX_WIDTH:
      case HEIGHT:
      case MIN_HEIGHT:
      case MAX_HEIGHT:
      case TOP:
      case BOTTOM:
      case LEFT:
      case RIGHT:
        if (computedValue == double.infinity) {
          return true;
        }
        break;
    }
    return type == CSSLengthType.AUTO;
  }

  bool get isNotAuto {
    return !isAuto;
  }

  bool get isPrecise {
    return type == CSSLengthType.PX ||
        type == CSSLengthType.VW ||
        type == CSSLengthType.VH ||
        type == CSSLengthType.VMIN ||
        type == CSSLengthType.VMAX ||
        type == CSSLengthType.EM ||
        type == CSSLengthType.CH ||
        type == CSSLengthType.REM ||
        type == CSSLengthType.PERCENTAGE;
  }

  bool get isNone {
    return type == CSSLengthType.NONE;
  }

  bool get isNotNone {
    return type != CSSLengthType.NONE;
  }

  bool get isPercentage {
    return type == CSSLengthType.PERCENTAGE;
  }

  bool get isZero {
    return value == 0;
  }

  bool get isMinContent => type == CSSLengthType.MIN_CONTENT;
  bool get isMaxContent => type == CSSLengthType.MAX_CONTENT;
  bool get isFitContent => type == CSSLengthType.FIT_CONTENT;
  bool get isIntrinsic => isMinContent || isMaxContent || isFitContent;

  /// Compares two length for equality.
  @override
  bool operator ==(Object other) {
    return other is CSSLengthValue && other.value == value && other.calcValue == calcValue && (isZero || other.type == type);
  }

  @override
  int get hashCode => Object.hash(value, type);

  @override
  String toString() =>
      'CSSLengthValue(value: $value, unit: $type, computedValue: $computedValue, calcValue: $calcValue)';
}

// Cache computed length value during perform layout.
// format: { hashCode: { renderStyleKey: renderStyleValue } }
final LinkedLruHashMap<int, Map<String, double>> _cachedComputedValue = LinkedLruHashMap(maximumSize: 500);

// Get computed length value from cache only in perform layout stage.
double? getCachedComputedValue(RenderStyle renderStyle, String propertyName) {
  if (renderBoxInLayoutHashCodes.isNotEmpty) {
    return _cachedComputedValue[renderStyle.hashCode]?[propertyName];
  }
  return null;
}

// Cache computed length value only in perform layout stage.
void cacheComputedValue(RenderStyle renderStyle, String propertyName, double value) {
  if (renderBoxInLayoutHashCodes.isNotEmpty) {
    _cachedComputedValue[renderStyle.hashCode] = _cachedComputedValue[renderStyle.hashCode] ?? {};
    _cachedComputedValue[renderStyle.hashCode]![propertyName] = value;
  }
}

void _clearCssLengthStaticValue() {
  CSSLengthValue.zero.renderStyle = null;
  CSSLengthValue.auto.renderStyle = null;
  CSSLengthValue.initial.renderStyle = null;
  CSSLengthValue.unknown.renderStyle = null;
  CSSLengthValue.normal.renderStyle = null;
  CSSLengthValue.none.renderStyle = null;
}

void clearCssLength() {
  clearComputedValueCache();
  _clearCssLengthStaticValue();
}

// Clear all the computed length value cache.
void clearComputedValueCache() {
  _cachedComputedValue.clear();
}

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#lengths
class CSSLength {
  static double? toDouble(value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    } else {
      return null;
    }
  }

  static int? toInt(value) {
    if (value is double) {
      return value.toInt();
    } else if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }

  static bool isAuto(String? value) {
    return value == AUTO;
  }

  static bool isInitial(String? value) {
    return value == INITIAL;
  }

  static bool isLength(String? value) {
    return value != null && (value == ZERO || _lengthRegExp.hasMatch(value));
  }

  static bool isNonNegativeLength(String? value) {
    return value != null &&
        (value == ZERO ||
            _negativeZeroRegExp.hasMatch(value) // Negative zero is considered to be equal to zero.
            ||
            _nonNegativeLengthRegExp.hasMatch(value));
  }

  static CSSLengthValue? resolveLength(String text, RenderStyle renderStyle, String propertyName) {
    if (text.isEmpty) {
      // Empty string means delete value.
      return null;
    } else {
      return parseLength(text, renderStyle, propertyName);
    }
  }

  static CSSLengthValue parseLength(String text, RenderStyle? renderStyle, [String? propertyName, Axis? axisType]) {
    double? value;
    CSSLengthType unit = CSSLengthType.PX;
    if (text == ZERO) {
      // Only '0' is accepted with no unit.
      return CSSLengthValue.zero;
    } else if (text == INITIAL) {
      return CSSLengthValue.initial;
    } else if (text == INHERIT) {
      // Per CSS Cascade, `inherit` sets the computed value on the element to
      // the computed value of its parent. For <length-percentage> properties,
      // this means percentage should remain a percentage (e.g. `100%`) and then
      // be resolved against the *child's* containing block during layout.
      //
      // Avoid resolving percentages using the parent's containing block (which
      // would incorrectly turn `100%` into an absolute px length here).
      if (renderStyle != null && propertyName != null) {
        final parent = renderStyle.target.parentElement;
        if (parent != null) {
          final dynamic parentComputed = parent.renderStyle.getProperty(propertyName);
          if (parentComputed is CSSLengthValue) {
            final String computedText = parentComputed.cssText();
            if (computedText.isNotEmpty) {
              return parseLength(computedText, renderStyle, propertyName, axisType);
            }
          }

          // Fallback to parent's serialized specified value when computed is unavailable.
          final String specified = parent.style.getPropertyValue(propertyName);
          if (specified.isNotEmpty) {
            return parseLength(specified, renderStyle, propertyName, axisType);
          }
        }

        // Root element (or missing parent): fall back to initial value.
        final String initialValue = (cssInitialValues[propertyName] as String?) ?? AUTO;
        return parseLength(initialValue, renderStyle, propertyName, axisType);
      }

      return CSSLengthValue.unknown;
    } else if (text == AUTO) {
      return CSSLengthValue.auto;
    } else if (text == NONE) {
      return CSSLengthValue.none;
    } else if (text.toLowerCase() == 'content') {
      // flex-basis: content
      return CSSLengthValue(null, CSSLengthType.CONTENT, renderStyle, propertyName, axisType);
    } else if (text.toLowerCase() == 'min-content') {
      return CSSLengthValue(null, CSSLengthType.MIN_CONTENT, renderStyle, propertyName, axisType);
    } else if (text.toLowerCase() == 'max-content') {
      return CSSLengthValue(null, CSSLengthType.MAX_CONTENT, renderStyle, propertyName, axisType);
    } else if (text.toLowerCase() == 'fit-content') {
      return CSSLengthValue(null, CSSLengthType.FIT_CONTENT, renderStyle, propertyName, axisType);
    } else if (text.endsWith(REM)) {
      value = double.tryParse(text.split(REM)[0]);
      unit = CSSLengthType.REM;
    } else if (text.endsWith(EM)) {
      value = double.tryParse(text.split(EM)[0]);
      unit = CSSLengthType.EM;
    } else if (text.endsWith(EX)) {
      value = double.tryParse(text.split(EX)[0]);
      unit = CSSLengthType.EX;
    } else if (text.endsWith(CH)) {
      value = double.tryParse(text.split(CH)[0]);
      unit = CSSLengthType.CH;
    } else if (text.endsWith(RPX)) {
      value = double.tryParse(text.split(RPX)[0]);
      unit = CSSLengthType.RPX;
    } else if (text.endsWith(PX)) {
      value = double.tryParse(text.split(PX)[0]);
    } else if (text.endsWith(VW)) {
      value = double.tryParse(text.split(VW)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VW;
    } else if (text.endsWith(VH)) {
      value = double.tryParse(text.split(VH)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VH;
    } else if (text.endsWith(CM)) {
      value = double.tryParse(text.split(CM)[0]);
      if (value != null) value = value * _1cm;
    } else if (text.endsWith(MM)) {
      value = double.tryParse(text.split(MM)[0]);
      if (value != null) value = value * _1mm;
    } else if (text.endsWith(PC)) {
      value = double.tryParse(text.split(PC)[0]);
      if (value != null) value = value * _1pc;
    } else if (text.endsWith(PT)) {
      value = double.tryParse(text.split(PT)[0]);
      if (value != null) value = value * _1pt;
    } else if (text.endsWith(VMIN)) {
      value = double.tryParse(text.split(VMIN)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VMIN;
    } else if (text.endsWith(VMAX)) {
      value = double.tryParse(text.split(VMAX)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VMAX;
    } else if (text.endsWith(IN)) {
      value = double.tryParse(text.split(IN)[0]);
      if (value != null) value = value * _1in;
    } else if (text.endsWith(Q)) {
      value = double.tryParse(text.split(Q)[0]);
      if (value != null) value = value * _1Q;
    } else if (text.endsWith(PERCENTAGE)) {
      value = double.tryParse(text.split(PERCENTAGE)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.PERCENTAGE;
    } else if (CSSFunction.isFunction(text)) {
      if (renderStyle != null) {
        CSSCalcValue? calcValue = CSSCalcValue.tryParse(renderStyle, propertyName ?? '', text);
        if (calcValue != null) {
          return CSSLengthValue.calc(calcValue, renderStyle, propertyName);
        }
      }
    } else {
      value = double.tryParse(text);
    }

    if (value == 0 && unit != CSSLengthType.PERCENTAGE) {
      return CSSLengthValue.zero;
    } else if (value == null) {
      return CSSLengthValue.unknown;
    } else if (unit == CSSLengthType.PX) {
      return CSSLengthValue(value, unit);
    } else {
      return CSSLengthValue(value, unit, renderStyle, propertyName, axisType);
    }
  }
}
