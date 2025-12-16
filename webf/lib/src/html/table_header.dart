/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:flutter/material.dart';
import 'package:webf/src/html/table_header_bindings_generated.dart';
import 'package:webf/src/widget/widget_element.dart';
import 'table_cell.dart';

// ignore: constant_identifier_names
const String WEBF_TABLE_HEADER = 'WEBF-TABLE-HEADER';

class WebFTableHeader extends WebFTableHeaderBindings {
  WebFTableHeader(super.context);

  bool _sticky = false;

  @override
  WebFWidgetElementState createState() {
    return WebFTableHeaderState(this);
  }

  List<Widget> buildCellChildren() {
    return childNodes.whereType<WebFTableCell>().map((element) {
      return element.toTableCell();
    }).toList(growable: false);
  }

  Map<int, TableColumnWidth>? getColumnWidths() {
    final cells = childNodes.whereType<WebFTableCell>().toList();
    if (cells.isEmpty) return null;

    Map<int, TableColumnWidth>? columnWidths;
    for (int i = 0; i < cells.length; i++) {
      final cell = cells[i];
      if (cell.columnWidth != null) {
        columnWidths ??= {};
        columnWidths[i] = FixedColumnWidth(cell.columnWidth!);
      }
    }

    return columnWidths;
  }

  @override
  bool get sticky => _sticky;

  @override
  set sticky(value) {
    if (value is bool) {
      _sticky = value;
    } else if (value is String) {
      _sticky = value == 'true' || value == '';
    } else {
      _sticky = false;
    }
    state?.requestUpdateState(() {});
  }
}

class WebFTableHeaderState extends WebFWidgetElementState {
  WebFTableHeaderState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
