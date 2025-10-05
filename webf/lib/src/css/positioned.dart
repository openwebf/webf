/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/foundation/logger.dart';
import 'package:webf/src/foundation/positioned_layout_logging.dart';

// CSS Positioned Layout: https://drafts.csswg.org/css-position/

// RenderPositionHolder may be affected by overflow: scroller offset.
// We need to reset these offset to keep positioned elements render at their original position.
// @NOTE: Attention that renderObjects in tree may not all subtype of RenderBoxModel, use `is` to identify.
Offset? _getRenderPositionHolderScrollOffset(RenderPositionPlaceholder holder, RenderObject root) {
  RenderObject? current = holder.parent;
  while (current != null && current != root) {
    if (current is RenderBoxModel) {
      if (current.clipX || current.clipY) {
        return Offset(current.scrollLeft, current.scrollTop);
      }
    }
    current = current.parent;
  }
  return null;
}

// Get the offset of the RenderPlaceholder of positioned element to its parent RenderBoxModel.
Offset _getPlaceholderToParentOffset(RenderPositionPlaceholder? placeholder, RenderBoxModel parent,
    {bool excludeScrollOffset = false}) {
  if (placeholder == null || !placeholder.attached) {
    return Offset.zero;
  }
  Offset positionHolderScrollOffset = _getRenderPositionHolderScrollOffset(placeholder, parent) ?? Offset.zero;
  // Offset of positioned element should exclude scroll offset to its containing block.
  Offset toParentOffset =
      placeholder.getOffsetToAncestor(Offset.zero, parent, excludeScrollOffset: excludeScrollOffset);
  Offset placeholderOffset = positionHolderScrollOffset + toParentOffset;

  return placeholderOffset;
}

class CSSPositionedLayout {
  // Find nearest scroll container ancestor for a given node.
  // A scroll container is any RenderBoxModel with overflow not visible on either axis.
  static RenderBoxModel? _nearestScrollContainer(RenderObject start) {
    RenderObject? current = start;
    while (current != null) {
      if (current is RenderBoxModel) {
        if (current.clipX || current.clipY) return current;
      }
      current = current.parent;
    }
    return null;
  }

  // Compute viewport size of a scroll container's padding box.
  static Size _scrollViewportSize(RenderBoxModel scrollContainer) {
    final CSSRenderStyle rs = scrollContainer.renderStyle;
    final double vw = math.max(
      0.0,
      scrollContainer.size.width -
          rs.effectiveBorderLeftWidth.computedValue -
          rs.effectiveBorderRightWidth.computedValue,
    );
    final double vh = math.max(
      0.0,
      scrollContainer.size.height -
          rs.effectiveBorderTopWidth.computedValue -
          rs.effectiveBorderBottomWidth.computedValue,
    );
    return Size(vw, vh);
  }

  static Offset? getRelativeOffset(RenderStyle renderStyle) {
    CSSLengthValue left = renderStyle.left;
    CSSLengthValue right = renderStyle.right;
    CSSLengthValue top = renderStyle.top;
    CSSLengthValue bottom = renderStyle.bottom;
    if (renderStyle.position == CSSPositionType.relative) {
      double? dx;
      double? dy;

      // CSS2.1 §9.4.3 (Relative positioning): If both 'left' and 'right' are
      // specified as non-auto values, the 'direction' property determines which
      // one applies: in LTR, 'left' wins; in RTL, 'right' wins.
      final bool hasLeft = left.isNotAuto;
      final bool hasRight = right.isNotAuto;
      if (hasLeft && hasRight) {
        if (renderStyle.direction == TextDirection.rtl) {
          // RTL: use 'right' and ignore 'left'
          dx = -right.computedValue;
        } else {
          // LTR: use 'left' and ignore 'right'
          dx = left.computedValue;
        }
      } else if (hasLeft) {
        dx = left.computedValue;
      } else if (hasRight) {
        dx = -right.computedValue;
      }

      // Vertical axis: if both 'top' and 'bottom' are non-auto, 'top' wins per CSS2.1.
      final bool hasTop = top.isNotAuto;
      final bool hasBottom = bottom.isNotAuto;
      if (hasTop) {
        dy = top.computedValue;
      } else if (hasBottom) {
        dy = -bottom.computedValue;
      }

      if (dx != null || dy != null) {
        return Offset(dx ?? 0, dy ?? 0);
      }
    }
    return null;
  }

  static void applyRelativeOffset(Offset? relativeOffset, RenderBox renderBox) {
    RenderLayoutParentData? boxParentData = renderBox.parentData as RenderLayoutParentData?;

    if (boxParentData != null) {
      Offset? styleOffset;
      // Text node does not have relative offset
      if (renderBox is RenderBoxModel) {
        styleOffset = getRelativeOffset(renderBox.renderStyle);
      }

      if (relativeOffset != null) {
        if (styleOffset != null) {
          boxParentData.offset = relativeOffset.translate(styleOffset.dx, styleOffset.dy);
        } else {
          boxParentData.offset = relativeOffset;
        }
      } else {
        boxParentData.offset = styleOffset!;
      }
    }
  }

  static bool isSticky(RenderBoxModel child) {
    final renderStyle = child.renderStyle;
    return renderStyle.position == CSSPositionType.sticky &&
        (renderStyle.top.isNotAuto ||
            renderStyle.left.isNotAuto ||
            renderStyle.bottom.isNotAuto ||
            renderStyle.right.isNotAuto);
  }

  static void layoutPositionedChild(RenderBoxModel parent, RenderBoxModel child, {bool needsRelayout = false}) {
    BoxConstraints childConstraints = child.getConstraints();

    // Whether child need to layout
    bool isChildNeedsLayout = true;
    if (child.hasSize && !needsRelayout && (childConstraints == child.constraints) && (!child.needsLayout)) {
      isChildNeedsLayout = false;
    }

    if (isChildNeedsLayout) {
      try {
        PositionedLayoutLog.log(
          impl: PositionedImpl.layout,
          feature: PositionedFeature.layout,
          message: () => '<${child.renderStyle.target.tagName.toLowerCase()}> layout start '
              'constraints=(${childConstraints.minWidth.toStringAsFixed(1)}..${childConstraints.maxWidth.isFinite ? childConstraints.maxWidth.toStringAsFixed(1) : '∞'}, '
              '${childConstraints.minHeight.toStringAsFixed(1)}..${childConstraints.maxHeight.isFinite ? childConstraints.maxHeight.toStringAsFixed(1) : '∞'})',
        );
      } catch (_) {}
      // Should create relayoutBoundary for positioned child.
      child.layout(childConstraints, parentUsesSize: false);
      try {
        final Size s = child.size;
        PositionedLayoutLog.log(
          impl: PositionedImpl.layout,
          feature: PositionedFeature.layout,
          message: () => '<${child.renderStyle.target.tagName.toLowerCase()}> layout done size=${s.width.toStringAsFixed(2)}×${s.height.toStringAsFixed(2)}',
        );
      } catch (_) {}
    }
  }

