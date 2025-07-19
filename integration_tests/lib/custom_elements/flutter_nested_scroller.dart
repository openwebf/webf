import 'package:flutter/material.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart' as dom;
import 'package:collection/collection.dart';

/// Simplified nested scroller for integration tests
class FlutterNestScrollerSkeleton extends WidgetElement {
  FlutterNestScrollerSkeleton(BindingContext? context) : super(context);

  @override
  String get tagName => 'FLUTTER-NEST-SCROLLER-SKELETON';

  @override
  FlutterNestScrollerSkeletonState? get state => 
      super.state as FlutterNestScrollerSkeletonState?;

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
  void dispose() {
    super.dispose();
    controller.dispose();
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
    /// Top area
    final topArea =
        _buildSlotWidget("FLUTTER-NEST-SCROLLER-ITEM-TOP-AREA") ?? 
        const SizedBox.shrink();

    /// Persistent header
    final persistentHeaderArea =
        _buildSlotWidget("FLUTTER-NEST-SCROLLER-ITEM-PERSISTENT-HEADER") ?? 
        const SizedBox.shrink();

    /// Sliver scroll area
    final sliverScrollerArea = _buildSlotWidget("FLUTTER-SLIVER-LISTVIEW");

    // Simplified version using CustomScrollView
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(child: topArea),
        SliverToBoxAdapter(child: persistentHeaderArea),
        if (sliverScrollerArea != null)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 500, // Fixed height for testing
              child: sliverScrollerArea,
            ),
          ),
      ],
    );
  }
}

class FlutterNestScrollerSkeletonItem extends WidgetElement {
  FlutterNestScrollerSkeletonItem(BindingContext? context) : super(context);

  @override
  WebFWidgetElementState createState() {
    return FlutterNestScrollerSkeletonItemState(this);
  }
}

class FlutterNestScrollerSkeletonItemState extends WebFWidgetElementState {
  FlutterNestScrollerSkeletonItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final dom.Node? node = widgetElement.childNodes.firstWhereOrNull((node) {
      if (node is dom.Element) {
        return true;
      }
      return false;
    });
    return node?.toWidget() ?? const SizedBox.shrink();
  }
}

class FlutterNestScrollerSkeletonItemTopArea extends FlutterNestScrollerSkeletonItem {
  FlutterNestScrollerSkeletonItemTopArea(BindingContext? context) : super(context);

  @override
  String get tagName => "FLUTTER-NEST-SCROLLER-ITEM-TOP-AREA";
}

class FlutterNestScrollerSkeletonItemPersistentHeader extends FlutterNestScrollerSkeletonItem {
  FlutterNestScrollerSkeletonItemPersistentHeader(BindingContext? context) : super(context);

  @override
  String get tagName => "FLUTTER-NEST-SCROLLER-ITEM-PERSISTENT-HEADER";
}