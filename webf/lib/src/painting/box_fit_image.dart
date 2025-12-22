/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
// Use flutter_svg parse API via the main entrypoint
import 'package:flutter_svg/flutter_svg.dart' as svg;

class BoxFitImageKey {
  const BoxFitImageKey({
    required this.url,
    this.configuration,
  });

  final Uri url;
  final ImageConfiguration? configuration;

  @override
  bool operator ==(Object other) {
    return other is BoxFitImageKey && other.url == url && other.configuration == configuration;
  }

  @override
  int get hashCode => Object.hash(configuration, url);

  @override
  String toString() => 'BoxFitImageKey($url, $configuration)';
}

class ImageLoadResponse {
  final Uint8List bytes;
  final String? mime;

  ImageLoadResponse(this.bytes, {this.mime});
}

typedef LoadImage = Future<ImageLoadResponse> Function(Element ownerElement, Uri url);
typedef OnImageLoad = void Function(Element ownerElement, int naturalWidth, int naturalHeight, int frameCount);

class BoxFitImage extends ImageProvider<BoxFitImageKey> {
  // Static cache to prevent duplicate loads of the same URL
  static final Map<String, Future<Codec>> _loadingFutures = {};

  BoxFitImage({
    required LoadImage loadImage,
    required this.url,
    required this.boxFit,
    required this.devicePixelRatio,
    required this.contextId,
    required this.targetElementPtr,
    this.onImageLoad,
  }) : _loadImage = loadImage;

  final LoadImage _loadImage;
  final Uri url;
  final BoxFit boxFit;
  final OnImageLoad? onImageLoad;
  final double devicePixelRatio;
  final double contextId;
  final ffi.Pointer<NativeBindingObject> targetElementPtr;

