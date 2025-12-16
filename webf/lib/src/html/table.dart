/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:webf/src/html/table_bindings_generated.dart';
import 'package:webf/src/html/table_header.dart';
import 'package:webf/src/html/table_row.dart';
import 'package:webf/src/widget/widget_element.dart';

// ignore: constant_identifier_names
const String WEBF_TABLE = 'WEBF-TABLE';

class WebFTable extends WebFTableBindings {
  WebFTable(super.context);

  WebFTableTextDirection? _textDirection;
  WebFTableDefaultVerticalAlignment? _defaultVerticalAlignment;
  double? _defaultColumnWidth;
  String? _columnWidths;
  String? _border;
  WebFTableTextBaseline? _textBaseline;

  @override
  WebFWidgetElementState createState() {
    return WebFTableState(this);
  }

  @override
  WebFTableTextDirection? get textDirection => _textDirection;

  @override
  set textDirection(value) {
    if (value is WebFTableTextDirection?) {
      _textDirection = value;
    } else if (value is String) {
      _textDirection = WebFTableTextDirection.parse(value);
    } else {
      _textDirection = null;
    }
    state?.requestUpdateState(() {});
  }

  @override
  WebFTableDefaultVerticalAlignment? get defaultVerticalAlignment => _defaultVerticalAlignment;

  @override
  set defaultVerticalAlignment(value) {
    if (value is WebFTableDefaultVerticalAlignment?) {
      _defaultVerticalAlignment = value;
    } else if (value is String) {
      _defaultVerticalAlignment = WebFTableDefaultVerticalAlignment.parse(value);
    } else {
      _defaultVerticalAlignment = null;
    }
    state?.requestUpdateState(() {});
  }

  @override
  double? get defaultColumnWidth => _defaultColumnWidth;

  @override
  set defaultColumnWidth(value) {
    if (value is num?) {
      _defaultColumnWidth = value?.toDouble();
    } else if (value is String) {
      _defaultColumnWidth = double.tryParse(value);
    } else {
      _defaultColumnWidth = null;
    }
    state?.requestUpdateState(() {});
  }

  @override
  String? get columnWidths => _columnWidths;

  @override
  set columnWidths(value) {
    if (value is String?) {
      _columnWidths = value;
    } else {
      _columnWidths = value?.toString();
    }
    state?.requestUpdateState(() {});
  }

  @override
  String? get border => _border;

  @override
  set border(value) {
    if (value is String?) {
      _border = value;
    } else {
      _border = value?.toString();
    }
    state?.requestUpdateState(() {});
  }

  @override
  WebFTableTextBaseline? get textBaseline => _textBaseline;

  @override
  set textBaseline(value) {
    if (value is WebFTableTextBaseline?) {
      _textBaseline = value;
    } else if (value is String) {
      _textBaseline = WebFTableTextBaseline.parse(value);
    } else {
      _textBaseline = null;
    }
    state?.requestUpdateState(() {});
  }
}

class WebFTableState extends WebFWidgetElementState {
  WebFTableState(super.widgetElement);

  TableCellVerticalAlignment _getVerticalAlignment(WebFTable table) {
    switch (table.defaultVerticalAlignment) {
      case WebFTableDefaultVerticalAlignment.top:
        return TableCellVerticalAlignment.top;
      case WebFTableDefaultVerticalAlignment.middle:
        return TableCellVerticalAlignment.middle;
      case WebFTableDefaultVerticalAlignment.bottom:
        return TableCellVerticalAlignment.bottom;
      case WebFTableDefaultVerticalAlignment.baseline:
        return TableCellVerticalAlignment.baseline;
      case WebFTableDefaultVerticalAlignment.fill:
        return TableCellVerticalAlignment.fill;
      default:
        return TableCellVerticalAlignment.middle;
    }
  }

  TableColumnWidth _getDefaultColumnWidth(WebFTable table) {
    // If a fixed width is specified, use it
    if (table._defaultColumnWidth != null) {
      return FixedColumnWidth(table._defaultColumnWidth!);
    }

    // Otherwise default to flex layout
    return const FlexColumnWidth();
  }

  TextDirection? _getTextDirection(WebFTable table) {
    switch (table.textDirection) {
      case WebFTableTextDirection.ltr:
        return TextDirection.ltr;
      case WebFTableTextDirection.rtl:
        return TextDirection.rtl;
      default:
        return null;
    }
  }

  TextBaseline? _getTextBaseline(WebFTable table) {
    switch (table.textBaseline) {
      case WebFTableTextBaseline.alphabetic:
        return TextBaseline.alphabetic;
      case WebFTableTextBaseline.ideographic:
        return TextBaseline.ideographic;
      default:
        return null;
    }
  }

  TableBorder? _getBorder(WebFTable table) {
    if (table.border == null || table.border!.isEmpty) {
      return null;
    }
    // Simple border for now - can be enhanced to parse JSON configuration
    return TableBorder.all();
  }

  @override
  Widget build(BuildContext context) {
    final webfTable = widgetElement as WebFTable;
    // Get table configuration
    final verticalAlignment = _getVerticalAlignment(webfTable);
    final defaultColumnWidth = _getDefaultColumnWidth(webfTable);
    final textDirection = _getTextDirection(webfTable);
    final textBaseline = _getTextBaseline(webfTable);
    final border = _getBorder(webfTable);

    WebFTableHeader? header =
        widgetElement.childNodes.firstWhereOrNull((node) => node is WebFTableHeader) as WebFTableHeader?;
    List<WebFTableRow> rows = widgetElement.childNodes.whereType<WebFTableRow>().toList(growable: false);

    bool isStickyHeader = header != null && header.sticky;

    // Get column widths from header cells
    final headerColumnWidths = header?.getColumnWidths();

    if (header != null && isStickyHeader) {
      // With sticky header: header stays at top while scrolling
      return Column(
        children: [
          // Sticky header
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              columnWidths: headerColumnWidths,
              textDirection: textDirection,
              defaultVerticalAlignment: verticalAlignment,
              defaultColumnWidth: defaultColumnWidth,
              border: border,
              textBaseline: textBaseline,
              children: [TableRow(decoration: header.renderStyle.decoration, children: header.buildCellChildren())],
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    columnWidths: headerColumnWidths,
                    textDirection: textDirection,
                    defaultVerticalAlignment: verticalAlignment,
                    defaultColumnWidth: defaultColumnWidth,
                    border: border,
                    textBaseline: textBaseline,
                    children: [
                      ...rows.map((row) {
                        return TableRow(decoration: row.renderStyle.decoration, children: row.buildCellChildren());
                      })
                    ],
                  )),
            ),
          ),
        ],
      );
    } else {
      // Without sticky header: everything scrolls together
      return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Table(
                columnWidths: headerColumnWidths,
                textDirection: textDirection,
                defaultVerticalAlignment: verticalAlignment,
                defaultColumnWidth: defaultColumnWidth,
                border: border,
                textBaseline: textBaseline,
                children: [
                  if (header != null)
                    TableRow(
                      decoration: header.renderStyle.decoration,
                      children: header.buildCellChildren(),
                    ),
                  ...rows.map((row) {
                    return TableRow(decoration: row.renderStyle.decoration, children: row.buildCellChildren());
                  })
                ],
              )));
    }
  }
}
