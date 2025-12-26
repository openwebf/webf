/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/css.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/painting.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/scheduler/debounce.dart';

void _imgLog(String message) {
  if (kDebugMode && DebugFlags.enableImageLogs) {
    debugPrint(message);
  }
}

({int width, int height})? _tryParseSvgIntrinsicSize(Uint8List bytes) {
  try {
    // Only probe the head; SVG root attributes are near the start.
    final int probeLen = bytes.length < 4096 ? bytes.length : 4096;
    final String head = utf8.decode(bytes.sublist(0, probeLen), allowMalformed: true);
    final Match? svgTagMatch = RegExp(r'<svg\b[^>]*>', caseSensitive: false).firstMatch(head);
    if (svgTagMatch == null) return null;
    final String tag = svgTagMatch.group(0)!;

    int? parseLengthAttr(String name) {
      final Match? m = RegExp('$name\\s*=\\s*([\"\\\']?)([^\"\\\'>\\s]+)\\1', caseSensitive: false).firstMatch(tag);
      if (m == null) return null;
      String v = m.group(2)!.trim();
      if (v.endsWith('%')) return null;
      if (v.endsWith('px')) v = v.substring(0, v.length - 2);
      final double? d = double.tryParse(v);
      if (d == null || d <= 0) return null;
      return d.round();
    }

    final int? w = parseLengthAttr('width');
    final int? h = parseLengthAttr('height');
    if (w != null && h != null) return (width: w, height: h);

    final Match? vb = RegExp('viewBox\\s*=\\s*([\"\\\'])([^\"\\\']+)\\1', caseSensitive: false).firstMatch(tag);
    if (vb != null) {
      final parts = vb.group(2)!.trim().split(RegExp(r'[ ,]+'));
      if (parts.length == 4) {
        final double? vbw = double.tryParse(parts[2]);
        final double? vbh = double.tryParse(parts[3]);
        if (vbw != null && vbh != null && vbw > 0 && vbh > 0) {
          return (width: vbw.round(), height: vbh.round());
        }
      }
    }
  } catch (_) {}
  return null;
}

const String IMAGE = 'IMG';
const String NATURAL_WIDTH = 'naturalWidth';
const String NATURAL_HEIGHT = 'naturalHeight';
const String LOADING = 'loading';
const String SCALING = 'scaling';
const String LAZY = 'lazy';
const String SCALE = 'scale';

// FIXME: should be inline default.
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

// The HTMLImageElement.
class ImageElement extends Element {
  final Set<ImageState> _imageState = {};

  // Flag to track if an image update is pending but couldn't be delivered
  bool _hasPendingImageUpdate = false;

  ImageState? get state {
    final stateFinder = _imageState.where((state) => state.mounted == true);
    return stateFinder.isEmpty ? null : stateFinder.last;
  }

  BoxFitImage? _currentImageProvider;
  ImageConfiguration? _currentImageConfig;

  ImageStream? _cachedImageStream;
  ImageInfo? _cachedImageInfo;

  ImageRequest? _currentRequest;

  // Current image source.
  Uri? _resolvedUri;

  // Current image data([ui.Image]).
  ui.Image? get image => _cachedImageInfo?.image;

  bool _isListeningStream = false;

  bool _isSVGImage = false;
  Uint8List? _svgBytes;
  // Prefetched response used to avoid duplicate network fetch when
  // we need to detect content-type before choosing render path.
  ImageLoadResponse? _prefetchedImageResponse;
  Uri? _prefetchedImageUri;

  // https://html.spec.whatwg.org/multipage/embedded-content.html#dom-img-complete-dev
  // A boolean value which indicates whether or not the image has completely loaded.
  // https://html.spec.whatwg.org/multipage/embedded-content.html#dom-img-complete-dev
  // The IDL attribute complete must return true if any of the following conditions is true:
  // 1. Both the src attribute and the srcset attribute are omitted.
  // 2. The srcset attribute is omitted and the src attribute's value is the empty string.
  // 3. The img element's current request's state is completely available and its pending request is null.
  // 4. The img element's current request's state is broken and its pending request is null.
  bool get complete {
    // @TODO: Implement the srcset.
    if (src.isEmpty) return true;
    if (_currentRequest != null && _currentRequest!.available) return true;
    if (_currentRequest != null && _currentRequest!.state == ImageRequestState.broken) return true;
    return true;
  }

  // The attribute directs the user agent to fetch a resource immediately or to defer fetching
  // until some conditions associated with the element are met, according to the attribute's
  // current state.
  // https://html.spec.whatwg.org/multipage/urls-and-fetching.html#lazy-loading-attributes
  bool get shouldLazyLoading => getAttribute(LOADING) == LAZY;

  // Resize the rendering image to a fixed size if the original image is much larger than the display size.
  // This feature could save memory if the original image is much larger than it's actual display size.
  // Note that images with the same URL but different sizes could produce different resized images, and WebF will treat them
  // as different images. However, in most cases, using the same image with different sizes is much rarer than using images with different URL.
  bool get _shouldScaling => getAttribute(SCALING) == SCALE;

  ImageStreamCompleterHandle? _completerHandle;

  // only the last task works
  Future<void>? _updateImageDataTaskFuture;
  int _updateImageDataTaskId = 0;

  // When there has a delay task, should complete it to continue.
  Completer<bool?>? _updateImageDataLazyCompleter;

  ImageElement([super.context]) {
    // Add default event listener to make sure load or error event can be fired to the native side to release the keepAlive
    // handler of HTMLImageElement.
    BindingBridge.listenEvent(this, 'load');
    BindingBridge.listenEvent(this, 'error');
  }