  @override
  Future<BoxFitImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<BoxFitImageKey>(BoxFitImageKey(
      url: url,
      configuration: configuration,
    ));
  }

  Future<Codec> _loadAsync(BoxFitImageKey key) async {
    // Use URL as the deduplication key since that's what matters for network requests
    final String dedupeKey = url.toString();

    // Check if this URL is already being loaded
    final existingFuture = _loadingFutures[dedupeKey];
    if (existingFuture != null) {
      // Reuse the existing future
      return existingFuture;
    }

    // Create a new future for this URL
    final future = _performLoad(key);
    _loadingFutures[dedupeKey] = future;

    // Clean up when done (whether success or failure)
    future.whenComplete(() {
      _loadingFutures.remove(dedupeKey);
    });

    return future;
  }

  Future<Codec> _performLoad(BoxFitImageKey key) async {
    ImageLoadResponse response;
    WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
    try {
      if (controller == null) {
        throw StateError('Could not load the image, controller: $contextId were not exist');
      }
      response = await _loadImage(controller.view.getBindingObject<Element>(targetElementPtr)!, url);

      Uint8List bytes = response.bytes;
      if (bytes.isEmpty) {
        PaintingBinding.instance.imageCache.evict(key);
        throw StateError('Unable to read data');
      }

      // Some servers incorrectly apply compression to already-compressed image
      // payloads (e.g. GIF) or return gzipped bodies without the client layer
      // transparently inflating them. Try a cheap gunzip pass when the magic
      // header is present.
      final Uint8List? gunzipped = _tryGunzip(bytes);
      if (gunzipped != null && gunzipped.isNotEmpty) {
        bytes = gunzipped;
      }

      // Detect SVG via mime or sniff
      final bool isSvg = _isSvgMime(response.mime) || _sniffSvg(bytes);
      final bool isGif = !isSvg && (_isGifMime(response.mime) || _sniffGif(bytes));

      int? preferredWidth;
      int? preferredHeight;
      int? svgPreferredWidth;
      int? svgPreferredHeight;

      // For SVG rasterization, prefer configuration size in physical pixels when available.
      if (isSvg && key.configuration?.size != null) {
        svgPreferredWidth = (key.configuration!.size!.width * devicePixelRatio).round();
        svgPreferredHeight = (key.configuration!.size!.height * devicePixelRatio).round();
      }

      // For raster images, compute preferred size for codec scaling
      if (key.configuration?.size != null && !isSvg) {
        preferredWidth = (key.configuration!.size!.width * devicePixelRatio).toInt();
        preferredHeight = (key.configuration!.size!.height * devicePixelRatio).toInt();
      }

      late final _DecodedImage decoded;
      try {
        decoded = await _decodeImageBytes(
          bytes,
          isSvg: isSvg,
          isGif: isGif,
          boxFit: boxFit,
          // For SVG, we rasterize to a target size; avoid scaling again.
          preferredWidth: isSvg ? null : preferredWidth,
          preferredHeight: isSvg ? null : preferredHeight,
          svgPreferredWidth: svgPreferredWidth,
          svgPreferredHeight: svgPreferredHeight,
        );
      } catch (e) {
        throw FlutterError('Failed to decode image $url (mime=${response.mime}, bytes=${bytes.length}): $e');
      }

      // Fire image on load after codec created.
      scheduleMicrotask(() {
        if (!controller.disposed && onImageLoad != null && controller.view.getBindingObject(targetElementPtr) != null) {
          onImageLoad!(
            controller.view.getBindingObject<Element>(targetElementPtr)!,
            decoded.naturalWidth,
            decoded.naturalHeight,
            decoded.codec.frameCount,
          );
        }
        _imageStreamCompleter!.setDimension(Dimension(decoded.naturalWidth, decoded.naturalHeight, decoded.codec.frameCount));
      });
      return decoded.codec;
    } on FlutterError {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } catch (_) {
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    }
  }


  bool _isSvgMime(String? mime) {
    final m = mime?.toLowerCase();
    if (m == null) return false;
    return m.contains('image/svg');
  }

  bool _isGifMime(String? mime) {
    final m = mime?.toLowerCase();
    if (m == null) return false;
    return m.contains('image/gif');
  }

  bool _sniffSvg(Uint8List bytes) {
    try {
      final int probeLen = bytes.length < 512 ? bytes.length : 512;
      final String head = String.fromCharCodes(bytes.sublist(0, probeLen)).toLowerCase();
      return head.contains('<svg') ||
          (head.contains('<?xml') && head.contains('svg')) ||
          head.contains('xmlns="http://www.w3.org/2000/svg"');
    } catch (_) {
      return false;
    }
  }

  static bool _sniffGif(Uint8List bytes) {
    if (bytes.length < 10) return false;
    // GIF header: "GIF87a" or "GIF89a"
    return bytes[0] == 0x47 && // G
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x38 && // 8
        (bytes[4] == 0x37 || bytes[4] == 0x39) && // 7 or 9
        bytes[5] == 0x61; // a
  }

  static ({int width, int height})? _tryParseGifDimensions(Uint8List bytes) {
    if (!_sniffGif(bytes)) return null;
    if (bytes.length < 10) return null;
    final int width = bytes[6] | (bytes[7] << 8);
    final int height = bytes[8] | (bytes[9] << 8);
    if (width <= 0 || height <= 0) return null;
    return (width: width, height: height);
  }

  static Uint8List? _tryGunzip(Uint8List bytes) {
    if (bytes.length < 2) return null;
    // gzip magic header: 1F 8B
    if (bytes[0] != 0x1f || bytes[1] != 0x8b) return null;
    try {
      final List<int> decoded = GZipDecoder().decodeBytes(bytes, verify: true);
      return Uint8List.fromList(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _rasterizeSvgToPng(
    Uint8List svgBytes, {
    int? preferredWidth,
    int? preferredHeight,
    BoxFit? boxFit,
  }) async {
    // Use flutter_svg BytesLoader + vector_graphics utilities to decode
    final svg.SvgBytesLoader loader = svg.SvgBytesLoader(svgBytes);
    final svg.PictureInfo pictureInfo = await svg.vg.loadPicture(loader, null, clipViewbox: true);

    // Intrinsic size from the vector graphic
    final Size intrinsic = pictureInfo.size;
    int targetWidth;
    int targetHeight;

    if (preferredWidth != null && preferredHeight != null && !intrinsic.isEmpty) {
      // Respect aspect ratio roughly according to boxFit
      final double iw = intrinsic.width;
      final double ih = intrinsic.height;
      double tw = preferredWidth.toDouble();
      double th = preferredHeight.toDouble();
      if (boxFit == BoxFit.contain) {
        final double scale = (tw / iw).clamp(0.0, double.infinity);
        final double scaleAlt = (th / ih).clamp(0.0, double.infinity);
        final double s = scale < scaleAlt ? scale : scaleAlt;
        tw = (iw * s).clamp(1.0, double.infinity);
        th = (ih * s).clamp(1.0, double.infinity);
      } else if (boxFit == BoxFit.cover) {
        final double scale = (tw / iw).clamp(0.0, double.infinity);
        final double scaleAlt = (th / ih).clamp(0.0, double.infinity);
        final double s = scale > scaleAlt ? scale : scaleAlt;
        tw = (iw * s).clamp(1.0, double.infinity);
        th = (ih * s).clamp(1.0, double.infinity);
      } else if (boxFit == BoxFit.none) {
        tw = iw;
        th = ih;
      }
      targetWidth = tw.round();
      targetHeight = th.round();
    } else if (preferredWidth != null && preferredHeight == null && !intrinsic.isEmpty) {
      final double iw = intrinsic.width;
      final double ih = intrinsic.height;
      final double ar = iw > 0 && ih > 0 ? iw / ih : 1.0;
      targetWidth = preferredWidth;
      targetHeight = (preferredWidth / ar).round();
    } else if (preferredHeight != null && preferredWidth == null && !intrinsic.isEmpty) {
      final double iw = intrinsic.width;
      final double ih = intrinsic.height;
      final double ar = iw > 0 && ih > 0 ? iw / ih : 1.0;
      targetHeight = preferredHeight;
      targetWidth = (preferredHeight * ar).round();
    } else if (!intrinsic.isEmpty) {
      targetWidth = intrinsic.width.round();
      targetHeight = intrinsic.height.round();
    } else {
      // Fallback if no intrinsic size available
      targetWidth = preferredWidth ?? 100;
      targetHeight = preferredHeight ?? 100;
    }

    // Ensure minimum size
    if (targetWidth <= 0) targetWidth = 1;
    if (targetHeight <= 0) targetHeight = 1;

    final Image image = await pictureInfo.picture.toImage(targetWidth, targetHeight);
    final ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to rasterize SVG to PNG');
    }
    return byteData.buffer.asUint8List();
  }

  DimensionedMultiFrameImageStreamCompleter? _imageStreamCompleter;

  @override
  ImageStreamCompleter loadImage(BoxFitImageKey key, ImageDecoderCallback decode) {
    // Create a completer that will load the image
    return _imageStreamCompleter = DimensionedMultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: 1.0,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<BoxFitImageKey>('Image key', key),
        ];
      },
    );
  }

  @override
  void resolveStreamForKey(
      ImageConfiguration configuration, ImageStream stream, BoxFitImageKey key, ImageErrorListener handleError) {
    if (stream.completer != null) {
      final ImageStreamCompleter? completer = PaintingBinding.instance.imageCache.putIfAbsent(
        key,
        () => stream.completer!,
        onError: handleError,
      );
      assert(identical(completer, stream.completer));
      return;
    }
    final ImageStreamCompleter? completer = PaintingBinding.instance.imageCache.putIfAbsent(
      key,
      () => loadImage(key, PaintingBinding.instance.instantiateImageCodecWithSize),
      onError: handleError,
    );
    if (_imageStreamCompleter == null &&
        completer is DimensionedMultiFrameImageStreamCompleter &&
        onImageLoad != null) {
      completer.dimension.then((Dimension dimension) {
        WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
        if (controller != null) {
          onImageLoad!(controller.view.getBindingObject<Element>(targetElementPtr)!, dimension.width, dimension.height,
              dimension.frameCount);
        }
      });
    }
    if (completer != null) {
      stream.setCompleter(completer);
    }
  }

  static Future<Codec> _instantiateImageCodec(
    ImageDescriptor descriptor, {
    BoxFit boxFit = BoxFit.none,
    int? preferredWidth,
    int? preferredHeight,
  }) async {
    final int naturalWidth = descriptor.width;
    final int naturalHeight = descriptor.height;

    final ({int? width, int? height}) targetSize = _calculateTargetSize(
      naturalWidth: naturalWidth,
      naturalHeight: naturalHeight,
      boxFit: boxFit,
      preferredWidth: preferredWidth,
      preferredHeight: preferredHeight,
    );

    final Codec rawCodec = await descriptor.instantiateCodec(
      targetWidth: targetSize.width,
      targetHeight: targetSize.height,
    );

    // Wrap the underlying codec so that dispose() is resilient to races where
    // the native image peer has already been collected (e.g. during aggressive
    // teardown of WebF controllers while animated images are still decoding).
    return _SafeImageCodec(rawCodec);
  }

  static ({int? width, int? height}) _calculateTargetSize({
    required int naturalWidth,
    required int naturalHeight,
    required BoxFit boxFit,
    required int? preferredWidth,
    required int? preferredHeight,
  }) {
    int? targetWidth;
    int? targetHeight;

    // Image will be resized according to its aspect radio if object-fit is not fill.
    // https://www.w3.org/TR/css-images-3/#propdef-object-fit
    if (preferredWidth != null && preferredHeight != null) {
      // When targetWidth or targetHeight is not set at the same time,
      // image will be resized according to its aspect radio.
      // https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/box_fit.dart#L152
      if (boxFit == BoxFit.contain) {
        if (preferredWidth / preferredHeight > naturalWidth / naturalHeight) {
          targetHeight = preferredHeight;
        } else {
          targetWidth = preferredWidth;
        }

        // Resized image should maintain its intrinsic aspect radio event if object-fit is fill
        // which behaves just like object-fit cover otherwise the cached resized image with
        // distorted aspect ratio will not work when object-fit changes to not fill.
      } else if (boxFit == BoxFit.fill || boxFit == BoxFit.cover) {
        if (preferredWidth / preferredHeight > naturalWidth / naturalHeight) {
          targetWidth = preferredWidth;
        } else {
          targetHeight = preferredHeight;
        }

        // Image should maintain its aspect radio and not resized if object-fit is none.
      } else if (boxFit == BoxFit.none) {
        targetWidth = naturalWidth;
        targetHeight = naturalHeight;

        // If image size is smaller than its natural size when object-fit is contain,
        // scale-down is parsed as none, otherwise parsed as contain.
      } else if (boxFit == BoxFit.scaleDown) {
        if (preferredWidth / preferredHeight > naturalWidth / naturalHeight) {
          if (preferredHeight > naturalHeight) {
            targetWidth = naturalWidth;
            targetHeight = naturalHeight;
          } else {
            targetHeight = preferredHeight;
          }
        } else {
          if (preferredWidth > naturalWidth) {
            targetWidth = naturalWidth;
            targetHeight = naturalHeight;
          } else {
            targetWidth = preferredWidth;
          }
        }
      }
    } else {
      targetWidth = preferredWidth;
      targetHeight = preferredHeight;
    }

    // Resize image size should not be larger than its natural size.
    if (targetWidth != null && targetWidth > naturalWidth) {
      targetWidth = naturalWidth;
    }
    if (targetHeight != null && targetHeight > naturalHeight) {
      targetHeight = naturalHeight;
    }

    return (width: targetWidth, height: targetHeight);
  }

  Future<_DecodedImage> _decodeImageBytes(
    Uint8List bytes, {
    required bool isSvg,
    required bool isGif,
    required BoxFit boxFit,
    required int? preferredWidth,
    required int? preferredHeight,
    required int? svgPreferredWidth,
    required int? svgPreferredHeight,
  }) async {
    if (isSvg) {
      final Uint8List rasterPng = await _rasterizeSvgToPng(
        bytes,
        preferredWidth: svgPreferredWidth,
        preferredHeight: svgPreferredHeight,
        boxFit: boxFit,
      );
      final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(rasterPng);
      try {
        final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);
        try {
          final Codec codec = await _instantiateImageCodec(descriptor, boxFit: boxFit);
          final Codec managed = _ResourceDisposingCodec(
            codec,
            onDispose: () {
              descriptor.dispose();
              buffer.dispose();
            },
          );
          return _DecodedImage(codec: managed, naturalWidth: descriptor.width, naturalHeight: descriptor.height);
        } catch (_) {
          descriptor.dispose();
          rethrow;
        }
      } catch (_) {
        // Fallback to engine decode if ImageDescriptor is unavailable in this runtime.
        buffer.dispose();
        return _decodeViaInstantiateCodec(
          rasterPng,
          boxFit: boxFit,
          preferredWidth: null,
          preferredHeight: null,
        );
      }
    }

    // GIF decoding: Some engine builds don't support GIF via ImageDescriptor.encoded,
    // but do support it via instantiateImageCodec().
    if (isGif) {
      final ({int width, int height})? dims = _tryParseGifDimensions(bytes);
      final int? naturalWidth = dims?.width;
      final int? naturalHeight = dims?.height;
      if (naturalWidth != null && naturalHeight != null) {
        final ({int? width, int? height}) targetSize = _calculateTargetSize(
          naturalWidth: naturalWidth,
          naturalHeight: naturalHeight,
          boxFit: boxFit,
          preferredWidth: preferredWidth,
          preferredHeight: preferredHeight,
        );
        final Codec rawCodec = await instantiateImageCodec(
          bytes,
          targetWidth: targetSize.width,
          targetHeight: targetSize.height,
        );
        return _DecodedImage(codec: _SafeImageCodec(rawCodec), naturalWidth: naturalWidth, naturalHeight: naturalHeight);
      }
      // If header parse fails, fall back to codec priming.
      final Codec rawCodec = await instantiateImageCodec(bytes);
      final _PrimedCodec primed = await _PrimedCodec.prime(_SafeImageCodec(rawCodec));
      return _DecodedImage(
        codec: primed.codec,
        naturalWidth: primed.naturalWidth,
        naturalHeight: primed.naturalHeight,
      );
    }

    // Default path: prefer ImageDescriptor for fast header decode and scaling.
    final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(bytes);
    try {
      final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);
      try {
        final Codec codec = await _instantiateImageCodec(
          descriptor,
          boxFit: boxFit,
          preferredWidth: preferredWidth,
          preferredHeight: preferredHeight,
        );
        final Codec managed = _ResourceDisposingCodec(
          codec,
          onDispose: () {
            descriptor.dispose();
            buffer.dispose();
          },
        );
        return _DecodedImage(codec: managed, naturalWidth: descriptor.width, naturalHeight: descriptor.height);
      } catch (_) {
        descriptor.dispose();
        rethrow;
      }
    } catch (_) {
      // Fallback: decode via engine and infer dimensions from the first frame.
      // This also covers runtimes where ImageDescriptor.encoded doesn't support
      // certain formats (notably GIF on some platforms).
      buffer.dispose();
      return _decodeViaInstantiateCodec(
        bytes,
        boxFit: boxFit,
        preferredWidth: preferredWidth,
        preferredHeight: preferredHeight,
      );
    }
  }

  Future<_DecodedImage> _decodeViaInstantiateCodec(
    Uint8List bytes, {
    required BoxFit boxFit,
    required int? preferredWidth,
    required int? preferredHeight,
  }) async {
    final Codec rawCodec = await instantiateImageCodec(bytes);
    final _PrimedCodec primed = await _PrimedCodec.prime(_SafeImageCodec(rawCodec));

    final int naturalWidth = primed.naturalWidth;
    final int naturalHeight = primed.naturalHeight;

    if (preferredWidth == null && preferredHeight == null) {
      return _DecodedImage(codec: primed.codec, naturalWidth: naturalWidth, naturalHeight: naturalHeight);
    }

    final ({int? width, int? height}) targetSize = _calculateTargetSize(
      naturalWidth: naturalWidth,
      naturalHeight: naturalHeight,
      boxFit: boxFit,
      preferredWidth: preferredWidth,
      preferredHeight: preferredHeight,
    );

    final int resolvedTargetWidth = targetSize.width ?? naturalWidth;
    final int resolvedTargetHeight = targetSize.height ?? naturalHeight;
    final bool needsResize = resolvedTargetWidth != naturalWidth || resolvedTargetHeight != naturalHeight;
    if (!needsResize) {
      return _DecodedImage(codec: primed.codec, naturalWidth: naturalWidth, naturalHeight: naturalHeight);
    }

    // Avoid keeping two codecs alive at the same time.
    primed.codec.dispose();

    final Codec resizedCodec = await instantiateImageCodec(
      bytes,
      targetWidth: targetSize.width,
      targetHeight: targetSize.height,
    );
    final _PrimedCodec primedResized = await _PrimedCodec.prime(_SafeImageCodec(resizedCodec));
    // Keep natural size as the original dimensions.
    return _DecodedImage(codec: primedResized.codec, naturalWidth: naturalWidth, naturalHeight: naturalHeight);
  }
}

