/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/src/css/grid.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/foundation/debug_flags.dart';
import 'package:webf/src/foundation/logger.dart';

/// Temporary Grid render object scaffold.
///
/// For the initial step, RenderGridLayout subclasses RenderFlowLayout so that
/// display:grid containers behave like block/flow containers while we land the
/// full CSS Grid algorithm incrementally. This ensures display:grid does not
/// throw and can participate in layout/painting with predictable behavior.
class RenderGridLayout extends RenderLayoutBox {
  RenderGridLayout({
    List<RenderBox>? children,
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
  }

  void _gridLog(String Function() message) {
    if (!DebugFlags.debugLogGridEnabled) return;
    renderingLogger.finer('[Grid] ${message()}');
  }

  double _resolveTrackSize(GridTrackSize track, double? innerAvailable) {
    if (track is GridFixed) {
      final CSSLengthValue lv = track.length;
      if (lv.type == CSSLengthType.PX) {
        return lv.computedValue;
      }
      if (lv.type == CSSLengthType.PERCENTAGE) {
        if (innerAvailable != null && innerAvailable.isFinite) {
          return (lv.value ?? 0) * innerAvailable;
        }
        return 0;
      }
      return lv.computedValue;
    } else if (track is GridFraction) {
      if (innerAvailable != null && innerAvailable.isFinite && innerAvailable > 0) {
        return innerAvailable * (track.fr / math.max(1.0, track.fr));
      }
      return 0;
    }
    return 0;
  }

  List<double> _resolveTracks(List<GridTrackSize> tracks, double? innerAvailable, Axis axis) {
    if (tracks.isEmpty) {
      return <double>[];
    }

    final List<double> sizes = List<double>.filled(tracks.length, 0.0, growable: true);

    double fixed = 0.0;
    double frSum = 0.0;
    for (int i = 0; i < tracks.length; i++) {
      final t = tracks[i];
      if (t is GridFraction) {
        frSum += t.fr;
      } else if (t is GridFixed) {
        sizes[i] = _resolveTrackSize(t, innerAvailable);
        fixed += sizes[i];
      } else {
        sizes[i] = 0;
      }
    }

    if (frSum > 0 && innerAvailable != null && innerAvailable.isFinite) {
      final double remaining = math.max(0.0, innerAvailable - fixed);
      for (int i = 0; i < tracks.length; i++) {
        final t = tracks[i];
        if (t is GridFraction) {
          final portion = remaining * (t.fr / frSum);
          sizes[i] = portion;
        }
      }
    }

    return sizes;
  }

  @override
  void performLayout() {
    _gridLog(() => 'performLayout constraints=$constraints');
    // Compute inner available sizes (content box constraints)
    final double paddingLeft = renderStyle.paddingLeft.computedValue;
    final double paddingRight = renderStyle.paddingRight.computedValue;
    final double paddingTop = renderStyle.paddingTop.computedValue;
    final double paddingBottom = renderStyle.paddingBottom.computedValue;
    final double borderLeft = renderStyle.effectiveBorderLeftWidth.computedValue;
    final double borderRight = renderStyle.effectiveBorderRightWidth.computedValue;
    final double borderTop = renderStyle.effectiveBorderTopWidth.computedValue;
    final double borderBottom = renderStyle.effectiveBorderBottomWidth.computedValue;

    final double horizontalPaddingBorder = paddingLeft + paddingRight + borderLeft + borderRight;
    final double verticalPaddingBorder = paddingTop + paddingBottom + borderTop + borderBottom;

    final bool hasBW = constraints.hasBoundedWidth;
    final bool hasBH = constraints.hasBoundedHeight;
    final double? innerMaxWidth = hasBW ? math.max(0.0, constraints.maxWidth - horizontalPaddingBorder) : null;
    final double? innerMaxHeight = hasBH ? math.max(0.0, constraints.maxHeight - verticalPaddingBorder) : null;

    // Resolve tracks
    // Resolve explicit track definitions from render style; if not yet materialized
    // (e.g., very early layout), fall back to parsing inline style string once.
    List<GridTrackSize> colsDef = renderStyle.gridTemplateColumns;
    List<GridTrackSize> rowsDef = renderStyle.gridTemplateRows;
    final List<GridTrackSize> autoRowDefs = renderStyle.gridAutoRows;
    if (colsDef.isEmpty) {
      String raw = renderStyle.target.style.getPropertyValue(GRID_TEMPLATE_COLUMNS);
      if (raw.isEmpty) {
        final String? styleAttr = (renderStyle.target as Element).getAttribute('style');
        if (styleAttr != null) {
          final RegExp re = RegExp(r'grid-template-columns\s*:\s*([^;]+)', caseSensitive: false);
          final m = re.firstMatch(styleAttr);
          if (m != null) raw = m.group(1)!.trim();
        }
      }
      if (raw.isNotEmpty) {
        colsDef = CSSGridParser.parseTrackList(raw, renderStyle, GRID_TEMPLATE_COLUMNS, Axis.horizontal);
      }
    }
    if (rowsDef.isEmpty) {
      String raw = renderStyle.target.style.getPropertyValue(GRID_TEMPLATE_ROWS);
      if (raw.isEmpty) {
        final String? styleAttr = (renderStyle.target as Element).getAttribute('style');
        if (styleAttr != null) {
          final RegExp re = RegExp(r'grid-template-rows\s*:\s*([^;]+)', caseSensitive: false);
          final m = re.firstMatch(styleAttr);
          if (m != null) raw = m.group(1)!.trim();
        }
      }
      if (raw.isNotEmpty) {
        rowsDef = CSSGridParser.parseTrackList(raw, renderStyle, GRID_TEMPLATE_ROWS, Axis.vertical);
      }
    }
    final int colCount = colsDef.isEmpty ? 1 : colsDef.length;

    final double colGap = renderStyle.columnGap.computedValue;
    final double rowGap = renderStyle.rowGap.computedValue;

    double? adjustedInnerWidth = innerMaxWidth;
    if (adjustedInnerWidth != null && adjustedInnerWidth.isFinite) {
      final double totalColGap = colGap * math.max(0, colCount - 1);
      adjustedInnerWidth = math.max(0.0, adjustedInnerWidth - totalColGap);
    }
    final List<double> colSizes = _resolveTracks(
        colsDef.isEmpty ? <GridTrackSize>[const GridAuto()] : colsDef, adjustedInnerWidth, Axis.horizontal);
    List<double> rowSizes =
        rowsDef.isEmpty ? <double>[] : _resolveTracks(rowsDef, innerMaxHeight, Axis.vertical);
    _gridLog(() =>
        'tracks resolved columns=${colSizes.map((e) => e.toStringAsFixed(2)).join(', ')} rows=${rowSizes.map((e) => e.toStringAsFixed(2)).join(', ')} autoRows=${renderStyle.gridAutoRows.length} autoFlow=${renderStyle.gridAutoFlow}');

    // Layout children: simple auto-placement row-wise across explicit columns, create implicit rows as needed.
    int index = 0;
    double yCursor = paddingTop + borderTop;
    final double xStart = paddingLeft + borderLeft;
    // Track per-row max child height when rows are auto/implicit
    List<double> implicitRowHeights = [];

    RenderBox? child = firstChild;
    while (child != null) {
      final int colIndex = index % colCount;
      final int rowIndex = index ~/ colCount;
      // Ensure rowSizes contains this row; if rowsDef empty, use implicit heights that we'll compute
      if (rowIndex >= rowSizes.length) {
        rowSizes.add(0);
      }
      if (rowsDef.isEmpty && rowSizes[rowIndex] <= 0) {
        final double? autoSize = _resolveAutoTrackAt(autoRowDefs, rowIndex, innerMaxHeight);
        if (autoSize != null) {
          rowSizes[rowIndex] = autoSize;
        }
      }
      if (rowIndex >= implicitRowHeights.length) implicitRowHeights.add(0);

      double xOffset = xStart;
      for (int c = 0; c < colIndex; c++) {
        xOffset += colSizes[c];
        if (c < colCount - 1) xOffset += colGap;
      }

      final double cellWidth = colSizes[colIndex];
      final bool hasExplicitRowSize = rowSizes[rowIndex] > 0;
      final double cellHeight = hasExplicitRowSize ? rowSizes[rowIndex] : double.nan;
      final BoxConstraints childConstraints = BoxConstraints(
        minWidth: cellWidth.isFinite ? cellWidth : 0,
        maxWidth: cellWidth.isFinite ? cellWidth : (innerMaxWidth ?? double.infinity),
        minHeight: cellHeight.isFinite ? cellHeight : 0,
        maxHeight: cellHeight.isFinite ? cellHeight : (innerMaxHeight ?? double.infinity),
      );

      child.layout(childConstraints, parentUsesSize: true);

      final Size childSize = child.size;
      // Update implicit row height if needed
      if (rowsDef.isEmpty && !hasExplicitRowSize) {
        implicitRowHeights[rowIndex] = math.max(implicitRowHeights[rowIndex], childSize.height);
      }

      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      double rowTop = yCursor;
      // Compute y offset: sum previous rows + gaps
      if (rowIndex > 0) {
        rowTop = paddingTop + borderTop;
        for (int r = 0; r < rowIndex; r++) {
          double rh;
          if (rowsDef.isEmpty) {
            final double assigned = (r < rowSizes.length && rowSizes[r] > 0) ? rowSizes[r] : 0;
            rh = assigned > 0
                ? assigned
                : (r < implicitRowHeights.length ? implicitRowHeights[r] : 0);
          } else {
            rh = rowSizes[r];
          }
          rowTop += rh;
          if (r < (rowIndex)) rowTop += rowGap;
        }
      }
      pd.offset = Offset(xOffset, rowTop);
      _gridLog(() =>
          'child#$index row=$rowIndex col=$colIndex offset=${pd.offset} childSize=$childSize constraints=$childConstraints explicitRow=$hasExplicitRowSize');

      index++;
      child = pd.nextSibling;
    }

    // Compute used content size
    double usedContentWidth = 0;
    for (int c = 0; c < colSizes.length; c++) {
      usedContentWidth += colSizes[c];
      if (c < colSizes.length - 1) usedContentWidth += colGap;
    }
    double usedContentHeight = 0;
    if (rowsDef.isEmpty) {
      final int totalRows = math.max(rowSizes.length, implicitRowHeights.length);
      for (int r = 0; r < totalRows; r++) {
        double segment = 0;
        if (r < rowSizes.length && rowSizes[r] > 0) {
          segment = rowSizes[r];
        } else if (r < implicitRowHeights.length) {
          segment = implicitRowHeights[r];
        }
        usedContentHeight += segment;
        if (r < totalRows - 1) usedContentHeight += rowGap;
      }
    } else {
      for (int r = 0; r < rowSizes.length; r++) {
        usedContentHeight += rowSizes[r];
        if (r < rowSizes.length - 1) usedContentHeight += rowGap;
      }
    }

    // Final size constrained by constraints
    final double desiredWidth = usedContentWidth + horizontalPaddingBorder;
    final double desiredHeight = usedContentHeight + verticalPaddingBorder;
    size = constraints.constrain(Size(desiredWidth, desiredHeight));
    _gridLog(() =>
        'final size=$size content=${usedContentWidth.toStringAsFixed(2)}x${usedContentHeight.toStringAsFixed(2)} rows=${rowSizes.length} implicitRows=${implicitRowHeights.length}');

    // Compute and cache CSS baselines for the grid container
    calculateBaseline();
  }

  @override
  void calculateBaseline() {
    // MVP baseline behavior: use the bottom border edge as baseline when inline-level.
    // For block-level grid containers, baseline is generally not used; we still cache
    // a reasonable value to satisfy callers.
    final double baseline = boxSize?.height ?? size.height;
    setCssBaselines(first: baseline, last: baseline);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final double? first = computeCssFirstBaselineOf(baseline);
    if (first != null) return first;
    final double? last = computeCssLastBaselineOf(baseline);
    if (last != null) return last;
    return boxSize?.height;
  }
  double? _resolveAutoTrackAt(List<GridTrackSize> tracks, int index, double? innerAvailable) {
    if (tracks.isEmpty) return null;
    final GridTrackSize track = tracks[index % tracks.length];
    final double size = _resolveTrackSize(track, innerAvailable);
    if (size > 0) return size;
    return null;
  }
}