  // Position of positioned element involves inset, size , margin and its containing block size.
  // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
  static void applyPositionedChildOffset(
    RenderBoxModel parent,
    RenderBoxModel child,
  ) {
    RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
    Size size = child.boxSize!;
    Size parentSize = parent.boxSize!;

    RenderStyle parentRenderStyle = parent.renderStyle;

    CSSLengthValue parentBorderLeftWidth = parentRenderStyle.effectiveBorderLeftWidth;
    CSSLengthValue parentBorderRightWidth = parentRenderStyle.effectiveBorderRightWidth;
    CSSLengthValue parentBorderTopWidth = parentRenderStyle.effectiveBorderTopWidth;
    CSSLengthValue parentBorderBottomWidth = parentRenderStyle.effectiveBorderBottomWidth;
    CSSLengthValue parentPaddingLeft = parentRenderStyle.paddingLeft;
    CSSLengthValue parentPaddingTop = parentRenderStyle.paddingTop;

    // The containing block of not an inline box is formed by the padding edge of the ancestor.
    // Thus the final offset of child need to add the border of parent.
    // https://www.w3.org/TR/css-position-3/#def-cb
    Size containingBlockSize = Size(
        parentSize.width - parentBorderLeftWidth.computedValue - parentBorderRightWidth.computedValue,
        parentSize.height - parentBorderTopWidth.computedValue - parentBorderBottomWidth.computedValue);

    CSSRenderStyle childRenderStyle = child.renderStyle;
    CSSLengthValue left = childRenderStyle.left;
    CSSLengthValue right = childRenderStyle.right;
    CSSLengthValue top = childRenderStyle.top;
    CSSLengthValue bottom = childRenderStyle.bottom;
    CSSLengthValue marginLeft = childRenderStyle.marginLeft;
    CSSLengthValue marginRight = childRenderStyle.marginRight;
    CSSLengthValue marginTop = childRenderStyle.marginTop;
    CSSLengthValue marginBottom = childRenderStyle.marginBottom;

    // Fix side effects by render portal.
    if (child is RenderEventListener && child.child is RenderBoxModel) {
      child = child.child as RenderBoxModel;
      childParentData = child.parentData as RenderLayoutParentData;
    }

    // The static position of positioned element is its offset when its position property had been static
    // which equals to the position of its placeholder renderBox.
    // https://www.w3.org/TR/CSS2/visudet.html#static-position
    RenderPositionPlaceholder? ph = child.renderStyle.getSelfPositionPlaceHolder();
    Offset staticPositionOffset = _getPlaceholderToParentOffset(ph, parent,
        excludeScrollOffset: child.renderStyle.position != CSSPositionType.fixed);

    try {
      final pTag = parent.renderStyle.target.tagName.toLowerCase();
      final cTag = child.renderStyle.target.tagName.toLowerCase();
      final phOff = (ph != null && ph.parentData is RenderLayoutParentData)
          ? (ph.parentData as RenderLayoutParentData).offset
          : null;
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.staticPosition,
        message: () => '<$cTag> static from placeholder: raw=${phOff == null ? 'null' : '${phOff.dx.toStringAsFixed(2)},${phOff.dy.toStringAsFixed(2)}'} '
            'toParent=${staticPositionOffset.dx.toStringAsFixed(2)},${staticPositionOffset.dy.toStringAsFixed(2)} parent=<$pTag>',
      );
    } catch (_) {}

