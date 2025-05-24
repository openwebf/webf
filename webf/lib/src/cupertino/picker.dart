/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'picker_bindings_generated.dart';

class FlutterCupertinoPicker extends FlutterCupertinoPickerBindings {
  FlutterCupertinoPicker(super.context);

  int? _height;
  int? _itemHeight;

  @override
  int? get height => _height;
  @override
  set height(value) {
    _height = int.tryParse(value.toString());
  }

  @override
  int? get itemHeight => _itemHeight;
  @override
  set itemHeight(value) {
    _itemHeight = int.tryParse(value.toString());
  }

  @override
  FlutterCupertinoPickerState? get state => super.state as FlutterCupertinoPickerState?;

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
      height: widgetElement.height?.toDouble() ?? 200,
      child: CupertinoPicker(
        itemExtent: widgetElement.itemHeight?.toDouble() ?? 32,
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
