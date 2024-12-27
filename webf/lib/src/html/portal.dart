import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/src/dom/child_node_list.dart';
import 'package:webf/src/widget/widget_element.dart';
import 'package:webf/widget.dart';

const PORTAL = 'PORTAL';

class PortalElement extends WidgetElement {
  PortalElement(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return Portal(ownerElement: this, child: childNodes.isNotEmpty ? childNodes.first.toWidget() : SizedBox.shrink());
  }
}
