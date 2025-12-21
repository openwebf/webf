/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2025
 */

import 'package:flutter/rendering.dart' show Axis;
import 'package:webf/css.dart';

/// Grid track size model for CSS Grid (subset for MVP).
abstract class GridTrackSize {
  final List<String> leadingLineNames;
  final List<String> trailingLineNames;
  final bool isAutoFit;
  const GridTrackSize({
    this.leadingLineNames = const <String>[],
    this.trailingLineNames = const <String>[],
    this.isAutoFit = false,
  });
}

class GridFixed extends GridTrackSize {
  final CSSLengthValue length; // may be px or percentage
  GridFixed(
    this.length, {
    super.leadingLineNames,
    super.trailingLineNames,
    super.isAutoFit,
  });
}

class GridFraction extends GridTrackSize {
  final double fr;
  GridFraction(
    this.fr, {
    super.leadingLineNames,
    super.trailingLineNames,
    super.isAutoFit,
  });
}

class GridAuto extends GridTrackSize {
  const GridAuto({
    super.leadingLineNames,
    super.trailingLineNames,
    super.isAutoFit,
  }) : super();
}

class GridMinContent extends GridTrackSize {
  const GridMinContent({
    super.leadingLineNames,
    super.trailingLineNames,
    super.isAutoFit,
  }) : super();
}

class GridMaxContent extends GridTrackSize {
  const GridMaxContent({
    super.leadingLineNames,
    super.trailingLineNames,
    super.isAutoFit,
  }) : super();
}

class GridMinMax extends GridTrackSize {
  final GridTrackSize minTrack;
  final GridTrackSize maxTrack;
  GridMinMax(
    this.minTrack,
    this.maxTrack, {
    super.leadingLineNames,
    super.trailingLineNames,
    super.isAutoFit,
  });
}

class GridFitContent extends GridTrackSize {
  final CSSLengthValue limit;
  GridFitContent(
    this.limit, {
    super.leadingLineNames,
    super.trailingLineNames,
    super.isAutoFit,
  });
}

enum GridRepeatKind { count, autoFill, autoFit }

class GridRepeat extends GridTrackSize {
  final GridRepeatKind kind;
  final int? count;
  final List<GridTrackSize> tracks;
  const GridRepeat._(
    this.kind, {
    this.count,
    required this.tracks,
    super.leadingLineNames,
    super.trailingLineNames,
    super.isAutoFit,
  });
  const GridRepeat.count(
    int repeatCount,
    List<GridTrackSize> tracks, {
    List<String> leadingLineNames = const <String>[],
    List<String> trailingLineNames = const <String>[],
  }) : this._(
          GridRepeatKind.count,
          count: repeatCount,
          tracks: tracks,
          leadingLineNames: leadingLineNames,
          trailingLineNames: trailingLineNames,
        );
  const GridRepeat.autoFill(
    List<GridTrackSize> tracks, {
    List<String> leadingLineNames = const <String>[],
    List<String> trailingLineNames = const <String>[],
  }) : this._(
          GridRepeatKind.autoFill,
          tracks: tracks,
          leadingLineNames: leadingLineNames,
          trailingLineNames: trailingLineNames,
        );
  const GridRepeat.autoFit(
    List<GridTrackSize> tracks, {
    List<String> leadingLineNames = const <String>[],
    List<String> trailingLineNames = const <String>[],
  }) : this._(
          GridRepeatKind.autoFit,
          tracks: tracks,
          leadingLineNames: leadingLineNames,
          trailingLineNames: trailingLineNames,
          isAutoFit: true,
        );
}

class GridTemplateAreaRect {
  final int rowStart;
  final int rowEnd;
  final int columnStart;
  final int columnEnd;
  const GridTemplateAreaRect(this.rowStart, this.rowEnd, this.columnStart, this.columnEnd);
  int get rowSpan => rowEnd - rowStart;
  int get columnSpan => columnEnd - columnStart;
}

class GridTemplateAreasDefinition {
  final Map<String, GridTemplateAreaRect> areas;
  final int rowCount;
  final int columnCount;
  final String cssText;
  const GridTemplateAreasDefinition({
    required this.areas,
    required this.rowCount,
    required this.columnCount,
    required this.cssText,
  });
}

enum GridPlacementKind { auto, line, span }

class GridPlacement {
  final GridPlacementKind kind;
  final int? line;
  final String? lineName;
  final int? lineNameOccurrence;
  final bool hasExplicitLineNameOccurrence;
  final int? span;

