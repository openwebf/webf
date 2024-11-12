import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

const LISTVIEW = 'LISTVIEW';

class FlutterListViewElement extends WidgetElement {
  FlutterListViewElement(BindingContext? context) : super(context);

  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (controller.position.atEdge) {
      bool isReachBottom = controller.position.pixels != 0;
      if (isReachBottom) {
        dispatchEvent(Event('loadmore'));
      }
    }
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return CupertinoContextMenu.builder(
          actions: [
          CupertinoContextMenuAction(
            child: Text('Action 1'),
            onPressed: () {
              Navigator.pop(context);
              print('1111');
            },
          ),
          CupertinoContextMenuAction(
            child: Text('Action 2'),
            onPressed: () {
              Navigator.pop(context);
              print('2222');
            },
          ),
        ],
        builder: (BuildContext context, Animation<double> animation) {
          return children[index];
        }
      );
      },
      padding: const EdgeInsets.all(0),
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}