class _DecodedImage {
  const _DecodedImage({
    required this.codec,
    required this.naturalWidth,
    required this.naturalHeight,
  });

  final Codec codec;
  final int naturalWidth;
  final int naturalHeight;
}

class _ResourceDisposingCodec implements Codec {
  _ResourceDisposingCodec(this._inner, {required this.onDispose});

  final Codec _inner;
  final VoidCallback onDispose;
  bool _resourcesDisposed = false;

  @override
  int get frameCount => _inner.frameCount;

  @override
  int get repetitionCount => _inner.repetitionCount;

  @override
  Future<FrameInfo> getNextFrame() => _inner.getNextFrame();

  @override
  void dispose() {
    try {
      _inner.dispose();
    } finally {
      if (!_resourcesDisposed) {
        _resourcesDisposed = true;
        try {
          onDispose();
        } catch (_) {
          // Best-effort cleanup.
        }
      }
    }
  }

  @override
  String toString() => _inner.toString();
}

class _PrimedCodec {
  const _PrimedCodec({
    required this.codec,
    required this.naturalWidth,
    required this.naturalHeight,
  });

  final Codec codec;
  final int naturalWidth;
  final int naturalHeight;

  static Future<_PrimedCodec> prime(Codec codec) async {
    final FrameInfo firstFrame = await codec.getNextFrame();
    final int width = firstFrame.image.width;
    final int height = firstFrame.image.height;
    return _PrimedCodec(
      codec: _FirstFrameCachingCodec(codec, firstFrame),
      naturalWidth: width,
      naturalHeight: height,
    );
  }
}

