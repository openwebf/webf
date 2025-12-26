/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webf/foundation.dart';
import 'package:webf/module.dart';
import 'package:webf/bridge.dart';
import 'package:webf/launcher.dart';
import 'package:dio/dio.dart';

const String DEFAULT_URL = 'about:blank';
const String UTF_8 = 'utf-8';

final ContentType _cssContentType = ContentType('text', 'css', charset: UTF_8);
// MIME types suits JavaScript: https://mathiasbynens.be/demo/javascript-mime-type
final ContentType javascriptContentType = ContentType('text', 'javascript', charset: UTF_8);
final ContentType htmlContentType = ContentType('text', 'html', charset: UTF_8);
final ContentType _javascriptApplicationContentType = ContentType('application', 'javascript', charset: UTF_8);
final ContentType _xJavascriptContentType = ContentType('application', 'x-javascript', charset: UTF_8);
final ContentType webfBc1ContentType = ContentType('application', 'vnd.webf.bc1');

const List<String> _supportedByteCodeVersions = ['1'];

bool _isSupportedBytecode(String mimeType, Uri? uri) {
  if (uri != null) {
    for (int i = 0; i < _supportedByteCodeVersions.length; i++) {
      if (mimeType.contains('application/vnd.webf.bc${_supportedByteCodeVersions[i]}')) return true;
      // @NOTE: This is useful for most http server that did not recognize a .kbc1 file.
      // Simply treat some.kbc1 file as the bytecode.
      if (uri.path.endsWith('.kbc${_supportedByteCodeVersions[i]}')) return true;
    }
  }
  return false;
}

bool isGzip(List<int> data) {
  if (data.length < 2) {
    return false;
  }

  int magicNumber1 = data[0];
  int magicNumber2 = data[1];

  return magicNumber1 == 0x1F && magicNumber2 == 0x8B;
}


// The default accept request header.
// The order is HTML -> KBC -> JavaScript.
String _acceptHeader() {
  String bc = _supportedByteCodeVersions.map((String v) => 'application/vnd.webf.bc$v').join(',');
  // Be permissive: this is used for all resource types (HTML/CSS/JS/images/fonts).
  // Some servers/CDNs negotiate responses based on Accept; lacking image types can
  // cause image URLs to return HTML and break decoding ("Invalid image data").
  return 'text/html,$bc,application/javascript,image/gif,image/png,image/jpeg,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
}

bool _isAssetsScheme(String path) {
  return path.startsWith('assets:');
}

bool _isFileScheme(String path) {
  return path.startsWith('file:');
}

bool _isHttpScheme(String path) {
  return path.startsWith('http:') || path.startsWith('https:');
}

bool _isDataScheme(String path) {
  return path.startsWith('data:');
}

bool _isDefaultUrl(String url) {
  return url == DEFAULT_URL;
}

void _failedToResolveBundle(String url) {
  throw FlutterError('Failed to resolve bundle for $url');
}

abstract class WebFBundle with Diagnosticable {
  WebFBundle(this.url, { ContentType? contentType }): _contentType = contentType;

  // Unique resource locator.
  final String url;

  // Uri parsed by uriParser, assigned after resolving.
  Uri? _uri;
  Uri? get resolvedUri {
    _uri ??= Uri.tryParse(url);
    return _uri;
  }

  // The bundle data of raw.
  Uint8List? data;

  // Indicate the bundle is resolved.
  bool get isResolved => _uri != null;
  bool get isDataObtained => data != null;

  bool _hitCache = false;
  set hitCache(bool value) => _hitCache = value;

  String? get cacheKey {
    if (!_hitCache) return null;
    return HttpCacheController.getCacheKey(resolvedUri!).hashCode.toString();
  }

  bool _wasLoadedFromCache = false;
  bool get loadedFromCache => _wasLoadedFromCache;
  void setLoadingFromCache() {
    _wasLoadedFromCache = true;
  }

  // Content type for data.
  // The default value is plain text.
  ContentType? _contentType;
  ContentType get contentType => _contentType ?? _resolveContentType(_uri);

  // Pre process the data before the data actual used.
  Future<void> preProcessing(double contextId, {bool isModule = false}) async {
    if (isJavascript && data != null && isPageAlive(contextId)) {
      assert(isValidUTF8String(data!), 'JavaScript code is not UTF-8 encoded.');

      data = await dumpQuickjsByteCode(contextId, data!, url: _uri.toString(), isModule: isModule);

      _contentType = webfBc1ContentType;
    }
  }