  @override
  bool get isReplacedElement => true;

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  @override
  flutter.Widget toWidget({Key? key, bool positioned = false}) {
    return WebFReplacedElementWidget(webFElement: this, key: key ?? this.key, child: WebFImage(this));
  }

  @override
  void initializeDynamicProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeDynamicProperties(properties);
    properties['src'] = BindingObjectProperty(getter: () => src, setter: (value) => src = castToType<String>(value));
    properties['loading'] =
        BindingObjectProperty(getter: () => loading, setter: (value) => loading = castToType<String>(value));
    properties['alt'] = BindingObjectProperty(getter: () => alt, setter: (value) => alt = castToType<String>(value));
    properties['width'] = BindingObjectProperty(getter: () => width, setter: (value) => width = value);
    properties['height'] = BindingObjectProperty(getter: () => height, setter: (value) => height = value);
    properties['scaling'] =
        BindingObjectProperty(getter: () => scaling, setter: (value) => scaling = castToType<String>(value));
    properties['naturalWidth'] = BindingObjectProperty(getter: () => naturalWidth);
    properties['naturalHeight'] = BindingObjectProperty(getter: () => naturalHeight);
    properties['complete'] = BindingObjectProperty(getter: () => complete);
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['src'] = ElementAttributeProperty(setter: (value) => src = attributeToProperty<String>(value));
    attributes['loading'] = ElementAttributeProperty(setter: (value) => loading = attributeToProperty<String>(value));
    attributes['alt'] = ElementAttributeProperty(
        setter: (value) => alt = attributeToProperty<String>(value));
    attributes['width'] = ElementAttributeProperty(setter: (value) {
      CSSLengthValue input = CSSLength.parseLength(attributeToProperty<String>(value), renderStyle);
      if (input.value != null) {
        width = input.value!.toInt();
      }
    });
    attributes['height'] = ElementAttributeProperty(setter: (value) {
      CSSLengthValue input = CSSLength.parseLength(attributeToProperty<String>(value), renderStyle);
      if (input.value != null) {
        height = input.value!.toInt();
      }
    });
    attributes['scaling'] = ElementAttributeProperty(setter: (value) => scaling = attributeToProperty<String>(value));
  }

  @override
  RenderObject willAttachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    RenderObject renderObject = super.willAttachRenderer(flutterWidgetElement);
    _imgLog('[IMG] willAttachRenderer elem=$hashCode');
    style.addStyleChangeListener(_stylePropertyChanged);
    RenderReplaced? renderReplaced = renderObject as RenderReplaced;
    if ((!_didWatchAnimationImage) && (shouldLazyLoading) && renderReplaced.hasIntersectionObserver() == false) {
      renderReplaced.addIntersectionChangeListener(handleIntersectionChange);
    }

    return renderObject;
  }

  @override
  void didAttachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
    super.didAttachRenderer();
  }

  @override
  void didDetachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) async {
    super.didDetachRenderer(flutterWidgetElement);
    _imgLog('[IMG] didDetachRenderer elem=$hashCode');
    style.removeStyleChangeListener(_stylePropertyChanged);
  }

  String get scaling => getAttribute(SCALING) ?? '';

  set scaling(String value) {
    internalSetAttribute(SCALING, value);
  }

  String get src => _resolvedUri?.toString() ?? '';

  // Expose alt as a reflected content attribute.
  String get alt => attributes['alt'] ?? '';
  set alt(String value) {
    internalSetAttribute('alt', value);
  }

  set src(String value) {
    internalSetAttribute('src', value);
    final resolvedUri = _resolveResourceUri(value);
    _imgLog('[IMG] set src value=$value resolved=$resolvedUri prev=$_resolvedUri elem=$hashCode hasRenderer=${renderStyle.attachedRenderBoxModel != null}');
    if (_resolvedUri != resolvedUri) {
      _loaded = false;
      _resolvedUri = resolvedUri;
      // Clear any stale prefetched response from prior URL to avoid cross-URL leakage
      if (_prefetchedImageResponse != null) {
        _imgLog('[IMG] clear stale prefetched response on src change elem=$hashCode');
      }
      _prefetchedImageResponse = null;
      _prefetchedImageUri = null;
      // Reset cached frame so UI won't reuse old image
      _cachedImageInfo = null;
      _isSVGImage = false;
      // Stop listening to the old stream immediately since URL changed
      _stopListeningStream(keepStreamAlive: false);
      _imgLog('[IMG] _startLoadNewImage due to src change elem=$hashCode');
      _startLoadNewImage();
    }
  }

  String get loading => getAttribute(LOADING) ?? '';

  set loading(String value) {
    if (loading == LAZY && value != LAZY) {
      _updateImageDataLazyCompleter?.complete();
    }
    internalSetAttribute(LOADING, value);
  }

  set width(int value) {
    if (value == width) return;
    internalSetAttribute(WIDTH, '${value}px');
    if (_shouldScaling) {
      _reloadImage();
    } else {
      _resizeImage();
    }
  }

  set height(int value) {
    if (value == height) return;
    internalSetAttribute(HEIGHT, '${value}px');
    if (_shouldScaling) {
      _reloadImage();
    } else {
      _resizeImage();
    }
  }

  ImageStreamListener? _imageStreamListener;

  ImageStreamListener get _listener =>
      _imageStreamListener ??= ImageStreamListener(_handleImageFrame, onError: _onImageError);

  void _listenToStream() {
    if (_isListeningStream) return;
    _imgLog('[IMG] _listenToStream elem=$hashCode');
    final ImageStream? stream = _cachedImageStream;
    if (stream == null) return;

    try {
      stream.addListener(_listener);
      _isListeningStream = true;
    } on StateError catch (e) {
      // Recover from "Stream has been disposed" by creating a new stream from the provider.
      if (e.message.contains('Stream has been disposed') && _currentImageProvider != null) {
        _imgLog('[IMG] stream disposed; recreate stream elem=$hashCode url=$_resolvedUri');
        // Evict first to avoid ImageCache returning the disposed completer again.
        try {
          _currentImageProvider!.evict(configuration: _currentImageConfig ?? ImageConfiguration.empty);
        } catch (_) {}

        final ImageStream newStream = _currentImageProvider!.resolve(_currentImageConfig ?? ImageConfiguration.empty);
        _updateSourceStream(newStream);
        try {
          _cachedImageStream?.addListener(_listener);
          _isListeningStream = true;
        } on StateError {
          _isListeningStream = false;
        }
      } else {
        rethrow;
      }
    }
  }

  bool _didWatchAnimationImage = false;

  void _watchAnimatedImageWhenVisible() {
    RenderReplaced? renderReplaced = renderStyle.attachedRenderBoxModel as RenderReplaced?;
    if (renderReplaced != null && _isListeningStream && !_didWatchAnimationImage) {
      _stopListeningStream(keepStreamAlive: true);
      renderReplaced.addIntersectionChangeListener(handleIntersectionChange);
      _didWatchAnimationImage = true;
    }
  }

  @override
  void dispose() async {
    super.dispose();
    _imgLog('[IMG] dispose elem=$hashCode states=${_imageState.length} hasStream=$_isListeningStream');

    RenderReplaced? renderReplaced = renderStyle.attachedRenderBoxModel as RenderReplaced?;
    renderReplaced?.removeIntersectionChangeListener(handleIntersectionChange);

    // Stop and remove image stream reference.
    _stopListeningStream();

    // Safely dispose completer handle
    try {
      _completerHandle?.dispose();
    } catch (e) {
      // Ignore StateError for disposed native peers during controller disposal
      if (e is StateError && e.message.contains('native peer has been collected')) {
        if (kDebugMode) {
          debugPrint('ImageElement: Native peer disposed before completer cleanup: ${e.message}');
        }
      } else {
        rethrow;
      }
    }
    _completerHandle = null;
    _imageStreamListener = null;
    _cachedImageStream = null;
    _cachedImageInfo = null;

    // Safely evict image provider
    try {
      _currentImageProvider?.evict(configuration: _currentImageConfig ?? ImageConfiguration.empty);
    } catch (e) {
      // Ignore StateError for disposed native peers during controller disposal
      if (e is StateError && e.message.contains('native peer has been collected')) {
        if (kDebugMode) {
          debugPrint('ImageElement: Native peer disposed before image provider eviction: ${e.message}');
        }
      } else {
        rethrow;
      }
    }

    _currentImageConfig = null;
    _currentImageProvider = null;
    _svgBytes = null;
  }

  // Width and height set through style declaration.
  double? get _styleWidth {
    String width = style.getPropertyValue(WIDTH);
    if (width.isNotEmpty) {
      // For images, when CSS width is explicitly 'auto', we should ignore HTML width attribute
      // and use intrinsic dimensions instead
      if (width == 'auto') {
        return null; // This allows fallback to intrinsic sizing
      }
      CSSLengthValue len = CSSLength.parseLength(width, renderStyle, WIDTH);
      return len.computedValue;
    }
    return null;
  }

  double? get _styleHeight {
    String height = style.getPropertyValue(HEIGHT);
    if (height.isNotEmpty) {
      // For images, when CSS height is explicitly 'auto', we should ignore HTML height attribute
      // and use intrinsic dimensions instead
      if (height == 'auto') {
        return null; // This allows fallback to intrinsic sizing
      }
      CSSLengthValue len = CSSLength.parseLength(height, renderStyle, HEIGHT);
      return len.computedValue;
    }
    return null;
  }

  // Width and height set through attributes.
  double? get _attrWidth {
    if (hasAttribute(WIDTH)) {
      final width = getAttribute(WIDTH);
      if (width != null) {
        return CSSLength.parseLength(width, renderStyle, WIDTH).computedValue;
      }
    }
    return null;
  }

  double? get _attrHeight {
    if (hasAttribute(HEIGHT)) {
      final height = getAttribute(HEIGHT);
      if (height != null) {
        return CSSLength.parseLength(height, renderStyle, HEIGHT).computedValue;
      }
    }
    return null;
  }

  int get width {
    // Width calc priority: style > attr > intrinsic.
    // When CSS width is 'auto', _styleWidth returns null, so we fall back to intrinsic sizing
    final double borderBoxWidth = _styleWidth ?? _attrWidth ?? (naturalWidth > 0 ? naturalWidth.toDouble() : renderStyle.getWidthByAspectRatio());
    return borderBoxWidth.isFinite ? borderBoxWidth.round() : 0;
  }

  int get height {
    // Height calc priority: style > attr > intrinsic.
    // When CSS height is 'auto', _styleHeight returns null, so we fall back to intrinsic sizing
    final double borderBoxHeight = _styleHeight ?? _attrHeight ?? (naturalHeight > 0 ? naturalHeight.toDouble() : renderStyle.getHeightByAspectRatio());
    return borderBoxHeight.isFinite ? borderBoxHeight.round() : 0;
  }

  bool get _isSVGMode {
    String path = _resolvedUri?.path ?? '';
    if ((_resolvedUri?.scheme == 'data' && _resolvedUri!.path.substring(0, 9) == 'image/svg') ||
        path.endsWith('.svg')) {
      return true;
    }
    return false;
  }

  // Read the original image width of loaded image.
  // The getter must be called after image had loaded, otherwise will return 0.
  int naturalWidth = 0;

  // Read the original image height of loaded image.
  // The getter must be called after image had loaded, otherwise will return 0.
  int naturalHeight = 0;

  @override
  bool handleIntersectionChange(IntersectionObserverEntry entry) {
    if (disposed) return false;
    super.handleIntersectionChange(entry);

    // When appear
    if (entry.isIntersecting) {
      _imgLog('[IMG] Intersection visible -> resume stream elem=$hashCode');
      _updateImageDataLazyCompleter?.complete();
      _listenToStream();
    } else {
      _imgLog('[IMG] Intersection hidden -> pause stream elem=$hashCode');
      _stopListeningStream(keepStreamAlive: true);
    }
    return false;
  }

  // To prevent trigger load event more than once.
  bool _loaded = false;

  void _dispatchLoadEvent() {
    dispatchEvent(Event(EVENT_LOAD));
  }

  void _dispatchErrorEvent() {
    dispatchEvent(Event(EVENT_ERROR));
  }

  bool hadTryReload = false;

  void _onImageError(Object exception, StackTrace? stackTrace) async {
    _imgLog('[IMG] _onImageError elem=$hashCode url=$_resolvedUri exception=$exception');
    if (_resolvedUri != null) {
      // Invalidate http cache for this failed image loads.
      await WebFBundle.invalidateCache(_resolvedUri!.toString());
      if (!hadTryReload) {
        _imgLog('[IMG] try force reload after error elem=$hashCode');
        _reloadImage(forceUpdate: true);
        hadTryReload = true;
      }
    }

    debugPrint('$exception\n$stackTrace');
    scheduleMicrotask(_dispatchErrorEvent);
    // Decrement load event delay count after decode.
    ownerDocument.decrementLoadEventDelayCount();
  }

  void _resizeImage() {
    // Check if CSS width is explicitly 'auto' - if so, don't use HTML width attribute
    String cssWidth = style.getPropertyValue(WIDTH);
    if (_styleWidth == null && _attrWidth != null && cssWidth != 'auto') {
      // The intrinsic width of the image in pixels. Must be an integer without a unit.
      renderStyle.width = CSSLengthValue(_attrWidth, CSSLengthType.PX);
    }

    // Check if CSS height is explicitly 'auto' - if so, don't use HTML height attribute
    String cssHeight = style.getPropertyValue(HEIGHT);
    if (_styleHeight == null && _attrHeight != null && cssHeight != 'auto') {
      // The intrinsic height of the image, in pixels. Must be an integer without a unit.
      renderStyle.height = CSSLengthValue(_attrHeight, CSSLengthType.PX);
    }

    renderStyle.intrinsicWidth = naturalWidth.toDouble();
    renderStyle.intrinsicHeight = naturalHeight.toDouble();

    // Respect author-specified aspect-ratio if present; otherwise set intrinsic.
    final String arDecl = style.getPropertyValue(ASPECT_RATIO);
    final bool cssHasAspectRatio = arDecl.isNotEmpty && arDecl.toLowerCase() != 'auto';
    if (!cssHasAspectRatio) {
      if (naturalWidth == 0.0 || naturalHeight == 0.0) {
        renderStyle.aspectRatio = null;
      } else {
        renderStyle.aspectRatio = naturalWidth / naturalHeight;
      }
    }

    // // Force a relayout when image dimensions are available
    // // This ensures the replaced element layout can use the new intrinsic dimensions
    // if (naturalWidth > 0 && naturalHeight > 0) {
    //   renderStyle.markNeedsLayout();
    // }
  }

  @override
  void removeAttribute(String qualifiedName) {
    super.removeAttribute(qualifiedName);
    if (qualifiedName == 'loading') {
      _updateImageDataLazyCompleter?.complete();
    }
  }

  void _stopListeningStream({bool keepStreamAlive = false}) {
    final ImageStream? stream = _cachedImageStream;
    // KeepAlive handle is useful even if we're not currently listening, because
    // the stream may become disposed between pause/resume if no handles exist.
    if (!keepStreamAlive && _completerHandle != null) {
      _completerHandle?.dispose();
      _completerHandle = null;
    } else if (keepStreamAlive && _completerHandle == null && _cachedImageStream?.completer != null) {
      _completerHandle = _cachedImageStream!.completer!.keepAlive();
    }

    // If we want to pause while the stream is still unresolved (no completer yet),
    // removing the listener can cause the completer to be disposed as soon as it
    // arrives. Keep the listener attached in this edge case.
    if (keepStreamAlive && _isListeningStream && stream?.completer == null) {
      _imgLog('[IMG] pause requested but stream unresolved; keep listening elem=$hashCode');
      return;
    }

    if (!_isListeningStream) return;
    _imgLog('[IMG] _stopListeningStream elem=$hashCode keepAlive=$keepStreamAlive');

    // Safely remove listener to prevent accessing disposed native peers
    try {
      _cachedImageStream?.removeListener(_listener);
    } catch (e) {
      // Ignore StateError for disposed native peers during controller disposal
      if (e is StateError && e.message.contains('native peer has been collected')) {
        // This is expected during controller disposal when native resources are freed
        // before Dart objects. Just log in debug mode and continue.
        if (kDebugMode) {
          debugPrint('ImageElement: Native peer disposed before Dart object cleanup: ${e.message}');
        }
      } else {
        // Re-throw other types of errors
        rethrow;
      }
    }
    _isListeningStream = false;
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_cachedImageStream?.key == newStream.key) return;
    _imgLog('[IMG] _updateSourceStream elem=$hashCode oldKey=${_cachedImageStream?.key} newKey=${newStream.key}');
    if (_isListeningStream) {
      try {
        _cachedImageStream?.removeListener(_listener);
      } catch (_) {
        // Best-effort: stream may already be disposed.
      }
    }

    // Stream changed; any keepAlive handle is no longer valid for the new stream.
    _completerHandle?.dispose();
    _completerHandle = null;

    _cachedImageStream = newStream;

    if (_isListeningStream) {
      _cachedImageStream!.addListener(_listener);
    }
  }

  // Invoke when image descriptor has created.
  // We can know the naturalWidth and naturalHeight of current image.
  static void _onImageLoad(Element element, int width, int height, int frameCount) {
    ImageElement self = element as ImageElement;

    self.naturalWidth = width;
    self.naturalHeight = height;
    self._resizeImage();

    if (frameCount > 1) {
      element.state?.requestStateUpdate(ToRepaintBoundaryUpdateReason());
      self._watchAnimatedImageWhenVisible();
    }

    // Decrement load event delay count after decode.
    self.ownerDocument.decrementLoadEventDelayCount();
  }

  // Callback when image are loaded, encoded and available to use.
  // This callback may fire multiple times when image have multiple frames (such as an animated GIF).
  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    _cachedImageInfo = imageInfo;
    _imgLog('[IMG] _handleImageFrame elem=$hashCode size=${imageInfo.image.width}x${imageInfo.image.height} sync=$synchronousCall');

    if (_currentRequest?.state != ImageRequestState.completelyAvailable) {
      _currentRequest?.state = ImageRequestState.completelyAvailable;
    }

    // Option 1: Store pending update if no mounted state exists
    final currentState = state;
    if (currentState != null) {
      currentState.requestStateUpdate();
      _hasPendingImageUpdate = false;
    } else if (_imageState.isNotEmpty) {
      // There are states but none are mounted yet, mark update as pending
      _hasPendingImageUpdate = true;

      // Option 2: Also schedule update for next frame as a fallback
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_hasPendingImageUpdate) {
          state?.requestStateUpdate();
          _hasPendingImageUpdate = false;
        }
      });
      SchedulerBinding.instance.scheduleFrame();
    }

    // Fire the load event at first frame come.
    if (!_loaded) {
      _loaded = true;
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _dispatchLoadEvent();
        _reportLCPCandidate();
        // Report FP first (if not already reported)
        ownerDocument.controller.reportFP();
        // Report FCP when image is first painted
        ownerDocument.controller.reportFCP();
      });
      SchedulerBinding.instance.scheduleFrame();
    }
  }

  // https://html.spec.whatwg.org/multipage/images.html#update-the-image-data
  void _updateImageData() {
    if (_updateImageDataTaskFuture != null) {
      // now has a processing loading, cancel it and restart a new one
      _updateImageDataLazyCompleter?.complete(true); // cancel lazy task
    }
    final taskId = ++_updateImageDataTaskId;
    _imgLog('[IMG] _updateImageData elem=$hashCode taskId=$taskId lazy=$shouldLazyLoading mountedStates=${_imageState.length}');
    final future = _updateImageDataTask(taskId);
    _updateImageDataTaskFuture = future;
    future.catchError((e, stack) {
      debugPrint('$e\n$stack');
    }).whenComplete(() {
      if (taskId == _updateImageDataTaskId) {
        _imgLog('[IMG] _updateImageData complete elem=$hashCode taskId=$taskId');
        _updateImageDataTaskFuture = null;
      }
    });
  }

  Future<void> _updateImageDataTask(int taskId) async {
    if (shouldLazyLoading) {
      final completer = Completer<bool?>();
      _updateImageDataLazyCompleter = completer;

      /// The method is foolproof to avoid IntersectionObserver not working
      Future.delayed(Duration(seconds: 3), () {
        _updateImageDataLazyCompleter?.complete();
      });
      // Wait image is show. If has a error, should run dispose and return;
      final abort = await completer.future;

      if (abort == true || taskId != _updateImageDataTaskId) {
        _imgLog('[IMG] _updateImageDataTask aborted elem=$hashCode taskId=$taskId');
        return;
      }
      // Because the renderObject can changed between rendering, So we need to reassign the value;
      _updateImageDataLazyCompleter = null;
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (taskId != _updateImageDataTaskId) {
        return;
      }

      loadImg() async {
        // Increment load event delay count before decode.
        ownerDocument.incrementLoadEventDelayCount();
        _imgLog('[IMG] begin load elem=$hashCode url=$_resolvedUri');

        // Fast path if URL/data scheme indicates SVG
        if (_isSVGMode) {
          _imgLog('[IMG] detected SVG mode by URL elem=$hashCode');
          _loadSVGImage();
          return;
        }

        // Otherwise prefetch to inspect content-type and sniff as needed
        try {
          final ImageLoadResponse response = await obtainImage(this, _resolvedUri!);
          final String? mime = response.mime?.toLowerCase();

          bool isSvg = false;
          if (mime != null) {
            isSvg = mime.contains('image/svg');
          }
          if (!isSvg) {
            // Sniff bytes for SVG signatures when header is absent/misleading
            final int probeLen = response.bytes.length < 256 ? response.bytes.length : 256;
            try {
              final String head = String.fromCharCodes(response.bytes.sublist(0, probeLen));
              final String headLower = head.toLowerCase();
              if (headLower.contains('<svg') ||
                  (headLower.contains('<?xml') && headLower.contains('svg')) ||
                  headLower.contains('xmlns="http://www.w3.org/2000/svg"')) {
                isSvg = true;
              }
            } catch (_) {}
          }

          if (isSvg) {
            _imgLog('[IMG] prefetch decided SVG elem=$hashCode');
            _applySVGResponse(response);
            // Decrement load event delay here for prefetch SVG path
            ownerDocument.decrementLoadEventDelayCount();
          } else {
            // Hand off to raster pipeline and avoid double-fetch
            _imgLog('[IMG] prefetch decided raster elem=$hashCode');
            _prefetchedImageResponse = response;
            _prefetchedImageUri = _resolvedUri;
            _isSVGImage = false;
            _loadNormalImage();
          }
        } catch (e, stack) {
          debugPrint('$e\n$stack');
          _dispatchErrorEvent();
          // Decrement on failure
          ownerDocument.decrementLoadEventDelayCount();
        }
      }

      if (!ownerDocument.controller.isFlutterAttached) {
        ownerView.registerCallbackOnceForFlutterAttached(() {
          _imgLog('[IMG] Flutter not attached; defer load elem=$hashCode');
          loadImg();
        });
      } else {
        _imgLog('[IMG] Flutter attached; load now elem=$hashCode');
        loadImg();
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void _loadSVGImage() async {
    try {
      ImageLoadResponse response = await obtainImage(this, _resolvedUri!);
      _imgLog('[IMG] _loadSVGImage elem=$hashCode bytes=${response.bytes.length}');
      _applySVGResponse(response);
    } catch (e, stack) {
      debugPrint('$e\n$stack');
      _dispatchErrorEvent();
    } finally {
      // Decrement load event delay count after decode.
      ownerDocument.decrementLoadEventDelayCount();
    }
    return;
  }

  void _applySVGResponse(ImageLoadResponse response) {
    _svgBytes = response.bytes;
    final dims = _tryParseSvgIntrinsicSize(response.bytes);
    if (dims != null) {
      naturalWidth = dims.width;
      naturalHeight = dims.height;
    }
    _resizeImage();
    _isSVGImage = true;
    _imgLog('[IMG] _applySVGResponse elem=$hashCode');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Apply the same fix for SVG images
      final currentState = state;
      if (currentState != null) {
        currentState.requestStateUpdate();
        _hasPendingImageUpdate = false;
      } else if (_imageState.isNotEmpty) {
        // There are states but none are mounted yet, mark update as pending
        _hasPendingImageUpdate = true;

        // Also schedule update for next frame as a fallback
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (_hasPendingImageUpdate) {
            state?.requestStateUpdate();
            _hasPendingImageUpdate = false;
          }
        });
        SchedulerBinding.instance.scheduleFrame();
      }
      // Report FP first (if not already reported)
      ownerDocument.controller.reportFP();
      // Report FCP when SVG image is first painted
      ownerDocument.controller.reportFCP();
    });
    SchedulerBinding.instance.scheduleFrame();

    _dispatchLoadEvent();
  }

  // https://html.spec.whatwg.org/multipage/images.html#decoding-images
  // Create an ImageStream that decodes the obtained image.
  // If imageElement has property size or width/height property on [renderStyle],
  // The image will be encoded into a small size for better rasterization performance.
  void _loadNormalImage() {
    var provider = _currentImageProvider;
    FlutterView? ownerFlutterView = ownerDocument.controller.ownerFlutterView;
    if (provider == null || (provider.boxFit != renderStyle.objectFit || provider.url != _resolvedUri)) {
      // Image should be resized based on different ratio according to object-fit value.
      BoxFit objectFit = renderStyle.objectFit;

      provider = _currentImageProvider = BoxFitImage(
        boxFit: objectFit,
        url: _resolvedUri!,
        targetElementPtr: pointer!,
        loadImage: obtainImage,
        onImageLoad: _onImageLoad,
        contextId: contextId!,
        devicePixelRatio: ownerFlutterView?.devicePixelRatio ?? 2.0,
      );
      _imgLog('[IMG] created provider elem=$hashCode url=$_resolvedUri fit=$objectFit dpr=${ownerFlutterView?.devicePixelRatio}');
    }

    // Try to make sure that this image can be encoded into a smaller size.
    int? cachedWidth = renderStyle.width.value != null && width > 0 && width.isFinite
        ? (width * (ownerFlutterView?.devicePixelRatio ?? 2.0)).toInt()
        : null;
    int? cachedHeight = renderStyle.height.value != null && height > 0 && height.isFinite
        ? (height * (ownerFlutterView?.devicePixelRatio ?? 2.0)).toInt()
        : null;
    _imgLog('[IMG] resolve stream elem=$hashCode cached=${cachedWidth}x$cachedHeight css=${renderStyle.width.value}x${renderStyle.height.value}');

    if (cachedWidth != null && cachedHeight != null) {
      // If a image with the same URL has a fixed size, attempt to remove the previous unsized imageProvider from imageCache.
      BoxFitImageKey previousUnSizedKey = BoxFitImageKey(
        url: _resolvedUri!,
        configuration: ImageConfiguration.empty,
      );
      PaintingBinding.instance.imageCache.evict(previousUnSizedKey, includeLive: true);
      _imgLog('[IMG] evict previous unsized cache elem=$hashCode');
    }

    ImageConfiguration imageConfiguration = _currentImageConfig =
        _shouldScaling && cachedWidth != null && cachedHeight != null
            ? ImageConfiguration(size: Size(cachedWidth.toDouble(), cachedHeight.toDouble()))
            : ImageConfiguration.empty;
    _imgLog('[IMG] imageConfiguration elem=$hashCode config=$imageConfiguration');
    final stream = provider.resolve(imageConfiguration);
    _updateSourceStream(stream);
    _listenToStream();
  }

  // To load the resource, and dispatch load event.
  // https://html.spec.whatwg.org/multipage/images.html#when-to-obtain-images
  static Future<ImageLoadResponse> obtainImage(Element element, Uri url) async {
    var self = element as ImageElement;
    // Use prefetched response if available to avoid duplicate network fetches
    if (self._prefetchedImageResponse != null && self._prefetchedImageUri == url) {
      final ImageLoadResponse resp = self._prefetchedImageResponse!;
      self._prefetchedImageResponse = null; // consume once
      self._prefetchedImageUri = null;
      _imgLog('[IMG] obtainImage use prefetched elem=${self.hashCode} url=$url');
      return resp;
    }
    if (self._prefetchedImageResponse != null && self._prefetchedImageUri != url) {
      _imgLog('[IMG] obtainImage drop stale prefetched elem=${self.hashCode} for=${self._prefetchedImageUri} expect=$url');
      self._prefetchedImageResponse = null;
      self._prefetchedImageUri = null;
    }
    ImageRequest request = self._currentRequest = ImageRequest.fromUri(url);
    // Increment count when request.
    self.ownerDocument.incrementRequestCount();
    _imgLog('[IMG] obtainImage start request elem=${self.hashCode} url=$url');

    final data = await request.obtainImage(self.ownerDocument.controller);

    // Decrement count when response.
    self.ownerDocument.decrementRequestCount();
    _imgLog('[IMG] obtainImage got data elem=${self.hashCode} url=$url bytes=${data.bytes.length} mime=${data.mime}');

    return data;
  }

  /// Anti-shake and throttling
  final _debounce = Debounce(milliseconds: 5);

  void _startLoadNewImage() {
    if (_resolvedUri == null) {
      _imgLog('[IMG] _startLoadNewImage ignored null url elem=$hashCode');
      return;
    }

    _debounce.run(() {
      _imgLog('[IMG] _startLoadNewImage -> _updateImageData elem=$hashCode url=$_resolvedUri');
      _updateImageData();
    });
  }

  // Reload current image when width/height/boxFit changed.
  // If url is changed, please call [_startLoadNewImage] instead.
  void _reloadImage({bool forceUpdate = false}) {
    // Clear the cache and previous loaded provider
    if (forceUpdate) {
      _currentImageProvider = null;
      BoxFitImageKey previousUnSizedKey = BoxFitImageKey(
        url: _resolvedUri!,
        configuration: ImageConfiguration.empty,
      );
      PaintingBinding.instance.imageCache.evict(previousUnSizedKey, includeLive: true);
      _imgLog('[IMG] _reloadImage forceUpdate elem=$hashCode');
    }

    if (_isSVGImage) {
      // In svg mode, we don't need to reload
    } else {
      _debounce.run(() {
        _imgLog('[IMG] _reloadImage -> _updateImageData elem=$hashCode');
        _updateImageData();
      });
    }
  }

  Uri? _resolveResourceUri(String src) {
    String base = ownerDocument.controller.url;
    // Data URLs don't need resolving and `Uri.parse` is stricter than browsers
    // for some characters (notably unescaped quotes) that frequently appear in
    // inline SVG payloads.
    if (src.startsWith('data:')) {
      Uri? normalized = _normalizeDataUri(src);
      if (normalized != null) return normalized;

      final Uri? uri = Uri.tryParse(src);
      if (uri != null) return uri;

      // Try a data-uri aware parser and re-serialize to a normalized form that
      // Dart's Uri parser accepts.
      try {
        final UriData uriData = UriData.parse(src);
        final String normalized = uriData.toString();
        final Uri? normalizedUri = Uri.tryParse(normalized);
        if (normalizedUri != null) return normalizedUri;
      } catch (_) {
      }

      // Try common sanitizations used by inline SVG encoders.
      final String sanitized = src.replaceAll("'", "%27").replaceAll('"', '%22');
      return Uri.tryParse(sanitized);
    }

    try {
      final Uri? srcUri = Uri.tryParse(src);
      if (srcUri == null) return null;
      return ownerDocument.controller.uriParser!.resolve(Uri.parse(base), srcUri);
    } catch (_) {
      // Ignoring the failure of resolving, but to remove the resolved hyperlink.
      return null;
    }
  }

  Uri? _normalizeDataUri(String src) {
    // Handles non-standard forms like `data:image/svg+xml;utf8,%3Csvg...`
    // by decoding the payload first and rebuilding a standards-compliant URI.
    try {
      final int comma = src.indexOf(',');
      if (!src.startsWith('data:') || comma == -1) return null;
      final String header = src.substring('data:'.length, comma);
      String payload = src.substring(comma + 1);
      final String lowerHeader = header.toLowerCase();

      // Only normalize non-base64 inline SVG payloads; other types fall back.
      final bool isBase64 = lowerHeader.contains(';base64');
      final bool isSvg = lowerHeader.startsWith('image/svg+xml');
      if (!isSvg || isBase64) return null;

      // `;utf8` is commonly used to indicate percent-encoded UTF-8 text.
      // Decode the percent-encoded payload to an SVG string, then rebuild.
      if (payload.contains('%')) {
        payload = Uri.decodeComponent(payload);
      }

      final UriData rebuilt = UriData.fromString(
        payload,
        mimeType: 'image/svg+xml',
        encoding: utf8,
      );
      final Uri uri = Uri.parse(rebuilt.toString());

      return uri;
    } catch (e) {
      return null;
    }
  }

  void _stylePropertyChanged(String property, String? original, String present, {String? baseHref}) {
    if (property == WIDTH || property == HEIGHT) {
      // Resize image
      if (_shouldScaling && _resolvedUri != null) {
        _reloadImage();
      } else {
        _resizeImage();
        renderStyle.requestWidgetToRebuild(UpdateRenderReplacedUpdateReason());
      }
    } else if (property == OBJECT_FIT || property == OBJECT_POSITION) {
      renderStyle.requestWidgetToRebuild(UpdateRenderReplacedUpdateReason());
    }
  }

  void _reportLCPCandidate() {
    if (naturalWidth > 0 &&
        naturalHeight > 0 &&
        renderStyle.attachedRenderBoxModel != null &&
        renderStyle.attachedRenderBoxModel!.hasSize &&
        !renderStyle.attachedRenderBoxModel!.size.isEmpty) {
      double visibleArea = renderStyle.attachedRenderBoxModel!.calculateVisibleArea();
      if (visibleArea > 0) {
        ownerDocument.controller.reportLCPCandidate(this, visibleArea);
      }
    }
  }
}

