/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

class FlutterCupertinoPicker extends WidgetElement {
  FlutterCupertinoPicker(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoPickerState(this);
  }
}

class FlutterCupertinoPickerState extends WebFWidgetElementState {
  FlutterCupertinoPickerState(super.widgetElement);

  @override
  FlutterCupertinoPicker get widgetElement => super.widgetElement as FlutterCupertinoPicker;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    for (var element in widgetElement.childNodes.whereType<dom.Element>()) {
      items.add(
        Center(
          child: Text(
            element.getAttribute('label') ?? '',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SizedBox(
      height: double.tryParse(widgetElement.getAttribute('height') ?? '') ?? 200,
      child: CupertinoPicker(
        itemExtent: double.tryParse(widgetElement.getAttribute('item-height') ?? '') ?? 32,
        onSelectedItemChanged: (index) {
          final selectedElement = widgetElement.childNodes.whereType<dom.Element>().elementAt(index);
          final value = selectedElement.getAttribute('val') ?? selectedElement.getAttribute('label') ?? '';
          widgetElement.dispatchEvent(CustomEvent('change', detail: value));
        },
        children: items,
      ),
    );
  }
}