  @mustCallSuper
  Future<void> resolve({ String? baseUrl, UriParser? uriParser }) async {
    if (isResolved) return;

    // Source is input by user, do not trust it's a valid URL.
    _uri = Uri.tryParse(url);

    if (baseUrl != null && _uri != null) {
      uriParser ??= UriParser();
      _uri = uriParser.resolve(Uri.parse(baseUrl), _uri!);
    }
  }

  Future<void> obtainData([double contextId]);

  // Dispose the memory obtained by bundle.
  @mustCallSuper
  void dispose() {
    data = null;
  }

  static Future<void> invalidateCache(String url) async {
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return;
    String origin = getOrigin(uri);
    HttpCacheController cacheController = HttpCacheController.instance(origin);
    HttpCacheObject cacheObject = await cacheController.getCacheObject(uri);
    await cacheObject.remove();
  }

  @override
  String toStringShort() {
    return '${describeIdentity(this)} (url: $url, contentType: $contentType, isLoaded: ${data != null}) ';
  }

  static WebFBundle fromUrl(String url, {Map<String, String>? additionalHttpHeaders, ContentType? contentType}) {
    if (_isHttpScheme(url)) {
      return NetworkBundle(url, additionalHttpHeaders: additionalHttpHeaders, contentType: contentType);
    } else if (_isAssetsScheme(url)) {
      return AssetsBundle(url, contentType: contentType);
    } else if (_isFileScheme(url)) {
      return FileBundle(url, contentType: contentType);
    } else if (_isDataScheme(url)) {
      return DataBundle.fromDataUrl(url, contentType: contentType);
    } else if (_isDefaultUrl(url)) {
      return DataBundle.fromString('', url, contentType: javascriptContentType);
    } else {
      throw FlutterError('Unsupported url. $url');
    }
  }

  static ContentType _resolveContentType(Uri? uri) {
    if (_isUriExt(uri, '.js') || _isUriExt(uri, '.mjs')) {
      return _javascriptApplicationContentType;
    } else if (_isUriExt(uri, '.html')) {
      return ContentType.html;
    } else if (_isSupportedBytecode('', uri)) {
      return webfBc1ContentType;
    } else if (_isUriExt(uri, '.css')) {
      return _cssContentType;
    }
    return ContentType.text;
  }

  static bool _isUriExt(Uri? uri, String ext) {
    if (uri == null) {
      return false;
    }
    return uri.path.toLowerCase().endsWith(ext);
  }

  static WebFBundle fromContent(String content, {String url = DEFAULT_URL, ContentType? contentType}) {
    return DataBundle.fromString(content, url, contentType: contentType ?? javascriptContentType);
  }

  static WebFBundle fromBytecode(Uint8List data, {String url = DEFAULT_URL}) {
    return DataBundle(data, url, contentType: webfBc1ContentType);
  }

  bool get isHTML => contentType.mimeType == ContentType.html.mimeType;
  bool get isCSS => contentType.mimeType == _cssContentType.mimeType;
  bool get isJavascript =>
      contentType.mimeType == javascriptContentType.mimeType ||
          contentType.mimeType == _javascriptApplicationContentType.mimeType ||
          contentType.mimeType == _xJavascriptContentType.mimeType;
  bool get isBytecode => contentType.mimeType == webfBc1ContentType.mimeType || _isSupportedBytecode(contentType.mimeType, _uri);
}

// The bundle that output input data.
class DataBundle extends WebFBundle {
  DataBundle(Uint8List data, String url, {ContentType? contentType}) : super(url) {
    this.data = data;
    _contentType = contentType ?? ContentType.binary;
  }

  DataBundle.fromString(String content, String url, {ContentType? contentType}) : super(url) {
    // Encode string to data by utf8.
    data = Uint8List.fromList(utf8.encode(content));
    _contentType = contentType ?? ContentType.text;
  }

  DataBundle.fromDataUrl(String dataUrl, {ContentType? contentType}) : super(dataUrl) {
    try {
      final UriData uriData = UriData.parse(dataUrl);
      data = uriData.contentAsBytes();
      _contentType = contentType ?? _contentTypeFromUriData(uriData);
    } on FormatException {
      // Some producers use non-standard `;utf8,` or include parameters that
      // `UriData.parse`/`ContentType.parse` reject. Fall back to a tolerant parser.
      final ({Uint8List bytes, ContentType type}) parsed = _parseDataUrlFallback(dataUrl);
      data = parsed.bytes;
      _contentType = contentType ?? parsed.type;
    }
  }

