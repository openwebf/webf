import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'package:dropdown_button2/dropdown_button2.dart';

class FlutterSelect extends WidgetElement {
  FlutterSelect(super.context);

  // Define the dropdown items
  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
  ];
  String? selectedValue;

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return Container(
      width: renderStyle.width.computedValue,
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          'Select Item',
          style: TextStyle(
            fontSize: renderStyle.fontSize.computedValue,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: childNodes.whereType<dom.Element>().map((element) {
          String value = element.getAttribute('value') ?? '';
          return DropdownMenuItem(value: value, child: element.toWidget(key: Key(value)));
        }).toList(),
        value: selectedValue,
        onChanged: (String? value) {
          setState(() {
            selectedValue = value;
          });
          dispatchEvent(CustomEvent('change', detail: value));
        },
        buttonStyleData: ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: renderStyle.width.computedValue - 10,
        ),
        underline: SizedBox.shrink(),
        // menuItemStyleData: const MenuItemStyleData(
        //   height: 40,
        // ),
      ),
    );
  }
}