  const GridPlacement._(
    this.kind, {
    this.line,
    this.lineName,
    this.lineNameOccurrence,
    this.hasExplicitLineNameOccurrence = false,
    this.span,
  });
  const GridPlacement.auto() : this._(GridPlacementKind.auto);
  const GridPlacement.line(int value) : this._(GridPlacementKind.line, line: value);
  const GridPlacement.named(
    String name, {
    int? occurrence,
    bool explicitOccurrence = false,
  }) : this._(
          GridPlacementKind.line,
          lineName: name,
          lineNameOccurrence: occurrence,
          hasExplicitLineNameOccurrence: explicitOccurrence,
        );
  const GridPlacement.span(int value) : this._(GridPlacementKind.span, span: value);
}

enum GridAutoFlow { row, column, rowDense, columnDense }

enum GridAxisAlignment {
  auto,
  start,
  end,
  center,
  stretch,
  baseline,
  lastBaseline,
}

class CSSGridParser {
  // Very simple whitespace splitter that ignores spaces inside parentheses.
  static List<String> _splitBySpacePreservingFunc(String input) {
    List<String> res = [];
    int depth = 0;
    int bracketDepth = 0;
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == '(') depth++;
      if (ch == ')') depth = depth > 0 ? depth - 1 : 0;
      if (ch == '[') bracketDepth++;
      if (ch == ']') bracketDepth = bracketDepth > 0 ? bracketDepth - 1 : 0;
      if (ch == ' ' && depth == 0 && bracketDepth == 0) {
        if (buf.isNotEmpty) {
          res.add(buf.toString());
          buf.clear();
        }
      } else {
        buf.write(ch);
      }
    }
    if (buf.isNotEmpty) res.add(buf.toString());
    return res;
  }

  static bool _isLineNameToken(String token) => token.startsWith('[') && token.endsWith(']');

  static List<String> _parseLineNames(String token) {
    final inner = token.substring(1, token.length - 1).trim();
    if (inner.isEmpty) return const <String>[];
    return inner.split(RegExp(r'\s+')).map((name) => name.trim()).where((name) => name.isNotEmpty).toList();
  }

  static final RegExp _customIdentRegExp = RegExp(r'^-?[_a-zA-Z][\w-]*$');
  static bool isCustomIdent(String token) {
    if (token.isEmpty) return false;
    final String lower = token.toLowerCase();
    if (lower == 'auto' || lower == 'span') return false;
    return _customIdentRegExp.hasMatch(token);
  }

  static int _topLevelCommaIndex(String input) {
    int depth = 0;
    for (int i = 0; i < input.length; i++) {
      final String ch = input[i];
      if (ch == '(') {
        depth++;
      } else if (ch == ')') {
        depth = depth > 0 ? depth - 1 : 0;
      } else if (ch == ',' && depth == 0) {
        return i;
      }
    }
    return -1;
  }

  static GridTrackSize _cloneTrackWithLineNames(
    GridTrackSize source, {
    List<String>? leading,
    List<String>? trailing,
  }) {
    final List<String> resolvedLeading =
        leading ?? (source.leadingLineNames.isEmpty ? const <String>[] : List<String>.from(source.leadingLineNames));
    final List<String> resolvedTrailing =
        trailing ?? (source.trailingLineNames.isEmpty ? const <String>[] : List<String>.from(source.trailingLineNames));

    if (source is GridFixed) {
      return GridFixed(
        source.length,
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
      );
    } else if (source is GridFraction) {
      return GridFraction(
        source.fr,
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
      );
    } else if (source is GridAuto) {
      return GridAuto(
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
      );
    } else if (source is GridMinContent) {
      return GridMinContent(
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
      );
    } else if (source is GridMaxContent) {
      return GridMaxContent(
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
      );
    } else if (source is GridMinMax) {
      return GridMinMax(
        source.minTrack,
        source.maxTrack,
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
      );
    } else if (source is GridFitContent) {
      return GridFitContent(
        source.limit,
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
      );
    } else if (source is GridRepeat) {
      return GridRepeat._(
        source.kind,
        count: source.count,
        tracks: source.tracks,
        leadingLineNames: resolvedLeading,
        trailingLineNames: resolvedTrailing,
      );
    }
    return source;
  }

  static GridTrackSize? _parseSingleTrack(
    String token,
    RenderStyle renderStyle,
    String propertyName,
    Axis axis, {
    List<String>? leadingNames,
    List<String>? trailingNames,
  }) {
    final List<String> resolvedLeading = leadingNames ?? const <String>[];
    final List<String> resolvedTrailing = trailingNames ?? const <String>[];
    final String t = token.trim();
    if (t.isEmpty) return null;
    final String lower = t.toLowerCase();
    if (lower == 'auto') {
      return GridAuto(leadingLineNames: resolvedLeading, trailingLineNames: resolvedTrailing);
    }
    if (lower == 'min-content') {
      return GridMinContent(leadingLineNames: resolvedLeading, trailingLineNames: resolvedTrailing);
    }
    if (lower == 'max-content') {
      return GridMaxContent(leadingLineNames: resolvedLeading, trailingLineNames: resolvedTrailing);
    }
    if (t.endsWith('fr')) {
      final numStr = t.substring(0, t.length - 2).trim();
      final fr = numStr.isEmpty ? 1.0 : double.tryParse(numStr);
      if (fr != null && fr >= 0) {
        return GridFraction(fr, leadingLineNames: resolvedLeading, trailingLineNames: resolvedTrailing);
      }
    }
    if (t.startsWith('fit-content(') && t.endsWith(')')) {
      final String inner = t.substring(12, t.length - 1).trim();
      final CSSLengthValue limit = CSSLength.parseLength(inner, renderStyle, propertyName, axis);
      if (limit != CSSLengthValue.unknown) {
        return GridFitContent(
          limit,
          leadingLineNames: resolvedLeading,
          trailingLineNames: resolvedTrailing,
        );
      }
    }
    if (t.startsWith('minmax(') && t.endsWith(')')) {
      final inner = t.substring(7, t.length - 1);
      final commaIndex = _topLevelCommaIndex(inner);
      if (commaIndex != -1) {
        final String minToken = inner.substring(0, commaIndex).trim();
        final String maxToken = inner.substring(commaIndex + 1).trim();
        final GridTrackSize? minTrack =
            _parseSingleTrack(minToken, renderStyle, propertyName, axis, leadingNames: const [], trailingNames: const []);
        final GridTrackSize? maxTrack =
            _parseSingleTrack(maxToken, renderStyle, propertyName, axis, leadingNames: const [], trailingNames: const []);
        if (minTrack != null && maxTrack != null) {
          return GridMinMax(
            minTrack,
            maxTrack,
            leadingLineNames: resolvedLeading,
            trailingLineNames: resolvedTrailing,
          );
        }
      }
    }
    final CSSLengthValue len = CSSLength.parseLength(t, renderStyle, propertyName, axis);
    if (len != CSSLengthValue.unknown) {
      return GridFixed(len, leadingLineNames: resolvedLeading, trailingLineNames: resolvedTrailing);
    }
    return null;
  }

  static GridRepeat? _parseRepeatComponent(
    String token,
    RenderStyle renderStyle,
    String propertyName,
    Axis axis, {
    List<String>? leadingNames,
  }) {
    final inner = token.substring(7, token.length - 1);
    final commaIndex = _topLevelCommaIndex(inner);
    if (commaIndex == -1) return null;
    final String countStr = inner.substring(0, commaIndex).trim();
    final String trackContent = inner.substring(commaIndex + 1).trim();
    if (trackContent.isEmpty) return null;

    final List<GridTrackSize> innerTracks =
        _parseTrackListInternal(trackContent, renderStyle, propertyName, axis);
    if (innerTracks.isEmpty) return null;

    final List<String> resolvedLeading = leadingNames ?? const <String>[];
    final String normalized = countStr.toLowerCase();
    if (normalized == 'auto-fill') {
      return GridRepeat.autoFill(
        innerTracks,
        leadingLineNames: resolvedLeading,
      );
    }
    if (normalized == 'auto-fit') {
      return GridRepeat.autoFit(
        innerTracks,
        leadingLineNames: resolvedLeading,
      );
    }

    final int? repeatCount = int.tryParse(countStr);
    if (repeatCount != null && repeatCount > 0) {
      return GridRepeat.count(
        repeatCount,
        innerTracks,
        leadingLineNames: resolvedLeading,
      );
    }
    return null;
  }

  static List<GridTrackSize> _parseTrackListInternal(
    String value,
    RenderStyle renderStyle,
    String propertyName,
    Axis axis,
  ) {
    final tokens = _splitBySpacePreservingFunc(value.trim());
    final List<GridTrackSize> sizes = <GridTrackSize>[];
    List<String> pendingLeadingNames = <String>[];
    bool pendingNamesAppliedAsTrailing = false;

    for (final rawToken in tokens) {
      final String t = rawToken.trim();
      if (t.isEmpty) continue;

      if (_isLineNameToken(t)) {
        final names = _parseLineNames(t);
        if (names.isEmpty) continue;
        if (sizes.isEmpty) {
          pendingLeadingNames = <String>[...pendingLeadingNames, ...names];
          pendingNamesAppliedAsTrailing = false;
        } else {
          final GridTrackSize last = sizes.removeLast();
          final List<String> updatedTrailing = <String>[...last.trailingLineNames, ...names];
          sizes.add(_cloneTrackWithLineNames(last, trailing: updatedTrailing));
          // Line names between tracks apply to the shared grid line between them.
          // Store them once as trailing names of the previous track (per grammar),
          // instead of also propagating as leading names for the next track.
          pendingLeadingNames = <String>[];
          pendingNamesAppliedAsTrailing = true;
        }
        continue;
      }

      if (t.startsWith('repeat(') && t.endsWith(')')) {
        final GridRepeat? repeatDef = _parseRepeatComponent(
          t,
          renderStyle,
          propertyName,
          axis,
          leadingNames: pendingLeadingNames,
        );
        if (repeatDef != null) {
          sizes.add(repeatDef);
          pendingLeadingNames = <String>[];
          pendingNamesAppliedAsTrailing = false;
          continue;
        }
      }

      final GridTrackSize? parsed = _parseSingleTrack(
        t,
        renderStyle,
        propertyName,
        axis,
        leadingNames: pendingLeadingNames,
      );
      pendingLeadingNames = <String>[];
      pendingNamesAppliedAsTrailing = false;
      if (parsed != null) {
        sizes.add(parsed);
      }
    }

    if (pendingLeadingNames.isNotEmpty && !pendingNamesAppliedAsTrailing && sizes.isNotEmpty) {
      final GridTrackSize last = sizes.removeLast();
      final List<String> updatedTrailing = <String>[...last.trailingLineNames, ...pendingLeadingNames];
      sizes.add(_cloneTrackWithLineNames(last, trailing: updatedTrailing));
    }

    return sizes;
  }

  static List<GridTrackSize> parseTrackList(
    String value,
    RenderStyle renderStyle,
    String propertyName,
    Axis axis,
  ) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const <GridTrackSize>[];
    }
    // For template track lists, `none` represents "no explicit tracks".
    // Represent this as an empty list so that layout can fall back to
    // auto tracks and computed-style serialization can emit `none`.
    if (trimmed.toLowerCase() == 'none') {
      return const <GridTrackSize>[];
    }
    return _parseTrackListInternal(trimmed, renderStyle, propertyName, axis);
  }

  static GridAutoFlow parseAutoFlow(String value) {
    final tokens = value
        .split(RegExp(r'\s+'))
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return GridAutoFlow.row;
    bool dense = tokens.contains('dense');
    bool column = tokens.contains('column');
    if (column) {
      return dense ? GridAutoFlow.columnDense : GridAutoFlow.column;
    }
    if (dense && tokens.length == 1) {
      return GridAutoFlow.rowDense;
    }
    return dense ? GridAutoFlow.rowDense : GridAutoFlow.row;
  }

  static GridAxisAlignment parseAxisAlignment(String value, {bool allowAuto = false}) {
    final String normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'auto':
        return allowAuto ? GridAxisAlignment.auto : GridAxisAlignment.stretch;
      case 'baseline':
      case 'first baseline':
        return GridAxisAlignment.baseline;
      case 'last baseline':
        return GridAxisAlignment.lastBaseline;
      case 'flex-start':
      case 'self-start':
      case 'start':
        return GridAxisAlignment.start;
      case 'flex-end':
      case 'self-end':
      case 'end':
        return GridAxisAlignment.end;
      case 'center':
        return GridAxisAlignment.center;
      case 'stretch':
      default:
        return GridAxisAlignment.stretch;
    }
  }

  static GridPlacement parsePlacement(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'auto') {
      return const GridPlacement.auto();
    }

    final String lower = trimmed.toLowerCase();
    if (lower.startsWith('span')) {
      final String rest = trimmed.substring(4).trim();
      if (rest.isEmpty) return const GridPlacement.span(1);
      int? spanValue;
      for (final String token in rest.split(RegExp(r'\s+'))) {
        final int? parsed = int.tryParse(token);
        if (parsed != null && parsed > 0) {
          spanValue = parsed;
          break;
        }
      }
      if (spanValue != null) {
        return GridPlacement.span(spanValue);
      }
      return const GridPlacement.span(1);
    }

    final int? lineValue = int.tryParse(trimmed);
    if (lineValue != null) {
      // Grid line number 0 is invalid per CSS Grid and should be treated as 'auto'.
      if (lineValue == 0) {
        return const GridPlacement.auto();
      }
      return GridPlacement.line(lineValue);
    }

    final List<String> tokens = trimmed.split(RegExp(r'\s+'));
    if (tokens.length == 2) {
      final int? occurrence = int.tryParse(tokens[1]);
      if (occurrence != null && occurrence != 0 && isCustomIdent(tokens[0])) {
        return GridPlacement.named(
          tokens[0],
          occurrence: occurrence,
          explicitOccurrence: true,
        );
      }
    }

    if (isCustomIdent(trimmed)) {
      return GridPlacement.named(trimmed);
    }

    return const GridPlacement.auto();
  }

  static GridTemplateAreasDefinition? parseTemplateAreas(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'none') {
      return const GridTemplateAreasDefinition(
        areas: <String, GridTemplateAreaRect>{},
        rowCount: 0,
        columnCount: 0,
        cssText: 'none',
      );
    }

    final RegExp rowPattern = RegExp(r'"([^"]*)"');
    final List<RegExpMatch> matches = rowPattern.allMatches(trimmed).toList();
    if (matches.isEmpty) return null;

    final List<List<String>> rows = <List<String>>[];
    for (final RegExpMatch match in matches) {
      final String rowText = match.group(1)!;
      final String normalized = rowText.trim();
      if (normalized.isEmpty) return null;
      final List<String> tokens =
          normalized.split(RegExp(r'\s+')).map((token) => token.trim()).where((token) => token.isNotEmpty).toList();
      if (tokens.isEmpty) return null;
      rows.add(tokens);
    }

    final int columnCount = rows.first.length;
    if (columnCount == 0) return null;
    for (final List<String> tokens in rows) {
      if (tokens.length != columnCount) return null;
    }

    final Map<String, _GridAreaBuilder> builders = <String, _GridAreaBuilder>{};
    for (int r = 0; r < rows.length; r++) {
      final List<String> tokens = rows[r];
      for (int c = 0; c < tokens.length; c++) {
        final String name = tokens[c];
        if (name == '.' || name.isEmpty) continue;
        final _GridAreaBuilder builder = builders.putIfAbsent(name, () => _GridAreaBuilder(r + 1, c + 1));
        builder.include(r + 1, c + 1);
      }
    }

    final Map<String, GridTemplateAreaRect> rects = <String, GridTemplateAreaRect>{};
    for (final MapEntry<String, _GridAreaBuilder> entry in builders.entries) {
      final _GridAreaBuilder builder = entry.value;
      for (int r = builder.minRow; r <= builder.maxRow; r++) {
        for (int c = builder.minCol; c <= builder.maxCol; c++) {
          if (rows[r - 1][c - 1] != entry.key) {
            return null;
          }
        }
      }
      rects[entry.key] =
          GridTemplateAreaRect(builder.minRow, builder.maxRow + 1, builder.minCol, builder.maxCol + 1);
    }

    return GridTemplateAreasDefinition(
      areas: rects,
      rowCount: rows.length,
      columnCount: columnCount,
      cssText: trimmed,
    );
  }
}