  static ContentType _contentTypeFromUriData(UriData uriData) {
    final String mimeType = uriData.mimeType.isNotEmpty ? uriData.mimeType : ContentType.text.mimeType;
    String? charset = uriData.charset;
    // Treat non-standard `;utf8` parameter as utf-8.
    if (charset == null && uriData.parameters.containsKey('utf8')) {
      charset = 'utf-8';
    }
    final String ct = charset != null ? '$mimeType; charset=$charset' : mimeType;
    try {
      return ContentType.parse(ct);
    } catch (_) {
      // Be permissive; callers can still sniff by bytes/mime.
      return ContentType.binary;
    }
  }

  static ({Uint8List bytes, ContentType type}) _parseDataUrlFallback(String dataUrl) {
    // Format: data:[<mediatype>][;base64],<data>
    final String s = dataUrl.trim();
    final int comma = s.indexOf(',');
    if (!s.startsWith('data:') || comma == -1) {
      return (bytes: Uint8List(0), type: ContentType.binary);
    }

    String header = s.substring('data:'.length, comma);
    String payload = s.substring(comma + 1);

    final String lowerHeader = header.toLowerCase();
    final bool isBase64 = lowerHeader.contains(';base64');

    // Extract mime type (before the first ';'), default per spec.
    String mimeType = header;
    final int semi = header.indexOf(';');
    if (semi != -1) {
      mimeType = header.substring(0, semi);
    }
    mimeType = mimeType.isNotEmpty ? mimeType : 'text/plain';

    // Charset handling.
    String? charset;
    final RegExp charsetRe = RegExp(r'charset=([^;]+)', caseSensitive: false);
    final Match? m = charsetRe.firstMatch(header);
    if (m != null) charset = m.group(1);
    if (charset == null && lowerHeader.contains(';utf8')) charset = 'utf-8';

    ContentType type;
    try {
      type = ContentType.parse(charset != null ? '$mimeType; charset=$charset' : mimeType);
    } catch (_) {
      type = ContentType.binary;
    }

    Uint8List bytes;
    try {
      if (isBase64) {
        // Some encoders percent-escape base64; decode if needed.
        if (payload.contains('%')) {
          payload = Uri.decodeFull(payload);
        }
        bytes = Uint8List.fromList(base64.decode(payload));
      } else {
        // Percent-decoded text; encode as UTF-8 bytes.
        final String decoded = payload.contains('%') ? Uri.decodeComponent(payload) : payload;
        bytes = Uint8List.fromList(utf8.encode(decoded));
      }
    } catch (_) {
      bytes = Uint8List(0);
    }

    return (bytes: bytes, type: type);
  }

  @override
  Future<void> obtainData([double contextId = 0]) async {}
}

// The bundle that source from http or https.
class NetworkBundle extends WebFBundle {
  // Do not access this field directly; use [_httpClient] instead.
  static final HttpClient sharedHttpClient = (() {
    final client = createWebFHttpClient();
    client.userAgent = NavigatorModule.getUserAgent();
    return client;
  })();

  NetworkBundle(super.url, {this.additionalHttpHeaders, super.contentType});

  Map<String, String>? additionalHttpHeaders = {};

