/*
 * Copyright (C) 2019-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/widget.dart';
import 'package:webf/rendering.dart';
import 'table_cell_bindings_generated.dart';
import 'table.dart';
import 'table_row.dart';

/// Tag name for WebF Table Cell element
const WEBF_TABLE_CELL = 'WEBF-TABLE-CELL';

const Map<String, dynamic> _defaultCellStyle = {
  DISPLAY: INLINE_BLOCK,
};

// WebF Table Cell Element
class WebFTableCell extends WebFTableCellBindings {
  WebFTableCell(super.context);

  WebFTableCellAlign _align = WebFTableCellAlign.left;
  WebFTableCellType _type = WebFTableCellType.data;
  double _colspan = 1;
  double _rowspan = 1;
  String? _width;
  String? _valueColor;

  @override
  WebFTableCellAlign? get align => _align;

  @override
  set align(value) {
    if (value is WebFTableCellAlign) {
      _align = value;
    } else if (value is String) {
      _align = WebFTableCellAlign.parse(value) ?? WebFTableCellAlign.left;
    }
    state?.requestUpdateState();
  }

  @override
  WebFTableCellType? get type => _type;

  @override
  set type(value) {
    if (value is WebFTableCellType) {
      _type = value;
    } else if (value is String) {
      _type = WebFTableCellType.parse(value) ?? WebFTableCellType.data;
    }
    state?.requestUpdateState();
  }

  @override
  double? get colspan => _colspan;

  @override
  set colspan(value) {
    _colspan = value is double ? value : (value is int ? value.toDouble() : 1);
    state?.requestUpdateState();
  }

  @override
  double? get rowspan => _rowspan;

  @override
  set rowspan(value) {
    _rowspan = value is double ? value : (value is int ? value.toDouble() : 1);
    state?.requestUpdateState();
  }

  @override
  String? get width => _width;

  @override
  set width(value) {
    _width = value as String?;
    state?.requestUpdateState();
  }

  @override
  String? get valueColor => _valueColor;

  @override
  set valueColor(value) {
    _valueColor = value as String?;
    state?.requestUpdateState();
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultCellStyle;

  @override
  WebFWidgetElementState createState() {
    return WebFTableCellState(this);
  }
}

class WebFTableCellState extends WebFWidgetElementState {
  WebFTableCellState(super.widgetElement);

  @override
  WebFTableCell get widgetElement => super.widgetElement as WebFTableCell;

  TextAlign _getTextAlign() {
    switch (widgetElement.align) {
      case WebFTableCellAlign.center:
        return TextAlign.center;
      case WebFTableCellAlign.right:
        return TextAlign.right;
      case WebFTableCellAlign.left:
      default:
        return TextAlign.left;
    }
  }

  Alignment _getAlignment() {
    switch (widgetElement.align) {
      case WebFTableCellAlign.center:
        return Alignment.center;
      case WebFTableCellAlign.right:
        return Alignment.centerRight;
      case WebFTableCellAlign.left:
      default:
        return Alignment.centerLeft;
    }
  }

  Color? _getValueColor() {
    if (widgetElement.valueColor != null) {
      try {
        return CSSColor.parseColor(widgetElement.valueColor!);
      } catch (e) {
        return null;
      }
    }

    // Auto-detect color based on content
    final textContent = _getTextContent();
    if (textContent != null) {
      switch (textContent.toUpperCase()) {
        case 'BUY':
          return const Color(0xFF22C55E);
        case 'SELL':
          return const Color(0xFFEF4444);
      }
    }

    return null;
  }

  String? _getTextContent() {
    for (final node in widgetElement.childNodes) {
      if (node is dom.TextNode) {
        return node.data;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final renderStyle = widgetElement.renderStyle;

    if (renderStyle.display == CSSDisplay.none) {
      return const SizedBox.shrink();
    }

    // Get parent table for styling
    WebFTable? parentTable;
    dom.Element? parent = widgetElement.parentElement;
    while (parent != null) {
      if (parent is WebFTable) {
        parentTable = parent;
        break;
      }
      parent = parent.parentElement;
    }

    final isCompact = parentTable?.compact ?? false;
    final isHeader = widgetElement.type == WebFTableCellType.header;

    Widget cellContent = WebFWidgetElementChild(
      child: widgetElement.childNodes.isEmpty
          ? const SizedBox()
          : DefaultTextStyle(
              style: TextStyle(
                color: _getValueColor() ?? (isHeader
                    ? theme.textTheme.titleMedium?.color
                    : theme.textTheme.bodyMedium?.color),
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                fontSize: isCompact ? 12 : 14,
              ),
              textAlign: _getTextAlign(),
              child: Column(
                children: widgetElement.childNodes.map((node) => node.toWidget()).toList(),
              ),
            ),
    );

    return InkWell(
      onTap: () {
        // Get row and column indices
        int rowIndex = 0;
        int columnIndex = 0;

        // Find row index
        final parentRow = widgetElement.parentElement;
        if (parentRow is WebFTableRow) {
          rowIndex = (parentRow.index ?? 0).toInt();
        }

        // Find column index
        if (parentRow != null) {
          int currentIndex = 0;
          for (final sibling in parentRow.childNodes) {
            if (sibling == widgetElement) {
              columnIndex = currentIndex;
              break;
            }
            if (sibling is dom.Element) {
              currentIndex++;
            }
          }
        }

        widgetElement.dispatchEvent(dom.CustomEvent('click', detail: {
          'row': rowIndex,
          'column': columnIndex,
          'value': _getTextContent(),
        }));
      },
      child: Container(
        width: widgetElement.width != null ? double.tryParse(widgetElement.width!) : null,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 4 : 8,
        ),
        alignment: _getAlignment(),
        child: cellContent,
      ),
    );
  }
}
