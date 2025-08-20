/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'picker_bindings_generated.dart';
import 'picker_item.dart';

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

    final validChildren = widgetElement.childNodes.where((child) {
      return (child is FlutterCupertinoPickerItem) || 
             (child is dom.Element && (child.getAttribute('label')?.isNotEmpty ?? false));
    }).toList();

    for (var child in validChildren) {
      String label = '';
      
      // Check if it's a FlutterCupertinoPickerItem first
      if (child is FlutterCupertinoPickerItem) {
        label = child.getAttribute('label') ?? '';
      } else if (child is dom.Element) {
        // Fallback to regular dom.Element for backward compatibility
        label = child.getAttribute('label') ?? '';
      }
      
      items.add(
        Center(
          child: Text(
            label,
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
          final validChildren = widgetElement.childNodes.where((child) {
            return (child is FlutterCupertinoPickerItem) || 
                   (child is dom.Element && (child.getAttribute('label')?.isNotEmpty ?? false));
          }).toList();
          
          if (index < validChildren.length) {
            final selectedChild = validChildren[index];
            String value = '';
            
            if (selectedChild is FlutterCupertinoPickerItem) {
              value = selectedChild.getAttribute('val') ?? selectedChild.getAttribute('label') ?? '';
            } else if (selectedChild is dom.Element) {
              value = selectedChild.getAttribute('val') ?? selectedChild.getAttribute('label') ?? '';
            }
            
            widgetElement.dispatchEvent(CustomEvent('change', detail: value));
          }
        },
        children: items,
      ),
    );
  }
}
