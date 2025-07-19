import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'extended_nested_scroll_view.dart';

class FlutterNestScrollerSkeleton extends WidgetElement {
  FlutterNestScrollerSkeleton(super.context);

  @override
  FlutterNestScrollerSkeletonState? get state => super.state as FlutterNestScrollerSkeletonState?;

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
  ];

  @override
  WebFWidgetElementState createState() {
    return FlutterNestScrollerSkeletonState(this);
  }

  @override
  ScrollController? get scrollControllerY => state?.controller;

  @override
  ScrollController? get scrollControllerX => null;

  @override
  bool get isScrollingElement => true;
}

class FlutterNestScrollerSkeletonState extends WebFWidgetElementState {
  FlutterNestScrollerSkeletonState(super.widgetElement);

  final controller = ScrollController();

  @override
  FlutterNestScrollerSkeleton get widgetElement =>
      super.widgetElement as FlutterNestScrollerSkeleton;

  @override
  void initState() {
    super.initState();
  }

  Widget? _buildSlotWidget(String tagName) {
    final slotNode = widgetElement.childNodes.firstWhereOrNull((node) {
      if (node is dom.Element) {
        return node.tagName == tagName;
      }
      return false;
    });

    if (slotNode != null) {
      return slotNode.toWidget();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    /// 顶部区域
    final topArea =
        _buildSlotWidget("FLUTTER-NEST-SCROLLER-ITEM-TOP-AREA") ?? const SizedBox.shrink();

    /// 吸顶区域
    final persistentHeaderArea =
        _buildSlotWidget("FLUTTER-NEST-SCROLLER-ITEM-PERSISTENT-HEADER") ?? const SizedBox.shrink();

    /// Sliver 滑动区域
    final sliverScrollerArea = _buildSlotWidget("FLUTTER-SLIVER-LISTVIEW");

    return ExtendedNestedScrollView(
      controller: controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverToBoxAdapter(child: topArea),
        ];
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          persistentHeaderArea,
          Expanded(
            child: WebFWidgetElementChild(
                child: sliverScrollerArea ?? const SliverToBoxAdapter(child: SizedBox.shrink())),
          ),
        ],
      ),
    );
  }
}

class FlutterNestScrollerSkeletonItem extends WidgetElement {
  FlutterNestScrollerSkeletonItem(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterNestScrollerSkeletonItemState(this);
  }
}

class FlutterNestScrollerSkeletonItemState extends WebFWidgetElementState {
  FlutterNestScrollerSkeletonItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final Node? node = widgetElement.childNodes.firstWhereOrNull((node) {
      if (node is dom.Element) {
        return true;
      }
      return false;
    });
    return node?.toWidget() ?? const SizedBox.shrink();
  }
}

class FlutterNestScrollerSkeletonItemTopArea extends FlutterNestScrollerSkeletonItem {
  FlutterNestScrollerSkeletonItemTopArea(super.context);

  @override
  String get tagName => "FLUTTER-NEST-SCROLLER-ITEM-TOP-AREA";
}

class FlutterNestScrollerSkeletonItemPersistentHeader extends FlutterNestScrollerSkeletonItem {
  FlutterNestScrollerSkeletonItemPersistentHeader(super.context);

  @override
  String get tagName => "FLUTTER-NEST-SCROLLER-ITEM-PERSISTENT-HEADER";
}
