/*
 * Copyright (C) 2019-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/widget.dart';
import 'table_row_bindings_generated.dart';
import 'table.dart';

/// Tag name for WebF Table Row element
const WEBF_TABLE_ROW = 'WEBF-TABLE-ROW';

const Map<String, dynamic> _defaultRowStyle = {
  DISPLAY: BLOCK,
};

// WebF Table Row Element
class WebFTableRow extends WebFTableRowBindings {
  WebFTableRow(super.context);

  double? _index;
  bool _highlighted = false;
  bool _clickable = true;

  @override
  double? get index => _index;

  @override
  set index(value) {
    _index = value is double? ? value : (value is int ? value.toDouble() : null);
    state?.requestUpdateState();
  }

  @override
  bool get highlighted => _highlighted;

  @override
  set highlighted(value) {
    _highlighted = value as bool;
    state?.requestUpdateState();
  }

  @override
  bool get clickable => _clickable;

  @override
  set clickable(value) {
    _clickable = value as bool;
    state?.requestUpdateState();
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultRowStyle;

  @override
  WebFWidgetElementState createState() {
    return WebFTableRowState(this);
  }
}

class WebFTableRowState extends WebFWidgetElementState {
  WebFTableRowState(super.widgetElement);

  @override
  WebFTableRow get widgetElement => super.widgetElement as WebFTableRow;

  bool _isHovered = false;

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

    final isStriped = parentTable?.striped ?? false;
    final isHoverable = parentTable?.hoverable ?? false;
    final rowIndex = widgetElement.index ?? 0;

    List<Widget> cells = [];
    for (final node in widgetElement.childNodes) {
      if (node is dom.Element) {
        cells.add(Expanded(child: node.toWidget()));
      }
    }

    Widget row = Container(
      decoration: BoxDecoration(
        color: widgetElement.highlighted
            ? theme.colorScheme.primary.withOpacity(0.1)
            : (isStriped && rowIndex % 2 == 1)
                ? theme.colorScheme.surfaceVariant.withOpacity(0.2)
                : (_isHovered && isHoverable)
                    ? theme.colorScheme.surfaceVariant.withOpacity(0.1)
                    : null,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cells,
      ),
    );

    if (widgetElement.clickable) {
      row = InkWell(
        onTap: () {
          widgetElement.dispatchEvent(dom.CustomEvent('click', detail: {
            'index': widgetElement.index ?? 0,
          }));
        },
        onHover: isHoverable ? (hovering) {
          setState(() {
            _isHovered = hovering;
          });
        } : null,
        child: row,
      );
    }

    return row;
  }
}
