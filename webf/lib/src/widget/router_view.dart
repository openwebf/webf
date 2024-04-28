import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

class WebFRouterViewRenderObjectWidget extends MultiChildRenderObjectWidget {
  final WebFController controller;

  WebFRouterViewRenderObjectWidget({required this.controller, super.children});

  @override
  MultiChildRenderObjectElement createElement() {
    return WebFRouterViewRenderObjectElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    RenderViewportBox root = RenderViewportBox(viewportSize: null, controller: controller);

    controller.view.activeRouterRoot = root;

    return root;
  }
}

class WebFRouterViewRenderObjectElement extends MultiChildRenderObjectElement {
  WebFRouterViewRenderObjectElement(super.widget);

  @override
  WebFRouterViewRenderObjectWidget get widget => super.widget as WebFRouterViewRenderObjectWidget;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    widget.controller.buildContextStack.add(this);
  }

  @override
  void unmount() {
    widget.controller.buildContextStack.removeLast();
    widget.controller.view.activeRouterRoot = null;
    super.unmount();
  }
}

class WebFRouterViewState extends State<WebFRouterView> with RouteAware {
  @override
  Widget build(BuildContext context) {
    Widget? child = widget.controller.view.getHybridRouterView(widget.path);
    if (child == null) {
      if (widget.defaultViewBuilder == null) {
        return SizedBox.shrink();
      }

      return widget.defaultViewBuilder!(context);
    }
    return WebFContext(
        controller: widget.controller,
        child: WebFRouterViewRenderObjectWidget(
            controller: widget.controller,
            children: [
              child
            ]));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.controller.routeObserver != null) {
      widget.controller.routeObserver!.subscribe(this, ModalRoute.of(context)!);
    }
  }

  @override
  void didPop() {
    super.didPop();
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    var name = route.settings.name;
    widget.controller.view.window.dispatchEvent(dom.HybridRouterChangeEvent(state: state, kind: 'pop', name: name!));
  }

  @override
  void didPush() {
    super.didPush();
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    var name = route.settings.name;
    widget.controller.view.window.dispatchEvent(dom.HybridRouterChangeEvent(state: state, kind: 'push', name: name!));
  }
}

class WebFRouterView extends StatefulWidget {
  final WebFController controller;
  final String path;
  final WidgetBuilder? defaultViewBuilder;

  WebFRouterView({required this.controller, required this.path, this.defaultViewBuilder});

  @override
  State<StatefulWidget> createState() {
    return WebFRouterViewState();
  }
}
