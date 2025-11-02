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

  static List<GridTrackSize> parseTrackList(
    String value,
    RenderStyle renderStyle,
    String propertyName,
    Axis axis,
  ) {
    final tokens = _splitBySpacePreservingFunc(value.trim());
    final List<GridTrackSize> sizes = [];
    for (final tok in tokens) {
      final t = tok.trim();
      if (t.isEmpty) continue;
      if (t == 'auto') {
        sizes.add(const GridAuto());
        continue;
      }
      if (t.endsWith('fr')) {
        final numStr = t.substring(0, t.length - 2).trim();
        final fr = numStr.isEmpty ? 1.0 : double.tryParse(numStr);
        if (fr != null && fr >= 0) {
          sizes.add(GridFraction(fr));
          continue;
        }
      }
      // Fallback to length/percentage
      final CSSLengthValue len = CSSLength.parseLength(t, renderStyle, propertyName, axis);
      if (len != CSSLengthValue.unknown) {
        sizes.add(GridFixed(len));
        continue;
      }
      // Ignore unsupported tokens (minmax(), min-content, max-content) for MVP
    }
    return sizes;
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
}
