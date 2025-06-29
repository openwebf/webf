/*
 * Copyright (C) 2019-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/widget.dart';
import 'table_header_bindings_generated.dart';

/// Tag name for WebF Table Header element
const WEBF_TABLE_HEADER = 'WEBF-TABLE-HEADER';

const Map<String, dynamic> _defaultRowStyle = {
  DISPLAY: BLOCK,
};

// WebF Table Header Element
class WebFTableHeader extends WebFTableHeaderBindings {
  WebFTableHeader(super.context);

  String? _backgroundColor;
  String? _color;
  bool _sticky = false;

  @override
  String? get backgroundColor => _backgroundColor;
  
  @override
  set backgroundColor(value) {
    _backgroundColor = value as String?;
    state?.requestUpdateState();
  }

  @override
  String? get color => _color;
  
  @override
  set color(value) {
    _color = value as String?;
    state?.requestUpdateState();
  }

  @override
  bool get sticky => _sticky;
  
  @override
  set sticky(value) {
    _sticky = value as bool;
    state?.requestUpdateState();
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultRowStyle;

  @override
  WebFWidgetElementState createState() {
    return WebFTableHeaderState(this);
  }
}

class WebFTableHeaderState extends WebFWidgetElementState {
  WebFTableHeaderState(super.widgetElement);

  @override
  WebFTableHeader get widgetElement => super.widgetElement as WebFTableHeader;

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    try {
      return CSSColor.parseColor(colorString);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final renderStyle = widgetElement.renderStyle;
    
    if (renderStyle.display == CSSDisplay.none) {
      return const SizedBox.shrink();
    }

    List<Widget> cells = [];
    for (final node in widgetElement.childNodes) {
      if (node is dom.Element) {
        cells.add(Expanded(child: node.toWidget()));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: _parseColor(widgetElement.backgroundColor) ?? 
               theme.colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 2,
          ),
        ),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: _parseColor(widgetElement.color) ?? theme.textTheme.titleMedium?.color,
          fontWeight: FontWeight.bold,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ),
    );
  }
}