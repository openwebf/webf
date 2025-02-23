import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterBottomSheet extends WidgetElement {
  FlutterBottomSheet(super.context);

  static StaticDefinedSyncBindingObjectMethodMap bottomSheetMethods = {
    'showBottomSheet': StaticDefinedSyncBindingObjectMethod(call: (element, args) {
      castToType<FlutterBottomSheet>(element).showBottomSheet();
    })
  };

  void showBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8, // Adjust height (50% of screen height)
          padding: EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: childNodes.length,
            itemBuilder: (context, index) {
              return childNodes.elementAt(index).toWidget(key: Key(index.toString()));
            },
            padding: const EdgeInsets.all(0),
            physics: const AlwaysScrollableScrollPhysics(),
          ),
        );
      },
    );
  }

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, bottomSheetMethods];

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return SizedBox.shrink();
  }
}
