import 'package:flutter/widgets.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

class WebFRouterViewRenderObjectWidget extends MultiChildRenderObjectWidget {
  final WebFController controller;

  WebFRouterViewRenderObjectWidget({required this.controller, super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderViewportBox(viewportSize: null, controller: controller);
  }
}

class WebFRouterViewState extends State<WebFRouterView> {
  @override
  Widget build(BuildContext context) {
    Widget? child = widget.controller.view.getHybridRouterView(widget.name);
    if (child == null) {
      if (widget.defaultViewBuilder == null) {
        return SizedBox.shrink();
      }

      return widget.defaultViewBuilder!(context);
    }
    return WebFContext(
        controller: widget.controller,
        child: WebFRouterViewRenderObjectWidget(controller: widget.controller, children: [
          WebFHTMLElement(tagName: 'P', inlineStyle: {
            'overflow': 'auto'
          }, children: [child])
        ]));
  }
}

class WebFRouterView extends StatefulWidget {
  final WebFController controller;
  final String name;
  final WidgetBuilder? defaultViewBuilder;

  WebFRouterView({required this.controller, required this.name, this.defaultViewBuilder});

  @override
  State<StatefulWidget> createState() {
    return WebFRouterViewState();
  }
}
