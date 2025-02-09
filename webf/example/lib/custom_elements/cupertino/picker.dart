import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

class FlutterCupertinoPicker extends WidgetElement {
  FlutterCupertinoPicker(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final items = <Widget>[];
    
    for (var element in childNodes.whereType<dom.Element>()) {
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
      height: double.tryParse(getAttribute('height') ?? '') ?? 200,
      child: CupertinoPicker(
        itemExtent: double.tryParse(getAttribute('item-height') ?? '') ?? 32,
        onSelectedItemChanged: (index) {
          dispatchEvent(CustomEvent('change', detail: index));
        },
        children: items,
      ),
    );
  }
}

class FlutterCupertinoPickerItem extends WidgetElement {
  FlutterCupertinoPickerItem(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return const SizedBox();
  }
}