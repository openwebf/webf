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
  const GridTrackSize();
}

class GridFixed extends GridTrackSize {
  final CSSLengthValue length; // may be px or percentage
  GridFixed(this.length);
}

class GridFraction extends GridTrackSize {
  final double fr;
  GridFraction(this.fr);
}

class GridAuto extends GridTrackSize {
  const GridAuto() : super();
}

enum GridPlacementKind { auto, line, span }

class GridPlacement {
  final GridPlacementKind kind;
  final int? line;
  final int? span;

  const GridPlacement._(this.kind, {this.line, this.span});
  const GridPlacement.auto() : this._(GridPlacementKind.auto);
  const GridPlacement.line(int value) : this._(GridPlacementKind.line, line: value);
  const GridPlacement.span(int value) : this._(GridPlacementKind.span, span: value);
}

enum GridAutoFlow { row, column, rowDense, columnDense }

enum GridAxisAlignment {
  auto,
  start,
  end,
  center,
  stretch,
}

class CSSGridParser {
  // Very simple whitespace splitter that ignores spaces inside parentheses.
  static List<String> _splitBySpacePreservingFunc(String input) {
    List<String> res = [];
    int depth = 0;
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == '(') depth++;
      if (ch == ')') depth = depth > 0 ? depth - 1 : 0;
      if (ch == ' ' && depth == 0) {
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

  static GridTrackSize? _parseSingleTrack(
    String token,
    RenderStyle renderStyle,
    String propertyName,
    Axis axis,
  ) {
    final String t = token.trim();
    if (t.isEmpty) return null;
    if (t == 'auto') {
      return const GridAuto();
    }
    if (t.endsWith('fr')) {
      final numStr = t.substring(0, t.length - 2).trim();
      final fr = numStr.isEmpty ? 1.0 : double.tryParse(numStr);
      if (fr != null && fr >= 0) {
        return GridFraction(fr);
      }
    }
    final CSSLengthValue len = CSSLength.parseLength(t, renderStyle, propertyName, axis);
    if (len != CSSLengthValue.unknown) {
      return GridFixed(len);
    }
    return null;
  }

  static List<GridTrackSize> parseTrackList(
    String value,
    RenderStyle renderStyle,
    String propertyName,
    Axis axis,
  ) {
    final tokens = _splitBySpacePreservingFunc(value.trim());
    final List<GridTrackSize> sizes = [];
    for (final tok in tokens) {
      final String t = tok.trim();
      if (t.isEmpty) continue;

      if (t.startsWith('repeat(') && t.endsWith(')')) {
        final inner = t.substring(7, t.length - 1);
        final commaIndex = inner.indexOf(',');
        if (commaIndex != -1) {
          final countStr = inner.substring(0, commaIndex).trim();
          final trackToken = inner.substring(commaIndex + 1).trim();
          final repeatCount = int.tryParse(countStr);
          if (repeatCount != null && repeatCount > 0) {
            for (int i = 0; i < repeatCount; i++) {
              final GridTrackSize? parsed =
                  _parseSingleTrack(trackToken, renderStyle, propertyName, axis);
              if (parsed != null) {
                sizes.add(parsed);
              }
            }
            continue;
          }
        }
      }

      final GridTrackSize? parsed =
          _parseSingleTrack(t, renderStyle, propertyName, axis);
      if (parsed != null) {
        sizes.add(parsed);
      }
      // Ignore unsupported tokens (minmax(), min-content, max-content) for MVP
    }
    return sizes;
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
      final String number = lower.substring(4).trim();
      final int? spanValue = int.tryParse(number);
      if (spanValue != null && spanValue > 0) {
        return GridPlacement.span(spanValue);
      }
      return const GridPlacement.span(1);
    }

    final int? lineValue = int.tryParse(trimmed);
    if (lineValue != null) {
      return GridPlacement.line(lineValue);
    }

    return const GridPlacement.auto();
  }
}

