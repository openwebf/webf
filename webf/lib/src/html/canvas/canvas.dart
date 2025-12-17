/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

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

  RenderCanvasPaint({required CustomPainter super.painter, required super.preferredSize, required this.pixelRatio})
      : super(
          foregroundPainter: null,
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
  final Set<WebFCanvasState> _canvasState = {};

  WebFCanvasState? get state {
    final stateFinder = _canvasState.where((state) => state.mounted == true);
    return stateFinder.isEmpty ? null : stateFinder.last;
  }

  final _CanvasRepaintNotifier _repaintNotifier = _CanvasRepaintNotifier();
  ChangeNotifier get repaintNotifier => _repaintNotifier;

  void notifyRepaint() => _repaintNotifier.trigger();

  /// The painter that paints before the children.
  late CanvasPainter painter;

  flutter.UniqueKey canvasKey = flutter.UniqueKey();

  // The custom paint render object.
  RenderCanvasPaint? renderCustomPaint;

  CanvasElement([super.context]) {
    painter = CanvasPainter(repaint: repaintNotifier);
  }

  @override
  flutter.Widget toWidget({Key? key, bool positioned = false}) {
    return WebFReplacedElementWidget(webFElement: this, key: key ?? this.key, child: WebFCanvas(this, key: canvasKey));
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
  void initializeDynamicMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeDynamicMethods(methods);
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
    state?.requestStateUpdate();
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

class _CanvasRepaintNotifier extends ChangeNotifier {
  void trigger() => notifyListeners();
}

class WebFCanvasState extends flutter.State<WebFCanvas> {
  CanvasElement get canvasElement => widget.canvasElement;

  void requestStateUpdate() {
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    canvasElement._canvasState.add(this);
  }

  @override
  void dispose() {
    super.dispose();
    canvasElement._canvasState.remove(this);
  }

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

  const WebFCanvas(this.canvasElement, {super.key});

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return WebFCanvasState();
  }
}

class WebFCanvasPaint extends flutter.SingleChildRenderObjectWidget {
  final Size preferredSize;
  final CanvasPainter painter;
  final double pixelRatio;
  final CanvasElement canvasElement;

  const WebFCanvasPaint(
      {super.key,
      required this.canvasElement,
      required this.preferredSize,
      required this.painter,
      required this.pixelRatio});

  @override
  RenderObject createRenderObject(flutter.BuildContext context) {
    RenderCanvasPaint canvasPaint =
        RenderCanvasPaint(painter: painter, preferredSize: preferredSize, pixelRatio: pixelRatio);
    updateCanvasPainterSize(preferredSize, canvasPaint);
    return canvasPaint;
  }

  @override
  void updateRenderObject(flutter.BuildContext context, RenderCanvasPaint renderObject) {
    super.updateRenderObject(context, renderObject);

    renderObject.preferredSize = preferredSize;
    updateCanvasPainterSize(preferredSize, renderObject);
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

    // Guard against zero bitmap dimensions (canvas width/height attributes) to
    // avoid infinite scales when style width/height are non-zero. This can
    // happen if JS sets canvas.width / canvas.height to 0 before layout.
    final int canvasWidth = canvasElement.width;
    final int canvasHeight = canvasElement.height;

    if (styleWidth != null) {
      scaleX = canvasWidth > 0 ? paintingBounding.width / canvasWidth : 1.0;
    }
    if (styleHeight != null) {
      scaleY = canvasHeight > 0 ? paintingBounding.height / canvasHeight : 1.0;
    }

    if (canvasElement.painter.scaleX != scaleX || canvasElement.painter.scaleY != scaleY) {
      canvasElement.painter
        ..scaleX = scaleX
        ..scaleY = scaleY;
      renderCanvas.markNeedsPaint();
    }
  }
}