class WebFImage extends flutter.StatefulWidget {
  final ImageElement imageElement;

  const WebFImage(this.imageElement, {super.key});

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return ImageState();
  }
}

class ImageState extends flutter.State<WebFImage> {
  ImageElement get imageElement => widget.imageElement;
  ImageState();

  bool isRepaintBoundary = false;

  void requestStateUpdate([AdapterUpdateReason? reason]) {
    if (reason is ToRepaintBoundaryUpdateReason) {
      isRepaintBoundary = true;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    imageElement._imageState.add(this);
    _imgLog('[IMG] ImageState.initState elem=${imageElement.hashCode} state=$hashCode mounted=$mounted');

    // Option 1: Check if there's a pending update that couldn't be delivered
    if (imageElement._hasPendingImageUpdate && imageElement._cachedImageInfo != null) {
      imageElement._hasPendingImageUpdate = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
      SchedulerBinding.instance.scheduleFrame();
    }
    // Also check if the image has already loaded (original check)
    else if (imageElement._cachedImageInfo != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
      SchedulerBinding.instance.scheduleFrame();
    }
  }

  @override
  void dispose() {
    super.dispose();
    imageElement._imageState.remove(this);
    _imgLog('[IMG] ImageState.dispose elem=${imageElement.hashCode} state=$hashCode');
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    flutter.Widget child;
    if (!imageElement._isSVGImage) {
      // Let the RenderImage size itself from parent constraints so CSS
      // controlled width/height (and intrinsic aspect-ratio adjustments)
      // take effect. Supplying the natural width/height here would override
      // the box size computed by RenderReplaced and break rules like
      // “height: 100px” which should scale width using the intrinsic ratio.
      child = WebFRawImage(
        image: imageElement._cachedImageInfo?.image,
        fit: imageElement.renderStyle.objectFit,
        alignment: imageElement.renderStyle.objectPosition,
      );
    } else {
      final bytes = imageElement._svgBytes!;
      final String svgString = utf8.decode(bytes, allowMalformed: true);
      child = SvgPicture.string(
        svgString,
        fit: imageElement.renderStyle.objectFit,
        alignment: imageElement.renderStyle.objectPosition,
        placeholderBuilder: (_) => const flutter.SizedBox.shrink(),
      );
    }
    if (isRepaintBoundary) {
      child = flutter.RepaintBoundary(child: child);
    }
    return child;
  }
}

// https://html.spec.whatwg.org/multipage/images.html#images-processing-model
enum ImageRequestState {
  // The user agent hasn't obtained any image data, or has obtained some or
  // all of the image data but hasn't yet decoded enough of the image to get
  // the image dimensions.
  unavailable,

