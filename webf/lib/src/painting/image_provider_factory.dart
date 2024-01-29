/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// defines the types of supported image source.
enum ImageType {
  /// Network image source with memory cache.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [CachedNetworkImage].
  /// will be called when [url] startsWith '//' ,'http://'，'https://'.
  /// [param] will be [bool], the value is true.
  cached,

  /// Network image source.
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [NetworkImage]
  /// will be called when [url] startsWith '//' ,'http://'，'https://'
  /// [param] will be [bool], the value is false.
  network,

  /// File path image source
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [FileImage]
  /// will be called when [url] startsWith 'file://'
  /// [param] will be type [File]
  file,

  /// Raw image data source
  ///
  /// NOTE:
  /// default ImageProviderFactory implementation [MemoryImage]
  /// will be called when [url] startsWith 'data://'
  /// [param]  will be [Uint8List], value is the content part of the data URI as bytes,
  /// which is converted by [UriData.contentAsBytes].
  dataUrl,

  /// Blob image source which created by URL.createObjectURL()
  ///
  blob,

  /// Assets image source.
  assets
}

class WebFResizeImage extends ResizeImage {
  WebFResizeImage(
    ImageProvider<Object> imageProvider, {
    int? width,
    int? height,
    this.objectFit,
  }) : super(imageProvider, width: width, height: height);

  BoxFit? objectFit;

  static ImageProvider<Object> resizeIfNeeded(
      int? cacheWidth, int? cacheHeight, BoxFit? objectFit, ImageProvider provider) {
    if (cacheWidth != null || cacheHeight != null) {
      return WebFResizeImage(provider, width: cacheWidth, height: cacheHeight, objectFit: objectFit);
    }
    return provider;
  }

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream, key, ImageErrorListener handleError) {
    // This is an unusual edge case where someone has told us that they found
    // the image we want before getting to this method. We should avoid calling
    // load again, but still update the image cache with LRU information.
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
    if (completer != null) {
      stream.setCompleter(completer);
    }
  }
}
