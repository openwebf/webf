import 'package:flutter/material.dart';
import 'package:webf/src/widget/widget_element.dart';
import 'table_row_bindings_generated.dart';
import 'table_cell.dart';

const String WEBF_TABLE_ROW = 'WEBF-TABLE-ROW';

class WebFTableRow extends WebFTableRowBindings {
  WebFTableRow(super.context);

  @override
  WebFWidgetElementState createState() {
    return WebFTableRowState(this);
  }

  List<Widget> buildCellChildren() {
    return childNodes.whereType<WebFTableCell>().map((element) {
      return element.toTableCell();
    }).toList(growable: false);
  }
}

class WebFTableRowState extends WebFWidgetElementState {
  WebFTableRowState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