  // The user agent has obtained some of the image data and at least the
  // image dimensions are available.
  partiallyAvailable,

  // The user agent has obtained all of the image data and at least the image
  // dimensions are available.
  completelyAvailable,

  // The user agent has obtained all of the image data that it can, but it
  // cannot even decode the image enough to get the image dimensions (e.g.
  // the image is corrupted, or the format is not supported, or no data
  // could be obtained).
  broken,
}

// https://html.spec.whatwg.org/multipage/images.html#image-request
class ImageRequest {
  ImageRequest.fromUri(
    this.currentUri, {
    this.state = ImageRequestState.unavailable,
  });

  /// The request uri.
  Uri currentUri;

  /// Current state of image request.
  ImageRequestState state;

  /// When an image request's state is either partially available or completely available,
  /// the image request is said to be available.
  bool get available =>
      state == ImageRequestState.completelyAvailable || state == ImageRequestState.partiallyAvailable;

  Future<ImageLoadResponse> obtainImage(WebFController controller) async {
    final WebFBundle? preloadedBundle = controller.getPreloadBundleFromUrl(currentUri.toString());
    const Map<String, String> imageHeaders = <String, String>{
      // Avoid advertising AVIF here: some CDNs will content-negotiate to AVIF
      // even for .gif URLs, but AVIF decode support varies by platform/runtime.
      'Accept': 'image/gif,image/png,image/jpeg,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
      // Avoid unsupported encodings (e.g. brotli) for binary image payloads.
      'Accept-Encoding': 'identity',
    };
    // Images should negotiate with an image-centric Accept header; some CDNs will
    // otherwise return HTML or other non-image payloads (leading to "Invalid image data").
    final WebFBundle bundle = preloadedBundle ??
        WebFBundle.fromUrl(
          currentUri.toString(),
          additionalHttpHeaders: imageHeaders,
        );
    await bundle.resolve(baseUrl: controller.url, uriParser: controller.uriParser);
    await bundle.obtainData(controller.view.contextId);

    if (!bundle.isResolved || bundle.data == null) {
      throw FlutterError('Failed to load $currentUri');
    }

    Uint8List data = bundle.data!;

    // Only dispose if it's not a preloaded bundle
    // Preloaded bundles should be reused for multiple requests
    if (preloadedBundle == null) {
      bundle.dispose();
    }

    return ImageLoadResponse(data, mime: bundle.contentType.toString());
  }
}
