/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:flutter/material.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/html/table_cell_bindings_generated.dart';
import 'package:webf/src/widget/webf_element.dart';
import 'package:webf/src/widget/widget_element.dart';

// ignore: constant_identifier_names
const String WEBF_TABLE_CELL = 'WEBF-TABLE-CELL';

class WebFTableCell extends WebFTableCellBindings {
  WebFTableCell(super.context);

  WebFTableCellVerticalAlignment? _verticalAlignment;
  double? _columnWidth;

  @override
  WebFWidgetElementState createState() {
    return WebFTableCellState(this);
  }

  @override
  WebFTableCellVerticalAlignment? get verticalAlignment => _verticalAlignment;

  @override
  set verticalAlignment(value) {
    if (value is WebFTableCellVerticalAlignment?) {
      _verticalAlignment = value;
    } else if (value is String) {
      _verticalAlignment = WebFTableCellVerticalAlignment.parse(value);
    } else {
      _verticalAlignment = null;
    }
    state?.requestUpdateState(() {});
  }

  @override
  double? get columnWidth => _columnWidth;

  @override
  set columnWidth(value) {
    if (value is num?) {
      _columnWidth = value?.toDouble();
    } else if (value is String) {
      _columnWidth = double.tryParse(value);
    } else {
      _columnWidth = null;
    }
    state?.requestUpdateState(() {});
  }

  TableCellVerticalAlignment? parseTableCellVerticalAlignment(WebFTableCellVerticalAlignment? verticalAlignment) {
    switch (verticalAlignment) {
      case WebFTableCellVerticalAlignment.top:
        return TableCellVerticalAlignment.top;
      case WebFTableCellVerticalAlignment.middle:
        return TableCellVerticalAlignment.middle;
      case WebFTableCellVerticalAlignment.bottom:
        return TableCellVerticalAlignment.bottom;
      case WebFTableCellVerticalAlignment.baseline:
        return TableCellVerticalAlignment.baseline;
      case WebFTableCellVerticalAlignment.fill:
        return TableCellVerticalAlignment.fill;
      case null:
        return null;
    }
  }

  TableCell toTableCell() {
    return TableCell(
        verticalAlignment: parseTableCellVerticalAlignment(verticalAlignment),
        child: WebFWidgetElementChild(
            child: toWidget()));
  }
}

class WebFTableCellState extends WebFWidgetElementState {
  WebFTableCellState(super.widgetElement);

  @override
  WebFTableCell get widgetElement => super.widgetElement as WebFTableCell;

  @override
  Widget build(BuildContext context) {
    return WebFHTMLElement(tagName: 'SPAN',
        controller: widgetElement.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList());
  }
}
