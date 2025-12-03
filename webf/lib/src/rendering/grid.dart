/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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

class GridLayoutParentData extends RenderLayoutParentData {
  int rowStart = 0;
  int columnStart = 0;
  int rowSpan = 1;
  int columnSpan = 1;

  @override
  String toString() {
    return '${super.toString()}; row=$rowStart; column=$columnStart; rowSpan=$rowSpan; columnSpan=$columnSpan';
  }
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
    if (child.parentData is! GridLayoutParentData) {
      child.parentData = GridLayoutParentData();
    }
  }

  void _gridLog(String Function() message) {
    if (!DebugFlags.enableCssGridLayout) return;
    renderingLogger.finer('[Grid] ${message()}');
  }

  bool get _gridProfilingEnabled => DebugFlags.enableCssGridProfiling;

  void _logGridProfile(String label, Duration elapsed) {
    if (!_gridProfilingEnabled) return;
    if (elapsed.inMilliseconds < DebugFlags.cssGridProfilingMinMs) return;
    final double ms = elapsed.inMicroseconds / 1000.0;
    renderingLogger.info('[GridProfile][$label] ${ms.toStringAsFixed(3)} ms');
  }

  T _profileGridSection<T>(String label, T Function() run) {
    if (!_gridProfilingEnabled) return run();
    final Stopwatch sw = Stopwatch()..start();
    final T result = run();
    sw.stop();
    _logGridProfile(label, sw.elapsed);
    return result;
  }

  int? _resolveGridLineNumber(
    GridPlacement placement,
    int trackCount, {
    Map<String, List<int>>? namedLines,
  }) {
    if (placement.kind != GridPlacementKind.line) return null;
    if (placement.lineName != null && namedLines != null) {
      final List<int>? indices = namedLines[placement.lineName!];
      if (indices != null && indices.isNotEmpty) {
        final int occurrence = placement.lineNameOccurrence ?? 1;
        if (occurrence == 0) return null;
        int selectedIndex;
        if (occurrence > 0) {
          if (occurrence > indices.length) return null;
          selectedIndex = indices[occurrence - 1];
        } else {
          final int absOccurrence = -occurrence;
          if (absOccurrence > indices.length) return null;
          selectedIndex = indices[indices.length - absOccurrence];
        }
        return selectedIndex + 1;
      }
    }
    if (placement.line == null) return null;
    final int raw = placement.line!;
    if (raw > 0) {
      return raw;
    }
    final int totalLines = math.max(trackCount, 0) + 1;
    final int candidate = totalLines + 1 + raw;
    return candidate.clamp(1, totalLines);
  }

  int? _resolveTrackIndexFromPlacement(
    GridPlacement placement,
    int trackCount, {
    Map<String, List<int>>? namedLines,
  }) {
    final int? lineNumber = _resolveGridLineNumber(placement, trackCount, namedLines: namedLines);
    if (lineNumber == null) return null;
    return math.max(0, lineNumber - 1);
  }

  int? _resolveLineRequirementIndex(
    GridPlacement placement,
    int trackCount, {
    Map<String, List<int>>? namedLines,
  }) {
    if (placement.kind != GridPlacementKind.line) return null;
    if (placement.lineName != null && namedLines != null) {
      final List<int>? indices = namedLines[placement.lineName!];
      if (indices != null && indices.isNotEmpty) {
        final int occurrence = placement.lineNameOccurrence ?? 1;
        if (occurrence == 0) return null;
        int selectedIndex;
        if (occurrence > 0) {
          if (occurrence > indices.length) return null;
          selectedIndex = indices[occurrence - 1];
        } else {
          final int absOccurrence = -occurrence;
          if (absOccurrence > indices.length) return null;
          selectedIndex = indices[indices.length - absOccurrence];
        }
        return selectedIndex;
      }
    }
    if (placement.line == null) return null;
    final int raw = placement.line!;
    if (raw > 0) {
      return raw - 1;
    }
    final int totalLines = math.max(trackCount, 0) + 1;
    final int candidate = totalLines + 1 + raw;
    return math.max(candidate - 1, 0);
  }

  int _resolveSpan(
    GridPlacement start,
    GridPlacement end,
    int trackCount, {
    Map<String, List<int>>? namedLines,
  }) {
    if (end.kind == GridPlacementKind.span && end.span != null) {
      return math.max(1, end.span!);
    }
    if (start.kind == GridPlacementKind.span && start.span != null) {
      return math.max(1, start.span!);
    }
    if (start.kind == GridPlacementKind.line && end.kind == GridPlacementKind.line) {
      final int normalizedTracks = math.max(trackCount, 1);
      final int? startLine =
          _resolveGridLineNumber(start, normalizedTracks, namedLines: namedLines);
      final int? endLine = _resolveGridLineNumber(end, normalizedTracks, namedLines: namedLines);
      if (startLine != null && endLine != null) {
        final int diff = endLine - startLine;
        return diff > 0 ? diff : 1;
      }
    }
    return 1;
  }

  void _ensureOccupancyRows(List<List<bool>> occupancy, int rows, int columns) {
    while (occupancy.length < rows) {
      occupancy.add(List<bool>.filled(columns, false, growable: true));
    }
    for (int r = 0; r < occupancy.length; r++) {
      List<bool> row = occupancy[r];
      if (row.length < columns) {
        row.addAll(List<bool>.filled(columns - row.length, false));
      }
    }
  }

  double _resolvedRowHeight(List<double> rowSizes, List<double> implicitRowHeights, int index) {
    final double explicit = index < rowSizes.length ? rowSizes[index] : 0;
    final double implicit = index < implicitRowHeights.length ? implicitRowHeights[index] : 0;
    if (explicit > 0) return explicit;
    return implicit;
  }

  double _resolveJustifyContentShift(JustifyContent justifyContent, double freeSpace) {
    if (freeSpace <= 0) return 0;
    switch (justifyContent) {
      case JustifyContent.center:
        return freeSpace / 2;
      case JustifyContent.flexEnd:
      case JustifyContent.end:
        return freeSpace;
      case JustifyContent.flexStart:
      case JustifyContent.start:
      case JustifyContent.spaceBetween:
      case JustifyContent.spaceAround:
      case JustifyContent.spaceEvenly:
      default:
        return 0;
    }
  }

  double _resolveAlignContentShift(AlignContent alignContent, double freeSpace) {
    if (freeSpace <= 0) return 0;
    switch (alignContent) {
      case AlignContent.center:
        return freeSpace / 2;
      case AlignContent.flexEnd:
      case AlignContent.end:
        return freeSpace;
      case AlignContent.flexStart:
      case AlignContent.start:
      case AlignContent.spaceBetween:
      case AlignContent.spaceAround:
      case AlignContent.spaceEvenly:
      case AlignContent.stretch:
      default:
        return 0;
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

  GridAxisAlignment _resolveJustifySelfAlignment(RenderStyle? childStyle) {
    final GridAxisAlignment alignment = childStyle?.justifySelf ?? GridAxisAlignment.auto;
    if (alignment == GridAxisAlignment.auto) {
      return renderStyle.justifyItems;
    }
    return alignment;
  }

  GridAxisAlignment _resolveAlignSelfAlignment(RenderStyle? childStyle) {
    final AlignSelf alignSelf = childStyle?.alignSelf ?? AlignSelf.auto;
    if (alignSelf == AlignSelf.auto) {
      return _convertAlignItemsToAxis(renderStyle.alignItems);
    }
    return _convertAlignSelfToAxis(alignSelf);
  }

  GridAxisAlignment _convertAlignItemsToAxis(AlignItems value) {
    switch (value) {
      case AlignItems.flexStart:
      case AlignItems.start:
        return GridAxisAlignment.start;
      case AlignItems.flexEnd:
      case AlignItems.end:
        return GridAxisAlignment.end;
      case AlignItems.center:
      case AlignItems.baseline:
        return GridAxisAlignment.center;
      case AlignItems.stretch:
      default:
        return GridAxisAlignment.stretch;
    }
  }

  GridAxisAlignment _convertAlignSelfToAxis(AlignSelf value) {
    switch (value) {
      case AlignSelf.flexStart:
      case AlignSelf.start:
        return GridAxisAlignment.start;
      case AlignSelf.flexEnd:
      case AlignSelf.end:
        return GridAxisAlignment.end;
      case AlignSelf.center:
      case AlignSelf.baseline:
        return GridAxisAlignment.center;
      case AlignSelf.stretch:
      default:
        return GridAxisAlignment.stretch;
    }
  }

  double _alignmentOffsetWithinCell(GridAxisAlignment alignment, double extraSpace) {
    if (extraSpace <= 0) return 0;
    switch (alignment) {
      case GridAxisAlignment.end:
        return extraSpace;
      case GridAxisAlignment.center:
        return extraSpace / 2;
      case GridAxisAlignment.auto:
      case GridAxisAlignment.start:
      case GridAxisAlignment.stretch:
      default:
        return 0;
    }
  }

  double? _preferredChildWidth(RenderStyle? childStyle) {
    if (childStyle == null) return null;
    if (childStyle.width.isAuto) return null;
    return childStyle.width.computedValue;
  }

  List<GridTrackSize> _materializeTrackList(
    List<GridTrackSize> tracks,
    double? innerAvailable,
    double gap,
    Axis axis,
  ) {
    if (tracks.isEmpty) return const <GridTrackSize>[];
    final List<GridTrackSize> resolved = <GridTrackSize>[];
    for (final GridTrackSize track in tracks) {
      if (track is GridRepeat) {
        final int repeatCount = _repeatCountFor(track, innerAvailable, gap);
        resolved.addAll(_expandRepeatTracks(track, repeatCount));
      } else {
        resolved.add(track);
      }
    }
    return resolved;
  }

  bool _patternHasFlexibleTracks(List<GridTrackSize> tracks) {
    for (final GridTrackSize track in tracks) {
      if (track is GridFraction) return true;
      if (track is GridMinMax && track.maxTrack is GridFraction) return true;
      if (track is GridRepeat) return true;
    }
    return false;
  }

  double _measurePatternBreadth(List<GridTrackSize> tracks, double? innerAvailable, double gap) {
    double total = 0;
    for (int i = 0; i < tracks.length; i++) {
      total += _resolveTrackSize(tracks[i], innerAvailable);
      if (i < tracks.length - 1) {
        total += gap;
      }
    }
    return total;
  }

  int _repeatCountFor(GridRepeat repeat, double? innerAvailable, double gap) {
    if (repeat.kind == GridRepeatKind.count) {
      return math.max(1, repeat.count ?? 1);
    }
    if (innerAvailable == null || !innerAvailable.isFinite) return 1;
    if (repeat.tracks.isEmpty) return 1;
    if (_patternHasFlexibleTracks(repeat.tracks)) return 1;

    final double patternBreadth = _measurePatternBreadth(repeat.tracks, innerAvailable, gap);
    if (patternBreadth <= 0) return 1;
    final double perPattern = patternBreadth + gap;
    final double available = innerAvailable + gap;
    final int repeatCount = math.max(1, (available / perPattern).floor());
    return repeatCount.clamp(1, 100);
  }

  List<GridTrackSize> _expandRepeatTracks(GridRepeat repeat, int repeatCount) {
    if (repeat.tracks.isEmpty || repeatCount <= 0) return const <GridTrackSize>[];
    final List<GridTrackSize> expanded = <GridTrackSize>[];
    for (int iteration = 0; iteration < repeatCount; iteration++) {
      for (int i = 0; i < repeat.tracks.length; i++) {
        List<String>? leading;
        List<String>? trailing;
        if (iteration == 0 && i == 0 && repeat.leadingLineNames.isNotEmpty) {
          leading = <String>[...repeat.leadingLineNames, ...repeat.tracks[i].leadingLineNames];
        }
        if (iteration == repeatCount - 1 && i == repeat.tracks.length - 1 && repeat.trailingLineNames.isNotEmpty) {
          trailing = <String>[...repeat.tracks[i].trailingLineNames, ...repeat.trailingLineNames];
        }
        expanded.add(_cloneTrackForRepeat(
          repeat.tracks[i],
          leading: leading,
          trailing: trailing,
          forceAutoFit: repeat.kind == GridRepeatKind.autoFit,
        ));
      }
    }
    return expanded;
  }

  GridTrackSize _cloneTrackForRepeat(
    GridTrackSize source, {
    List<String>? leading,
    List<String>? trailing,
    bool forceAutoFit = false,
  }) {
    final List<String> resolvedLeading =
        leading ?? (source.leadingLineNames.isEmpty ? const <String>[] : List<String>.from(source.leadingLineNames));
    final List<String> resolvedTrailing =
        trailing ?? (source.trailingLineNames.isEmpty ? const <String>[] : List<String>.from(source.trailingLineNames));
    final bool autoFit = forceAutoFit || source.isAutoFit;

    if (source is GridFixed) {
      return GridFixed(
        source.length,
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
        isAutoFit: autoFit,
      );
    } else if (source is GridFraction) {
      return GridFraction(
        source.fr,
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
        isAutoFit: autoFit,
      );
    } else if (source is GridAuto) {
      return GridAuto(
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
        isAutoFit: autoFit,
      );
    } else if (source is GridMinMax) {
      return GridMinMax(
        source.minTrack,
        source.maxTrack,
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
        isAutoFit: autoFit,
      );
    } else if (source is GridFitContent) {
      return GridFitContent(
        source.limit,
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
        isAutoFit: autoFit,
      );
    }
    return source;
  }

  Map<String, List<int>>? _buildLineNameMap(List<GridTrackSize> tracks) {
    if (tracks.isEmpty) return null;
    final Map<String, List<int>> map = <String, List<int>>{};
    int lineIndex = 0;

    void addNames(List<String> names, int index) {
      for (final name in names) {
        map.putIfAbsent(name, () => <int>[]).add(index);
      }
    }

    for (int i = 0; i < tracks.length; i++) {
      final GridTrackSize track = tracks[i];
      if (track.leadingLineNames.isNotEmpty) {
        addNames(track.leadingLineNames, lineIndex);
      }
      lineIndex++;
      if (track.trailingLineNames.isNotEmpty) {
        addNames(track.trailingLineNames, lineIndex);
      }
    }

    return map.isEmpty ? null : map;
  }

  _GridCellPlacement _placeAutoItem({
    required List<List<bool>> occupancy,
    required List<double> columnSizes,
    required int explicitColumnCount,
    required List<GridTrackSize> autoColumns,
    required double? adjustedInnerWidth,
    required int columnSpan,
    required int rowSpan,
    required int? explicitRow,
    required int? explicitColumn,
    required GridAutoFlow autoFlow,
    required _GridAutoCursor cursor,
    required bool hasDefiniteColumn,
    required bool hasDefiniteRow,
    required int explicitRowCount,
    required int rowTrackCountForPlacement,
  }) {
    final bool dense = autoFlow == GridAutoFlow.rowDense || autoFlow == GridAutoFlow.columnDense;
    final bool rowFlow = autoFlow == GridAutoFlow.row || autoFlow == GridAutoFlow.rowDense;

    int columnCount = columnSizes.length;
    final int colSpan = columnSpan.clamp(1, math.max(1, columnCount));
    final int rowSpanClamped = math.max(1, rowSpan);

    if (rowFlow) {
      int startRow;
      if (explicitRow != null) {
        startRow = explicitRow;
      } else if (dense || hasDefiniteColumn) {
        startRow = 0;
      } else {
        startRow = cursor.row;
      }
      int row = math.max(0, startRow);

      while (true) {
        _ensureOccupancyRows(occupancy, row + rowSpanClamped, columnCount);
        final int columnStart = explicitColumn ??
            (!dense && explicitRow == null && !hasDefiniteColumn && row == cursor.row ? cursor.column : 0);

        for (int col = math.max(0, columnStart); col <= columnCount - colSpan; col++) {
          if (_canPlace(occupancy, row, col, rowSpanClamped, colSpan, columnCount)) {
            _markPlacement(occupancy, row, col, rowSpanClamped, colSpan);
            if (explicitRow == null && !hasDefiniteColumn) {
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

    final bool useCursorColumn =
        !dense && explicitRow == null && explicitColumn == null && !hasDefiniteRow;
    int column = explicitColumn ?? (useCursorColumn ? cursor.column : 0);
    bool cursorApplied = false;

    while (true) {
      if (column < 0) column = 0;
      if (column + colSpan > columnCount) {
        _ensureImplicitColumns(
          colSizes: columnSizes,
          requiredCount: column + colSpan,
          explicitCount: explicitColumnCount,
          autoColumns: autoColumns,
          innerAvailable: adjustedInnerWidth,
        );
        columnCount = columnSizes.length;
      }

      final int desiredRowStart =
          explicitRow ?? ((useCursorColumn && !cursorApplied && column == cursor.column) ? cursor.row : 0);
      final int rowTrackLimit =
          math.max(rowTrackCountForPlacement, rowSpanClamped + math.max(0, desiredRowStart));
      final int maxRowIndex = math.max(0, rowTrackLimit - rowSpanClamped);

      int row = math.max(0, math.min(desiredRowStart, maxRowIndex));
      bool placed = false;

      while (row <= maxRowIndex) {
        _ensureOccupancyRows(occupancy, row + rowSpanClamped, columnCount);
        if (_canPlace(occupancy, row, column, rowSpanClamped, colSpan, columnCount)) {
          placed = true;
          break;
        }
        row++;
      }

      if (!placed && dense && explicitRow == null) {
        int wrapRow = 0;
        final int wrapLimit = math.min(math.max(0, desiredRowStart), maxRowIndex + 1);
        while (wrapRow < wrapLimit) {
          _ensureOccupancyRows(occupancy, wrapRow + rowSpanClamped, columnCount);
          if (_canPlace(occupancy, wrapRow, column, rowSpanClamped, colSpan, columnCount)) {
            row = wrapRow;
            placed = true;
            break;
          }
          wrapRow++;
        }
      }

      if (placed) {
        _markPlacement(occupancy, row, column, rowSpanClamped, colSpan);
        if (explicitRow == null && !hasDefiniteRow) {
          cursor.column = column;
          cursor.row = row + rowSpanClamped;
          if (!dense && cursor.row >= math.max(explicitRowCount, occupancy.length)) {
            cursor.row = 0;
            cursor.column = column + colSpan;
          }
        }
        return _GridCellPlacement(row, column);
      }

      cursorApplied = true;
      column++;
    }
  }

  double _resolveLengthValue(CSSLengthValue length, double? innerAvailable) {
    if (length.type == CSSLengthType.PERCENTAGE) {
      if (innerAvailable != null && innerAvailable.isFinite) {
        return (length.value ?? 0) * innerAvailable;
      }
      return 0;
    }
    return length.computedValue;
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
    } else if (track is GridMinMax) {
      final GridTrackSize maxTrack = track.maxTrack;
      if (maxTrack is GridFraction) {
        return _resolveTrackSize(track.minTrack, innerAvailable);
      }
      final double minValue = _resolveTrackSize(track.minTrack, innerAvailable);
      final double maxValue = _resolveTrackSize(maxTrack, innerAvailable);
      return math.max(minValue, maxValue);
    } else if (track is GridFitContent) {
      final double limit = _resolveLengthValue(track.limit, innerAvailable);
      if (innerAvailable != null && innerAvailable.isFinite) {
        return math.min(limit, innerAvailable);
      }
      return limit;
    }
    return 0;
  }

  List<double> _resolveTracks(List<GridTrackSize> tracks, double? innerAvailable, Axis axis) {
    if (tracks.isEmpty) {
      return <double>[];
    }

    final List<double> sizes = List<double>.filled(tracks.length, 0.0, growable: true);
    final List<double> minFlexSizes = List<double>.filled(tracks.length, 0.0, growable: true);
    final List<double> flexFactors = List<double>.filled(tracks.length, 0.0, growable: true);

    double fixed = 0.0;
    double frSum = 0.0;
    for (int i = 0; i < tracks.length; i++) {
      final t = tracks[i];
      if (t is GridFraction) {
        final double fr = t.fr;
        flexFactors[i] = fr;
        frSum += fr;
      } else if (t is GridMinMax && t.maxTrack is GridFraction) {
        final double minSize = _resolveTrackSize(t.minTrack, innerAvailable);
        minFlexSizes[i] = minSize;
        final double fr = (t.maxTrack as GridFraction).fr;
        flexFactors[i] = fr;
        frSum += fr;
      } else if (t is GridFixed) {
        sizes[i] = _resolveTrackSize(t, innerAvailable);
        fixed += sizes[i];
      } else {
        sizes[i] = _resolveTrackSize(t, innerAvailable);
        fixed += sizes[i];
      }
    }

    double remaining = 0.0;
    if (innerAvailable != null && innerAvailable.isFinite) {
      remaining = math.max(0.0, innerAvailable - fixed);
    }

    if (frSum > 0 && remaining > 0) {
      for (int i = 0; i < tracks.length; i++) {
        if (flexFactors[i] <= 0) continue;
        final double portion = remaining * (flexFactors[i] / frSum);
        final GridTrackSize t = tracks[i];
        if (t is GridFraction) {
          sizes[i] = portion;
        } else if (t is GridMinMax && t.maxTrack is GridFraction) {
          sizes[i] = math.max(portion, minFlexSizes[i]);
        }
      }
    } else {
      for (int i = 0; i < tracks.length; i++) {
        if (flexFactors[i] <= 0) continue;
        final GridTrackSize t = tracks[i];
        if (t is GridFraction) {
          sizes[i] = 0;
        } else if (t is GridMinMax && t.maxTrack is GridFraction) {
          sizes[i] = minFlexSizes[i];
        }
      }
    }

    return sizes;
  }

  @override
  void performLayout() {
    beforeLayout();
    final BoxConstraints contentConstraints = this.contentConstraints ?? constraints;
    try {
      _performGridLayout(contentConstraints);
      initOverflowLayout(
        Rect.fromLTRB(0, 0, size.width, size.height),
        Rect.fromLTRB(0, 0, size.width, size.height),
      );
      addOverflowLayoutFromChildren(_collectChildren());
    } catch (error, stack) {
      if (!kReleaseMode) {
        renderingLogger.severe('RenderGridLayout.performLayout error: $error\n$stack');
      }
      rethrow;
    }
  }

  void _performGridLayout(BoxConstraints contentConstraints) {
    _gridLog(() => 'performLayout constraints=$constraints');
    final bool profileGrid = _gridProfilingEnabled;
    final Stopwatch? totalProfile = profileGrid ? (Stopwatch()..start()) : null;
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

    final bool hasBW = contentConstraints.hasBoundedWidth;
    final bool hasBH = contentConstraints.hasBoundedHeight;
    final double? innerMaxWidth = hasBW ? math.max(0.0, contentConstraints.maxWidth) : null;
    final double? innerMaxHeight = hasBH ? math.max(0.0, contentConstraints.maxHeight) : null;

    // Resolve tracks
    // Resolve explicit track definitions from render style; if not yet materialized
    // (e.g., very early layout), fall back to parsing inline style string once.
    List<GridTrackSize> colsDef = renderStyle.gridTemplateColumns;
    List<GridTrackSize> rowsDef = renderStyle.gridTemplateRows;
    final List<GridTrackSize> autoRowDefs = renderStyle.gridAutoRows;
    final GridTemplateAreasDefinition? templateAreasDef = renderStyle.gridTemplateAreasDefinition;
    final Map<String, GridTemplateAreaRect>? templateAreaMap =
        templateAreasDef != null && templateAreasDef.areas.isNotEmpty ? templateAreasDef.areas : null;
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
    final double colGap = renderStyle.columnGap.computedValue;
    final double rowGap = renderStyle.rowGap.computedValue;

    final double? contentAvailableWidth = innerMaxWidth;
    final List<GridTrackSize> autoColDefs = renderStyle.gridAutoColumns;
    final List<GridTrackSize> resolvedColumnDefs = _profileGridSection(
      'grid.materializeColumns',
      () => _materializeTrackList(colsDef, contentAvailableWidth, colGap, Axis.horizontal),
    );
    double? adjustedInnerWidth = contentAvailableWidth;
    if (adjustedInnerWidth != null && adjustedInnerWidth.isFinite && resolvedColumnDefs.isNotEmpty) {
      final double totalColGap = colGap * math.max(0, resolvedColumnDefs.length - 1);
      adjustedInnerWidth = math.max(0.0, adjustedInnerWidth - totalColGap);
    }
    final bool hasExplicitCols = resolvedColumnDefs.isNotEmpty;
    final List<double> colSizes = hasExplicitCols
        ? _profileGridSection(
            'grid.resolveColumns',
            () => _resolveTracks(resolvedColumnDefs, adjustedInnerWidth, Axis.horizontal),
          )
        : <double>[];
    final int explicitColumnCount = hasExplicitCols ? colSizes.length : 0;
    List<bool>? explicitAutoFitColumns;
    if (explicitColumnCount > 0) {
      explicitAutoFitColumns =
          List<bool>.generate(explicitColumnCount, (int index) => resolvedColumnDefs[index].isAutoFit);
      if (!explicitAutoFitColumns.contains(true)) {
        explicitAutoFitColumns = null;
      }
    }
    if (!hasExplicitCols) {
      _ensureImplicitColumns(
        colSizes: colSizes,
        requiredCount: 1,
        explicitCount: explicitColumnCount,
        autoColumns: autoColDefs,
        innerAvailable: adjustedInnerWidth,
      );
    }
    final double? contentAvailableHeight = innerMaxHeight;
    final List<GridTrackSize> resolvedRowDefs = _profileGridSection(
      'grid.materializeRows',
      () => _materializeTrackList(rowsDef, contentAvailableHeight, rowGap, Axis.vertical),
    );
    double? adjustedInnerHeight = contentAvailableHeight;
    if (adjustedInnerHeight != null && adjustedInnerHeight.isFinite && resolvedRowDefs.isNotEmpty) {
      final double totalRowGap = rowGap * math.max(0, resolvedRowDefs.length - 1);
      adjustedInnerHeight = math.max(0.0, adjustedInnerHeight - totalRowGap);
    }
    List<double> rowSizes = resolvedRowDefs.isEmpty
        ? <double>[]
        : _profileGridSection(
            'grid.resolveRows',
            () => _resolveTracks(resolvedRowDefs, adjustedInnerHeight, Axis.vertical),
          );
    final int definedRowCount = resolvedRowDefs.length;
    final int explicitRowCount = definedRowCount > 0 ? definedRowCount : 1;
    List<bool>? explicitAutoFitRows;
    if (resolvedRowDefs.isNotEmpty) {
      explicitAutoFitRows =
          List<bool>.generate(explicitRowCount, (int index) => resolvedRowDefs[index].isAutoFit);
      if (!explicitAutoFitRows.contains(true)) {
        explicitAutoFitRows = null;
      }
    }
    _gridLog(() =>
        'tracks resolved columns=${colSizes.map((e) => e.toStringAsFixed(2)).join(', ')} rows=${rowSizes.map((e) => e.toStringAsFixed(2)).join(', ')} autoRows=${renderStyle.gridAutoRows.length} autoFlow=${renderStyle.gridAutoFlow}');

    final Map<String, List<int>>? columnLineNameMap = _buildLineNameMap(resolvedColumnDefs);
    final Map<String, List<int>>? rowLineNameMap = _buildLineNameMap(resolvedRowDefs);
    final GridAutoFlow autoFlow = renderStyle.gridAutoFlow;

    // Layout children using auto placement matrix.
    final List<List<bool>> occupancy = <List<bool>>[];
    bool hasAnyChild = false;
    final _GridAutoCursor autoCursor = _GridAutoCursor(0, 0);
    final double xStart = paddingLeft + borderLeft;
    List<double> implicitRowHeights = [];
    List<bool>? explicitAutoFitColumnUsage;
    if (explicitAutoFitColumns != null) {
      explicitAutoFitColumnUsage = List<bool>.filled(explicitColumnCount, false);
    }
    List<bool>? explicitAutoFitRowUsage;
    if (explicitAutoFitRows != null) {
      explicitAutoFitRowUsage = List<bool>.filled(explicitRowCount, false);
    }

    int childIndex = 0;
    final Stopwatch? placementStopwatch = profileGrid ? (Stopwatch()..start()) : null;
    Duration childLayoutDuration = Duration.zero;
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
      // Honor grid-template-areas by mapping named areas to explicit line placements.
      if (templateAreaMap != null && childGridStyle?.gridAreaName != null) {
        final GridTemplateAreaRect? rect = templateAreaMap[childGridStyle!.gridAreaName!];
        if (rect != null) {
          columnStart = GridPlacement.line(rect.columnStart);
          columnEnd = GridPlacement.line(rect.columnEnd);
          rowStart = GridPlacement.line(rect.rowStart);
          rowEnd = GridPlacement.line(rect.rowEnd);
        }
      }

      final int normalizedInitialCols = math.max(colSizes.length, 1);
      final int normalizedInitialRows = math.max(rowSizes.length, 1);
      int colSpan = _resolveSpan(
        columnStart,
        columnEnd,
        normalizedInitialCols,
        namedLines: columnLineNameMap,
      );
      int rowSpan = math.max(
        1,
        _resolveSpan(
          rowStart,
          rowEnd,
          normalizedInitialRows,
          namedLines: rowLineNameMap,
        ),
      );

      int neededColumns = colSizes.length;
      final int? columnStartRequirement =
          _resolveLineRequirementIndex(columnStart, normalizedInitialCols, namedLines: columnLineNameMap);
      if (columnStartRequirement != null) {
        neededColumns = math.max(neededColumns, columnStartRequirement + colSpan);
      }
      final int? columnEndRequirement =
          _resolveLineRequirementIndex(columnEnd, normalizedInitialCols, namedLines: columnLineNameMap);
      if (columnEndRequirement != null) {
        neededColumns = math.max(neededColumns, columnEndRequirement);
      }
      final bool rowFlow = autoFlow == GridAutoFlow.row || autoFlow == GridAutoFlow.rowDense;
      if (!rowFlow) {
        neededColumns = math.max(neededColumns, autoCursor.column + colSpan);
      }
      _ensureImplicitColumns(
        colSizes: colSizes,
        requiredCount: neededColumns,
        explicitCount: explicitColumnCount,
        autoColumns: autoColDefs,
        innerAvailable: adjustedInnerWidth,
      );
      final int colCount = colSizes.length;
      colSpan = colSpan.clamp(1, colCount);
      final int rowTrackCountForPlacement = math.max(math.max(rowSizes.length, explicitRowCount), 1);
      int? explicitColumn =
          _resolveTrackIndexFromPlacement(columnStart, colCount, namedLines: columnLineNameMap);
      if (explicitColumn != null) {
        explicitColumn = explicitColumn.clamp(0, math.max(0, colCount - colSpan));
      }
      int? explicitRow = _resolveTrackIndexFromPlacement(
        rowStart,
        rowTrackCountForPlacement,
        namedLines: rowLineNameMap,
      );
      if (explicitRow != null &&
          rowStart.kind == GridPlacementKind.line &&
          rowStart.line != null &&
          rowStart.line! < 0 &&
          rowEnd.kind == GridPlacementKind.auto &&
          explicitRow >= rowTrackCountForPlacement) {
        explicitRow = math.max(0, rowTrackCountForPlacement - rowSpan);
      }

      final bool hasDefiniteColumn =
          columnStart.kind == GridPlacementKind.line || columnEnd.kind == GridPlacementKind.line;
      final bool hasDefiniteRow =
          rowStart.kind == GridPlacementKind.line || rowEnd.kind == GridPlacementKind.line;

      final _GridCellPlacement placement = _placeAutoItem(
        occupancy: occupancy,
        columnSizes: colSizes,
        explicitColumnCount: explicitColumnCount,
        autoColumns: autoColDefs,
        adjustedInnerWidth: adjustedInnerWidth,
        columnSpan: colSpan,
        rowSpan: rowSpan,
        explicitRow: explicitRow,
        explicitColumn: explicitColumn,
        autoFlow: autoFlow,
        cursor: autoCursor,
        hasDefiniteColumn: hasDefiniteColumn,
        hasDefiniteRow: hasDefiniteRow,
        explicitRowCount: rowTrackCountForPlacement,
        rowTrackCountForPlacement: rowTrackCountForPlacement,
      );

      final int rowIndex = placement.row;
      final int colIndex = placement.column;
      if (explicitAutoFitColumnUsage != null && colIndex < explicitColumnCount) {
        final int usageEnd = math.min(explicitColumnCount, colIndex + colSpan);
        for (int c = colIndex; c < usageEnd; c++) {
          explicitAutoFitColumnUsage[c] = true;
        }
      }
      if (explicitAutoFitRowUsage != null && rowIndex < explicitRowCount) {
        final int usageEnd = math.min(explicitRowCount, rowIndex + rowSpan);
        for (int r = rowIndex; r < usageEnd; r++) {
          explicitAutoFitRowUsage[r] = true;
        }
      }

      while (rowSizes.length < rowIndex + rowSpan) {
        rowSizes.add(0);
      }
      while (implicitRowHeights.length < rowIndex + rowSpan) {
        implicitRowHeights.add(0);
      }

      if (rowsDef.isEmpty || rowIndex + rowSpan > definedRowCount) {
        for (int r = rowIndex; r < rowIndex + rowSpan; r++) {
          if (rowSizes[r] <= 0 && autoRowDefs.isNotEmpty) {
            final int implicitOrdinal =
                rowsDef.isEmpty ? r : math.max(0, r - definedRowCount);
            final double? autoSize = _resolveAutoTrackAt(autoRowDefs, implicitOrdinal, innerMaxHeight);
            if (autoSize != null) {
              rowSizes[r] = autoSize;
            }
          }
        }
      }

      if (colSpan == 1 &&
          colIndex < resolvedColumnDefs.length &&
          resolvedColumnDefs[colIndex] is GridFitContent) {
        final double? preferred = _preferredChildWidth(childGridStyle);
        if (preferred != null && preferred.isFinite) {
          final GridFitContent fitTrack = resolvedColumnDefs[colIndex] as GridFitContent;
          final double limit = _resolveLengthValue(fitTrack.limit, adjustedInnerWidth);
          final double target = math.max(limit, preferred);
          if (target > colSizes[colIndex]) {
            colSizes[colIndex] = target;
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
        explicitHeight += _resolvedRowHeight(rowSizes, implicitRowHeights, r);
      }
      if (hasExplicitRowSize) {
        explicitHeight += rowGap * math.max(0, rowSpan - 1);
      }
      final double cellHeight = hasExplicitRowSize ? explicitHeight : double.nan;

      double? explicitItemHeight;
      if (childGridStyle != null && childGridStyle.height.isNotAuto) {
        explicitItemHeight = childGridStyle.height.computedValue;
      }

      final GridAxisAlignment justifySelfAlignment = _resolveJustifySelfAlignment(childGridStyle);
      final GridAxisAlignment alignSelfAlignment = _resolveAlignSelfAlignment(childGridStyle);
      final bool childWidthAuto = childGridStyle?.width.isAuto ?? true;
      final bool childHeightAuto = childGridStyle?.height.isAuto ?? true;
      final bool stretchWidth =
          justifySelfAlignment == GridAxisAlignment.stretch && childWidthAuto && cellWidth.isFinite;
      final bool stretchHeight = alignSelfAlignment == GridAxisAlignment.stretch && childHeightAuto &&
          hasExplicitRowSize && explicitItemHeight == null;

      final double minWidthConstraint = stretchWidth ? cellWidth : 0;
      final double maxWidthConstraint = cellWidth.isFinite ? cellWidth : (innerMaxWidth ?? double.infinity);
      final double minHeightConstraint =
          explicitItemHeight ?? (stretchHeight && cellHeight.isFinite ? cellHeight : 0);
      final double maxHeightConstraint =
          explicitItemHeight ?? (cellHeight.isFinite ? cellHeight : (innerMaxHeight ?? double.infinity));

      final BoxConstraints childConstraints = BoxConstraints(
        minWidth: minWidthConstraint,
        maxWidth: maxWidthConstraint,
        minHeight: minHeightConstraint,
        maxHeight: maxHeightConstraint,
      );

      Stopwatch? childLayoutSw;
      if (profileGrid) childLayoutSw = Stopwatch()..start();
      child.layout(childConstraints, parentUsesSize: true);
      if (childLayoutSw != null) {
        childLayoutSw.stop();
        childLayoutDuration += childLayoutSw.elapsed;
      }

      final Size childSize = child.size;
      final double perRow = childSize.height / rowSpan;
      for (int r = 0; r < rowSpan; r++) {
        implicitRowHeights[rowIndex + r] = math.max(implicitRowHeights[rowIndex + r], perRow);
      }

      final GridLayoutParentData pd = child.parentData as GridLayoutParentData;
      double rowTop = paddingTop + borderTop;
      for (int r = 0; r < rowIndex; r++) {
        final double rh = _resolvedRowHeight(rowSizes, implicitRowHeights, r);
        rowTop += rh;
        rowTop += rowGap;
      }

      final double horizontalExtra = cellWidth.isFinite ? math.max(0, cellWidth - childSize.width) : 0;
      final double verticalExtra = hasExplicitRowSize && cellHeight.isFinite
          ? math.max(0, cellHeight - childSize.height)
          : 0;
      final double horizontalInset = _alignmentOffsetWithinCell(justifySelfAlignment, horizontalExtra);
      final double verticalInset = hasExplicitRowSize
          ? _alignmentOffsetWithinCell(alignSelfAlignment, verticalExtra)
          : 0;
      pd.offset = Offset(xOffset + horizontalInset, rowTop + verticalInset);
      pd
        ..rowStart = rowIndex
        ..columnStart = colIndex
        ..rowSpan = rowSpan
        ..columnSpan = colSpan;
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
    if (explicitAutoFitColumns != null && explicitAutoFitColumnUsage != null) {
      double collapsedWidth = 0;
      for (int i = explicitColumnCount - 1; i >= 0; i--) {
        if (!explicitAutoFitColumns![i] || explicitAutoFitColumnUsage[i]) {
          break;
        }
        collapsedWidth += colSizes[i];
        if (i > 0) {
          collapsedWidth += colGap;
        }
      }
      if (collapsedWidth > 0) {
        usedContentWidth = math.max(0.0, usedContentWidth - collapsedWidth);
      }
    }
    double usedContentHeight = 0;
    final int totalRows = math.max(rowSizes.length, implicitRowHeights.length);
    for (int r = 0; r < totalRows; r++) {
      final double segment = _resolvedRowHeight(rowSizes, implicitRowHeights, r);
      usedContentHeight += segment;
      if (r < totalRows - 1) usedContentHeight += rowGap;
    }
    if (explicitAutoFitRows != null && explicitAutoFitRowUsage != null) {
      double collapsedHeight = 0;
      for (int i = explicitRowCount - 1; i >= 0; i--) {
        if (!explicitAutoFitRows![i] || explicitAutoFitRowUsage[i]) {
          break;
        }
        collapsedHeight += rowSizes[i];
        if (i > 0) {
          collapsedHeight += rowGap;
        }
      }
      if (collapsedHeight > 0) {
        usedContentHeight = math.max(0.0, usedContentHeight - collapsedHeight);
      }
    }

    // Final size constrained by constraints
    final bool isBlockGrid =
        renderStyle.display == CSSDisplay.grid && renderStyle.effectiveDisplay == CSSDisplay.grid;
    double layoutContentWidth = usedContentWidth;
    double layoutContentHeight = usedContentHeight;

    if (renderStyle.width.isAuto && innerMaxWidth != null && innerMaxWidth.isFinite) {
      if (isBlockGrid) {
        layoutContentWidth = math.max(layoutContentWidth, innerMaxWidth);
      } else if (layoutContentWidth == 0 && !hasAnyChild) {
        layoutContentWidth = innerMaxWidth;
      }
    } else if (layoutContentWidth == 0 && innerMaxWidth != null && innerMaxWidth.isFinite) {
      if (renderStyle.width.isNotAuto || !hasAnyChild) {
        layoutContentWidth = innerMaxWidth;
      }
    }
    if (layoutContentHeight == 0 && innerMaxHeight != null && innerMaxHeight.isFinite) {
      if (renderStyle.height.isNotAuto || !hasAnyChild) {
        layoutContentHeight = innerMaxHeight;
      }
    }

    final double desiredWidth = layoutContentWidth + horizontalPaddingBorder;
    final double desiredHeight = layoutContentHeight + verticalPaddingBorder;
    size = constraints.constrain(Size(desiredWidth, desiredHeight));
    final double horizontalFree = math.max(0.0, size.width - horizontalPaddingBorder - usedContentWidth);
    final double verticalFree = math.max(0.0, size.height - verticalPaddingBorder - usedContentHeight);
    final double justifyShift = _resolveJustifyContentShift(renderStyle.justifyContent, horizontalFree);
    final double alignShift = _resolveAlignContentShift(renderStyle.alignContent, verticalFree);

    if (justifyShift != 0 || alignShift != 0) {
      RenderBox? child = firstChild;
      while (child != null) {
        final GridLayoutParentData pd = child.parentData as GridLayoutParentData;
        pd.offset += Offset(justifyShift, alignShift);
        child = pd.nextSibling;
      }
    }

    placementStopwatch?.stop();
    if (placementStopwatch != null) {
      _logGridProfile('grid.autoPlacement', placementStopwatch.elapsed);
    }
    if (profileGrid && childLayoutDuration > Duration.zero) {
      _logGridProfile('grid.childLayout', childLayoutDuration);
    }

    _gridLog(() =>
        'final size=$size content=${usedContentWidth.toStringAsFixed(2)}x${usedContentHeight.toStringAsFixed(2)} rows=${rowSizes.length} implicitRows=${implicitRowHeights.length} free=${horizontalFree.toStringAsFixed(2)}x${verticalFree.toStringAsFixed(2)} alignShift=$alignShift justifyShift=$justifyShift');

    // Compute and cache CSS baselines for the grid container
    calculateBaseline();

    totalProfile?.stop();
    if (totalProfile != null) {
      _logGridProfile('grid.total', totalProfile.elapsed);
    }
  }

  List<RenderBox> _collectChildren() {
    final List<RenderBox> children = <RenderBox>[];
    RenderBox? child = firstChild;
    while (child != null) {
      children.add(child);
      final GridLayoutParentData pd = child.parentData as GridLayoutParentData;
      child = pd.nextSibling;
    }
    return children;
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

  void _ensureImplicitColumns({
    required List<double> colSizes,
    required int requiredCount,
    required int explicitCount,
    required List<GridTrackSize> autoColumns,
    required double? innerAvailable,
  }) {
    if (requiredCount <= colSizes.length) return;
    while (colSizes.length < requiredCount) {
      final int implicitIndex = math.max(0, colSizes.length - explicitCount);
      final GridTrackSize pattern =
          autoColumns.isNotEmpty ? autoColumns[implicitIndex % autoColumns.length] : const GridAuto();
      final double size = _resolveTrackSize(pattern, innerAvailable);
      colSizes.add(size);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<GridAutoFlow>('gridAutoFlow', renderStyle.gridAutoFlow, defaultValue: GridAutoFlow.row));
    properties.add(IntProperty('explicitColumns', renderStyle.gridTemplateColumns.length, defaultValue: 0));
    properties.add(IntProperty('explicitRows', renderStyle.gridTemplateRows.length, defaultValue: 0));
    properties.add(IntProperty('autoColumnPatterns', renderStyle.gridAutoColumns.length, defaultValue: 0));
    properties.add(IntProperty('autoRowPatterns', renderStyle.gridAutoRows.length, defaultValue: 0));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final GridLayoutParentData pd = child.parentData as GridLayoutParentData;
      final String placement =
          'row ${pd.rowStart} span ${pd.rowSpan}, column ${pd.columnStart} span ${pd.columnSpan}';
      children.add(child.toDiagnosticsNode(name: 'child $index ($placement)'));
      child = pd.nextSibling;
      index++;
    }
    return children;
  }
}