class _FirstFrameCachingCodec implements Codec {
  _FirstFrameCachingCodec(this._inner, this._firstFrame);

  final Codec _inner;
  final FrameInfo _firstFrame;
  bool _returnedFirst = false;

  @override
  int get frameCount => _inner.frameCount;

  @override
  int get repetitionCount => _inner.repetitionCount;

  @override
  Future<FrameInfo> getNextFrame() {
    if (!_returnedFirst) {
      _returnedFirst = true;
      return SynchronousFuture<FrameInfo>(_firstFrame);
    }
    return _inner.getNextFrame();
  }

  @override
  void dispose() => _inner.dispose();

  @override
  String toString() => _inner.toString();
}

@visibleForTesting
Future<({Codec codec, int naturalWidth, int naturalHeight})> debugDecodeGifForTest(
  Uint8List bytes, {
  BoxFit boxFit = BoxFit.none,
  int? preferredWidth,
  int? preferredHeight,
}) async {
  final ({int width, int height})? dims = BoxFitImage._tryParseGifDimensions(bytes);
  if (dims == null) {
    throw ArgumentError('Bytes are not a valid GIF (or missing header dimensions).');
  }
  final ({int? width, int? height}) targetSize = BoxFitImage._calculateTargetSize(
    naturalWidth: dims.width,
    naturalHeight: dims.height,
    boxFit: boxFit,
    preferredWidth: preferredWidth,
    preferredHeight: preferredHeight,
  );
  final Codec rawCodec = await instantiateImageCodec(
    bytes,
    targetWidth: targetSize.width,
    targetHeight: targetSize.height,
  );
  return (codec: _SafeImageCodec(rawCodec), naturalWidth: dims.width, naturalHeight: dims.height);
}

