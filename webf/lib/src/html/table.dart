import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:webf/src/html/table_bindings_generated.dart';
import 'package:webf/src/html/table_header.dart';
import 'package:webf/src/html/table_row.dart';
import 'package:webf/src/widget/widget_element.dart';

const String WEBF_TABLE = 'WEBF-TABLE';


class WebFTable extends WebFTableBindings {
  WebFTable(super.context);

  WebFTableTextDirection? _textDirection;
  WebFTableDefaultVerticalAlignment? _defaultVerticalAlignment;
  WebFTableDefaultColumnWidth? _defaultColumnWidth;
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
  WebFTableDefaultColumnWidth? get defaultColumnWidth => _defaultColumnWidth;

  @override
  set defaultColumnWidth(value) {
    if (value is WebFTableDefaultColumnWidth?) {
      _defaultColumnWidth = value;
    } else if (value is String) {
      _defaultColumnWidth = WebFTableDefaultColumnWidth.parse(value);
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
    switch (table.defaultColumnWidth) {
      case WebFTableDefaultColumnWidth.flex:
        return const FlexColumnWidth();
      case WebFTableDefaultColumnWidth.intrinsic:
        return const IntrinsicColumnWidth();
      case WebFTableDefaultColumnWidth.fixed:
        return const FixedColumnWidth(100.0);
      case WebFTableDefaultColumnWidth.min:
        return const MinColumnWidth(FixedColumnWidth(50.0), FlexColumnWidth());
      case WebFTableDefaultColumnWidth.max:
        return const MaxColumnWidth(FixedColumnWidth(200.0), FlexColumnWidth());
      default:
        return const FlexColumnWidth();
    }
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

    if (header != null && isStickyHeader) {
      // With sticky header: header stays at top while scrolling
      return Column(
        children: [
          // Sticky header
          Table(
            textDirection: textDirection,
            defaultVerticalAlignment: verticalAlignment,
            defaultColumnWidth: defaultColumnWidth,
            border: border,
            textBaseline: textBaseline,
            children: [TableRow(decoration: header.renderStyle.decoration, children: header.buildCellChildren())],
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Table(
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
              ),
            ),
          ),
        ],
      );
    } else {
      // Without sticky header: everything scrolls together
      return SingleChildScrollView(
        child: Table(
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
        ),
      );
    }
  }
}
