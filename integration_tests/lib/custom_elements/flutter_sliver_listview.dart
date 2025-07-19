import 'package:flutter/material.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/dom.dart' show ElementAttributeProperty;
import 'package:webf/bridge.dart';

/// Simplified FlutterSliverListview for integration tests
class FlutterSliverListviewElement extends WidgetElement {
  FlutterSliverListviewElement(BindingContext? context) : super(context) {
    // Check if scrollDirection attribute was set during element creation
    final initialScrollDirection = getAttribute('scrollDirection');
    if (initialScrollDirection != null) {
      scrollDirection = initialScrollDirection;
    }
  }

  @override
  String get tagName => 'FLUTTER-SLIVER-LISTVIEW';

  Axis _scrollDirection = Axis.vertical;
  
  Axis get scrollDirection => _scrollDirection;
  
  set scrollDirection(dynamic value) {
    if (value is String) {
      _scrollDirection = value == 'horizontal' ? Axis.horizontal : Axis.vertical;
    } else if (value is Axis) {
      _scrollDirection = value;
    }
    state?.requestUpdateState();
  }

  @override
  ScrollController? get scrollControllerY {
    return scrollDirection == Axis.vertical ? _scrollController : null;
  }

  ScrollController? get _scrollController {
    return state?.mounted ?? false ? state!.scrollController : null;
  }

  @override
  ScrollController? get scrollControllerX {
    return scrollDirection == Axis.horizontal ? _scrollController : null;
  }

  @override
  bool get isScrollingElement => true;

  @override
  FlutterSliverListviewState? get state => super.state as FlutterSliverListviewState?;

  @override
  Map<String, dynamic> get defaultStyle => {'display': 'block'};
  
  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    properties['scrollDirection'] = BindingObjectProperty(
      getter: () => scrollDirection == Axis.horizontal ? 'horizontal' : 'vertical',
      setter: (value) => scrollDirection = value,
    );
  }
  
  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['scrollDirection'] = ElementAttributeProperty(
      setter: (value) => scrollDirection = value?.toString() ?? 'vertical',
    );
  }
  
  @override
  WebFWidgetElementState createState() {
    return FlutterSliverListviewState(this);
  }
}

class FlutterSliverListviewState extends WebFWidgetElementState {
  FlutterSliverListviewState(super.widgetElement);

  final ScrollController scrollController = ScrollController();

  @override
  FlutterSliverListviewElement get widgetElement => 
      super.widgetElement as FlutterSliverListviewElement;

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Widget buildListViewItemByIndex(int index) {
    dom.Node? node = widgetElement.childNodes.elementAt(index);
    return node.toWidget();
  }

  @override
  void initState() {
    super.initState();
    // Add listener to track scroll changes
    scrollController.addListener(() {
      if (mounted) {
        widgetElement.handleScroll(scrollController.position.pixels, 
            widgetElement.scrollDirection == Axis.vertical ? AxisDirection.down : AxisDirection.right);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Debug: log scroll direction
    print('FlutterSliverListview building with scrollDirection: ${widgetElement.scrollDirection}');
    
    return ListView.builder(
      controller: scrollController,
      scrollDirection: widgetElement.scrollDirection,
      itemCount: widgetElement.childNodes.length,
      itemBuilder: (context, index) {
        return buildListViewItemByIndex(index);
      },
    );
  }
}