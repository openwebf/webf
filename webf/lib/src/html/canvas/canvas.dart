/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';

import 'canvas_context_2d.dart';
import 'canvas_painter.dart';

const String CANVAS = 'CANVAS';
const int _ELEMENT_DEFAULT_WIDTH_IN_PIXEL = 300;
const int _ELEMENT_DEFAULT_HEIGHT_IN_PIXEL = 150;

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

class RenderCanvasPaint extends RenderCustomPaint {
  @override
  bool get isRepaintBoundary => true;

  double pixelRatio;

  @override
  CanvasPainter? get painter => super.painter as CanvasPainter;

  RenderCanvasPaint({required CustomPainter painter, required Size preferredSize, required this.pixelRatio})
      : super(
          painter: painter,
          foregroundPainter: null, // Ignore foreground painter
          preferredSize: preferredSize,
        );

  Future<Image> toImage(Size size) {
    return (layer as OffsetLayer).toImage(Rect.fromLTRB(0, 0, size.width, size.height), pixelRatio: pixelRatio);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (painter?.context == null) return;
    context.pushClipRect(needsCompositing, offset, Rect.fromLTWH(0, 0, preferredSize.width, preferredSize.height),
        (context, offset) {
      super.paint(context, offset);
    });
  }
}

class CanvasElement extends Element {
  final ChangeNotifier repaintNotifier = ChangeNotifier();

  /// The painter that paints before the children.
  late CanvasPainter painter;

  flutter.UniqueKey canvasKey = flutter.UniqueKey();

  // The custom paint render object.
  RenderCanvasPaint? renderCustomPaint;

  CanvasElement([BindingContext? context]) : super(context) {
    painter = CanvasPainter(repaint: repaintNotifier);
  }

  @override
  flutter.Widget toWidget({Key? key, bool positioned = false}) {
    flutter.Widget child =
        WebFReplacedElementWidget(webFElement: this, key: key ?? this.key, child: WebFCanvas(this, key: canvasKey));
    return WebFEventListener(ownerElement: this, child: child, hasEvent: true);
  }

  @override
  bool get isReplacedElement => true;

  @override
  bool get isDefaultRepaintBoundary => true;

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  // Currently only 2d rendering context for canvas is supported.
  CanvasRenderingContext2D? context2d;

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);
    methods['getContext'] = BindingObjectMethodSync(call: (args) => getContext(castToType<String>(args[0])));
  }

  static final StaticDefinedBindingPropertyMap _canvasProperties = {
    'width': StaticDefinedBindingProperty(
        getter: (canvas) => castToType<CanvasElement>(canvas).width,
        setter: (canvas, value) => castToType<CanvasElement>(canvas).width = castToType<int>(value)),
    'height': StaticDefinedBindingProperty(
        getter: (canvas) => castToType<CanvasElement>(canvas).height,
        setter: (canvas, value) => castToType<CanvasElement>(canvas).height = castToType<int>(value)),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _canvasProperties];

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
  }

  @override
  RenderObject willAttachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    RenderObject renderObject = super.willAttachRenderer(flutterWidgetElement);
    style.addStyleChangeListener(_styleChangedListener);
    return renderObject;
  }

  @override
  void didDetachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    super.didDetachRenderer(flutterWidgetElement);
    style.removeStyleChangeListener(_styleChangedListener);
  }

  CanvasRenderingContext2D getContext(String type, {options}) {
    switch (type) {
      case '2d':
        if (painter.context != null) {
          painter.context!.dispose();
          painter.dispose();
        }

        context2d =
            CanvasRenderingContext2D(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), this);
        painter.context = context2d;

        return context2d!;
      default:
        throw FlutterError('CanvasRenderingContext $type not supported!');
    }
  }

  /// The size that this [CustomPaint] should aim for, given the layout
  /// constraints, if there is no child.
  ///
  /// If there's a child, this is ignored, and the size of the child is used
  /// instead.
  Size get size {
    double? width;
    double? height;

    double? styleWidth = renderStyle.width.isAuto ? null : renderStyle.width.computedValue;
    double? styleHeight = renderStyle.height.isAuto ? null : renderStyle.height.computedValue;

    if (styleWidth != null) {
      width = styleWidth;
    }

    if (styleHeight != null) {
      height = styleHeight;
    }

    // [width/height] has default value, should not be null.
    if (height == null && width == null) {
      width = this.width.toDouble();
      height = this.height.toDouble();
    } else if (width == null && height != null) {
      width = this.height / height * this.width;
    } else if (width != null && height == null) {
      height = this.width / width * this.height;
    }

    // need to minus padding and border size
    width = width! -
        renderStyle.effectiveBorderLeftWidth.computedValue -
        renderStyle.effectiveBorderRightWidth.computedValue -
        renderStyle.paddingLeft.computedValue -
        renderStyle.paddingRight.computedValue;
    height = height! -
        renderStyle.effectiveBorderTopWidth.computedValue -
        renderStyle.effectiveBorderBottomWidth.computedValue -
        renderStyle.paddingTop.computedValue -
        renderStyle.paddingLeft.computedValue;

    return Size(width, height);
  }

  void resize() {
    // https://html.spec.whatwg.org/multipage/canvas.html#concept-canvas-set-bitmap-dimensions
    renderStyle.requestWidgetToRebuild(UpdateRenderReplacedUpdateReason());
  }

  /// Element property width.
  int get width {
    String? attrWidth = getAttribute(WIDTH);
    if (attrWidth != null) {
      return attributeToProperty<int>(attrWidth);
    } else {
      return _ELEMENT_DEFAULT_WIDTH_IN_PIXEL;
    }
  }

  set width(int value) {
    _setDimensions(value, null);
  }

  /// Element property height.
  int get height {
    String? attrHeight = getAttribute(HEIGHT);
    if (attrHeight != null) {
      return attributeToProperty<int>(attrHeight);
    } else {
      return _ELEMENT_DEFAULT_HEIGHT_IN_PIXEL;
    }
  }

  set height(int value) {
    _setDimensions(null, value);
  }

  void _setDimensions(num? width, num? height) {
    // When the user agent is to set bitmap dimensions to width and height, it must run these steps:
    // 1. Reset the rendering context to its default state.
    context2d?.reset();

    // 2. Let canvas be the canvas element to which the rendering context's canvas attribute was initialized.
    // 3. If the numeric value of canvas's width content attribute differs from width,
    // then set canvas's width content attribute to the shortest possible string representing width as
    // a valid non-negative integer.
    if (width != null && width.toString() != getAttribute(WIDTH)) {
      if (width < 0) width = 0;
      internalSetAttribute(WIDTH, width.toString());
    }
    // 5. If the numeric value of canvas's height content attribute differs from height,
    // then set canvas's height content attribute to the shortest possible string representing height as
    // a valid non-negative integer.
    if (height != null && height.toString() != getAttribute(HEIGHT)) {
      if (height < 0) height = 0;
      internalSetAttribute(HEIGHT, height.toString());
    }

    // 4. Resize the output bitmap to the new width and height and clear it to transparent black.
    resize();
  }

  void _styleChangedListener(String key, String? original, String present, {String? baseHref}) {
    switch (key) {
      case WIDTH:
      case HEIGHT:
      case PADDING_BOTTOM:
      case PADDING_LEFT:
      case PADDING_RIGHT:
      case PADDING_TOP:
      case BORDER_TOP_STYLE:
      case BORDER_TOP_WIDTH:
      case BORDER_LEFT_STYLE:
      case BORDER_LEFT_WIDTH:
      case BORDER_RIGHT_STYLE:
      case BORDER_RIGHT_WIDTH:
      case BORDER_BOTTOM_STYLE:
      case BORDER_BOTTOM_WIDTH:
        resize();
        break;
    }
  }

  @override
  void setAttribute(String qualifiedName, String value) {
    super.setAttribute(qualifiedName, value);
    switch (qualifiedName) {
      case 'width':
        width = attributeToProperty<int>(value);
        break;
      case 'height':
        height = attributeToProperty<int>(value);
        break;
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    // If not getContext and element is disposed that context is not existed.
    if (painter.context != null) {
      painter.context!.dispose();
    }
  }
}

