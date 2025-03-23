import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

class WebFRouterViewport extends MultiChildRenderObjectWidget {
  final WebFController controller;

  WebFRouterViewport({required this.controller, super.children});

  @override
  MultiChildRenderObjectElement createElement() {
    return WebRouterViewportElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    RenderViewportBox root = RenderViewportBox(viewportSize: null, controller: controller);

    return root;
  }
}

class WebRouterViewportElement extends MultiChildRenderObjectElement {
  WebRouterViewportElement(super.widget);

  @override
  WebFRouterViewport get widget => super.widget as WebFRouterViewport;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    widget.controller.buildContextStack.add(this);
  }

  @override
  void unmount() {
    widget.controller.buildContextStack.removeLast();
    super.unmount();
  }
}

class WebFRouterViewState extends State<WebFRouterView> with RouteAware {
  @override
  Widget build(BuildContext context) {
    WidgetElement? child = widget.controller.view.getHybridRouterView(widget.path);
    if (child == null) {
      if (widget.defaultViewBuilder == null) {
        return SizedBox.shrink();
      }

      return widget.defaultViewBuilder!(context);
    }

    return WebFContext(
        controller: widget.controller,
        child: WebFRouterViewport(
            controller: widget.controller,
            children: [
              child.toWidget()
            ]));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.routeObserver?.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    widget.controller.routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    super.didPop();
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    String name = route.settings.name ?? '';
    widget.controller.view.window.dispatchEvent(dom.HybridRouterChangeEvent(state: state, kind: 'pop', name: name));
  }

  @override
  void didPush() {
    super.didPush();
    ModalRoute route = ModalRoute.of(context)!;
    var state = route.settings.arguments;
    String name = route.settings.name ?? '';
    widget.controller.view.window.dispatchEvent(dom.HybridRouterChangeEvent(state: state, kind: 'push', name: name));
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