class _GridAreaBuilder {
  int minRow;
  int maxRow;
  int minCol;
  int maxCol;
  _GridAreaBuilder(int row, int col)
      : minRow = row,
        maxRow = row,
        minCol = col,
        maxCol = col;

  void include(int row, int col) {
    if (row < minRow) minRow = row;
    if (row > maxRow) maxRow = row;
    if (col < minCol) minCol = col;
    if (col > maxCol) maxCol = col;
  }
}

mixin CSSGridMixin on RenderStyle {
  List<GridTrackSize>? _gridTemplateColumns;
  @override
  List<GridTrackSize> get gridTemplateColumns => _gridTemplateColumns ?? const <GridTrackSize>[];
  set gridTemplateColumns(List<GridTrackSize>? value) {
    if (_gridTemplateColumns == value) return;
    _gridTemplateColumns = value;
    if (isSelfRenderGridLayout()) markNeedsLayout();
  }

  List<GridTrackSize>? _gridTemplateRows;
  @override
  List<GridTrackSize> get gridTemplateRows => _gridTemplateRows ?? const <GridTrackSize>[];
  set gridTemplateRows(List<GridTrackSize>? value) {
    if (_gridTemplateRows == value) return;
    _gridTemplateRows = value;
    if (isSelfRenderGridLayout()) markNeedsLayout();
  }

  List<GridTrackSize>? _gridAutoRows;
  @override
  List<GridTrackSize> get gridAutoRows => _gridAutoRows ?? const <GridTrackSize>[];
  set gridAutoRows(List<GridTrackSize>? value) {
    if (_gridAutoRows == value) return;
    _gridAutoRows = value;
    markNeedsLayout();
  }

  List<GridTrackSize>? _gridAutoColumns;
  @override
  List<GridTrackSize> get gridAutoColumns => _gridAutoColumns ?? const <GridTrackSize>[];
  set gridAutoColumns(List<GridTrackSize>? value) {
    if (_gridAutoColumns == value) return;
    _gridAutoColumns = value;
    markNeedsLayout();
  }

  GridAutoFlow? _gridAutoFlow;
  @override
  GridAutoFlow get gridAutoFlow => _gridAutoFlow ?? GridAutoFlow.row;
  set gridAutoFlow(GridAutoFlow? value) {
    if (_gridAutoFlow == value) return;
    _gridAutoFlow = value;
    markNeedsLayout();
  }

  GridAxisAlignment? _justifyItems;
  @override
  GridAxisAlignment get justifyItems => _normalizeAxisAlignmentValue(_justifyItems);
  set justifyItems(GridAxisAlignment? value) {
    if (_justifyItems == value) return;
    _justifyItems = value;
    if (isSelfRenderGridLayout()) markNeedsLayout();
  }

  GridAxisAlignment? _justifySelf;
  @override
  GridAxisAlignment get justifySelf => _justifySelf ?? GridAxisAlignment.auto;
  set justifySelf(GridAxisAlignment? value) {
    if (_justifySelf == value) return;
    _justifySelf = value;
    if (isParentRenderGridLayout()) markNeedsLayout();
  }

  GridPlacement? _gridColumnStart;
  @override
  GridPlacement get gridColumnStart => _gridColumnStart ?? const GridPlacement.auto();
  set gridColumnStart(GridPlacement? value) {
    if (_gridColumnStart == value) return;
    _gridColumnStart = value;
    markNeedsLayout();
  }

  GridPlacement? _gridColumnEnd;
  @override
  GridPlacement get gridColumnEnd => _gridColumnEnd ?? const GridPlacement.auto();
  set gridColumnEnd(GridPlacement? value) {
    if (_gridColumnEnd == value) return;
    _gridColumnEnd = value;
    markNeedsLayout();
  }

  GridPlacement? _gridRowStart;
  @override
  GridPlacement get gridRowStart => _gridRowStart ?? const GridPlacement.auto();
  set gridRowStart(GridPlacement? value) {
    if (_gridRowStart == value) return;
    _gridRowStart = value;
    markNeedsLayout();
  }

  GridPlacement? _gridRowEnd;
  @override
  GridPlacement get gridRowEnd => _gridRowEnd ?? const GridPlacement.auto();
  set gridRowEnd(GridPlacement? value) {
    if (_gridRowEnd == value) return;
    _gridRowEnd = value;
    markNeedsLayout();
  }

  GridTemplateAreasDefinition? _gridTemplateAreasDefinition;
  @override
  GridTemplateAreasDefinition? get gridTemplateAreasDefinition => _gridTemplateAreasDefinition;
  set gridTemplateAreasDefinition(GridTemplateAreasDefinition? value) {
    if (_gridTemplateAreasDefinition == value) return;
    _gridTemplateAreasDefinition = value;
    if (isSelfRenderGridLayout()) markNeedsLayout();
  }

  String? _gridAreaName;
  @override
  String? get gridAreaName => _gridAreaName;
  set gridAreaName(String? value) {
    final String? normalized = value == null || value.isEmpty || value.toLowerCase() == 'auto' ? null : value;
    if (_gridAreaName == normalized) return;
    _gridAreaName = normalized;
    markNeedsLayout();
  }

  GridTemplateAreaRect? resolveTemplateArea(String? name) {
    if (name == null || _gridTemplateAreasDefinition == null) return null;
    return _gridTemplateAreasDefinition!.areas[name];
  }
}

GridAxisAlignment _normalizeAxisAlignmentValue(GridAxisAlignment? value) {
  if (value == null || value == GridAxisAlignment.auto) return GridAxisAlignment.stretch;
  return value;
}
