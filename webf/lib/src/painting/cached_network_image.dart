/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:webf/foundation.dart';

class CachedNetworkImageKey {
  const CachedNetworkImageKey({required this.url, required this.scale});

  final String url;

  final double scale;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CachedNetworkImageKey && other.url == url && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);
}

class CachedNetworkImage extends ImageProvider<CachedNetworkImageKey> {
  const CachedNetworkImage(this.url, {this.scale = 1.0, this.headers, this.contextId});

  final String url;

  final double scale;

  final int? contextId;

  final Map<String, String>? headers;

  // Do not access this field directly; use [_httpClient] instead.
  static final HttpClient _sharedHttpClient = HttpClient();

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null) client = debugNetworkImageHttpClientProvider!();
      return true;
    }());
    return client;
  }

  Future<Uint8List> _getRawImageBytes(CachedNetworkImageKey key, StreamController<ImageChunkEvent> chunkEvents) async {
    HttpCacheController cacheController = HttpCacheController.instance(getOrigin(getEntrypointUri(contextId)));

    Uri uri = Uri.parse(url);
    Uint8List? bytes;

    if (HttpCacheController.mode != HttpCacheMode.NO_CACHE) {
      try {
        HttpCacheObject? cacheObject = await cacheController.getCacheObject(uri);
        bytes = await cacheObject.toBinaryContent();
      } catch (error, stackTrace) {
        print('Error while reading cache, $error\n$stackTrace');
      }
    }

    // Fallback to network
    bytes ??= await _fetchImageBytes(key, chunkEvents, cacheController);

    return bytes;
  }

  Future<Codec> _loadAsync(
      CachedNetworkImageKey key, ImageDecoderCallback decode, StreamController<ImageChunkEvent> chunkEvents) async {
    Uint8List bytes = await _getRawImageBytes(key, chunkEvents);
    ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  Future<Uint8List> _fetchImageBytes(CachedNetworkImageKey key, StreamController<ImageChunkEvent> chunkEvents,
      HttpCacheController cacheController) async {
    try {
      final Uri resolved = Uri.base.resolve(key.url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw NetworkImageLoadException(statusCode: response.statusCode, uri: resolved);

      HttpCacheObject cacheObject =
          HttpCacheObject.fromResponse(key.url, response, (await HttpCacheController.getCacheDirectory()).path);
      cacheController.putObject(resolved, cacheObject);

      HttpClientResponse _response = HttpClientCachedResponse(response, cacheObject);
      Uint8List bytes = await consolidateHttpClientResponseBytes(
        _response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );

      // To maintain compatibility with older versions of WebF, which save Gzip content in caches, we should check the bytes
      // and decode them if they are in gzip format.
      if (isGzip(bytes)) {
        bytes = Uint8List.fromList(gzip.decoder.convert(bytes));
      }

      if (bytes.lengthInBytes == 0) {
        HttpCacheObject cacheObject = await cacheController.getCacheObject(resolved);
        await cacheObject.remove();
        throw Exception('Image from network is an empty file: $resolved');
      }

      return bytes;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  Future<CachedNetworkImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedNetworkImageKey>(CachedNetworkImageKey(url: url, scale: scale));
  }

  @override
  ImageStreamCompleter loadImage(CachedNetworkImageKey key, ImageDecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode, chunkEvents),
        chunkEvents: chunkEvents.stream,
        scale: key.scale,
        informationCollector: () {
          return <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('Image provider', this),
            DiagnosticsProperty<CachedNetworkImageKey>('Image key', key),
          ];
        });
  }
}