class _WebFCanvasState extends flutter.State<WebFCanvas> {
  @override
  flutter.Widget build(flutter.BuildContext context) {
    return WebFCanvasPaint(
        canvasElement: widget.canvasElement,
        painter: widget.canvasElement.painter,
        preferredSize: widget.canvasElement.size,
        pixelRatio: widget.canvasElement.ownerDocument.defaultView.devicePixelRatio);
  }
}

class WebFCanvas extends flutter.StatefulWidget {
  final CanvasElement canvasElement;

  WebFCanvas(this.canvasElement, {flutter.Key? key}) : super(key: key);

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return _WebFCanvasState();
  }
}

class WebFCanvasPaint extends flutter.SingleChildRenderObjectWidget {
  final Size preferredSize;
  final CanvasPainter painter;
  final double pixelRatio;
  final CanvasElement canvasElement;

  WebFCanvasPaint(
      {flutter.Key? key,
      required this.canvasElement,
      required this.preferredSize,
      required this.painter,
      required this.pixelRatio})
      : super(key: key);

  @override
  RenderObject createRenderObject(flutter.BuildContext context) {
    RenderCanvasPaint canvasPaint = RenderCanvasPaint(painter: painter, preferredSize: preferredSize, pixelRatio: pixelRatio);
    updateCanvasPainterSize(preferredSize, canvasPaint);
    return canvasPaint;
  }

  @override
  void updateRenderObject(flutter.BuildContext context, RenderCanvasPaint renderCanvas) {
    super.updateRenderObject(context, renderCanvas);

    renderCanvas.preferredSize = preferredSize;
    updateCanvasPainterSize(preferredSize, renderCanvas);
  }

  void updateCanvasPainterSize(Size paintingBounding, RenderCanvasPaint renderCanvas) {
    // The intrinsic dimensions of the canvas element when it represents embedded content are
    // equal to the dimensions of the element’s bitmap.
    // A canvas element can be sized arbitrarily by a style sheet, its bitmap is then subject
    // to the object-fit CSS property.
    // @TODO: CSS object-fit for canvas.
    // To fill (default value of object-fit) the bitmap content, use scale to get the same performed.
    double? styleWidth = canvasElement.renderStyle.width.isAuto ? null : canvasElement.renderStyle.width.computedValue;
    double? styleHeight =
        canvasElement.renderStyle.height.isAuto ? null : canvasElement.renderStyle.height.computedValue;

    double? scaleX;
    double? scaleY;
    if (styleWidth != null) {
      scaleX = paintingBounding.width / canvasElement.width;
    }
    if (styleHeight != null) {
      scaleY = paintingBounding.height / canvasElement.height;
    }
    if (canvasElement.painter.scaleX != scaleX || canvasElement.painter.scaleY != scaleY) {
      canvasElement.painter
        ..scaleX = scaleX
        ..scaleY = scaleY;
      renderCanvas.markNeedsPaint();
    }
  }
}
