import 'dart:typed_data' show Uint8List;

import 'package:cronet_http/cronet_http.dart';
import 'package:dio/dio.dart';
import 'package:webf/webf.dart';

/// A [HttpClientAdapter] for Dio which delegates HTTP requests
/// to the native platform by making use of
/// [cronet_http](https://pub.dev/packages/cronet_http).
class CronetAdapter implements HttpClientAdapter {
  CronetAdapter(
      CronetEngine? engine, {
        bool closeEngine = true,
      }) : _conversionLayer = ConversionLayerAdapter(
    engine == null
        ? CronetClient.defaultCronetEngine()
        : CronetClient.fromCronetEngine(engine, closeEngine: closeEngine),
  );

  final ConversionLayerAdapter _conversionLayer;

  /// The underlying conversion layer adapter.
  ConversionLayerAdapter get adapter => _conversionLayer;

  @override
  void close({bool force = false}) => _conversionLayer.close(force: force);

  @override
  Future<ResponseBody> fetch(
      RequestOptions options,
      Stream<Uint8List>? requestStream,
      Future<dynamic>? cancelFuture,
      ) =>
      _conversionLayer.fetch(options, requestStream, cancelFuture);
}


// else if (Platform.isAndroid) {
//   nativeAdapter = NativeAdapter(createCronetEngine: () {
//     return CronetEngine.build(
//       cacheMode: (kReleaseMode || kProfileMode) ? CacheMode.disk : CacheMode.memory,
//       cacheMaxSize: 24 * 1024 * 1024,
//       enableBrotli: true,
//       enableHttp2: true,
//       enableQuic: true,
//       storagePath: (kReleaseMode || kProfileMode) ? null : cacheDirectory
//     );
//   });
// } else {
//   nativeAdapter = NativeAdapter();
// }