mixin CSSGridMixin on RenderStyle {
  List<GridTrackSize>? _gridTemplateColumns;
  List<GridTrackSize> get gridTemplateColumns => _gridTemplateColumns ?? const <GridTrackSize>[];
  set gridTemplateColumns(List<GridTrackSize>? value) {
    if (_gridTemplateColumns == value) return;
    _gridTemplateColumns = value;
    if (isSelfRenderGridLayout()) markNeedsLayout();
  }

  List<GridTrackSize>? _gridTemplateRows;
  List<GridTrackSize> get gridTemplateRows => _gridTemplateRows ?? const <GridTrackSize>[];
  set gridTemplateRows(List<GridTrackSize>? value) {
    if (_gridTemplateRows == value) return;
    _gridTemplateRows = value;
    if (isSelfRenderGridLayout()) markNeedsLayout();
  }

  List<GridTrackSize>? _gridAutoRows;
  List<GridTrackSize> get gridAutoRows => _gridAutoRows ?? const <GridTrackSize>[];
  set gridAutoRows(List<GridTrackSize>? value) {
    if (_gridAutoRows == value) return;
    _gridAutoRows = value;
    markNeedsLayout();
  }

  List<GridTrackSize>? _gridAutoColumns;
  List<GridTrackSize> get gridAutoColumns => _gridAutoColumns ?? const <GridTrackSize>[];
  set gridAutoColumns(List<GridTrackSize>? value) {
    if (_gridAutoColumns == value) return;
    _gridAutoColumns = value;
    markNeedsLayout();
  }

  GridAutoFlow? _gridAutoFlow;
  GridAutoFlow get gridAutoFlow => _gridAutoFlow ?? GridAutoFlow.row;
  set gridAutoFlow(GridAutoFlow? value) {
    if (_gridAutoFlow == value) return;
    _gridAutoFlow = value;
    markNeedsLayout();
  }

  GridAxisAlignment? _justifyItems;
  GridAxisAlignment get justifyItems => _normalizeAxisAlignmentValue(_justifyItems);
  set justifyItems(GridAxisAlignment? value) {
    if (_justifyItems == value) return;
    _justifyItems = value;
    if (isSelfRenderGridLayout()) markNeedsLayout();
  }

  GridAxisAlignment? _justifySelf;
  GridAxisAlignment get justifySelf => _justifySelf ?? GridAxisAlignment.auto;
  set justifySelf(GridAxisAlignment? value) {
    if (_justifySelf == value) return;
    _justifySelf = value;
    if (isParentRenderGridLayout()) markNeedsLayout();
  }

  GridPlacement? _gridColumnStart;
  GridPlacement get gridColumnStart => _gridColumnStart ?? const GridPlacement.auto();
  set gridColumnStart(GridPlacement? value) {
    if (_gridColumnStart == value) return;
    _gridColumnStart = value;
    markNeedsLayout();
  }

  GridPlacement? _gridColumnEnd;
  GridPlacement get gridColumnEnd => _gridColumnEnd ?? const GridPlacement.auto();
  set gridColumnEnd(GridPlacement? value) {
    if (_gridColumnEnd == value) return;
    _gridColumnEnd = value;
    markNeedsLayout();
  }

  GridPlacement? _gridRowStart;
  GridPlacement get gridRowStart => _gridRowStart ?? const GridPlacement.auto();
  set gridRowStart(GridPlacement? value) {
    if (_gridRowStart == value) return;
    _gridRowStart = value;
    markNeedsLayout();
  }

  GridPlacement? _gridRowEnd;
  GridPlacement get gridRowEnd => _gridRowEnd ?? const GridPlacement.auto();
  set gridRowEnd(GridPlacement? value) {
    if (_gridRowEnd == value) return;
    _gridRowEnd = value;
    markNeedsLayout();
  }
}

GridAxisAlignment _normalizeAxisAlignmentValue(GridAxisAlignment? value) {
  if (value == null || value == GridAxisAlignment.auto) return GridAxisAlignment.stretch;
  return value;
}
