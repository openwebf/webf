import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

class WebFRouterViewport extends MultiChildRenderObjectWidget {
  final WebFController controller;

  WebFRouterViewport({required this.controller, super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    RenderViewportBox root = RenderViewportBox(viewportSize: null, controller: controller);
    return root;
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

  /// Create a WebFRouterView widget using a controller name from WebFControllerManager.
  ///
  /// This constructor will asynchronously load the controller and automatically handle
  /// recreation of disposed controllers.
  ///
  /// You can customize the loading experience with loadingWidget and handle errors
  /// with errorBuilder. The builder allows you to create custom UI with the controller.
  static Widget fromControllerName({
    required String controllerName,
    required String path,
    Widget? loadingWidget,
    Widget Function(BuildContext context, Object error)? errorBuilder
  }) {
    return _AsyncWebFRouterView(
        controllerName: controllerName, path: path, loadingWidget: loadingWidget, errorBuilder: errorBuilder);
  }

  WebFRouterView({required this.controller, required this.path, this.defaultViewBuilder});

  @override
  State<StatefulWidget> createState() {
    return WebFRouterViewState();
  }

  @override
  StatefulElement createElement() {
    return _WebFRouterViewElement(this);
  }
}

class _WebFRouterViewElement extends StatefulElement {
  _WebFRouterViewElement(super.widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    widget.controller.pushNewBuildContext(this);
  }

  @override
  void unmount() {
    widget.controller.popBuildContext();
    super.unmount();
  }

  @override
  WebFRouterView get widget => super.widget as WebFRouterView;
}

class _AsyncWebFRouterView extends StatelessWidget {
  final String controllerName;
  final String path;
  final Widget? loadingWidget;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  _AsyncWebFRouterView({required this.controllerName, required this.path, this.loadingWidget, this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    WebFController? existingController = WebFControllerManager.getInstanceSync(controllerName);
    if (existingController != null) {
      return WebFRouterView(controller: existingController, path: path);
    }
    return FutureBuilder(
        future: WebFControllerManager.instance.getController(controllerName), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return loadingWidget ??
            const SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
      }

      if (snapshot.hasError) {
        return errorBuilder != null
            ? errorBuilder!(context, snapshot.error!)
            : Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData || snapshot.data == null) {
        final errorMsg = 'Controller "$controllerName" not found';
        return errorBuilder != null ? errorBuilder!(context, errorMsg) : Center(child: Text(errorMsg));
      }

      return WebFRouterView(controller: snapshot.data!, path: path);
    });
  }
}
