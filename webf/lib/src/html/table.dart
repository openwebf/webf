/*
 * Copyright (C) 2019-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/widget.dart';
import 'table_bindings_generated.dart';

/// Tag name for WebF Table element
const WEBF_TABLE = 'WEBF-TABLE';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

// WebF Table Container Element
class WebFTable extends WebFTableBindings {
  WebFTable(BindingContext? context) : super(context);

  bool _bordered = true;
  bool _striped = false;
  bool _compact = false;
  bool _stickyHeader = false;
  bool _hoverable = false;

  @override
  bool get bordered => _bordered;
  
  @override
  set bordered(value) {
    _bordered = value as bool;
    state?.requestUpdateState();
  }

  @override
  bool get striped => _striped;
  
  @override
  set striped(value) {
    _striped = value as bool;
    state?.requestUpdateState();
  }

  @override
  bool get compact => _compact;
  
  @override
  set compact(value) {
    _compact = value as bool;
    state?.requestUpdateState();
  }

  @override
  bool get stickyHeader => _stickyHeader;
  
  @override
  set stickyHeader(value) {
    _stickyHeader = value as bool;
    state?.requestUpdateState();
  }

  @override
  bool get hoverable => _hoverable;
  
  @override
  set hoverable(value) {
    _hoverable = value as bool;
    state?.requestUpdateState();
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  @override
  WebFWidgetElementState createState() {
    return WebFTableState(this);
  }
}

class WebFTableState extends WebFWidgetElementState {
  WebFTableState(super.widgetElement);

  @override
  WebFTable get widgetElement => super.widgetElement as WebFTable;

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    if (widgetElement.stickyHeader) {
      _scrollController = ScrollController();
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  List<Widget> _buildTableRows() {
    List<Widget> rows = [];
    
    for (final node in widgetElement.childNodes) {
      if (node is dom.Element) {
        rows.add(node.toWidget());
      }
    }
    
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final renderStyle = widgetElement.renderStyle;
    
    if (renderStyle.display == CSSDisplay.none) {
      return const SizedBox.shrink();
    }

    final rows = _buildTableRows();
    
    Widget tableContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );

    if (_scrollController != null) {
      tableContent = SingleChildScrollView(
        controller: _scrollController,
        child: tableContent,
      );
    }

    return Container(
      width: renderStyle.width.isAuto ? null : renderStyle.width.computedValue,
      height: renderStyle.height.isAuto ? null : renderStyle.height.computedValue,
      margin: renderStyle.margin,
      padding: renderStyle.padding,
      decoration: BoxDecoration(
        color: renderStyle.backgroundColor?.value,
        border: widgetElement.bordered ? Border.all(
          color: theme.dividerColor,
          width: 1,
        ) : null,
        borderRadius: renderStyle.borderRadius != null
            ? BorderRadius.circular(renderStyle.borderRadius!.first.x)
            : null,
      ),
      child: ClipRRect(
        borderRadius: renderStyle.borderRadius != null
            ? BorderRadius.circular(renderStyle.borderRadius!.first.x - 1)
            : BorderRadius.zero,
        child: tableContent,
      ),
    );
  }
}