// The [MultiFrameImageStreamCompleter] that saved the natural dimention of image.
class DimensionedMultiFrameImageStreamCompleter extends MultiFrameImageStreamCompleter {
  DimensionedMultiFrameImageStreamCompleter({
    required super.codec,
    required super.scale,
    super.debugLabel,
    super.chunkEvents,
    super.informationCollector,
  });

  final List<Completer<Dimension>> _dimensionCompleter = [];
  Dimension? _dimension;

  Future<Dimension> get dimension async {
    if (_dimension != null) {
      return _dimension!;
    } else {
      Completer<Dimension> completer = Completer<Dimension>();
      _dimensionCompleter.add(completer);
      return completer.future;
    }
  }

  void setDimension(Dimension dimension) {
    _dimension = dimension;
    if (_dimensionCompleter.isNotEmpty) {
      for (var completer in _dimensionCompleter) {
        completer.complete(dimension);
      }
      _dimensionCompleter.clear();
    }
  }
}

// Wrapper around a Codec that swallows the specific StateError thrown when the
// underlying native peer has already been collected. This can happen when the
// engine disposes native image/codec resources during controller teardown
// while Flutter's MultiFrameImageStreamCompleter is still trying to dispose
// or clean up its Codec.
class _SafeImageCodec implements Codec {
  _SafeImageCodec(this._inner);

  final Codec _inner;

  @override
  int get frameCount => _inner.frameCount;

  @override
  int get repetitionCount => _inner.repetitionCount;

  @override
  Future<FrameInfo> getNextFrame() {
    // Delegate directly; errors from getNextFrame are delivered via the
    // returned Future, which MultiFrameImageStreamCompleter already routes
    // through its error handling. We only need to guard dispose().
    return _inner.getNextFrame();
  }

  @override
  void dispose() {
    try {
      _inner.dispose();
    } catch (e) {
      // Ignore StateError for disposed native peers during controller disposal.
      if (e is StateError && e.message.contains('native peer has been collected')) {
        if (kDebugMode) {
          debugPrint('SafeImageCodec: Native peer disposed before codec.dispose: ${e.message}');
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  String toString() => _inner.toString();
}
