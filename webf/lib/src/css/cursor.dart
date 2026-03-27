/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/css.dart';

class CSSCursor {
  const CSSCursor._(this.keyword, this.mouseCursor);

  final String keyword;
  final MouseCursor mouseCursor;

  String cssText() => keyword;

  static const CSSCursor auto = CSSCursor._('auto', SystemMouseCursors.basic);
  static const CSSCursor basic =
      CSSCursor._('default', SystemMouseCursors.basic);
  static const CSSCursor pointer =
      CSSCursor._('pointer', SystemMouseCursors.click);
  static const CSSCursor text = CSSCursor._('text', SystemMouseCursors.text);
  static const CSSCursor verticalText =
      CSSCursor._('vertical-text', SystemMouseCursors.verticalText);
  static const CSSCursor move = CSSCursor._('move', SystemMouseCursors.move);
  static const CSSCursor allScroll =
      CSSCursor._('all-scroll', SystemMouseCursors.move);
  static const CSSCursor wait = CSSCursor._('wait', SystemMouseCursors.wait);
  static const CSSCursor progress =
      CSSCursor._('progress', SystemMouseCursors.progress);
  static const CSSCursor help = CSSCursor._('help', SystemMouseCursors.help);
  static const CSSCursor notAllowed =
      CSSCursor._('not-allowed', SystemMouseCursors.forbidden);
  static const CSSCursor noDrop =
      CSSCursor._('no-drop', SystemMouseCursors.noDrop);
  static const CSSCursor grab = CSSCursor._('grab', SystemMouseCursors.grab);
  static const CSSCursor grabbing =
      CSSCursor._('grabbing', SystemMouseCursors.grabbing);
  static const CSSCursor crosshair =
      CSSCursor._('crosshair', SystemMouseCursors.precise);
  static const CSSCursor alias = CSSCursor._('alias', SystemMouseCursors.alias);
  static const CSSCursor copy = CSSCursor._('copy', SystemMouseCursors.copy);
  static const CSSCursor cell = CSSCursor._('cell', SystemMouseCursors.cell);
  static const CSSCursor contextMenu =
      CSSCursor._('context-menu', SystemMouseCursors.contextMenu);
  static const CSSCursor zoomIn =
      CSSCursor._('zoom-in', SystemMouseCursors.zoomIn);
  static const CSSCursor zoomOut =
      CSSCursor._('zoom-out', SystemMouseCursors.zoomOut);
  static const CSSCursor colResize =
      CSSCursor._('col-resize', SystemMouseCursors.resizeColumn);
  static const CSSCursor rowResize =
      CSSCursor._('row-resize', SystemMouseCursors.resizeRow);
  static const CSSCursor ewResize =
      CSSCursor._('ew-resize', SystemMouseCursors.resizeLeftRight);
  static const CSSCursor nsResize =
      CSSCursor._('ns-resize', SystemMouseCursors.resizeUpDown);
  static const CSSCursor neswResize =
      CSSCursor._('nesw-resize', SystemMouseCursors.resizeUpRightDownLeft);
  static const CSSCursor nwseResize =
      CSSCursor._('nwse-resize', SystemMouseCursors.resizeUpLeftDownRight);
  static const CSSCursor none = CSSCursor._('none', SystemMouseCursors.none);

  static const Map<String, CSSCursor> _keywordMap = <String, CSSCursor>{
    'auto': auto,
    'default': basic,
    'pointer': pointer,
    'text': text,
    'vertical-text': verticalText,
    'move': move,
    'all-scroll': allScroll,
    'wait': wait,
    'progress': progress,
    'help': help,
    'not-allowed': notAllowed,
    'no-drop': noDrop,
    'grab': grab,
    'grabbing': grabbing,
    'crosshair': crosshair,
    'alias': alias,
    'copy': copy,
    'cell': cell,
    'context-menu': contextMenu,
    'zoom-in': zoomIn,
    'zoom-out': zoomOut,
    'col-resize': colResize,
    'row-resize': rowResize,
    'ew-resize': ewResize,
    'ns-resize': nsResize,
    'nesw-resize': neswResize,
    'nwse-resize': nwseResize,
    'none': none,
  };

  static CSSCursor fromCss(String value) {
    final String normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return auto;
    }

    // Support the standard fallback syntax:
    // cursor: url(foo.cur), pointer;
    for (final String token in normalized.split(',').reversed) {
      final String candidate = token.trim();
      if (candidate.isEmpty || candidate.startsWith('url(')) {
        continue;
      }
      return _keywordMap[candidate] ?? auto;
    }

    return _keywordMap[normalized] ?? auto;
  }
}

mixin CSSCursorMixin on RenderStyle {
  @override
  CSSCursor get cursor => _cursor ?? CSSCursor.auto;
  CSSCursor? _cursor;

  set cursor(CSSCursor? value) {
    final CSSCursor next = value ?? CSSCursor.auto;
    if (_cursor == next) return;
    _cursor = next;
    requestWidgetToRebuild(UpdateCursorReason());
  }

  static CSSCursor resolveCursor(String value) {
    return CSSCursor.fromCss(value);
  }
}
