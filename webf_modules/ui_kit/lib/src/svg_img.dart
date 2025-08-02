/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webf/webf.dart';
import 'package:webf/css.dart';

const Map<String, dynamic> _defaultStyle = {
  'display': 'inline-block',
};

class FlutterSVGImg extends WidgetElement {
  FlutterSVGImg(super.context) {
    BindingBridge.listenEvent(this, 'load');
    BindingBridge.listenEvent(this, 'error');
  }

  String? _src;
  bool _loaded = false;

  int naturalWidth = 0;
  int naturalHeight = 0;

  @override
  bool get isReplacedElement => true;

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);

    properties['src'] = BindingObjectProperty(
      getter: () => src,
      setter: (value) => src = castToType<String>(value)
    );

    properties['width'] = BindingObjectProperty(
      getter: () => width,
      setter: (value) => width = value
    );

    properties['height'] = BindingObjectProperty(
      getter: () => height,
      setter: (value) => height = value
    );

    properties['naturalWidth'] = BindingObjectProperty(getter: () => naturalWidth);
    properties['naturalHeight'] = BindingObjectProperty(getter: () => naturalHeight);
    properties['complete'] = BindingObjectProperty(getter: () => _loaded);
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['src'] = ElementAttributeProperty(
      setter: (value) => src = attributeToProperty<String>(value)
    );

    attributes['width'] = ElementAttributeProperty(
      setter: (value) {
        CSSLengthValue input = CSSLength.parseLength(attributeToProperty<String>(value), renderStyle);
        if (input.value != null) {
          width = input.value!.toInt();
        }
      }
    );

    attributes['height'] = ElementAttributeProperty(
      setter: (value) {
        CSSLengthValue input = CSSLength.parseLength(attributeToProperty<String>(value), renderStyle);
        if (input.value != null) {
          height = input.value!.toInt();
        }
      }
    );
  }

  String get src => _src ?? '';

  set src(String value) {
    if (_src != value) {
      _src = value;
      _loaded = false;
      ownerDocument.incrementLoadEventDelayCount();
      _loadSvg();
      state?.requestUpdateState();
    }
  }

  // Width and height set through style declaration
  double? get _styleWidth {
    String width = style.getPropertyValue('width');
    if (width.isNotEmpty) {
      CSSLengthValue len = CSSLength.parseLength(width, renderStyle, 'width');
      return len.computedValue;
    }
    return null;
  }

  double? get _styleHeight {
    String height = style.getPropertyValue('height');
    if (height.isNotEmpty) {
      CSSLengthValue len = CSSLength.parseLength(height, renderStyle, 'height');
      return len.computedValue;
    }
    return null;
  }

  // Width and height set through attributes
  double? get _attrWidth {
    if (hasAttribute('width')) {
      final width = getAttribute('width');
      if (width != null) {
        return CSSLength.parseLength(width, renderStyle, 'width').computedValue;
      }
    }
    return null;
  }

  double? get _attrHeight {
    if (hasAttribute('height')) {
      final height = getAttribute('height');
      if (height != null) {
        return CSSLength.parseLength(height, renderStyle, 'height').computedValue;
      }
    }
    return null;
  }

  int get width {
    // Width calc priority: style > attr > intrinsic
    final double borderBoxWidth = _styleWidth ?? _attrWidth ?? renderStyle.getWidthByAspectRatio();
    return borderBoxWidth.isFinite ? borderBoxWidth.round() : 0;
  }

  set width(int value) {
    if (value == width) return;
    internalSetAttribute('width', '${value}px');
    _resizeImage();
  }

  int get height {
    // Height calc priority: style > attr > intrinsic
    final double borderBoxHeight = _styleHeight ?? _attrHeight ?? renderStyle.getHeightByAspectRatio();
    return borderBoxHeight.isFinite ? borderBoxHeight.round() : 0;
  }

  set height(int value) {
    if (value == height) return;
    internalSetAttribute('height', '${value}px');
    _resizeImage();
  }

  void _resizeImage() {
    if (_styleWidth == null && _attrWidth != null) {
      renderStyle.width = CSSLengthValue(_attrWidth, CSSLengthType.PX);
    }
    if (_styleHeight == null && _attrHeight != null) {
      renderStyle.height = CSSLengthValue(_attrHeight, CSSLengthType.PX);
    }

    renderStyle.intrinsicWidth = naturalWidth.toDouble();
    renderStyle.intrinsicHeight = naturalHeight.toDouble();

    if (naturalWidth == 0.0 || naturalHeight == 0.0) {
      renderStyle.aspectRatio = null;
    } else {
      renderStyle.aspectRatio = naturalWidth / naturalHeight;
    }
  }
  Uri? _resolveResourceUri(String src) {
    String base = ownerDocument.controller.url;
    try {
      return ownerDocument.controller.uriParser!.resolve(Uri.parse(base), Uri.parse(src));
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadSvg() async {
    if (_src == null) return;

    final resolvedUri = _resolveResourceUri(_src!);
    if (resolvedUri == null) {
      dispatchEvent(Event('error'));
      ownerDocument.decrementLoadEventDelayCount();
      return;
    }

    try {
      final bundle = ownerDocument.controller.getPreloadBundleFromUrl(resolvedUri.toString()) ??
          WebFBundle.fromUrl(resolvedUri.toString());

      await bundle.resolve(
          baseUrl: ownerDocument.controller.url,
          uriParser: ownerDocument.controller.uriParser
      );
      await bundle.obtainData(ownerDocument.controller.view.contextId);

      if (!bundle.isResolved) {
        throw FlutterError('Failed to load $_src');
      }

      bundle.dispose();

      naturalWidth = 100;
      naturalHeight = 100;
      _resizeImage();

      _loaded = true;
      bundle.dispose();

      ownerDocument.decrementLoadEventDelayCount();
      dispatchEvent(Event('load'));
      state?.requestUpdateState();

    } catch (e) {
      print('Error loading SVG: $e');
      ownerDocument.decrementLoadEventDelayCount();
      dispatchEvent(Event('error'));
    }
  }

  @override
  FlutterSVGImgState? get state => super.state as FlutterSVGImgState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterSVGImgState(this);
  }
}

class FlutterSVGImgState extends WebFWidgetElementState {
  FlutterSVGImgState(super.widgetElement);

  @override
  FlutterSVGImg get widgetElement => super.widgetElement as FlutterSVGImg;

  @override
  Widget build(BuildContext context) {
    if (widgetElement._src == null || !widgetElement._loaded) {
      return const SizedBox();
    }

    return SvgPicture.network(
      widgetElement._src!,
      width: widgetElement.width.toDouble(),
      height: widgetElement.height.toDouble(),
      fit: widgetElement.renderStyle.objectFit,
      alignment: widgetElement.renderStyle.objectPosition,
      placeholderBuilder: (context) => const SizedBox(),
    );
  }

}