    // Diagnostics: static-position context snapshot
    try {
      final cTag = child.renderStyle.target.tagName.toLowerCase();
      final dispSpec = child.renderStyle.display.toString().split('.').last;
      final dispEff = child.renderStyle.effectiveDisplay.toString().split('.').last;
      final posType = child.renderStyle.position.toString().split('.').last;
      final phParent = ph == null ? 'null' : ph.parent.runtimeType.toString();
      final bool phInIFC = ph != null && ph.parent is RenderFlowLayout && (ph.parent as RenderFlowLayout).establishIFC;
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.staticPosition,
        message: () => 'context <${cTag}> pos=${posType} disp(spec=${dispSpec}, eff=${dispEff}) '
            'parentIsDocRoot=${parent.isDocumentRootBox} phParent=${phParent} phInIFC=${phInIFC}',
      );
    } catch (_) {}

    // Ensure static position accuracy for W3C compliance
    // W3C requires static position to represent where element would be in normal flow
    Offset adjustedStaticPosition = _ensureAccurateStaticPosition(
      staticPositionOffset,
      child,
      parent,
      left,
      right,
      top,
      bottom,
      parentBorderLeftWidth,
      parentBorderRightWidth,
      parentBorderTopWidth,
      parentBorderBottomWidth,
      parentPaddingLeft,
      parentPaddingTop
    );

    // Inline static-position correction (horizontal): when the placeholder sits inside
    // an IFC container (e.g., text followed by abspos inline), align the static X to the
    // inline advance within that container's content box so that `left:auto` follows the
    // preceding inline content per CSS static-position rules.
    // Only apply when the containing block is not the document root. Root cases are handled
    // specially below to preserve expected behavior.
    if (!parent.isDocumentRootBox && ph != null) {
      // Find the nearest ancestor flow container that establishes an IFC.
      RenderObject? a = ph.parent;
      RenderFlowLayout? flowParent;
      while (a != null) {
        if (a is RenderFlowLayout && a.establishIFC) {
          flowParent = a;
          break;
        }
        a = (a.parent is RenderObject) ? a.parent as RenderObject? : null;
      }
      if (flowParent != null) {
        // Only inline-level hypothetical boxes should use inline advance for static X.
        // Use specified display (not effective) to avoid misclassifying inline elements
        // that are out-of-flow as block.
        final CSSDisplay childDisp = child.renderStyle.display;
        final bool childIsBlockLike = (childDisp == CSSDisplay.block || childDisp == CSSDisplay.flex);
        // Base content-left inset inside the IFC container
        final double contentLeftInset =
            flowParent.renderStyle.effectiveBorderLeftWidth.computedValue +
            flowParent.renderStyle.paddingLeft.computedValue;
        if (!childIsBlockLike) {
          // Use IFC-provided inline advance; when unavailable (e.g., empty inline), keep 0.
          double inlineAdvance = flowParent.inlineAdvanceBefore(ph);
          try {
            PositionedLayoutLog.log(
              impl: PositionedImpl.layout,
              feature: PositionedFeature.staticPosition,
              message: () => 'IFC inline advance (non-root inline)=${inlineAdvance.toStringAsFixed(2)}',
            );
          } catch (_) {}
          if (inlineAdvance == 0.0) {
            // Fallback: if placeholder is appended after inline content within this IFC container,
            // use the paragraph visual max line width as the preceding inline advance.
            final bool hasPrecedingInline = _hasInlineContentBeforePlaceholder(flowParent, ph);
            if (hasPrecedingInline && flowParent.inlineFormattingContext != null) {
              inlineAdvance = flowParent.inlineFormattingContext!.paragraphVisualMaxLineWidth;
              try {
                PositionedLayoutLog.log(
                  impl: PositionedImpl.layout,
                  feature: PositionedFeature.staticPosition,
                  message: () => 'fallback inline advance by paragraph width =${inlineAdvance.toStringAsFixed(2)}',
                );
              } catch (_) {}
            }
          }
          // Do not use inline advance when the abspos has percentage width (e.g., width:100%),
          // since the horizontal insets equation will use the static position as 'left' and a
          // percentage width that fills the containing block; browsers effectively align such
          // overlays at the content-left (no inline advance).
          final bool widthIsPercentage = child.renderStyle.width.type == CSSLengthType.PERCENTAGE;
          final double effAdvance = widthIsPercentage ? 0.0 : inlineAdvance;
          // Compute flow content-left in CB space and add inline advance.
          final Offset _phToFlow = _getPlaceholderToParentOffset(ph, flowParent, excludeScrollOffset: true);
          final double targetX = staticPositionOffset.dx - _phToFlow.dx + contentLeftInset + effAdvance;
          adjustedStaticPosition = Offset(targetX, adjustedStaticPosition.dy);
          try {
            PositionedLayoutLog.log(
              impl: PositionedImpl.layout,
              feature: PositionedFeature.staticPosition,
              message: () => 'adjust static pos by IFC inline advance '
                  'contentLeft=${contentLeftInset.toStringAsFixed(2)} '
                  'advance=${effAdvance.toStringAsFixed(2)} '
                  '→ (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
            );
          } catch (_) {}
          // Vertical: when both top and bottom are auto, align to the IFC container's
          // content-top in CB coordinates so the abspos sits at the top of the line box.
          if (top.isAuto && bottom.isAuto) {
            final double contentTopInset = flowParent.renderStyle.paddingTop.computedValue +
                flowParent.renderStyle.effectiveBorderTopWidth.computedValue;
            final double targetY = staticPositionOffset.dy - _phToFlow.dy + contentTopInset;
            adjustedStaticPosition = Offset(adjustedStaticPosition.dx, targetY);
            try {
              PositionedLayoutLog.log(
                impl: PositionedImpl.layout,
                feature: PositionedFeature.staticPosition,
                message: () => 'adjust static Y by IFC content-top '
                    'flowContentTopInCB=${targetY.toStringAsFixed(2)}',
              );
            } catch (_) {}
          }
        } else {
          // Block-level hypothetical box: anchor to flow content-left in CB space.
          if (contentLeftInset != 0.0) {
            final Offset _phToFlow = _getPlaceholderToParentOffset(ph, flowParent, excludeScrollOffset: true);
            final double targetX = staticPositionOffset.dx - _phToFlow.dx + contentLeftInset;
            adjustedStaticPosition = Offset(targetX, adjustedStaticPosition.dy);
            try {
              PositionedLayoutLog.log(
                impl: PositionedImpl.layout,
                feature: PositionedFeature.staticPosition,
                message: () => 'adjust static pos by IFC content-left for block '
                    'contentLeft=${contentLeftInset.toStringAsFixed(2)} '
                    '→ (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
              );
            } catch (_) {}
          }
          // Block-level vertical: place below the inline line box height when top/bottom are auto
          // AND there is preceding inline content before the placeholder.
          if (top.isAuto && bottom.isAuto) {
            // Determine preceding inline by structural scan when width sums are unavailable.
            final bool hasPrecedingInline = _hasInlineContentBeforePlaceholder(flowParent, ph);
            try {
              PositionedLayoutLog.log(
                impl: PositionedImpl.layout,
                feature: PositionedFeature.staticPosition,
                message: () => 'non-root IFC block: hasPrecedingInline=${hasPrecedingInline}',
              );
            } catch (_) {}
            if (hasPrecedingInline) {
              final InlineFormattingContext? ifc = flowParent.inlineFormattingContext;
              if (ifc != null) {
                double paraH;
                final lines = ifc.paragraphLineMetrics;
                if (lines.isNotEmpty) {
                  paraH = lines.fold<double>(0.0, (sum, lm) => sum + lm.height);
                } else {
                  paraH = ifc.paragraph?.height ?? 0.0;
                }
                if (paraH != 0.0 && adjustedStaticPosition.dy.abs() < 0.5) {
                  adjustedStaticPosition = adjustedStaticPosition.translate(0, paraH);
                  try {
                  PositionedLayoutLog.log(
                    impl: PositionedImpl.layout,
                    feature: PositionedFeature.staticPosition,
                    message: () => 'adjust static pos by IFC paragraph height for block '
                        'lines=${lines.length} h=${paraH.toStringAsFixed(2)} '
                        '→ (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
                  );
                  } catch (_) {}
                }
              }
            }
          }
        }

        // Vertical static position for top/bottom auto in IFC:
        // Anchor to the IFC container's content top so the abspos aligns with
        // the line box where the placeholder sits (top of the first line).
        if (top.isAuto && bottom.isAuto) {
          final double padTop = flowParent.renderStyle.paddingTop.computedValue;
          final double borderTop = flowParent.renderStyle.effectiveBorderTopWidth.computedValue;
          final double contentTopInset = padTop + borderTop;
          if (contentTopInset != 0.0 && adjustedStaticPosition.dy.abs() < 0.5) {
            adjustedStaticPosition = adjustedStaticPosition.translate(0, contentTopInset);
            try {
              PositionedLayoutLog.log(
                impl: PositionedImpl.layout,
                feature: PositionedFeature.staticPosition,
                message: () => 'adjust static pos by IFC contentTop '
                    'inset=${contentTopInset.toStringAsFixed(2)} '
                    '→ (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
              );
            } catch (_) {}
          }
        }
      }
    }

    // If the containing block is the document root (<html>) and the placeholder lives
    // under the block formatting context of <body>, align the static position vertically
    // with the first in-flow block-level child’s collapsed top (ignoring parent collapse).
    // This matches browser behavior where the first in-flow child’s top margin effectively
    // offsets the visible content from the root. The positioned element’s static position
    // should reflect that visual start so the out-of-flow element and the following in-flow
    // element align vertically when no insets are specified.
    if (parent.isDocumentRootBox && ph != null) {
      final RenderObject? phParent = ph.parent;
      if (phParent is RenderBoxModel) {
        final RenderBoxModel phContainer = phParent;
        final RenderStyle cStyle = phContainer.renderStyle;
        final bool qualifiesBFC =
            cStyle.isLayoutBox() &&
            cStyle.effectiveDisplay == CSSDisplay.block &&
            (cStyle.effectiveOverflowY == CSSOverflowType.visible || cStyle.effectiveOverflowY == CSSOverflowType.clip) &&
            cStyle.paddingTop.computedValue == 0 &&
            cStyle.effectiveBorderTopWidth.computedValue == 0;

        // Only adjust when placeholder is the first attached child (no previous in-flow block)
        final bool isFirstChild = (ph.parentData is RenderLayoutParentData) &&
            ((ph.parentData as RenderLayoutParentData).previousSibling == null);

        if (qualifiesBFC && isFirstChild) {
          final RenderBoxModel? firstFlow = _resolveNextInFlowSiblingModel(ph);
          if (firstFlow != null) {
            final double childTopIgnoringParent = firstFlow.renderStyle.collapsedMarginTopIgnoringParent;
            if (childTopIgnoringParent != 0) {
              adjustedStaticPosition = adjustedStaticPosition.translate(0, childTopIgnoringParent);
              try {
                PositionedLayoutLog.log(
                  impl: PositionedImpl.layout,
                  feature: PositionedFeature.staticPosition,
                  message: () => 'adjust static pos by first in-flow child top(${childTopIgnoringParent.toStringAsFixed(2)}) '
                      '→ (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
                );
              } catch (_) {}
            }
          }
        }

        // Horizontal static-position in IFC under document root: when placeholder lives in an
        // inline formatting context (e.g., <div><span>text</span><abspos/></div>) but the containing
        // block is <html>, the static X should reflect the inline advance within the IFC container.
        // Compute inline advance from the IFC paragraph; if the placeholder is the last child,
        // fall back to the paragraph’s visual max line width.
        // Use the nearest IFC container up the chain for horizontal inline advance.
        RenderFlowLayout? flowParent;
        if (phParent is RenderFlowLayout && phParent.establishIFC) {
          flowParent = phParent as RenderFlowLayout;
        } else {
          RenderObject? a = phParent.parent;
          while (a != null) {
            if (a is RenderFlowLayout && a.establishIFC) {
              flowParent = a;
              break;
            }
            a = (a.parent is RenderObject) ? a.parent as RenderObject? : null;
          }
        }
        if (flowParent != null) {
          // Base inset: content-left inside the IFC container
          final double contentLeftInset =
              flowParent.renderStyle.effectiveBorderLeftWidth.computedValue +
              flowParent.renderStyle.paddingLeft.computedValue;
          // Under document root, honor block-level vs inline-level behavior:
          // - Block/flex: anchor to content-left only (x = content-left), no vertical shift.
          // - Inline-level: add horizontal inline advance before placeholder.
          // Use the specified display for block-vs-inline determination; effectiveDisplay
          // is normalized for out-of-flow and may not reflect original block-vs-inline.
          final CSSDisplay childDispSpecified = child.renderStyle.display;
          final bool childIsBlockLike = (childDispSpecified == CSSDisplay.block || childDispSpecified == CSSDisplay.flex);
          try {
            PositionedLayoutLog.log(
              impl: PositionedImpl.layout,
              feature: PositionedFeature.staticPosition,
              message: () => 'doc-root IFC path: dispSpecified=${childDispSpecified.toString().split('.').last} '
                  'blockLike=${childIsBlockLike} contentLeft=${contentLeftInset.toStringAsFixed(2)}',
            );
          } catch (_) {}
          if (childIsBlockLike) {
            if (contentLeftInset != 0.0) {
              final Offset _phToFlow = _getPlaceholderToParentOffset(ph, flowParent, excludeScrollOffset: true);
              final double targetX = staticPositionOffset.dx - _phToFlow.dx + contentLeftInset;
              adjustedStaticPosition = Offset(targetX, adjustedStaticPosition.dy);
              try {
                PositionedLayoutLog.log(
                  impl: PositionedImpl.layout,
                  feature: PositionedFeature.staticPosition,
                  message: () => 'adjust static pos under root by IFC content-left for block '
                      'contentLeft=${contentLeftInset.toStringAsFixed(2)} '
                      '→ (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
                );
              } catch (_) {}
            }
            // Vertical: if preceded by inline, move to the next line (add paragraph height).
            if (top.isAuto && bottom.isAuto) {
              final bool hasPrecedingInline = _hasInlineContentBeforePlaceholder(flowParent, ph);
              try {
                PositionedLayoutLog.log(
                  impl: PositionedImpl.layout,
                  feature: PositionedFeature.staticPosition,
                  message: () => 'doc-root IFC block: hasPrecedingInline=${hasPrecedingInline}',
                );
              } catch (_) {}
              if (hasPrecedingInline) {
                final InlineFormattingContext? ifc = flowParent.inlineFormattingContext;
                if (ifc != null) {
                  double paraH;
                  final lines = ifc.paragraphLineMetrics;
                  if (lines.isNotEmpty) {
                    paraH = lines.fold<double>(0.0, (sum, lm) => sum + lm.height);
                  } else {
                    paraH = ifc.paragraph?.height ?? 0.0;
                  }
                  if (paraH != 0.0) {
                    adjustedStaticPosition = adjustedStaticPosition.translate(0, paraH);
                    try {
                      PositionedLayoutLog.log(
                        impl: PositionedImpl.layout,
                        feature: PositionedFeature.staticPosition,
                        message: () => 'adjust static pos under root by IFC paragraph height for block '
                            'lines=${lines.length} '
                            'h=${paraH.toStringAsFixed(2)} '
                            '→ (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
                      );
                    } catch (_) {}
                  }
                }
              }
            }
          } else {
            double inlineAdvance = flowParent.inlineAdvanceBefore(ph);
            try {
              PositionedLayoutLog.log(
                impl: PositionedImpl.layout,
                feature: PositionedFeature.staticPosition,
                message: () => 'inline-level under root: inlineAdvance=${inlineAdvance.toStringAsFixed(2)}',
              );
            } catch (_) {}
            if (inlineAdvance == 0.0) {
              final bool hasPrecedingInline = _hasInlineContentBeforePlaceholder(flowParent, ph);
              if (hasPrecedingInline && flowParent.inlineFormattingContext != null) {
                inlineAdvance = flowParent.inlineFormattingContext!.paragraphVisualMaxLineWidth;
                try {
                  PositionedLayoutLog.log(
                    impl: PositionedImpl.layout,
                    feature: PositionedFeature.staticPosition,
                    message: () => 'fallback inline advance under root by paragraph width =${inlineAdvance.toStringAsFixed(2)}',
                  );
                } catch (_) {}
              }
            }
            final bool widthIsPercentage = child.renderStyle.width.type == CSSLengthType.PERCENTAGE;
            final double effAdvance = widthIsPercentage ? 0.0 : inlineAdvance;
            final Offset _phToFlow = _getPlaceholderToParentOffset(ph, flowParent, excludeScrollOffset: true);
            final double targetX = staticPositionOffset.dx - _phToFlow.dx + contentLeftInset + effAdvance;
            adjustedStaticPosition = Offset(targetX, adjustedStaticPosition.dy);
            try {
              PositionedLayoutLog.log(
                impl: PositionedImpl.layout,
                feature: PositionedFeature.staticPosition,
                message: () => 'adjust static pos under root by IFC inline advance '
                    'contentLeft=${contentLeftInset.toStringAsFixed(2)} '
                    'advance=${effAdvance.toStringAsFixed(2)} '
                    '→ (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
              );
            } catch (_) {}
          }
        }
      }
    }

    try {
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.staticPosition,
        message: () => 'adjusted static pos = (${adjustedStaticPosition.dx.toStringAsFixed(2)},${adjustedStaticPosition.dy.toStringAsFixed(2)})',
      );
    } catch (_) {}

    // Child renderObject is reparented under its containing block at build time,
    // and staticPositionOffset is already measured relative to the containing block.
    // No additional ancestor offset adjustment is needed.
    Offset ancestorOffset = Offset.zero;

    // ScrollTop and scrollLeft will be added to offset of renderBox in the paint stage
    // for positioned fixed element.
    if (childRenderStyle.position == CSSPositionType.fixed) {
      Offset scrollOffset = child.getTotalScrollOffset();
      child.additionalPaintOffsetX = scrollOffset.dx;
      child.additionalPaintOffsetY = scrollOffset.dy;
      try {
        PositionedLayoutLog.log(
          impl: PositionedImpl.layout,
          feature: PositionedFeature.fixed,
          message: () => '<${child.renderStyle.target.tagName.toLowerCase()}>'
              ' fixed paintOffset=(${scrollOffset.dx.toStringAsFixed(2)},${scrollOffset.dy.toStringAsFixed(2)})',
        );
      } catch (_) {}
    }

    // When the parent is a scroll container (overflow on either axis not visible),
    // convert positioned offsets to the scrolling content box coordinate space.
    // Overflow paint translates children relative to the content edge, so offsets
    // computed from the padding edge must exclude border and padding for alignment.
    final bool parentIsScrollContainer =
        parent.renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        parent.renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    // Determine direction for resolving 'auto' horizontal insets: use the
    // direction of the element establishing the static-position containing block
    // (typically the IFC container hosting the placeholder) when available;
    // otherwise fall back to the containing block's direction.
    TextDirection _staticContainingDir = parent.renderStyle.direction;
    if (ph != null && ph.parent is RenderFlowLayout) {
      final RenderFlowLayout flowParent = ph.parent as RenderFlowLayout;
      _staticContainingDir = flowParent.renderStyle.direction;
    }

    // For sticky positioning, the insets act as constraints during scroll, not as
    // absolute offsets at layout time. Compute the base (un-stuck) offset from the
    // static position by treating both axis insets as auto for layout.
    final bool isSticky = childRenderStyle.position == CSSPositionType.sticky;

    double x = _computePositionedOffset(
      Axis.horizontal,
      _staticContainingDir,
      false,
      parentBorderLeftWidth,
      parentPaddingLeft,
      containingBlockSize.width,
      size.width,
      adjustedStaticPosition.dx,
      isSticky ? CSSLengthValue.auto : left,
      isSticky ? CSSLengthValue.auto : right,
      marginLeft,
      marginRight,
    );

    double y = _computePositionedOffset(
      Axis.vertical,
      parent.renderStyle.direction,
      false,
      parentBorderTopWidth,
      parentPaddingTop,
      containingBlockSize.height,
      size.height,
      adjustedStaticPosition.dy,
      isSticky ? CSSLengthValue.auto : top,
      isSticky ? CSSLengthValue.auto : bottom,
      marginTop,
      marginBottom,
    );
    try {
      final dir = parent.renderStyle.direction;
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.offsets,
        message: () => 'compute offset for <${child.renderStyle.target.tagName.toLowerCase()}>'
            ' dir=$dir parentScroll=$parentIsScrollContainer left=${left.cssText()} right=${right.cssText()} '
            'top=${top.cssText()} bottom=${bottom.cssText()} → (${x.toStringAsFixed(2)},${y.toStringAsFixed(2)})',
      );
    } catch (_) {}

    final Offset finalOffset = Offset(x, y) - ancestorOffset;
    // If this positioned element is wrapped (e.g., by RenderEventListener), ensure
    // the wrapper is placed at the positioned offset so its background/border align
    // with the child content. The child uses internal offsets relative to the wrapper.
    bool placedWrapper = false;
    final RenderObject? directParent = child.parent;
    if (directParent is RenderEventListener) {
      final RenderLayoutParentData pd = directParent.parentData as RenderLayoutParentData;
      pd.offset = finalOffset;
      placedWrapper = true;
    }
    if (!placedWrapper) {
      childParentData.offset = finalOffset;
    }

    try {
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.offsets,
        message: () => 'apply offset final=(${finalOffset.dx.toStringAsFixed(2)},${finalOffset.dy.toStringAsFixed(2)}) '
            'from x=${x.toStringAsFixed(2)} y=${y.toStringAsFixed(2)} ancestor=(${ancestorOffset.dx.toStringAsFixed(2)},${ancestorOffset.dy.toStringAsFixed(2)})',
      );
    } catch (_) {}
  }

  // Apply sticky paint-time offset based on scroll position of nearest scroll container.
  // The child must already be laid out and have its base (un-stuck) layout offset set
  // to its static position within the containing block (done in applyPositionedChildOffset for sticky).
  static void applyStickyChildOffset(RenderBoxModel parent, RenderBoxModel child, {RenderBoxModel? scrollContainer}) {
    if (child.renderStyle.position != CSSPositionType.sticky) return;

    // Identify the scroll container that constrains stickiness.
    RenderBoxModel? scroller = scrollContainer ?? _nearestScrollContainer(parent) ?? _nearestScrollContainer(child);

    // Use zero scroll if no container; sticky behaves like relative.
    final double scrollTop = scroller?.scrollTop ?? 0.0;
    final double scrollLeft = scroller?.scrollLeft ?? 0.0;
    final Size viewport = (scroller != null && scroller.hasSize) ? _scrollViewportSize(scroller) : Size.infinite;

    // Base static layout offset measured in the containing block coordinates.
    // If wrapped by RenderEventListener, the wrapper carries the positioned offset.
    Offset base;
    final RenderObject? directParent = child.parent;
    if (directParent is RenderEventListener) {
      final RenderLayoutParentData pdw = directParent.parentData as RenderLayoutParentData;
      base = pdw.offset;
    } else {
      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      base = pd.offset;
    }

    final CSSRenderStyle rs = child.renderStyle;
    final double childW = child.boxSize?.width ?? child.size.width;
    final double childH = child.boxSize?.height ?? child.size.height;

    // Natural on-screen position relative to the scroll container's viewport.
    final double natY = base.dy - scrollTop;
    final double natX = base.dx - scrollLeft;

    double desiredY = natY;
    double desiredX = natX;

    // Apply vertical stickiness constraints.
    if (rs.top.isNotAuto || rs.bottom.isNotAuto) {
      // Top stick: engage as soon as the natural top would cross the top edge,
      // and keep clamped thereafter until bottom boundary says otherwise.
      if (rs.top.isNotAuto) {
        final double topLimit = rs.top.computedValue;
        if (natY < topLimit) desiredY = math.max(desiredY, topLimit);
      }
      // Bottom stick: only clamp when the box is within the viewport (entering from below)
      if (rs.bottom.isNotAuto && viewport.height.isFinite) {
        final double maxY = viewport.height - rs.bottom.computedValue - childH;
        // Bottom stick engages once the element's natural top exceeds the clamp threshold,
        // regardless of whether its top edge is already inside the viewport.
        if (natY > maxY) desiredY = math.min(desiredY, maxY);
      }
    }

    // Apply horizontal stickiness constraints.
    if (rs.left.isNotAuto || rs.right.isNotAuto) {
      if (rs.left.isNotAuto) {
        final double leftLimit = rs.left.computedValue;
        if (natX < leftLimit) desiredX = math.max(desiredX, leftLimit);
      }
      if (rs.right.isNotAuto && viewport.width.isFinite) {
        final double maxX = viewport.width - rs.right.computedValue - childW;
        if (natX > maxX) desiredX = math.min(desiredX, maxX);
      }
    }

    // Convert desired on-screen delta back to an additional paint offset.
    // additional = desiredOnScreen - currentOnScreen = desired - (base - scroll)
    final double addY = desiredY - natY;
    final double addX = desiredX - natX;

    if ((child.additionalPaintOffsetY ?? 0.0) != addY) {
      child.additionalPaintOffsetY = addY;
    }
    if ((child.additionalPaintOffsetX ?? 0.0) != addX) {
      child.additionalPaintOffsetX = addX;
    }

    try {
      PositionedLayoutLog.log(
        impl: PositionedImpl.layout,
        feature: PositionedFeature.sticky,
        message: () => '<${child.renderStyle.target.tagName.toLowerCase()}>'
            ' sticky base=(${base.dx.toStringAsFixed(2)},${base.dy.toStringAsFixed(2)})'
            ' scroll=(${scrollLeft.toStringAsFixed(2)},${scrollTop.toStringAsFixed(2)})'
            ' add=(${addX.toStringAsFixed(2)},${addY.toStringAsFixed(2)})',
      );
    } catch (_) {}
  }

  // Resolve the next in-flow block-level RenderBoxModel sibling after a placeholder.
  // Skips wrappers (RenderEventListener) and ignores other placeholders.
  static RenderBoxModel? _resolveNextInFlowSiblingModel(RenderPositionPlaceholder ph) {
    RenderObject? current = ph;
    // Move to next sibling in the parent's child list
    if (ph.parentData is! RenderLayoutParentData) return null;
    RenderObject? next = (ph.parentData as RenderLayoutParentData).nextSibling as RenderObject?;
    while (next != null) {
      if (next is RenderPositionPlaceholder) {
        // Skip other placeholders
        current = next;
        next = (next.parentData as RenderLayoutParentData?)?.nextSibling as RenderObject?;
        continue;
      }
      if (next is RenderBoxModel) {
        final rs = next.renderStyle;
        if ((rs.effectiveDisplay == CSSDisplay.block || rs.effectiveDisplay == CSSDisplay.flex) && !rs.isSelfPositioned()) {
          return next;
        }
      }
      if (next is RenderEventListener) {
        final RenderBox? inner = next.child as RenderBox?;
        if (inner is RenderBoxModel) {
          final rs = inner.renderStyle;
          if ((rs.effectiveDisplay == CSSDisplay.block || rs.effectiveDisplay == CSSDisplay.flex) && !rs.isSelfPositioned()) {
            return inner;
          }
        }
      }
      // Fallback: advance to subsequent sibling
      current = next;
      next = (current.parentData as RenderLayoutParentData?)?.nextSibling as RenderObject?;
    }
    return null;
  }

  // Heuristic: detect if there is any inline text content before the placeholder within an IFC container.
  static bool _hasInlineContentBeforePlaceholder(RenderFlowLayout flowParent, RenderPositionPlaceholder ph) {
    RenderBox? child = flowParent.firstChild;
    while (child != null && child != ph) {
      if (_containsInlineText(child)) return true;
      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      child = pd.nextSibling;
    }
    return false;
  }

  static bool _containsInlineText(RenderObject node, [int depth = 0]) {
    if (depth > 8) return false;
    if (node is RenderTextBox) {
      final String data = node.data;
      return data.trim().isNotEmpty;
    }
    if (node is RenderEventListener) {
      final RenderBox? c = node.child;
      if (c != null) return _containsInlineText(c, depth + 1);
    }
    if (node is RenderFlowLayout) {
      RenderBox? c = node.firstChild;
      while (c != null) {
        if (_containsInlineText(c, depth + 1)) return true;
        final RenderLayoutParentData pd = c.parentData as RenderLayoutParentData;
        c = pd.nextSibling;
      }
      return false;
    }
    if (node is RenderObjectWithChildMixin<RenderBox>) {
      final RenderBox? c = (node as dynamic).child as RenderBox?;
      if (c != null) return _containsInlineText(c, depth + 1);
    }
    return false;
  }

  // Compute inline horizontal advance (sum of visual widths) of siblings before the
  // placeholder within an IFC container. Prefers text measurement for RenderTextBox,
  // skips placeholders and out-of-flow boxes.
  static double _computeInlineAdvanceBeforePlaceholder(RenderFlowLayout flowParent, RenderPositionPlaceholder ph) {
    double sum = 0.0;
    if (ph.parentData is! RenderLayoutParentData) return 0.0;
    RenderBox? child = flowParent.firstChild;
    while (child != null && child != ph) {
      if (child is RenderTextBox) {
        // Measure full text width with no wrap to approximate natural advance.
        try {
          final Size sz = child.computeFullTextSizeForWidth(double.infinity);
          sum += sz.width;
        } catch (_) {}
      } else if (child is RenderBoxModel) {
        // Inline-level boxes: if they have a size, add their border-box width.
        // Positioned/placeholder are excluded by size==null or handled elsewhere.
        final Size? sz = child.boxSize;
        if (sz != null) sum += sz.width;
      }
      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      child = pd.nextSibling;
    }
    return sum;
  }

  // Compute the offset of positioned element in one axis.
  static double _computePositionedOffset(
    Axis axis,
    TextDirection containerDirection,
    bool isParentScrollingContentBox,
    CSSLengthValue parentBorderBeforeWidth,
    CSSLengthValue parentPaddingBefore,
    double containingBlockLength,
    double length,
    double staticPosition,
    CSSLengthValue insetBefore,
    CSSLengthValue insetAfter,
    CSSLengthValue marginBefore,
    CSSLengthValue marginAfter,
  ) {
    // Offset of positioned element in one axis.
    double offset;

    // Take horizontal axis for example.
    // left + margin-left + width + margin-right + right = width of containing block
    // Refer to the table of `Summary of rules for dir=ltr in horizontal writing modes` in following spec.
    // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
    if (insetBefore.isAuto && insetAfter.isAuto) {
      // Both insets are auto. Per CSS Positioned Layout:
      // - Set auto margins to 0.
      // - If the direction of the element establishing the static-position
      //   containing block is LTR, use left = static-position.
      // - If RTL, use right = static-position.
      if (axis == Axis.horizontal && containerDirection == TextDirection.rtl) {
        // Resolve right = staticPosition → compute left offset accordingly.
        // left = contentLeft + (CB width - width - staticPosition)
        final double leftFromContent = containingBlockLength - length - staticPosition;
        offset = parentBorderBeforeWidth.computedValue + leftFromContent + marginBefore.computedValue;
      } else {
        offset = staticPosition;
      }
    } else {
      if (insetBefore.isNotAuto && insetAfter.isNotAuto) {
        double freeSpace = containingBlockLength - length - insetBefore.computedValue - insetAfter.computedValue;
        double marginBeforeValue;

        if (marginBefore.isAuto && marginAfter.isAuto) {
          // Note: There is difference for auto margin resolve rule of horizontal and vertical axis.
          // margin-left is resolved as 0 only in horizontal axis and resolved as equal values of free space
          // in vertical axis, refer to following doc in the spec:
          //
          // If both margin-left and margin-right are auto, solve the equation under the extra constraint
          // that the two margins get equal values, unless this would make them negative, in which case
          // when direction of the containing block is ltr (rtl), set margin-left (margin-right) to 0
          // and solve for margin-right (margin-left).
          // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
          //
          // If both margin-top and margin-bottom are auto, solve the equation under the extra constraint
          // that the two margins get equal values.
          // https://www.w3.org/TR/css-position-3/#abs-non-replaced-height
          if (freeSpace < 0 && axis == Axis.horizontal) {
            // margin-left → '0', solve the above equation for margin-right
            marginBeforeValue = 0;
          } else {
            // margins split positive free space
            marginBeforeValue = freeSpace / 2;
          }
        } else if (marginBefore.isAuto && marginAfter.isNotAuto) {
          // If one of margin-left or margin-right is auto, solve the equation for that value.
          // Solve for margin-left in this case.
          marginBeforeValue = freeSpace - marginAfter.computedValue;
        } else {
          // If one of margin-left or margin-right is auto, solve the equation for that value.
          // Use specified margin-left in this case.
          marginBeforeValue = marginBefore.computedValue;
        }
        offset = parentBorderBeforeWidth.computedValue + insetBefore.computedValue + marginBeforeValue;
      } else if (insetBefore.isAuto && insetAfter.isNotAuto) {
        // If left/top is auto, width/height and right/bottom are not auto, then solve for left/top.
        // For vertical axis with bottom specified, we need to calculate position from the bottom edge
        double insetBeforeValue = containingBlockLength -
            length -
            insetAfter.computedValue -
            marginBefore.computedValue -
            marginAfter.computedValue;
        offset = parentBorderBeforeWidth.computedValue + insetBeforeValue + marginBefore.computedValue;
      } else {
        // If right/bottom is auto, left/top and width/height are not auto, then solve for right/bottom.
        // Offsets are measured from the padding edge; relative to the parent's border edge, add border + inset.
        // Do NOT add parentPaddingBefore here; 'left/top' is already relative to the padding edge.
        offset = parentBorderBeforeWidth.computedValue + insetBefore.computedValue + marginBefore.computedValue;
      }

      // Convert position relative to scrolling content box.
      // Scrolling content box positions relative to the content edge of its parent.
      if (isParentScrollingContentBox) {
        offset = offset - parentBorderBeforeWidth.computedValue - parentPaddingBefore.computedValue;
      }
    }

    return offset;
  }

  /// Ensures accurate static position calculation for W3C compliance.
  ///
  /// According to W3C CSS Position Level 3, static position represents "an approximation
  /// of the position the box would have had if it were position: static".
  ///
  /// This method corrects cases where the placeholder-based static position calculation
  /// includes unwanted flow layout artifacts that don't represent true normal flow position.
  static Offset _ensureAccurateStaticPosition(
    Offset staticPositionOffset,
    RenderBoxModel child,
    RenderBoxModel parent,
    CSSLengthValue left,
    CSSLengthValue right,
    CSSLengthValue top,
    CSSLengthValue bottom,
    CSSLengthValue parentBorderLeftWidth,
    CSSLengthValue parentBorderRightWidth,
    CSSLengthValue parentBorderTopWidth,
    CSSLengthValue parentBorderBottomWidth,
    CSSLengthValue parentPaddingLeft,
    CSSLengthValue parentPaddingTop,
  ) {
    // Only process absolutely positioned elements
    if (child.renderStyle.position != CSSPositionType.absolute) {
      return staticPositionOffset;
    }

    RenderPositionPlaceholder? placeholder = child.renderStyle.getSelfPositionPlaceHolder();
    // Placeholder may live under a different parent than the containing block (e.g., under inline ancestor);
    // still valid: we can compute its offset to the containing block.
    if (placeholder == null) {
      return staticPositionOffset;
    }

    // Detect whether the placeholder is laid out inside a flex container.
    final bool placeholderInFlex = placeholder.parent is RenderFlexLayout;

    // W3C: When insets are auto, use static position. We may refine horizontal/vertical
    // axes when the placeholder’s current offset is known to be inaccurate, but by
    // default we keep the computed placeholder offset.
    bool shouldUseAccurateHorizontalPosition = left.isAuto && right.isAuto;
    bool shouldUseAccurateVerticalPosition = top.isAuto && bottom.isAuto;

    if (!shouldUseAccurateHorizontalPosition && !shouldUseAccurateVerticalPosition) {
      return staticPositionOffset;
    }

    // Check if current static position may be inaccurate due to flow layout artifacts
    bool needsCorrection = _staticPositionNeedsCorrection(placeholder, staticPositionOffset, parent);

    // Special-case: Inline Formatting Context containing block with no in-flow anchor
    // For absolutely positioned non-replaced elements with all insets auto, when the
    // containing block establishes an IFC and there is no in-flow sibling before the
    // placeholder (i.e., nothing to anchor in normal flow), browsers place the box at
    // the bottom-right corner of the padding box. Constrain within padding edges.
    final bool isIFCContainingBlock = parent is RenderFlowLayout && (parent as RenderFlowLayout).establishIFC;
    if (!placeholderInFlex && isIFCContainingBlock && left.isAuto && right.isAuto && top.isAuto && bottom.isAuto) {
      if (placeholder.parentData is RenderLayoutParentData) {
        final RenderLayoutParentData pd = placeholder.parentData as RenderLayoutParentData;
        if (pd.previousSibling == null) {
          final double padLeft = parentBorderLeftWidth.computedValue + parentPaddingLeft.computedValue;
          final double padTop = parentBorderTopWidth.computedValue + parentPaddingTop.computedValue;
          final Size parentSize = parent.boxSize ?? Size.zero;
          final Size childSize = child.boxSize ?? Size.zero;
          final double rightEdge = parentSize.width - parentBorderRightWidth.computedValue;
          final double bottomEdge = parentSize.height - parentBorderBottomWidth.computedValue;
          final double bx = math.max(padLeft, rightEdge - childSize.width);
          final double by = math.max(padTop, bottomEdge - childSize.height);
          return Offset(bx, by);
        }
      }
    }

    // Calculate the true normal flow position following W3C static position rules
    double contentAreaX = parentBorderLeftWidth.computedValue + parentPaddingLeft.computedValue;

    // For horizontal axis: use content area start only when a correction is necessary.
    double correctedX = (shouldUseAccurateHorizontalPosition && needsCorrection)
        ? contentAreaX
        : staticPositionOffset.dx;

    // Vertical axis: decide whether placeholder offset already accounts for the
    // element's own vertical margins. In normal flow (RenderFlowLayout), placeholders
    // are 0×0 and aligned to the following in-flow sibling without adding the positioned
    // element's own margins, so we must add the element's margin-top to reach the margin box.
    double correctedY = staticPositionOffset.dy +
        ((shouldUseAccurateVerticalPosition && !placeholderInFlex)
            ? child.renderStyle.marginTop.computedValue
            : 0);

    // Special handling for flex containers: if both top/bottom are auto and the
    // container aligns items to the center on the cross axis, align the static
    // position to the flex centering result using the container's content box.
    // This matches browser behavior where an abspos with all insets auto in a
    // row-direction flex container visually centers vertically when align-items:center.
    // For flex containers, refine the vertical static position when top/bottom are auto
    // and cross-axis centering applies (align-self/align-items center). The placeholder
    // is 0-height and is placed at the cross-axis center; we need to subtract half of the
    // child's box height so the top edge is positioned correctly.
    if (placeholderInFlex && (shouldUseAccurateVerticalPosition || shouldUseAccurateHorizontalPosition)) {
      // Use the flex container (placeholder's parent) to determine direction and alignment.
      final RenderFlexLayout flexContainer = placeholder.parent as RenderFlexLayout;
      final CSSRenderStyle pStyle = flexContainer.renderStyle;
      final FlexDirection dir = pStyle.flexDirection;
      final bool isRowDirection = (dir == FlexDirection.row || dir == FlexDirection.rowReverse);
      // Effective cross-axis alignment respects child's align-self when specified,
      // otherwise falls back to container's align-items.
      final AlignSelf self = child.renderStyle.alignSelf;
      final AlignItems parentAlignItems = pStyle.alignItems;
      final bool isCenter = self == AlignSelf.center || (self == AlignSelf.auto && parentAlignItems == AlignItems.center);
      final bool isEnd = self == AlignSelf.flexEnd || (self == AlignSelf.auto && parentAlignItems == AlignItems.flexEnd);
      final bool isStart = self == AlignSelf.flexStart || (self == AlignSelf.auto && parentAlignItems == AlignItems.flexStart);

      if (isRowDirection && shouldUseAccurateVerticalPosition) {
        // Compute from the flex container’s content box in the containing block’s
        // coordinate space: containerOffset + padding/border + alignment.
        final RenderLayoutParentData? phPD = placeholder.parentData as RenderLayoutParentData?;
        final Offset phOffsetInFlex = phPD?.offset ?? Offset.zero;
        // staticPositionOffset = flexOffsetToCB + placeholderOffsetInFlex
        final Offset flexOffsetToCB = staticPositionOffset - phOffsetInFlex;

        final double fcBorderTop = pStyle.effectiveBorderTopWidth.computedValue;
        final double fcBorderBottom = pStyle.effectiveBorderBottomWidth.computedValue;
        final double fcPadTop = pStyle.paddingTop.computedValue;
        final double fcPadBottom = pStyle.paddingBottom.computedValue;
        final Size fcSize = flexContainer.boxSize ?? Size.zero;
        final double fcContentH = (fcSize.height - fcBorderTop - fcBorderBottom - fcPadTop - fcPadBottom).clamp(0.0, double.infinity);
        final double childH = child.boxSize?.height ?? 0;
        final double contentTopInCB = flexOffsetToCB.dy + fcBorderTop + fcPadTop;
        if (isCenter) {
          correctedY = contentTopInCB + (fcContentH - childH) / 2.0;
        } else if (isEnd) {
          correctedY = contentTopInCB + (fcContentH - childH);
        } else if (isStart) {
          correctedY = contentTopInCB;
        }
      } else if (!isRowDirection && shouldUseAccurateHorizontalPosition) {
        // Column direction: cross-axis is horizontal. Compute left from the flex
        // container content box so the abspos element centers and updates when width changes.
        final RenderLayoutParentData? phPD = placeholder.parentData as RenderLayoutParentData?;
        final Offset phOffsetInFlex = phPD?.offset ?? Offset.zero;
        final Offset flexOffsetToCB = staticPositionOffset - phOffsetInFlex;

        final double fcBorderLeft = pStyle.effectiveBorderLeftWidth.computedValue;
        final double fcBorderRight = pStyle.effectiveBorderRightWidth.computedValue;
        final double fcPadLeft = pStyle.paddingLeft.computedValue;
        final double fcPadRight = pStyle.paddingRight.computedValue;
        final Size fcSize = flexContainer.boxSize ?? Size.zero;
        final double fcContentW = (fcSize.width - fcBorderLeft - fcBorderRight - fcPadLeft - fcPadRight).clamp(0.0, double.infinity);
        final double childW = child.boxSize?.width ?? 0;
        final double contentLeftInCB = flexOffsetToCB.dx + fcBorderLeft + fcPadLeft;
        if (isCenter) {
          correctedX = contentLeftInCB + (fcContentW - childW) / 2.0;
        } else if (isEnd) {
          correctedX = contentLeftInCB + (fcContentW - childW);
        } else if (isStart) {
          correctedX = contentLeftInCB;
        }
      }
    }

    // For non-flex containers, keep the placeholder-computed position with optional margin compensation.

    return Offset(correctedX, correctedY);
  }

  /// Determines if static position calculation needs correction to be W3C compliant.
  ///
  /// Checks for cases where flow layout artifacts may have affected the placeholder
  /// position in ways that don't represent true normal flow position.
  static bool _staticPositionNeedsCorrection(
    RenderPositionPlaceholder placeholder,
    Offset staticPositionOffset,
    RenderBoxModel parent,
  ) {
    if (placeholder.parentData is! RenderLayoutParentData) {
      return false;
    }

    RenderLayoutParentData placeholderData = placeholder.parentData as RenderLayoutParentData;
    RenderBox? previousSibling = placeholderData.previousSibling;

    if (previousSibling == null) {
      return false;
    }

    // Static position may need correction if it follows certain layout patterns
    // that can introduce unwanted offsets not representative of normal flow

    // Case 1: Direct replaced element
    if (previousSibling is RenderReplaced) {
      return _hasSignificantOffset(staticPositionOffset, parent);
    }

    // Case 2: Interactive replaced element (wrapped in RenderEventListener)
    if (previousSibling is RenderEventListener &&
        previousSibling.child is RenderReplaced) {
      return _hasSignificantOffset(staticPositionOffset, parent);
    }

    return false;
  }

  /// Calculates the true vertical static position by considering the normal document flow.
  ///
  /// Unlike horizontal positioning which typically starts at the content area,
  /// vertical positioning must account for where the element would actually appear
  /// in the normal flow after previous siblings.
  static double _calculateTrueVerticalStaticPosition(
    RenderPositionPlaceholder placeholder,
    RenderBoxModel parent,
    Offset currentStaticPosition,
  ) {
    // Static position should reflect where the element would appear in normal
    // flow without collapsing with the parent. Use the element's own top margin
    // collapsed only with its first in-flow child (if any), i.e., ignoring
    // parent collapse, so positioned elements' margins do not disappear.
    final RenderBoxModel? positioned = placeholder.positioned;
    if (positioned != null) {
      // For absolutely positioned elements, the static position uses the box's
      // own used margin values (no margin-collapsing with descendants).
      // Use the specified margin-top to offset from the placeholder position.
      final double ownTopMargin = positioned.renderStyle.marginTop.computedValue;
      return currentStaticPosition.dy + ownTopMargin;
    }
    return currentStaticPosition.dy;
  }

  /// Checks if the static position has significant offset that may indicate
  /// flow layout artifacts rather than true normal flow position.
  static bool _hasSignificantOffset(Offset staticPosition, RenderBoxModel parent) {
    RenderStyle parentStyle = parent.renderStyle;
    double expectedX = parentStyle.effectiveBorderLeftWidth.computedValue +
                      parentStyle.paddingLeft.computedValue;
    double expectedY = parentStyle.effectiveBorderTopWidth.computedValue +
                      parentStyle.paddingTop.computedValue;

    // Allow small tolerance for rounding differences
    const double tolerance = 1.0;

    // If static position is significantly different from content area start,
    // it may need correction
    bool hasUnexpectedHorizontalOffset = (staticPosition.dx - expectedX).abs() > tolerance;
    bool hasUnexpectedVerticalOffset = (staticPosition.dy - expectedY).abs() > tolerance;

    return hasUnexpectedHorizontalOffset || hasUnexpectedVerticalOffset;
  }
}
