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

enum _GridPlacementPass {
  bothAxes,
  rowOnly,
  columnOnly,
  auto,
}

enum _IntrinsicTrackKind {
  none,
  auto,
  minContent,
  maxContent,
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
    required super.renderStyle,
  }) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! GridLayoutParentData) {
      child.parentData = GridLayoutParentData();
    }
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
    if (placement.lineName != null) {
      if (namedLines != null) {
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
      final int normalizedTracks = math.max(0, trackCount);
      final String name = placement.lineName!;
      if (name.endsWith('-start')) {
        return normalizedTracks + 1;
      }
      if (name.endsWith('-end')) {
        return normalizedTracks + 2;
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
    if (placement.lineName != null) {
      if (namedLines != null) {
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
      final int normalizedTracks = math.max(0, trackCount);
      final String name = placement.lineName!;
      if (name.endsWith('-start')) {
        return normalizedTracks;
      }
      if (name.endsWith('-end')) {
        return normalizedTracks + 1;
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
        if (diff <= 0) return 0;
        return math.max(1, diff);
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

  double _resolveJustifyContentShift(
    JustifyContent justifyContent,
    double freeSpace, {
    required int trackCount,
  }) {
    if (freeSpace <= 0) return 0;
    final int normalizedTracks = math.max(0, trackCount);
    switch (justifyContent) {
      case JustifyContent.center:
        return freeSpace / 2;
      case JustifyContent.flexEnd:
      case JustifyContent.end:
        return freeSpace;
      case JustifyContent.spaceAround:
        if (normalizedTracks <= 0) return 0;
        return freeSpace / (normalizedTracks * 2);
      case JustifyContent.spaceEvenly:
        if (normalizedTracks <= 0) return 0;
        return freeSpace / (normalizedTracks + 1);
      case JustifyContent.stretch:
      case JustifyContent.flexStart:
      case JustifyContent.start:
      case JustifyContent.spaceBetween:
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
        return GridAxisAlignment.stretch;
    }
  }

  GridAxisAlignment _convertAlignSelfToAxis(AlignSelf value) {
    switch (value) {
      case AlignSelf.auto:
        return GridAxisAlignment.auto;
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
    final int autoRepeatIndex = tracks.indexWhere((GridTrackSize track) {
      if (track is! GridRepeat) return false;
      return track.kind == GridRepeatKind.autoFill || track.kind == GridRepeatKind.autoFit;
    });
    int? autoRepeatCount;
    if (autoRepeatIndex != -1) {
      int otherTrackCount = 0;
      double otherSizeSum = 0;
      for (int i = 0; i < tracks.length; i++) {
        if (i == autoRepeatIndex) continue;
        final GridTrackSize track = tracks[i];
        if (track is GridRepeat) {
          final int repeatCount = track.kind == GridRepeatKind.count ? math.max(1, track.count ?? 1) : 1;
          if (track.tracks.isNotEmpty && repeatCount > 0) {
            otherTrackCount += track.tracks.length * repeatCount;
            otherSizeSum += _measurePatternMinBreadth(track.tracks, innerAvailable, 0) * repeatCount;
          }
          continue;
        }
        otherTrackCount += 1;
        otherSizeSum += _trackMinBreadth(track, innerAvailable);
      }
      autoRepeatCount = _repeatCountForAutoRepeatInTrackList(
        tracks[autoRepeatIndex] as GridRepeat,
        innerAvailable,
        gap,
        otherTrackCount: otherTrackCount,
        otherSizeSum: otherSizeSum,
      );
    }

    for (int i = 0; i < tracks.length; i++) {
      final GridTrackSize track = tracks[i];
      if (track is GridRepeat) {
        final int repeatCount = (autoRepeatIndex != -1 && i == autoRepeatIndex)
            ? (autoRepeatCount ?? 1)
            : _repeatCountFor(track, innerAvailable, gap);
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

  double _measurePatternMinBreadth(List<GridTrackSize> tracks, double? innerAvailable, double gap) {
    double total = 0;
    for (int i = 0; i < tracks.length; i++) {
      total += _trackMinBreadth(tracks[i], innerAvailable);
      if (i < tracks.length - 1) {
        total += gap;
      }
    }
    return total;
  }

  double _trackMinBreadth(GridTrackSize track, double? innerAvailable) {
    if (track is GridFixed) {
      return _resolveTrackSize(track, innerAvailable);
    }
    if (track is GridMinMax) {
      return _resolveTrackSize(track.minTrack, innerAvailable);
    }
    if (track is GridRepeat) {
      return _measurePatternMinBreadth(track.tracks, innerAvailable, 0);
    }
    if (track is GridAuto) {
      return 0;
    }
    if (track is GridFitContent) {
      return _resolveLengthValue(track.limit, innerAvailable);
    }
    // Fractional tracks have no definite minimum contribution for auto-repeat sizing.
    return 0;
  }

  int _repeatCountFor(GridRepeat repeat, double? innerAvailable, double gap) {
    if (repeat.kind == GridRepeatKind.count) {
      return math.max(1, repeat.count ?? 1);
    }
    if (innerAvailable == null || !innerAvailable.isFinite) return 1;
    if (repeat.tracks.isEmpty) return 1;
    final bool autoRepeat = repeat.kind == GridRepeatKind.autoFit || repeat.kind == GridRepeatKind.autoFill;
    final bool hasFlexible = _patternHasFlexibleTracks(repeat.tracks);

    double patternBreadth;
    if (hasFlexible) {
      if (!autoRepeat) {
        return 1;
      }
      patternBreadth = _measurePatternMinBreadth(repeat.tracks, innerAvailable, gap);
    } else {
      patternBreadth = _measurePatternBreadth(repeat.tracks, innerAvailable, gap);
    }

    if (patternBreadth <= 0) return 1;
    final double perPattern = patternBreadth + gap;
    final double available = innerAvailable + gap;
    final int repeatCount = math.max(1, (available / perPattern).floor());
    return repeatCount.clamp(1, 100);
  }

  int _repeatCountForAutoRepeatInTrackList(
    GridRepeat repeat,
    double? innerAvailable,
    double gap, {
    required int otherTrackCount,
    required double otherSizeSum,
  }) {
    if (repeat.kind == GridRepeatKind.count) {
      return math.max(1, repeat.count ?? 1);
    }
    if (innerAvailable == null || !innerAvailable.isFinite) return 1;
    if (repeat.tracks.isEmpty) return 1;

    final bool hasFlexible = _patternHasFlexibleTracks(repeat.tracks);
    final double patternSizeSum = hasFlexible
        ? _measurePatternMinBreadth(repeat.tracks, innerAvailable, 0)
        : _measurePatternBreadth(repeat.tracks, innerAvailable, 0);

    if (patternSizeSum <= 0) return 1;
    final int patternTrackCount = repeat.tracks.length;
    final double perRepeat = patternSizeSum + gap * patternTrackCount;
    if (perRepeat <= 0) return 1;

    final double base = otherSizeSum + gap * (otherTrackCount - 1);
    final double availableForRepeat = innerAvailable - base;
    final int repeatCount = math.max(1, (availableForRepeat / perRepeat).floor());
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
    } else if (source is GridMinContent) {
      return GridMinContent(
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
        isAutoFit: autoFit,
      );
    } else if (source is GridMaxContent) {
      return GridMaxContent(
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
        final List<int> indices = map.putIfAbsent(name, () => <int>[]);
        if (indices.isEmpty || indices.last != index) {
          indices.add(index);
        }
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

    // Items with definite placement in both axes should be placed at their specified
    // grid area/lines even if that overlaps previously placed items.
    if (hasDefiniteRow && hasDefiniteColumn && explicitRow != null && explicitColumn != null) {
      int row = math.max(0, explicitRow);
      int column = math.max(0, explicitColumn);
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
      _ensureOccupancyRows(occupancy, row + rowSpanClamped, columnCount);
      _markPlacement(occupancy, row, column, rowSpanClamped, colSpan);
      return _GridCellPlacement(row, column);
    }

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

  double _resolveTrackSize(GridTrackSize track, double? innerAvailable, {double? percentageBasis}) {
    if (track is GridFixed) {
      final CSSLengthValue lv = track.length;
      if (lv.type == CSSLengthType.PX) {
        return lv.computedValue;
      }
      if (lv.type == CSSLengthType.PERCENTAGE) {
        final double? basis =
            (percentageBasis != null && percentageBasis.isFinite) ? percentageBasis : innerAvailable;
        if (basis != null && basis.isFinite) {
          return (lv.value ?? 0) * basis;
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
        return _resolveTrackSize(track.minTrack, innerAvailable, percentageBasis: percentageBasis);
      }
      final double minValue = _resolveTrackSize(track.minTrack, innerAvailable, percentageBasis: percentageBasis);
      final double maxValue = _resolveTrackSize(maxTrack, innerAvailable, percentageBasis: percentageBasis);
      return math.max(minValue, maxValue);
    } else if (track is GridFitContent) {
      final double limit = _resolveLengthValue(track.limit, percentageBasis ?? innerAvailable);
      if (innerAvailable != null && innerAvailable.isFinite) {
        return math.min(limit, innerAvailable);
      }
      return limit;
    }
    return 0;
  }

  List<double> _resolveTracks(
    List<GridTrackSize> tracks,
    double? innerAvailable,
    Axis axis, {
    double? percentageBasis,
  }) {
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
        final double minSize = _resolveTrackSize(t.minTrack, innerAvailable, percentageBasis: percentageBasis);
        minFlexSizes[i] = minSize;
        final double fr = (t.maxTrack as GridFraction).fr;
        flexFactors[i] = fr;
        frSum += fr;
      } else if (t is GridFixed) {
        sizes[i] = _resolveTrackSize(t, innerAvailable, percentageBasis: percentageBasis);
        fixed += sizes[i];
      } else {
        sizes[i] = _resolveTrackSize(t, innerAvailable, percentageBasis: percentageBasis);
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
        final String? styleAttr = (renderStyle.target).getAttribute('style');
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
        final String? styleAttr = (renderStyle.target).getAttribute('style');
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
    double? gapBaseWidth = innerMaxWidth;
    final double? gapLogicalBorderBoxWidth = renderStyle.borderBoxLogicalWidth;
    if (renderStyle.width.isNotAuto &&
        gapLogicalBorderBoxWidth != null &&
        gapLogicalBorderBoxWidth.isFinite &&
        gapLogicalBorderBoxWidth > 0) {
      gapBaseWidth = math.max(0.0, gapLogicalBorderBoxWidth - horizontalPaddingBorder);
    }

    double? gapBaseHeight;
    final double? gapLogicalBorderBoxHeight = renderStyle.borderBoxLogicalHeight;
    if (renderStyle.height.isNotAuto &&
        gapLogicalBorderBoxHeight != null &&
        gapLogicalBorderBoxHeight.isFinite &&
        gapLogicalBorderBoxHeight > 0) {
      gapBaseHeight = math.max(0.0, gapLogicalBorderBoxHeight - verticalPaddingBorder);
    } else if (hasBH && contentConstraints.minHeight == contentConstraints.maxHeight) {
      gapBaseHeight = innerMaxHeight;
    }

    final double colGap = _resolveLengthValue(renderStyle.columnGap, gapBaseWidth);
    final double rowGap = _resolveLengthValue(renderStyle.rowGap, gapBaseHeight);

    double? contentAvailableWidth = innerMaxWidth;
    if ((contentAvailableWidth == null || !contentAvailableWidth.isFinite) &&
        renderStyle.width.isNotAuto &&
        gapLogicalBorderBoxWidth != null &&
        gapLogicalBorderBoxWidth.isFinite &&
        gapLogicalBorderBoxWidth > 0) {
      contentAvailableWidth = math.max(0.0, gapLogicalBorderBoxWidth - horizontalPaddingBorder);
    }
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
            () => _resolveTracks(
              resolvedColumnDefs,
              adjustedInnerWidth,
              Axis.horizontal,
              percentageBasis: contentAvailableWidth,
            ),
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
    double? contentAvailableHeight = innerMaxHeight;
    if ((contentAvailableHeight == null || !contentAvailableHeight.isFinite) &&
        renderStyle.height.isNotAuto &&
        gapLogicalBorderBoxHeight != null &&
        gapLogicalBorderBoxHeight.isFinite &&
        gapLogicalBorderBoxHeight > 0) {
      contentAvailableHeight = math.max(0.0, gapLogicalBorderBoxHeight - verticalPaddingBorder);
    }
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
            () => _resolveTracks(
              resolvedRowDefs,
              adjustedInnerHeight,
              Axis.vertical,
              percentageBasis: contentAvailableHeight,
            ),
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

    final Stopwatch? placementStopwatch = profileGrid ? (Stopwatch()..start()) : null;
    Duration childLayoutDuration = Duration.zero;

    RenderBox? child;

    // Pass 1: resolve placements and grow implicit track lists.
    final List<RenderBox> placementChildren = _collectChildren();
    final int orderingColumnTrackCount = math.max(colSizes.length, 1);
    final int orderingRowTrackCount = math.max(rowSizes.length, 1);
    final List<RenderBox> definiteBothAxisItems = <RenderBox>[];
    final List<RenderBox> definiteRowItems = <RenderBox>[];
    final List<RenderBox> definiteColumnItems = <RenderBox>[];
    final List<RenderBox> autoItems = <RenderBox>[];

    for (final RenderBox placementChild in placementChildren) {
      RenderStyle? childGridStyle;
      if (placementChild is RenderBoxModel) {
        childGridStyle = placementChild.renderStyle;
      } else if (placementChild is RenderEventListener) {
        final RenderBox? wrapped = placementChild.child;
        if (wrapped is RenderBoxModel) {
          childGridStyle = wrapped.renderStyle;
        }
      }

      GridPlacement columnStart = childGridStyle?.gridColumnStart ?? const GridPlacement.auto();
      GridPlacement columnEnd = childGridStyle?.gridColumnEnd ?? const GridPlacement.auto();
      GridPlacement rowStart = childGridStyle?.gridRowStart ?? const GridPlacement.auto();
      GridPlacement rowEnd = childGridStyle?.gridRowEnd ?? const GridPlacement.auto();
      final String? areaName = childGridStyle?.gridAreaName;
      if (areaName != null) {
        final GridTemplateAreaRect? rect = templateAreaMap?[areaName];
        if (rect != null) {
          columnStart = GridPlacement.line(rect.columnStart);
          columnEnd = GridPlacement.line(rect.columnEnd);
          rowStart = GridPlacement.line(rect.rowStart);
          rowEnd = GridPlacement.line(rect.rowEnd);
        } else {
          final String startName = '${areaName}-start';
          final String endName = '${areaName}-end';
          columnStart = GridPlacement.named(startName);
          columnEnd = GridPlacement.named(endName);
          rowStart = GridPlacement.named(startName);
          rowEnd = GridPlacement.named(endName);
        }
      }

      final int resolvedColSpan = _resolveSpan(
        columnStart,
        columnEnd,
        orderingColumnTrackCount,
        namedLines: columnLineNameMap,
      );
      final int resolvedRowSpan = _resolveSpan(
        rowStart,
        rowEnd,
        orderingRowTrackCount,
        namedLines: rowLineNameMap,
      );
      if (resolvedColSpan <= 0) {
        columnStart = const GridPlacement.auto();
        columnEnd = const GridPlacement.auto();
      }
      if (resolvedRowSpan <= 0) {
        rowStart = const GridPlacement.auto();
        rowEnd = const GridPlacement.auto();
      }

      final bool hasDefiniteColumn =
          columnStart.kind == GridPlacementKind.line || columnEnd.kind == GridPlacementKind.line;
      final bool hasDefiniteRow = rowStart.kind == GridPlacementKind.line || rowEnd.kind == GridPlacementKind.line;
      if (hasDefiniteRow && hasDefiniteColumn) {
        definiteBothAxisItems.add(placementChild);
      } else if (hasDefiniteRow) {
        definiteRowItems.add(placementChild);
      } else if (hasDefiniteColumn) {
        definiteColumnItems.add(placementChild);
      } else {
        autoItems.add(placementChild);
      }
    }

    final List<RenderBox> orderedChildren = <RenderBox>[
      ...definiteBothAxisItems,
      ...definiteRowItems,
      ...definiteColumnItems,
      ...autoItems,
    ];

    for (final RenderBox child in orderedChildren) {
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
      final String? areaName = childGridStyle?.gridAreaName;
      if (areaName != null) {
        // Honor grid-template-areas by mapping named areas to explicit line placements. When the
        // name does not match any template area, treat it like an unresolved named area by
        // falling back to the generated *-start/*-end line names (which may create implicit tracks).
        final GridTemplateAreaRect? rect = templateAreaMap?[areaName];
        if (rect != null) {
          columnStart = GridPlacement.line(rect.columnStart);
          columnEnd = GridPlacement.line(rect.columnEnd);
          rowStart = GridPlacement.line(rect.rowStart);
          rowEnd = GridPlacement.line(rect.rowEnd);
        } else {
          final String startName = '${areaName}-start';
          final String endName = '${areaName}-end';
          columnStart = GridPlacement.named(startName);
          columnEnd = GridPlacement.named(endName);
          rowStart = GridPlacement.named(startName);
          rowEnd = GridPlacement.named(endName);
        }
      }

      final int normalizedInitialCols = math.max(colSizes.length, 1);
      final int normalizedInitialRows = math.max(rowSizes.length, 1);
      final int resolvedColSpan = _resolveSpan(
        columnStart,
        columnEnd,
        normalizedInitialCols,
        namedLines: columnLineNameMap,
      );
      final int resolvedRowSpan = _resolveSpan(
        rowStart,
        rowEnd,
        normalizedInitialRows,
        namedLines: rowLineNameMap,
      );

      final bool invalidColumnRange = resolvedColSpan <= 0;
      final bool invalidRowRange = resolvedRowSpan <= 0;
      if (invalidColumnRange) {
        columnStart = const GridPlacement.auto();
        columnEnd = const GridPlacement.auto();
      }
      if (invalidRowRange) {
        rowStart = const GridPlacement.auto();
        rowEnd = const GridPlacement.auto();
      }

      int colSpan = invalidColumnRange ? 1 : resolvedColSpan;
      int rowSpan = invalidRowRange ? 1 : resolvedRowSpan;

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
      final GridLayoutParentData pd = child.parentData as GridLayoutParentData;
      pd
        ..rowStart = rowIndex
        ..columnStart = colIndex
        ..rowSpan = rowSpan
        ..columnSpan = colSpan;
      hasAnyChild = true;
    }

    // Resolve intrinsic sizing for content-based columns (auto/min-content/max-content) before laying out children.
    if (colSizes.isNotEmpty) {
      GridTrackSize columnTrackAt(int index) {
        if (index >= 0 && index < resolvedColumnDefs.length) {
          return resolvedColumnDefs[index];
        }
        final int implicitIndex = math.max(0, index - explicitColumnCount);
        return autoColDefs.isNotEmpty ? autoColDefs[implicitIndex % autoColDefs.length] : const GridAuto();
      }

      _IntrinsicTrackKind intrinsicKindForBaseTrack(GridTrackSize track) {
        if (track is GridAuto) return _IntrinsicTrackKind.auto;
        if (track is GridMinContent) return _IntrinsicTrackKind.minContent;
        if (track is GridMaxContent) return _IntrinsicTrackKind.maxContent;
        return _IntrinsicTrackKind.none;
      }

      _IntrinsicTrackKind intrinsicKindForTrack(GridTrackSize track) {
        if (track is GridMinMax) {
          final _IntrinsicTrackKind maxKind = intrinsicKindForBaseTrack(track.maxTrack);
          if (maxKind != _IntrinsicTrackKind.none) return maxKind;
          return intrinsicKindForBaseTrack(track.minTrack);
        }
        return intrinsicKindForBaseTrack(track);
      }

      final List<bool> autoColumnsMask = List<bool>.filled(colSizes.length, false);
      final List<bool> minContentColumnsMask = List<bool>.filled(colSizes.length, false);
      final List<bool> maxContentColumnsMask = List<bool>.filled(colSizes.length, false);
      final List<double> rangeMinColSizes = List<double>.filled(colSizes.length, 0.0);
      final List<double> rangeMaxColSizes = List<double>.filled(colSizes.length, 0.0);
      final List<double> flexFactors = List<double>.filled(colSizes.length, 0.0);
      final List<double> flexMinColSizes = List<double>.filled(colSizes.length, 0.0);
      bool hasIntrinsicColumns = false;
      bool hasAutoColumns = false;
      bool hasRangeColumns = false;
      bool hasFlexColumns = false;
      for (int c = 0; c < colSizes.length; c++) {
        final GridTrackSize track = columnTrackAt(c);
        final _IntrinsicTrackKind kind = intrinsicKindForTrack(track);
        switch (kind) {
          case _IntrinsicTrackKind.auto:
            autoColumnsMask[c] = true;
            hasAutoColumns = true;
            hasIntrinsicColumns = true;
            break;
          case _IntrinsicTrackKind.minContent:
            minContentColumnsMask[c] = true;
            hasIntrinsicColumns = true;
            break;
          case _IntrinsicTrackKind.maxContent:
            maxContentColumnsMask[c] = true;
            hasIntrinsicColumns = true;
            break;
          case _IntrinsicTrackKind.none:
            break;
        }

        // For `minmax(<intrinsic>, <fixed>)`, allow the intrinsic contribution to determine
        // the track size (up to the fixed max) instead of eagerly sizing to the max.
        if (track is GridMinMax &&
            intrinsicKindForBaseTrack(track.minTrack) != _IntrinsicTrackKind.none &&
            track.maxTrack is! GridFraction) {
          final double maxLimit =
              _resolveTrackSize(track.maxTrack, adjustedInnerWidth, percentageBasis: contentAvailableWidth);
          if (maxLimit > 0) {
            colSizes[c] = 0.0;
          }
        }

        // Track sizing for minmax(<fixed>, <fixed>) tracks (range tracks) and flex tracks.
        if (track is GridFraction) {
          flexFactors[c] = track.fr;
          hasFlexColumns = true;
        } else if (track is GridMinMax) {
          if (track.maxTrack is GridFraction) {
            final double fr = (track.maxTrack as GridFraction).fr;
            flexFactors[c] = fr;
            hasFlexColumns = true;
            final double minSize =
                _resolveTrackSize(track.minTrack, adjustedInnerWidth, percentageBasis: contentAvailableWidth);
            if (minSize.isFinite && minSize > flexMinColSizes[c]) {
              flexMinColSizes[c] = minSize;
            }
          } else {
            final double minSize =
                _resolveTrackSize(track.minTrack, adjustedInnerWidth, percentageBasis: contentAvailableWidth);
            final double rawMaxSize =
                _resolveTrackSize(track.maxTrack, adjustedInnerWidth, percentageBasis: contentAvailableWidth);
            double normalizedMinSize = minSize.isFinite && minSize > 0 ? minSize : 0.0;
            double normalizedMaxSize = rawMaxSize.isFinite && rawMaxSize > 0 ? rawMaxSize : 0.0;
            // Spec: If the resolved max is less than the resolved min, the max is floored to the min.
            if (normalizedMaxSize > 0 && normalizedMinSize > normalizedMaxSize) {
              normalizedMaxSize = normalizedMinSize;
            }
            if (normalizedMaxSize.isFinite && normalizedMaxSize > 0) {
              rangeMinColSizes[c] = normalizedMinSize;
              rangeMaxColSizes[c] = normalizedMaxSize;
              hasRangeColumns = true;
              // Start at min instead of max; grow toward max after flex minimums are satisfied.
              colSizes[c] = rangeMinColSizes[c];
            }
          }
        }
      }

      final bool needsColumnSizingResolution = hasIntrinsicColumns || hasRangeColumns || hasFlexColumns;
      if (needsColumnSizingResolution) {
        // Track each auto column's min-content contribution so that we can
        // clamp max-content sizing to the available inline size and allow
        // line wrapping (browser behavior).
        final List<double> autoMinColSizes = List<double>.filled(colSizes.length, 0.0);

        void resolveFlexibleAndRangeTracks() {
          if (adjustedInnerWidth == null || !adjustedInnerWidth!.isFinite || adjustedInnerWidth! <= 0) return;
          final double available = adjustedInnerWidth!;

          double fixedNonFlexNonRange = 0.0;
          double rangeBaseSum = 0.0;
          double flexMinSum = 0.0;
          double frSum = 0.0;
          final List<int> growableRanges = <int>[];

          for (int c = 0; c < colSizes.length; c++) {
            final double fr = flexFactors[c];
            if (fr > 0) {
              double minSize = flexMinColSizes[c];
              if (!minSize.isFinite || minSize < 0) minSize = 0.0;
              flexMinColSizes[c] = minSize;
              flexMinSum += minSize;
              frSum += fr;
              continue;
            }

            final double maxRange = rangeMaxColSizes[c];
            if (maxRange > 0 && maxRange.isFinite) {
              double base = colSizes[c];
              if (!base.isFinite || base < 0) base = 0.0;
              final double minRange = rangeMinColSizes[c];
              if (base < minRange) base = minRange;
              if (base > maxRange) base = maxRange;
              colSizes[c] = base;
              rangeBaseSum += base;
              if (maxRange > base + 0.01) {
                growableRanges.add(c);
              }
              continue;
            }

            fixedNonFlexNonRange += colSizes[c];
          }

          final double minUsed = fixedNonFlexNonRange + rangeBaseSum + flexMinSum;
          if (minUsed >= available) {
            for (int c = 0; c < colSizes.length; c++) {
              final double fr = flexFactors[c];
              if (fr <= 0) continue;
              colSizes[c] = flexMinColSizes[c];
            }
            return;
          }

          double free = available - minUsed;

          if (growableRanges.isNotEmpty && free > 0) {
            final List<int> active = List<int>.from(growableRanges);
            while (active.isNotEmpty && free > 0) {
              final double share = free / active.length;
              bool anyFrozen = false;
              for (int i = active.length - 1; i >= 0; i--) {
                final int idx = active[i];
                final double maxSize = rangeMaxColSizes[idx];
                final double current = colSizes[idx];
                final double capacity = maxSize - current;
                if (capacity <= 0) {
                  active.removeAt(i);
                  continue;
                }
                if (capacity <= share + 1e-6) {
                  colSizes[idx] = maxSize;
                  free -= capacity;
                  active.removeAt(i);
                  anyFrozen = true;
                } else {
                  colSizes[idx] = current + share;
                  free -= share;
                }
              }
              if (!anyFrozen) break;
            }
          }

          if (frSum > 0) {
            double occupiedNonFlex = fixedNonFlexNonRange;
            for (int c = 0; c < colSizes.length; c++) {
              final double maxRange = rangeMaxColSizes[c];
              if (maxRange > 0 && maxRange.isFinite) {
                occupiedNonFlex += colSizes[c];
              }
            }

            final double flexSpace = math.max(0.0, available - occupiedNonFlex);
            double remainingSpace = flexSpace;
            double remainingFrSum = frSum;
            final List<int> activeFlex = <int>[
              for (int c = 0; c < colSizes.length; c++)
                if (flexFactors[c] > 0) c
            ];

            while (activeFlex.isNotEmpty && remainingFrSum > 0) {
              bool frozeAny = false;
              for (int i = activeFlex.length - 1; i >= 0; i--) {
                final int idx = activeFlex[i];
                final double fr = flexFactors[idx];
                if (fr <= 0) {
                  activeFlex.removeAt(i);
                  continue;
                }
                final double portion = remainingSpace * (fr / remainingFrSum);
                double minSize = flexMinColSizes[idx];
                if (!minSize.isFinite || minSize < 0) minSize = 0.0;
                if (portion + 1e-6 < minSize) {
                  colSizes[idx] = minSize;
                  remainingSpace -= minSize;
                  remainingFrSum -= fr;
                  activeFlex.removeAt(i);
                  frozeAny = true;
                }
              }
              if (remainingSpace < 0) remainingSpace = 0.0;
              if (!frozeAny) {
                for (final int idx in activeFlex) {
                  final double fr = flexFactors[idx];
                  if (fr <= 0 || remainingFrSum <= 0) {
                    colSizes[idx] = flexMinColSizes[idx];
                    continue;
                  }
                  colSizes[idx] = remainingSpace * (fr / remainingFrSum);
                }
                break;
              }
            }
          }
        }

        RenderBox? childForIntrinsic = firstChild;
        while (childForIntrinsic != null) {
          final GridLayoutParentData pd = childForIntrinsic.parentData as GridLayoutParentData;
          final int startCol = pd.columnStart;
          final int span = math.max(1, pd.columnSpan);
          if (startCol >= 0 && startCol < colSizes.length) {
            RenderStyle? childGridStyle;
            if (childForIntrinsic is RenderBoxModel) {
              childGridStyle = childForIntrinsic.renderStyle;
            } else if (childForIntrinsic is RenderEventListener) {
              final RenderBox? wrapped = childForIntrinsic.child;
              if (wrapped is RenderBoxModel) {
                childGridStyle = wrapped.renderStyle;
              }
            }

            double intrinsicMaxWidth = childForIntrinsic.getMaxIntrinsicWidth(double.infinity);
            double intrinsicMinWidth = childForIntrinsic.getMinIntrinsicWidth(double.infinity);
            if (childGridStyle != null) {
              // Guard against circular dependencies where percentage widths contribute to intrinsic sizing
              // of `auto` tracks; fall back to the definite min-width floor if available.
              final CSSLengthValue minWidth = childGridStyle.minWidth;
              if (minWidth.isNotAuto && minWidth.type != CSSLengthType.PERCENTAGE) {
                final double minWidthValue = minWidth.computedValue;
                if (minWidthValue.isFinite && minWidthValue > 0) {
                  if (!intrinsicMinWidth.isFinite || intrinsicMinWidth < minWidthValue) {
                    intrinsicMinWidth = minWidthValue;
                  }
                  if (!intrinsicMaxWidth.isFinite || intrinsicMaxWidth < minWidthValue) {
                    intrinsicMaxWidth = minWidthValue;
                  }
                }
              }

              // Keep max-content contribution at least the min-content contribution to avoid
              // shrinking auto tracks below their minimum contribution.
              if (intrinsicMinWidth.isFinite &&
                  intrinsicMinWidth > 0 &&
                  (!intrinsicMaxWidth.isFinite || intrinsicMaxWidth < intrinsicMinWidth)) {
                intrinsicMaxWidth = intrinsicMinWidth;
              }
            }
            final int endCol = math.min(colSizes.length, startCol + span);

            int autoCount = 0;
            int minContentCount = 0;
            int maxContentCount = 0;
            int flexCount = 0;
            for (int c = startCol; c < endCol; c++) {
              if (autoColumnsMask[c]) autoCount++;
              if (minContentColumnsMask[c]) minContentCount++;
              if (maxContentColumnsMask[c]) maxContentCount++;
              if (flexFactors[c] > 0) flexCount++;
            }

            if ((autoCount > 0 || maxContentCount > 0) && intrinsicMaxWidth.isFinite && intrinsicMaxWidth > 0) {
              final double availableMax =
                  math.max(0.0, intrinsicMaxWidth - colGap * math.max(0, span - 1));
              if (autoCount > 0) {
                final double perAutoTrack = availableMax / autoCount;
                for (int c = startCol; c < endCol; c++) {
                  if (!autoColumnsMask[c]) continue;
                  if (perAutoTrack > colSizes[c]) {
                    colSizes[c] = perAutoTrack;
                  }
                }
              }
              if (maxContentCount > 0) {
                final double perMaxContentTrack = availableMax / maxContentCount;
                for (int c = startCol; c < endCol; c++) {
                  if (!maxContentColumnsMask[c]) continue;
                  if (perMaxContentTrack > colSizes[c]) {
                    colSizes[c] = perMaxContentTrack;
                  }
                }
              }
            }

            if ((autoCount > 0 || minContentCount > 0) && intrinsicMinWidth.isFinite && intrinsicMinWidth > 0) {
              final double availableMin =
                  math.max(0.0, intrinsicMinWidth - colGap * math.max(0, span - 1));
              if (autoCount > 0) {
                final double perAutoMinTrack = availableMin / autoCount;
                for (int c = startCol; c < endCol; c++) {
                  if (!autoColumnsMask[c]) continue;
                  if (perAutoMinTrack > autoMinColSizes[c]) {
                    autoMinColSizes[c] = perAutoMinTrack;
                  }
                }
              }
              if (minContentCount > 0) {
                final double perMinContentTrack = availableMin / minContentCount;
                for (int c = startCol; c < endCol; c++) {
                  if (!minContentColumnsMask[c]) continue;
                  if (perMinContentTrack > colSizes[c]) {
                    colSizes[c] = perMinContentTrack;
                  }
                }
              }
            }

            if (flexCount > 0 && intrinsicMinWidth.isFinite && intrinsicMinWidth > 0) {
              final double availableMin =
                  math.max(0.0, intrinsicMinWidth - colGap * math.max(0, span - 1));
              final double perFlexMinTrack = availableMin / flexCount;
              for (int c = startCol; c < endCol; c++) {
                if (flexFactors[c] <= 0) continue;
                if (perFlexMinTrack > flexMinColSizes[c]) {
                  flexMinColSizes[c] = perFlexMinTrack;
                }
              }
            }
          }
          childForIntrinsic = pd.nextSibling;
        }

        // Ensure auto tracks are at least their min-content contributions.
        if (hasAutoColumns) {
          for (int c = 0; c < colSizes.length; c++) {
            if (!autoColumnsMask[c]) continue;
            final double minSize = autoMinColSizes[c];
            if (minSize.isFinite && minSize > colSizes[c]) {
              colSizes[c] = minSize;
            }
          }
        }

        // Clamp range-limited tracks (minmax(<min>, <max>)) to their max limit after intrinsic sizing.
        for (int c = 0; c < colSizes.length; c++) {
          final double maxRange = rangeMaxColSizes[c];
          if (maxRange <= 0 || !maxRange.isFinite) continue;
          final double minRange = rangeMinColSizes[c];
          double value = colSizes[c];
          if (!value.isFinite || value < 0) value = 0.0;
          if (value < minRange) value = minRange;
          if (value > maxRange) value = maxRange;
          colSizes[c] = value;
        }

        // Resolve range tracks first (up to their max) and then distribute remaining space to flex tracks,
        // while respecting flex tracks' automatic minimum sizes (min-content contributions).
        resolveFlexibleAndRangeTracks();

        // Clamp auto columns between their min-content and max-content contributions
        // when the grid container has a definite inline size. This prevents auto
        // columns from growing without bound and matches browser behavior where
        // long text wraps instead of forcing horizontal overflow.
        bool didClampAutoColumns = false;
        if (hasAutoColumns && adjustedInnerWidth != null && adjustedInnerWidth.isFinite && adjustedInnerWidth > 0) {
          double totalWidth = 0.0;
          for (final double size in colSizes) {
            totalWidth += size;
          }
          if (totalWidth > adjustedInnerWidth + 0.5) {
            final double overflow = totalWidth - adjustedInnerWidth;
            final List<double> shrinkCapacities = List<double>.filled(colSizes.length, 0.0);
            double totalCapacity = 0.0;
            for (int c = 0; c < colSizes.length; c++) {
              if (!autoColumnsMask[c]) continue;
              double minSize = autoMinColSizes[c];
              if (!minSize.isFinite || minSize < 0) minSize = 0.0;
              if (minSize > colSizes[c]) minSize = colSizes[c];
              autoMinColSizes[c] = minSize;
              final double capacity = math.max(0.0, colSizes[c] - minSize);
              shrinkCapacities[c] = capacity;
              totalCapacity += capacity;
            }
            if (totalCapacity > 0) {
              final double ratio = math.min(1.0, overflow / totalCapacity);
              for (int c = 0; c < colSizes.length; c++) {
                final double capacity = shrinkCapacities[c];
                if (capacity <= 0) continue;
                final double shrink = capacity * ratio;
                colSizes[c] = math.max(autoMinColSizes[c], colSizes[c] - shrink);
              }
              didClampAutoColumns = true;
            }
          }
        }

        // If we clamped auto columns due to overflow (non-flex tracks exceed available space),
        // re-resolve range/flex tracks to consume any newly freed space.
        if (didClampAutoColumns) {
          resolveFlexibleAndRangeTracks();
        }
      }
    }

    // Pass 2: layout children with resolved column widths.
    if (implicitRowHeights.isNotEmpty) {
      implicitRowHeights = List<double>.filled(implicitRowHeights.length, 0.0, growable: true);
    }

    child = firstChild;
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

      final GridLayoutParentData pd = child.parentData as GridLayoutParentData;
      final int rowIndex = pd.rowStart;
      final int colIndex = pd.columnStart;
      final int rowSpan = math.max(1, pd.rowSpan);
      final int colSpan = math.max(1, pd.columnSpan).clamp(1, math.max(1, colSizes.length - colIndex));

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
      final bool stretchHeight =
          alignSelfAlignment == GridAxisAlignment.stretch && childHeightAuto && hasExplicitRowSize && explicitItemHeight == null;

      final double minWidthConstraint = stretchWidth ? cellWidth : 0;
      final double maxWidthConstraint = cellWidth.isFinite ? cellWidth : (innerMaxWidth ?? double.infinity);
      final double minHeightConstraint = explicitItemHeight ?? (stretchHeight && cellHeight.isFinite ? cellHeight : 0);
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
        final int targetRow = rowIndex + r;
        if (targetRow >= 0 && targetRow < implicitRowHeights.length) {
          implicitRowHeights[targetRow] = math.max(implicitRowHeights[targetRow], perRow);
        }
      }

      double rowTop = paddingTop + borderTop;
      for (int r = 0; r < rowIndex; r++) {
        final double rh = _resolvedRowHeight(rowSizes, implicitRowHeights, r);
        rowTop += rh;
        rowTop += rowGap;
      }

      final double horizontalExtra = cellWidth.isFinite ? math.max(0, cellWidth - childSize.width) : 0;
      final double verticalExtra = hasExplicitRowSize && cellHeight.isFinite ? math.max(0, cellHeight - childSize.height) : 0;
      final double horizontalInset = _alignmentOffsetWithinCell(justifySelfAlignment, horizontalExtra);
      final double verticalInset =
          hasExplicitRowSize ? _alignmentOffsetWithinCell(alignSelfAlignment, verticalExtra) : 0;
      pd.offset = Offset(xOffset + horizontalInset, rowTop + verticalInset);

      child = pd.nextSibling;
    }

    // If auto-sized rows resolve to a definite height (from intrinsic measurement),
    // apply align-self: stretch so items fill the resolved row size, matching CSS Grid.
    bool relayoutForImplicitRowStretch = false;
    RenderBox? stretchCheckChild = firstChild;
    while (stretchCheckChild != null) {
      RenderStyle? childGridStyle;
      if (stretchCheckChild is RenderBoxModel) {
        childGridStyle = stretchCheckChild.renderStyle;
      } else if (stretchCheckChild is RenderEventListener) {
        final RenderBox? wrapped = stretchCheckChild.child;
        if (wrapped is RenderBoxModel) {
          childGridStyle = wrapped.renderStyle;
        }
      }
      final GridAxisAlignment alignSelfAlignment = _resolveAlignSelfAlignment(childGridStyle);
      final bool childHeightAuto = childGridStyle?.height.isAuto ?? true;
      double? explicitItemHeight;
      if (childGridStyle != null && childGridStyle.height.isNotAuto) {
        explicitItemHeight = childGridStyle.height.computedValue;
      }
      if (alignSelfAlignment == GridAxisAlignment.stretch && childHeightAuto && explicitItemHeight == null) {
        final GridLayoutParentData pd = stretchCheckChild.parentData as GridLayoutParentData;
        final int rowIndex = pd.rowStart;
        final int rowSpan = math.max(1, pd.rowSpan);
        double resolvedCellHeight = 0;
        bool hasDefiniteCellHeight = true;
        for (int r = rowIndex; r < rowIndex + rowSpan; r++) {
          final double rh = _resolvedRowHeight(rowSizes, implicitRowHeights, r);
          if (rh <= 0) {
            hasDefiniteCellHeight = false;
            break;
          }
          resolvedCellHeight += rh;
        }
        if (hasDefiniteCellHeight) {
          resolvedCellHeight += rowGap * math.max(0, rowSpan - 1);
        }
        if (hasDefiniteCellHeight && resolvedCellHeight.isFinite) {
          final double currentHeight = stretchCheckChild.size.height;
          if (resolvedCellHeight > currentHeight + 0.5) {
            relayoutForImplicitRowStretch = true;
            break;
          }
        }
      }
      stretchCheckChild = (stretchCheckChild.parentData as GridLayoutParentData).nextSibling;
    }

    // Compute used content size
    double usedContentWidth = 0;
    int justificationColumnCount = colSizes.length;
    for (int c = 0; c < colSizes.length; c++) {
      usedContentWidth += colSizes[c];
      if (c < colSizes.length - 1) usedContentWidth += colGap;
    }
    if (explicitAutoFitColumns != null && explicitAutoFitColumnUsage != null) {
      double collapsedWidth = 0;
      int collapsedCount = 0;
      for (int i = explicitColumnCount - 1; i >= 0; i--) {
        if (!explicitAutoFitColumns[i] || explicitAutoFitColumnUsage[i]) {
          break;
        }
        collapsedWidth += colSizes[i];
        collapsedCount++;
        if (i > 0) {
          collapsedWidth += colGap;
        }
      }
      if (collapsedWidth > 0) {
        usedContentWidth = math.max(0.0, usedContentWidth - collapsedWidth);
        justificationColumnCount = math.max(0, justificationColumnCount - collapsedCount);
      }
    }
    double usedContentHeight = 0;
    final int totalRows = math.max(rowSizes.length, implicitRowHeights.length);
    int alignmentRowCount = totalRows;
    for (int r = 0; r < totalRows; r++) {
      final double segment = _resolvedRowHeight(rowSizes, implicitRowHeights, r);
      usedContentHeight += segment;
      if (r < totalRows - 1) usedContentHeight += rowGap;
    }
    if (explicitAutoFitRows != null && explicitAutoFitRowUsage != null) {
      double collapsedHeight = 0;
      int collapsedCount = 0;
      for (int i = explicitRowCount - 1; i >= 0; i--) {
        if (!explicitAutoFitRows[i] || explicitAutoFitRowUsage[i]) {
          break;
        }
        collapsedHeight += rowSizes[i];
        collapsedCount++;
        if (i > 0) {
          collapsedHeight += rowGap;
        }
      }
      if (collapsedHeight > 0) {
        usedContentHeight = math.max(0.0, usedContentHeight - collapsedHeight);
        alignmentRowCount = math.max(0, alignmentRowCount - collapsedCount);
      }
    }

    // Final size constrained by constraints.
    // For grid containers, the used border-box width/height come from:
    //   - definite width/height if specified;
    //   - otherwise, auto sizing rules using the available inner size.
    final bool isBlockGrid =
        renderStyle.display == CSSDisplay.grid && renderStyle.effectiveDisplay == CSSDisplay.grid;
    double layoutContentWidth = usedContentWidth;
    double layoutContentHeight = usedContentHeight;

    // 1) Definite width: honor the specified border-box width from style tree.
    //    This is required so that alignment properties (justify-content) operate
    //    against the correct container width even when auto-fit collapses tracks.
    final double? logicalBorderBoxWidth = renderStyle.borderBoxLogicalWidth;
    if (renderStyle.width.isNotAuto &&
        logicalBorderBoxWidth != null &&
        logicalBorderBoxWidth.isFinite &&
        logicalBorderBoxWidth > 0) {
      layoutContentWidth = math.max(0.0, logicalBorderBoxWidth - horizontalPaddingBorder);
    } else if (renderStyle.width.isAuto && innerMaxWidth != null && innerMaxWidth.isFinite) {
      // 2) Auto width: for block-level grids, stretch to the available width
      //    (similar to block and flow layout); for others, only adopt the
      //    available width when empty so they still shrink-wrap contents.
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

    // Height follows existing auto rules but also respects definite height.
    final double? logicalBorderBoxHeight = renderStyle.borderBoxLogicalHeight;
    if (renderStyle.height.isNotAuto &&
        logicalBorderBoxHeight != null &&
        logicalBorderBoxHeight.isFinite &&
        logicalBorderBoxHeight > 0) {
      layoutContentHeight = math.max(0.0, logicalBorderBoxHeight - verticalPaddingBorder);
    } else if (layoutContentHeight == 0 && innerMaxHeight != null && innerMaxHeight.isFinite) {
      if (renderStyle.height.isNotAuto || !hasAnyChild) {
        layoutContentHeight = innerMaxHeight;
      }
    }

    final double desiredWidth = layoutContentWidth + horizontalPaddingBorder;
    final double desiredHeight = layoutContentHeight + verticalPaddingBorder;
    size = constraints.constrain(Size(desiredWidth, desiredHeight));
    double horizontalFree = math.max(0.0, size.width - horizontalPaddingBorder - usedContentWidth);
    double verticalFree = math.max(0.0, size.height - verticalPaddingBorder - usedContentHeight);
    bool relayoutForStretchedTracks = false;

    if (horizontalFree > 0 &&
        renderStyle.justifyContent == JustifyContent.stretch &&
        justificationColumnCount > 0) {
      GridTrackSize columnTrackAt(int index) {
        if (index >= 0 && index < resolvedColumnDefs.length) {
          return resolvedColumnDefs[index];
        }
        final int implicitIndex = math.max(0, index - explicitColumnCount);
        return autoColDefs.isNotEmpty ? autoColDefs[implicitIndex % autoColDefs.length] : const GridAuto();
      }

      bool isStretchableColumn(GridTrackSize track) {
        if (track is GridAuto) return true;
        if (track is GridMinMax) return track.maxTrack is GridAuto;
        return false;
      }

      final List<int> stretchableColumns = <int>[];
      for (int c = 0; c < justificationColumnCount; c++) {
        if (isStretchableColumn(columnTrackAt(c))) {
          stretchableColumns.add(c);
        }
      }
      if (stretchableColumns.isNotEmpty) {
        final double perColumn = horizontalFree / stretchableColumns.length;
        for (final int c in stretchableColumns) {
          colSizes[c] += perColumn;
        }
        usedContentWidth += horizontalFree;
        horizontalFree = 0;
        relayoutForStretchedTracks = true;
      }
    }
    if (verticalFree > 0 && renderStyle.alignContent == AlignContent.stretch && alignmentRowCount > 0) {
      final List<int> stretchableRows = <int>[];
      for (int r = 0; r < alignmentRowCount; r++) {
        if (r < rowSizes.length && rowSizes[r] > 0) continue;
        if (r >= implicitRowHeights.length) continue;
        if (implicitRowHeights[r] <= 0) continue;
        stretchableRows.add(r);
      }
      if (stretchableRows.isNotEmpty) {
        final double perRow = verticalFree / stretchableRows.length;
        for (final int r in stretchableRows) {
          implicitRowHeights[r] += perRow;
        }
        usedContentHeight += verticalFree;
        verticalFree = 0;
        relayoutForStretchedTracks = true;
      }
    }

    if (!relayoutForStretchedTracks && relayoutForImplicitRowStretch) {
      relayoutForStretchedTracks = true;
    }

    if (relayoutForStretchedTracks) {
      RenderBox? childForRelayout = firstChild;
      while (childForRelayout != null) {
        RenderStyle? childGridStyle;
        if (childForRelayout is RenderBoxModel) {
          childGridStyle = childForRelayout.renderStyle;
        } else if (childForRelayout is RenderEventListener) {
          final RenderBox? wrapped = childForRelayout.child;
          if (wrapped is RenderBoxModel) {
            childGridStyle = wrapped.renderStyle;
          }
        }

        final GridAxisAlignment justifySelfAlignment = _resolveJustifySelfAlignment(childGridStyle);
        final GridAxisAlignment alignSelfAlignment = _resolveAlignSelfAlignment(childGridStyle);
        final bool childWidthAuto = childGridStyle?.width.isAuto ?? true;
        final bool childHeightAuto = childGridStyle?.height.isAuto ?? true;

        final GridLayoutParentData pd = childForRelayout.parentData as GridLayoutParentData;
        final int rowIndex = pd.rowStart;
        final int colIndex = pd.columnStart;
        final int rowSpan = math.max(1, pd.rowSpan);
        final int colSpan = math.max(1, pd.columnSpan);

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

        double resolvedCellHeight = 0;
        bool hasDefiniteCellHeight = true;
        for (int r = rowIndex; r < rowIndex + rowSpan; r++) {
          final double rh = _resolvedRowHeight(rowSizes, implicitRowHeights, r);
          if (rh <= 0) {
            hasDefiniteCellHeight = false;
            break;
          }
          resolvedCellHeight += rh;
        }
        if (hasDefiniteCellHeight) {
          resolvedCellHeight += rowGap * math.max(0, rowSpan - 1);
        }
        final double cellHeight = hasDefiniteCellHeight ? resolvedCellHeight : double.nan;

        double? explicitItemHeight;
        if (childGridStyle != null && childGridStyle.height.isNotAuto) {
          explicitItemHeight = childGridStyle.height.computedValue;
        }

        final bool stretchWidth =
            justifySelfAlignment == GridAxisAlignment.stretch && childWidthAuto && cellWidth.isFinite;
        final bool stretchHeight = alignSelfAlignment == GridAxisAlignment.stretch &&
            childHeightAuto &&
            explicitItemHeight == null &&
            cellHeight.isFinite;

        final double minWidthConstraint = stretchWidth ? cellWidth : 0;
        final double maxWidthConstraint = cellWidth.isFinite ? cellWidth : (innerMaxWidth ?? double.infinity);
        final double minHeightConstraint = explicitItemHeight ?? (stretchHeight ? cellHeight : 0);
        final double maxHeightConstraint =
            explicitItemHeight ?? (cellHeight.isFinite ? cellHeight : (innerMaxHeight ?? double.infinity));

        final BoxConstraints childConstraints = BoxConstraints(
          minWidth: minWidthConstraint,
          maxWidth: maxWidthConstraint,
          minHeight: minHeightConstraint,
          maxHeight: maxHeightConstraint,
        );

        childForRelayout.layout(childConstraints, parentUsesSize: true);
        final Size childSize = childForRelayout.size;

        double rowTop = paddingTop + borderTop;
        for (int r = 0; r < rowIndex; r++) {
          final double rh = _resolvedRowHeight(rowSizes, implicitRowHeights, r);
          rowTop += rh;
          rowTop += rowGap;
        }

        final double horizontalExtra = cellWidth.isFinite ? math.max(0, cellWidth - childSize.width) : 0;
        final double verticalExtra =
            cellHeight.isFinite ? math.max(0, cellHeight - childSize.height) : 0;
        final double horizontalInset = _alignmentOffsetWithinCell(justifySelfAlignment, horizontalExtra);
        final double verticalInset =
            cellHeight.isFinite ? _alignmentOffsetWithinCell(alignSelfAlignment, verticalExtra) : 0;
        pd.offset = Offset(xOffset + horizontalInset, rowTop + verticalInset);

        childForRelayout = pd.nextSibling;
      }
    }

    final double justifyShift = _resolveJustifyContentShift(
      renderStyle.justifyContent,
      horizontalFree,
      trackCount: justificationColumnCount,
    );
    double columnDistributionBetween = 0;
    bool distributeColumns = false;
    if (horizontalFree > 0 && justificationColumnCount > 0) {
      final JustifyContent justifyContent = renderStyle.justifyContent;
      switch (justifyContent) {
        case JustifyContent.spaceBetween:
          if (justificationColumnCount > 1) {
            columnDistributionBetween = horizontalFree / (justificationColumnCount - 1);
            distributeColumns = true;
          }
          break;
        case JustifyContent.spaceAround:
          columnDistributionBetween = horizontalFree / justificationColumnCount;
          distributeColumns = true;
          break;
        case JustifyContent.spaceEvenly:
          columnDistributionBetween = horizontalFree / (justificationColumnCount + 1);
          distributeColumns = true;
          break;
        default:
          break;
      }
    }
    double rowDistributionLeading = 0;
    double rowDistributionBetween = 0;
    bool distributeRows = false;
    if (verticalFree > 0 && alignmentRowCount > 0) {
      final AlignContent alignContent = renderStyle.alignContent;
      switch (alignContent) {
        case AlignContent.spaceBetween:
          if (alignmentRowCount > 1) {
            rowDistributionBetween = verticalFree / (alignmentRowCount - 1);
            distributeRows = true;
          }
          break;
        case AlignContent.spaceAround:
          rowDistributionBetween = verticalFree / alignmentRowCount;
          rowDistributionLeading = rowDistributionBetween / 2;
          distributeRows = true;
          break;
        case AlignContent.spaceEvenly:
          rowDistributionBetween = verticalFree / (alignmentRowCount + 1);
          rowDistributionLeading = rowDistributionBetween;
          distributeRows = true;
          break;
        default:
          break;
      }
    }
    final double alignShift =
        _resolveAlignContentShift(renderStyle.alignContent, distributeRows ? 0 : verticalFree);

    RenderBox? childForAlignment = firstChild;
    while (childForAlignment != null) {
      final GridLayoutParentData pd = childForAlignment.parentData as GridLayoutParentData;
      double additionalY = alignShift;
      if (distributeRows) {
        additionalY = rowDistributionLeading + pd.rowStart * rowDistributionBetween;
      }
      double additionalX = justifyShift;
      if (distributeColumns) {
        additionalX += pd.columnStart * columnDistributionBetween;
      }
      pd.offset += Offset(additionalX, additionalY);
      childForAlignment = pd.nextSibling;
    }

    placementStopwatch?.stop();
    if (placementStopwatch != null) {
      _logGridProfile('grid.autoPlacement', placementStopwatch.elapsed);
    }
    if (profileGrid && childLayoutDuration > Duration.zero) {
      _logGridProfile('grid.childLayout', childLayoutDuration);
    }

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

class RepaintBoundaryGridLayout extends RenderGridLayout {
  RepaintBoundaryGridLayout({required super.renderStyle});

  @override
  bool get isRepaintBoundary => true;
}
