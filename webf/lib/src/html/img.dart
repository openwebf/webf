/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
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
import 'package:webf/widget.dart';
import 'package:webf/src/scheduler/debounce.dart';
import 'package:webf/svg.dart';

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
    if (_currentRequest != null && _currentRequest!.state == _ImageRequestState.broken) return true;
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

  ImageElement([BindingContext? context]) : super(context) {
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
    flutter.Widget child = WebFReplacedElementWidget(webFElement: this, key: key ?? this.key, child: WebFImage(this));
    return WebFEventListener(ownerElement: this, child: child, hasEvent: true);
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    properties['src'] = BindingObjectProperty(getter: () => src, setter: (value) => src = castToType<String>(value));
    properties['loading'] =
        BindingObjectProperty(getter: () => loading, setter: (value) => loading = castToType<String>(value));
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
    style.removeStyleChangeListener(_stylePropertyChanged);
  }

  String get scaling => getAttribute(SCALING) ?? '';

  set scaling(String value) {
    internalSetAttribute(SCALING, value);
  }

  String get src => _resolvedUri?.toString() ?? '';

  set src(String value) {
    internalSetAttribute('src', value);
    final resolvedUri = _resolveResourceUri(value);
    if (_resolvedUri != resolvedUri) {
      _loaded = false;
      _resolvedUri = resolvedUri;
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

    _cachedImageStream?.addListener(_listener);
    _isListeningStream = true;
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

    RenderReplaced? renderReplaced = renderStyle.attachedRenderBoxModel as RenderReplaced?;
    renderReplaced?.removeIntersectionChangeListener(handleIntersectionChange);

    // Stop and remove image stream reference.
    _stopListeningStream();
    _completerHandle?.dispose();
    _completerHandle = null;
    _imageStreamListener = null;
    _cachedImageStream = null;
    _cachedImageInfo = null;
    _currentImageProvider?.evict(configuration: _currentImageConfig ?? ImageConfiguration.empty);
    _currentImageConfig = null;
    _currentImageProvider = null;
    _svgBytes = null;
  }

  // Width and height set through style declaration.
  double? get _styleWidth {
    String width = style.getPropertyValue(WIDTH);
    if (width.isNotEmpty) {
      CSSLengthValue len = CSSLength.parseLength(width, renderStyle, WIDTH);
      return len.computedValue;
    }
    return null;
  }

  double? get _styleHeight {
    String height = style.getPropertyValue(HEIGHT);
    if (height.isNotEmpty) {
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
    final double borderBoxWidth = _styleWidth ?? _attrWidth ?? renderStyle.getWidthByAspectRatio();
    return borderBoxWidth.isFinite ? borderBoxWidth.round() : 0;
  }

  int get height {
    // Height calc priority: style > attr > intrinsic.
    final double borderBoxHeight = _styleHeight ?? _attrHeight ?? renderStyle.getHeightByAspectRatio();
    return borderBoxHeight.isFinite ? borderBoxHeight.round() : 0;
  }

  bool get _isSVGMode => _resolvedUri?.path.endsWith('.svg') ?? false;

  // Read the original image width of loaded image.
  // The getter must be called after image had loaded, otherwise will return 0.
  int naturalWidth = 0;

  // Read the original image height of loaded image.
  // The getter must be called after image had loaded, otherwise will return 0.
  int naturalHeight = 0;

  @override
  void handleIntersectionChange(IntersectionObserverEntry entry) async {
    super.handleIntersectionChange(entry);

    // When appear
    if (entry.isIntersecting) {
      _updateImageDataLazyCompleter?.complete();
      _listenToStream();
    } else {
      _stopListeningStream(keepStreamAlive: true);
    }
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
    if (_resolvedUri != null) {
      // Invalidate http cache for this failed image loads.
      await WebFBundle.invalidateCache(_resolvedUri!.toString());
      if (!hadTryReload) {
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
    if (_styleWidth == null && _attrWidth != null) {
      // The intrinsic width of the image in pixels. Must be an integer without a unit.
      renderStyle.width = CSSLengthValue(_attrWidth, CSSLengthType.PX);
    }
    if (_styleHeight == null && _attrHeight != null) {
      // The intrinsic height of the image, in pixels. Must be an integer without a unit.
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

  @override
  void removeAttribute(String key) {
    super.removeAttribute(key);
    if (key == 'loading') {
      _updateImageDataLazyCompleter?.complete();
    }
  }

  void _stopListeningStream({bool keepStreamAlive = false}) {
    if (!_isListeningStream) return;

    if (keepStreamAlive && _completerHandle == null && _cachedImageStream?.completer != null) {
      _completerHandle = _cachedImageStream!.completer!.keepAlive();
    }
    _cachedImageStream?.removeListener(_listener);
    _isListeningStream = false;
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_cachedImageStream?.key == newStream.key) return;

    if (_isListeningStream) {
      _cachedImageStream?.removeListener(_listener);
    }

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

    // Multi frame image should wrap a repaint boundary for better composite performance.
    if (frameCount > 1 && !self.isRepaintBoundary) {
      self.forceToRepaintBoundary = true;
      self._watchAnimatedImageWhenVisible();
    }

    // Decrement load event delay count after decode.
    self.ownerDocument.decrementLoadEventDelayCount();
  }

  // Callback when image are loaded, encoded and available to use.
  // This callback may fire multiple times when image have multiple frames (such as an animated GIF).
  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    _cachedImageInfo = imageInfo;

    if (_currentRequest?.state != _ImageRequestState.completelyAvailable) {
      _currentRequest?.state = _ImageRequestState.completelyAvailable;
    }

    renderStyle.requestWidgetToRebuild(UpdateRenderReplacedUpdateReason());

    // Fire the load event at first frame come.
    if (!_loaded) {
      _loaded = true;
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _dispatchLoadEvent();
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
    final future = _updateImageDataTask(taskId);
    _updateImageDataTaskFuture = future;
    future.catchError((e) {
      print(e);
    }).whenComplete(() {
      if (taskId == _updateImageDataTaskId) {
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
        return;
      }
      // Because the renderObject can changed between rendering, So we need to reassign the value;
      _updateImageDataLazyCompleter = null;
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (taskId != _updateImageDataTaskId) {
        return;
      }

      _loadImg() {
        // Increment load event delay count before decode.
        ownerDocument.incrementLoadEventDelayCount();

        if (_isSVGMode) {
          _loadSVGImage();
        } else {
          _loadNormalImage();
        }
      }

      if (!ownerDocument.controller.isFlutterAttached) {
        ownerView.registerCallbackOnceForFlutterAttached(() {
          _loadImg();
        });
      } else {
        _loadImg();
      }
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void _loadSVGImage() async {
    try {
      ImageLoadResponse response = await obtainImage(this, _resolvedUri!);
      _svgBytes = response.bytes;
      _resizeImage();
      _isSVGImage = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        renderStyle.requestWidgetToRebuild(UpdateRenderReplacedUpdateReason());
      });
      SchedulerBinding.instance.scheduleFrame();

      _dispatchLoadEvent();
    } catch (e, stack) {
      print('$e\n$stack');
      _dispatchErrorEvent();
    } finally {
      // Decrement load event delay count after decode.
      ownerDocument.decrementLoadEventDelayCount();
    }
    return;
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
    }

    // Try to make sure that this image can be encoded into a smaller size.
    int? cachedWidth = renderStyle.width.value != null && width > 0 && width.isFinite
        ? (width * (ownerFlutterView?.devicePixelRatio ?? 2.0)).toInt()
        : null;
    int? cachedHeight = renderStyle.height.value != null && height > 0 && height.isFinite
        ? (height * (ownerFlutterView?.devicePixelRatio ?? 2.0)).toInt()
        : null;

    if (cachedWidth != null && cachedHeight != null) {
      // If a image with the same URL has a fixed size, attempt to remove the previous unsized imageProvider from imageCache.
      BoxFitImageKey previousUnSizedKey = BoxFitImageKey(
        url: _resolvedUri!,
        configuration: ImageConfiguration.empty,
      );
      PaintingBinding.instance.imageCache.evict(previousUnSizedKey, includeLive: true);
    }

    ImageConfiguration imageConfiguration = _currentImageConfig =
        _shouldScaling && cachedWidth != null && cachedHeight != null
            ? ImageConfiguration(size: Size(cachedWidth.toDouble(), cachedHeight.toDouble()))
            : ImageConfiguration.empty;
    final stream = provider.resolve(imageConfiguration);
    _updateSourceStream(stream);
    _listenToStream();
  }

  // To load the resource, and dispatch load event.
  // https://html.spec.whatwg.org/multipage/images.html#when-to-obtain-images
  static Future<ImageLoadResponse> obtainImage(Element element, Uri url) async {
    var self = element as ImageElement;
    ImageRequest request = self._currentRequest = ImageRequest.fromUri(url);
    // Increment count when request.
    self.ownerDocument.incrementRequestCount();

    final data = await request.obtainImage(self.ownerDocument.controller);

    // Decrement count when response.
    self.ownerDocument.decrementRequestCount();

    return data;
  }

  /// Anti-shake and throttling
  final _debounce = Debounce(milliseconds: 5);

  void _startLoadNewImage() {
    if (_resolvedUri == null) {
      return;
    }

    _debounce.run(() {
      _updateImageData();
    });
  }

  // Reload current image when width/height/boxFit changed.
  // If url is changed, please call [_startLoadNewImage] instead.
  void _reloadImage({ bool forceUpdate = false }) {

    // Clear the cache and previous loaded provider
    if (forceUpdate) {
      _currentImageProvider = null;
      BoxFitImageKey previousUnSizedKey = BoxFitImageKey(
        url: _resolvedUri!,
        configuration: ImageConfiguration.empty,
      );
      PaintingBinding.instance.imageCache.evict(previousUnSizedKey, includeLive: true);
    }


    if (_isSVGMode) {
      // In svg mode, we don't need to reload
    } else {
      _debounce.run(() {
        _updateImageData();
      });
    }
  }

  Uri? _resolveResourceUri(String src) {
    String base = ownerDocument.controller.url;
    try {
      return ownerDocument.controller.uriParser!.resolve(Uri.parse(base), Uri.parse(src));
    } catch (_) {
      // Ignoring the failure of resolving, but to remove the resolved hyperlink.
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
}

class WebFImage extends flutter.StatefulWidget {
  final ImageElement imageElement;

  WebFImage(this.imageElement, {flutter.Key? key}) : super(key: key);

  @override
  flutter.State<flutter.StatefulWidget> createState() {
    return _ImageState(imageElement);
  }
}

class _ImageState extends flutter.State<WebFImage> {
  final ImageElement imageElement;

  _ImageState(this.imageElement);

  @override
  flutter.Widget build(flutter.BuildContext context) {
    flutter.Widget child;
    if (!imageElement._isSVGImage) {
      child = WebFRawImage(
          image: imageElement._cachedImageInfo?.image,
          width: imageElement.naturalWidth.toDouble(),
          fit: imageElement.renderStyle.objectFit,
          alignment: imageElement.renderStyle.objectPosition,
          height: imageElement.naturalHeight.toDouble());
    } else {
      child = SvgPicture.memory(
        imageElement._svgBytes!,
      );
    }

    return child;
  }
}

// https://html.spec.whatwg.org/multipage/images.html#images-processing-model
enum _ImageRequestState {
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
    this.state = _ImageRequestState.unavailable,
  });

  /// The request uri.
  Uri currentUri;

  /// Current state of image request.
  _ImageRequestState state;

  /// When an image request's state is either partially available or completely available,
  /// the image request is said to be available.
  bool get available =>
      state == _ImageRequestState.completelyAvailable || state == _ImageRequestState.partiallyAvailable;

  Future<ImageLoadResponse> obtainImage(WebFController controller) async {
    final WebFBundle? preloadedBundle = controller.getPreloadBundleFromUrl(currentUri.toString());
    final WebFBundle bundle = preloadedBundle ?? WebFBundle.fromUrl(currentUri.toString());
    await bundle.resolve(baseUrl: controller.url, uriParser: controller.uriParser);
    await bundle.obtainData(controller.view.contextId);

    if (!bundle.isResolved) {
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
