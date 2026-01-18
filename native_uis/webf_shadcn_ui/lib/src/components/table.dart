/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'table_bindings_generated.dart';

/// WebF custom element for tables.
///
/// Exposed as `<flutter-shadcn-table>` in the DOM.
class FlutterShadcnTable extends FlutterShadcnTableBindings {
  FlutterShadcnTable(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnTableState(this);
}

class FlutterShadcnTableState extends WebFWidgetElementState {
  FlutterShadcnTableState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgetElement.childNodes
            .map((node) => WebFWidgetElementChild(child: node.toWidget()))
            .toList(),
      ),
    );
  }
}

/// WebF custom element for table header.
class FlutterShadcnTableHeader extends WidgetElement {
  FlutterShadcnTableHeader(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnTableHeaderState(this);
}

class FlutterShadcnTableHeaderState extends WebFWidgetElementState {
  FlutterShadcnTableHeaderState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widgetElement.childNodes
            .map((node) => WebFWidgetElementChild(child: node.toWidget()))
            .toList(),
      ),
    );
  }
}

/// WebF custom element for table body.
class FlutterShadcnTableBody extends WidgetElement {
  FlutterShadcnTableBody(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnTableBodyState(this);
}

class FlutterShadcnTableBodyState extends WebFWidgetElementState {
  FlutterShadcnTableBodyState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgetElement.childNodes
          .map((node) => WebFWidgetElementChild(child: node.toWidget()))
          .toList(),
    );
  }
}

/// WebF custom element for table row.
class FlutterShadcnTableRow extends WidgetElement {
  FlutterShadcnTableRow(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnTableRowState(this);
}

class FlutterShadcnTableRowState extends WebFWidgetElementState {
  FlutterShadcnTableRowState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: widgetElement.childNodes
            .map((node) => Expanded(
                  child: WebFWidgetElementChild(child: node.toWidget()),
                ))
            .toList(),
      ),
    );
  }
}

/// WebF custom element for table header cell.
class FlutterShadcnTableHead extends WidgetElement {
  FlutterShadcnTableHead(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnTableHeadState(this);
}

class FlutterShadcnTableHeadState extends WebFWidgetElementState {
  FlutterShadcnTableHeadState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DefaultTextStyle(
        style: theme.textTheme.small.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.mutedForeground,
        ),
        child: WebFWidgetElementChild(
          child: WebFHTMLElement(
            tagName: 'SPAN',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList(),
          ),
        ),
      ),
    );
  }
}

/// WebF custom element for table cell.
class FlutterShadcnTableCell extends WidgetElement {
  FlutterShadcnTableCell(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnTableCellState(this);
}

class FlutterShadcnTableCellState extends WebFWidgetElementState {
  FlutterShadcnTableCellState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DefaultTextStyle(
        style: theme.textTheme.small,
        child: WebFWidgetElementChild(
          child: WebFHTMLElement(
            tagName: 'SPAN',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList(),
          ),
        ),
      ),
    );
  }
}
