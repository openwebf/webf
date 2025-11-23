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
class _GridAutoCursor {
  int row;
  int column;
  _GridAutoCursor(this.row, this.column);
}

class _GridCellPlacement {
  final int row;
  final int column;
  _GridCellPlacement(this.row, this.column);
}

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

  int? _resolveLineIndex(GridPlacement placement) {
    if (placement.kind == GridPlacementKind.line && placement.line != null) {
      return math.max(0, placement.line! - 1);
    }
    return null;
  }

  int _resolveSpan(GridPlacement start, GridPlacement end) {
    if (end.kind == GridPlacementKind.span && end.span != null) {
      return math.max(1, end.span!);
    }
    if (start.kind == GridPlacementKind.span && start.span != null) {
      return math.max(1, start.span!);
    }
    if (start.kind == GridPlacementKind.line && end.kind == GridPlacementKind.line &&
        start.line != null && end.line != null) {
      final int diff = end.line! - start.line!;
      return diff > 0 ? diff : 1;
    }
    return 1;
  }

  void _ensureOccupancyRows(List<List<bool>> occupancy, int rows, int columns) {
    while (occupancy.length < rows) {
      occupancy.add(List<bool>.filled(columns, false));
    }
  }

  bool _canPlace(List<List<bool>> occupancy, int row, int column, int rowSpan, int colSpan, int columns) {
    if (column < 0 || column + colSpan > columns) return false;
    _ensureOccupancyRows(occupancy, row + rowSpan, columns);
    for (int r = row; r < row + rowSpan; r++) {
      for (int c = column; c < column + colSpan; c++) {
        if (occupancy[r][c]) return false;
      }
    }
    return true;
  }

  void _markPlacement(List<List<bool>> occupancy, int row, int column, int rowSpan, int colSpan) {
    for (int r = row; r < row + rowSpan; r++) {
      for (int c = column; c < column + colSpan; c++) {
        occupancy[r][c] = true;
      }
    }
  }

  _GridCellPlacement _placeAutoItem({
    required List<List<bool>> occupancy,
    required int columnCount,
    required int columnSpan,
    required int rowSpan,
    required int? explicitRow,
    required int? explicitColumn,
    required GridAutoFlow autoFlow,
    required _GridAutoCursor cursor,
  }) {
    final bool dense = autoFlow == GridAutoFlow.rowDense || autoFlow == GridAutoFlow.columnDense;
    final bool rowFlow = autoFlow == GridAutoFlow.row || autoFlow == GridAutoFlow.rowDense;

    final int colSpan = columnSpan.clamp(1, columnCount);
    final int rowSpanClamped = math.max(1, rowSpan);

    int startRow = explicitRow ?? (rowFlow ? (dense ? 0 : cursor.row) : cursor.row);
    int row = math.max(0, startRow);

    while (true) {
      _ensureOccupancyRows(occupancy, row + rowSpanClamped, columnCount);
      final int columnStart = explicitColumn ??
          (rowFlow && !dense && explicitRow == null && row == cursor.row ? cursor.column : 0);

      for (int col = math.max(0, columnStart); col <= columnCount - colSpan; col++) {
        if (_canPlace(occupancy, row, col, rowSpanClamped, colSpan, columnCount)) {
          _markPlacement(occupancy, row, col, rowSpanClamped, colSpan);
          if (explicitRow == null && rowFlow) {
            cursor.row = row;
            cursor.column = col + colSpan;
            if (cursor.column >= columnCount) {
              cursor.row += 1;
              cursor.column = 0;
            }
          }
          return _GridCellPlacement(row, col);
        }
      }
      row++;
    }
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

    final GridAutoFlow autoFlow = renderStyle.gridAutoFlow;

    // Layout children using auto placement matrix.
    final List<List<bool>> occupancy = <List<bool>>[];
    bool hasAnyChild = false;
    final _GridAutoCursor autoCursor = _GridAutoCursor(0, 0);
    final double xStart = paddingLeft + borderLeft;
    List<double> implicitRowHeights = [];

    int childIndex = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      RenderStyle? childGridStyle;
      if (child is RenderBoxModel) {
        childGridStyle = child.renderStyle;
      } else if (child is RenderEventListener) {
        final RenderBox? wrapped = child.child;
        if (wrapped is RenderBoxModel) {
          childGridStyle = wrapped.renderStyle;
        }
      }

      GridPlacement columnStart = childGridStyle?.gridColumnStart ?? const GridPlacement.auto();
      GridPlacement columnEnd = childGridStyle?.gridColumnEnd ?? const GridPlacement.auto();
      GridPlacement rowStart = childGridStyle?.gridRowStart ?? const GridPlacement.auto();
      GridPlacement rowEnd = childGridStyle?.gridRowEnd ?? const GridPlacement.auto();

      int colSpan = _resolveSpan(columnStart, columnEnd).clamp(1, colCount);
      int rowSpan = math.max(1, _resolveSpan(rowStart, rowEnd));

      int? explicitColumn = _resolveLineIndex(columnStart);
      int? explicitRow = _resolveLineIndex(rowStart);
      if (explicitColumn != null) {
        explicitColumn = explicitColumn.clamp(0, math.max(0, colCount - colSpan));
      }

      final _GridCellPlacement placement = _placeAutoItem(
        occupancy: occupancy,
        columnCount: colCount,
        columnSpan: colSpan,
        rowSpan: rowSpan,
        explicitRow: explicitRow,
        explicitColumn: explicitColumn,
        autoFlow: autoFlow,
        cursor: autoCursor,
      );

      final int rowIndex = placement.row;
      final int colIndex = placement.column;

      while (rowSizes.length < rowIndex + rowSpan) {
        rowSizes.add(0);
      }
      while (implicitRowHeights.length < rowIndex + rowSpan) {
        implicitRowHeights.add(0);
      }

      if (rowsDef.isEmpty) {
        for (int r = rowIndex; r < rowIndex + rowSpan; r++) {
          if (rowSizes[r] <= 0) {
            final double? autoSize = _resolveAutoTrackAt(autoRowDefs, r, innerMaxHeight);
            if (autoSize != null) {
              rowSizes[r] = autoSize;
            }
          }
        }
      }

      double xOffset = xStart;
      for (int c = 0; c < colIndex; c++) {
        xOffset += colSizes[c];
        xOffset += colGap;
      }

      double cellWidth = 0;
      for (int c = colIndex; c < math.min(colIndex + colSpan, colSizes.length); c++) {
        cellWidth += colSizes[c];
        if (c < colIndex + colSpan - 1) cellWidth += colGap;
      }

      bool hasExplicitRowSize = true;
      double explicitHeight = 0;
      for (int r = rowIndex; r < rowIndex + rowSpan; r++) {
        if (r >= rowSizes.length || rowSizes[r] <= 0) {
          hasExplicitRowSize = false;
          break;
        }
        explicitHeight += rowSizes[r];
      }
      if (hasExplicitRowSize) {
        explicitHeight += rowGap * math.max(0, rowSpan - 1);
      }
      final double cellHeight = hasExplicitRowSize ? explicitHeight : double.nan;

      final BoxConstraints childConstraints = BoxConstraints(
        minWidth: cellWidth.isFinite ? cellWidth : 0,
        maxWidth: cellWidth.isFinite ? cellWidth : (innerMaxWidth ?? double.infinity),
        minHeight: cellHeight.isFinite ? cellHeight : 0,
        maxHeight: cellHeight.isFinite ? cellHeight : (innerMaxHeight ?? double.infinity),
      );

      child.layout(childConstraints, parentUsesSize: true);

      final Size childSize = child.size;
      if (rowsDef.isEmpty && !hasExplicitRowSize) {
        final double perRow = childSize.height / rowSpan;
        for (int r = 0; r < rowSpan; r++) {
          implicitRowHeights[rowIndex + r] = math.max(implicitRowHeights[rowIndex + r], perRow);
        }
      }

      final RenderLayoutParentData pd = child.parentData as RenderLayoutParentData;
      double rowTop = paddingTop + borderTop;
      for (int r = 0; r < rowIndex; r++) {
        final double rh = rowSizes[r] > 0 ? rowSizes[r] : implicitRowHeights[r];
        rowTop += rh;
        rowTop += rowGap;
      }
      pd.offset = Offset(xOffset, rowTop);
      hasAnyChild = true;
      _gridLog(() =>
          'child#$childIndex row=$rowIndex col=$colIndex span=${rowSpan}x$colSpan offset=${pd.offset} childSize=${childSize} constraints=${childConstraints} explicitRow=$hasExplicitRowSize');

      child = pd.nextSibling;
      childIndex++;
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
    if (usedContentWidth == 0 && innerMaxWidth != null && innerMaxWidth.isFinite) {
      if (renderStyle.width.isNotAuto || !hasAnyChild) {
        usedContentWidth = innerMaxWidth;
      }
    }
    if (usedContentHeight == 0 && innerMaxHeight != null && innerMaxHeight.isFinite) {
      if (renderStyle.height.isNotAuto || !hasAnyChild) {
        usedContentHeight = innerMaxHeight;
      }
    }

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