  @override
  Future<void> obtainData([double contextId = 0]) async {
    if (data != null) return;

    // Get the loading state dumper for this context
    final dumper = LoadingStateRegistry.instance.getDumper(contextId);

    // If globally enabled, use Dio path
    if (WebFControllerManager.instance.useDioForNetwork) {
      // Track network request start
      dumper?.recordNetworkRequestStart(
        url,
        method: 'GET',
        headers: {},
        protocol: _uri!.scheme,
        remotePort: _uri!.hasAuthority ? _uri!.port : null,
      );
      // Track request sent stage to align with HttpClient path
      dumper?.recordNetworkRequestStage(url, LoadingState.stageRequestSent, metadata: {
        'method': 'GET',
        'headers': {'Accept': _acceptHeader(), ...?additionalHttpHeaders},
      });

      try {
        final dio = await getOrCreateWebFDio(
          contextId: contextId,
          uri: _uri!,
          ownerBundle: this,
        );

        // Mark the moment we see the first received byte
        bool responseStartedEmitted = false;

        final resp = await dio.requestUri(
          _uri!,
          options: Options(
            method: 'GET',
            responseType: ResponseType.bytes,
            headers: {'Accept': _acceptHeader(), ...?additionalHttpHeaders},
            followRedirects: true,
            // Accept 200 OK and 304 Not Modified (cache validation)
            validateStatus: (s) => s == HttpStatus.ok || s == HttpStatus.notModified,
          ),
          onReceiveProgress: (received, total) {
            if (!responseStartedEmitted && received > 0) {
              responseStartedEmitted = true;
              dumper?.recordNetworkRequestStage(url, LoadingState.stageResponseStarted, metadata: {
                'contentLength': total,
              });
            }
          },
        );

        // If no progress callback fired (e.g., very small or cached responses),
        // ensure we still emit a response_started marker here.
        if (!responseStartedEmitted) {
          dumper?.recordNetworkRequestStage(url, LoadingState.stageResponseStarted, metadata: {
            'statusCode': resp.statusCode,
            'contentLength': resp.data?.length ?? 0,
          });
        }

        if (resp.statusCode != HttpStatus.ok && resp.statusCode != HttpStatus.notModified) {
          dumper?.recordNetworkRequestComplete(url, statusCode: resp.statusCode ?? 0, responseHeaders: {
            'error': 'HTTP ${resp.statusCode}',
          });
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Unable to load asset: $url'),
            IntProperty('HTTP status code', resp.statusCode ?? 0),
          ]);
        }

        // Track cache hit from interceptor
        final cacheHit = resp.requestOptions.extra['webf_cache_hit'] == true;
        hitCache = cacheHit;
        if (cacheHit) {
          dumper?.recordNetworkRequestCacheInfo(url,
            cacheHit: true,
            cacheType: 'disk',
            cacheHeaders: {},
          );
        }

        Uint8List bytes = resp.data ?? Uint8List(0);
        // Response fully received
        dumper?.recordNetworkRequestStage(url, LoadingState.stageResponseReceived, metadata: {
          'responseSize': bytes.length,
        });

        if (bytes.isEmpty) {
          await WebFBundle.invalidateCache(url);
          return;
        }

        // To maintain compatibility with older versions of WebF, which save Gzip
        // content in caches, decode it here as well (Dio path).
        final bool wasGzipped = isGzip(bytes);
        if (wasGzipped) {
          bytes = Uint8List.fromList(gzip.decoder.convert(bytes));
        }

        data = bytes;
        final contentTypeHeader = resp.headers.value(HttpHeaders.contentTypeHeader);
        _contentType = contentTypeHeader != null ? ContentType.parse(contentTypeHeader) : ContentType.binary;

        // Completion
        final responseHeaders = <String, String>{};
        String? contentType;
        resp.headers.forEach((name, values) {
          final headerValue = values.join(', ');
          responseHeaders[name] = headerValue;
          if (name.toLowerCase() == 'content-type') {
            contentType = headerValue;
          }
        });
        dumper?.recordNetworkRequestComplete(url,
          statusCode: resp.statusCode ?? 0,
          responseHeaders: responseHeaders,
          contentType: contentType,
        );
        return;
      } on DioException catch (e) {
        // Report to loading state and let DevTools interceptor emit failure event too
        dumper?.recordNetworkRequestError(url, e.message ?? e.error?.toString() ?? 'Network error');
        rethrow;
      } catch (e) {
        dumper?.recordNetworkRequestError(url, e.toString());
        rethrow;
      }
    }

    // Track network request start
    dumper?.recordNetworkRequestStart(
      url,
      method: 'GET',
      headers: {},
      protocol: _uri!.scheme,
      remotePort: _uri!.hasAuthority ? _uri!.port : null,
    );

    ProxyHttpClientRequest? request;
    try {
    final HttpClientRequest rawRequest = await sharedHttpClient.getUrl(_uri!);
      request = rawRequest as ProxyHttpClientRequest;

      // Prepare request headers.
      rawRequest.headers.set('Accept', _acceptHeader());
      additionalHttpHeaders?.forEach(rawRequest.headers.set);
      WebFHttpOverrides.setContextHeader(rawRequest.headers, contextId);

      request.ownerBundle = this;

      // Track request sent stage
      dumper?.recordNetworkRequestStage(url, LoadingState.stageRequestSent, metadata: {
        'method': 'GET',
        'headers': additionalHttpHeaders ?? {},
      });

      final HttpClientResponse response = await rawRequest.close();
      request.ownerBundle = null;

      // Track response started stage
      dumper?.recordNetworkRequestStage(url, LoadingState.stageResponseStarted, metadata: {
        'statusCode': response.statusCode,
        'contentLength': response.contentLength,
      });

      if (response.statusCode != HttpStatus.ok) {
        // Track error completion
        dumper?.recordNetworkRequestComplete(url, statusCode: response.statusCode, responseHeaders: {
          'error': 'HTTP ${response.statusCode}',
        });
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Unable to load asset: $url'),
          IntProperty('HTTP status code', response.statusCode),
        ]);
      }

      hitCache = response is HttpClientStreamResponse || response is HttpClientCachedResponse;

      // Track cache info if hit cache
      if (_hitCache) {
        dumper?.recordNetworkRequestCacheInfo(url,
          cacheHit: true,
          cacheType: response is HttpClientCachedResponse ? 'disk' : 'memory',
          cacheHeaders: {},
        );
      }

      // Track downloading stage
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);

      // Track response fully received
      dumper?.recordNetworkRequestStage(url, LoadingState.stageResponseReceived, metadata: {
        'responseSize': bytes.length,
      });

      // To maintain compatibility with older versions of WebF, which save Gzip content in caches, we should check the bytes
      // and decode them if they are in gzip format.
      final bool wasGzipped = isGzip(bytes);
      if (wasGzipped) {
        bytes = Uint8List.fromList(gzip.decoder.convert(bytes));
      }

      if (bytes.isEmpty) {
        data = Uint8List.fromList([]);
        await WebFBundle.invalidateCache(url);
        return;
      }

      data = bytes.buffer.asUint8List();
      _contentType = response.headers.contentType ?? ContentType.binary;

      // Track completion
      final responseHeaders = <String, String>{};
      String? contentType;
      response.headers.forEach((name, values) {
        final headerValue = values.join(', ');
        responseHeaders[name] = headerValue;
        if (name.toLowerCase() == 'content-type') {
          contentType = headerValue;
        }
      });

      dumper?.recordNetworkRequestComplete(url,
        statusCode: response.statusCode,
        responseHeaders: responseHeaders,
        contentType: contentType,
      );
    } on SocketException catch (e) {
      final errText = 'SocketException: ${e.message}';
      dumper?.recordNetworkRequestError(url, errText);
      if (request != null) request.ownerBundle = null;
      rethrow;
    } on TimeoutException catch (e) {
      final errText = 'TimeoutException: ${e.message ?? 'timeout'}';
      dumper?.recordNetworkRequestError(url, errText);
      if (request != null) request.ownerBundle = null;
      rethrow;
    } on HttpException catch (e) {
      final errText = 'HttpException: ${e.message}';
      dumper?.recordNetworkRequestError(url, errText);
      if (request != null) request.ownerBundle = null;
      rethrow;
    } on TlsException catch (e) {
      final errText = 'TlsException: ${e.message}';
      dumper?.recordNetworkRequestError(url, errText);
      if (request != null) request.ownerBundle = null;
      rethrow;
    } catch (e) {
      final errText = e.toString();
      dumper?.recordNetworkRequestError(url, errText);
      if (request != null) request.ownerBundle = null;
      rethrow;
    }
  }
}

