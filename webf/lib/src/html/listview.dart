import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

const LISTVIEW = 'LISTVIEW';
const WEBF_LISTVIEW = 'WEBF-LISTVIEW';

class FlutterListViewElement extends WidgetElement {
  FlutterListViewElement(BindingContext? context) : super(context);
  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return WebFChildNodeSize(
        ownerElement: this,
        child: ListView.builder(
          itemCount: childNodes.length,
          itemBuilder: (context, index) {
            return LayoutBoxWrapper(
              child: WebFHTMLElement(
                  tagName: 'DIV',
                  controller: ownerDocument.controller,
                  parentElement: this,
                  children: [childNodes.elementAt(index).toWidget()])
            );
          },
          padding: const EdgeInsets.all(0),
          // controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
        ));
  }
}