class AssetsBundle extends WebFBundle {
  AssetsBundle(super.url, { super.contentType });

  @override
  Future<void> obtainData([double contextId = 0]) async {
    if (data != null) return;

    final Uri? resolvedUri = this.resolvedUri;
    if (resolvedUri != null) {
      final String assetName = getAssetName(resolvedUri);
      ByteData byteData = await rootBundle.load(assetName);
      data = byteData.buffer.asUint8List();
    } else {
      _failedToResolveBundle(url);
    }
  }

  /// Get flutter asset name from uri scheme asset.
  ///   eg: assets:///foo/bar.html -> foo/bar.html
  ///       assets:foo/bar.html -> foo/bar.html
  static String getAssetName(Uri assetUri) {
    String assetName = assetUri.path;

    // Remove leading `/`.
    if (assetName.startsWith('/')) {
      assetName = assetName.substring(1);
    }
    return assetName;
  }
}

/// The bundle that source from local io.
class FileBundle extends WebFBundle {
  FileBundle(super.url, { super.contentType });

  @override
  Future<void> obtainData([double contextId = 0]) async {
    if (data != null) return;

    Uri uri = _uri!;
    final String path = uri.path;
    File file = File(path);

    if (await file.exists()) {
      data = await file.readAsBytes();
    } else {
      _failedToResolveBundle(url);
    }
  }
}
