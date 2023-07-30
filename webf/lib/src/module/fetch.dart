/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:webf/foundation.dart';
import 'package:webf/module.dart';

String EMPTY_STRING = '';

class FetchModule extends BaseModule {
  @override
  String get name => 'Fetch';

  bool _disposed = false;

  FetchModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {
    _disposed = true;
  }

  static final HttpClient _sharedHttpClient = HttpClient()..userAgent = NavigatorModule.getUserAgent();
  HttpClient get httpClient => _sharedHttpClient;

  Uri _resolveUri(String input) {
    final Uri parsedUri = Uri.parse(input);

    if (moduleManager != null) {
      Uri base = Uri.parse(moduleManager!.controller.url);
      UriParser uriParser = moduleManager!.controller.uriParser!;
      return uriParser.resolve(base, parsedUri);
    } else {
      return parsedUri;
    }
  }

  static const String fallbackUserAgent = 'WebF';
  static String? _defaultUserAgent;
  static String _getDefaultUserAgent() {
    if (_defaultUserAgent == null) {
      try {
        _defaultUserAgent = NavigatorModule.getUserAgent();
      } catch (error) {
        // Ignore if dynamic library is missing.
        return fallbackUserAgent;
      }
    }
    return _defaultUserAgent!;
  }

  @visibleForTesting
  FutureOr<HttpClientRequest> getRequest(Uri uri, String? method, Map? headers, data) async {
    HttpClientRequest request = await httpClient.openUrl(method ?? 'GET', uri);
    // Reset WebF UA.
    request.headers.removeAll(HttpHeaders.userAgentHeader);
    request.headers.add(HttpHeaders.userAgentHeader, _getDefaultUserAgent());

    // Add additional headers.
    if (headers is Map<String, dynamic>) {
      for (MapEntry<String, dynamic> entry in headers.entries) {
        request.headers.add(entry.key, entry.value);
      }
    }

    // Set ContextID Header
    if (moduleManager != null) {
      request.headers.set(HttpHeaderContext, moduleManager!.contextId.toString());
    }

    if (data is List<int>) {
      request.add(data);
    } else if (data != null) {
      // Treat as string as default.
      request.add(utf8.encode(data));
    }

    return request;
  }

  @override
  FutureOr<String> invoke(String method, params, InvokeModuleCallback callback) async {
    Uri uri = _resolveUri(method);
    Map<String, dynamic> options = params;

    _handleError(Object error, StackTrace? stackTrace) {
      String errmsg = '$error';
      if (stackTrace != null) {
        errmsg += '\n$stackTrace';
      }
      callback(error: errmsg);
    }

    if (uri.host.isEmpty) {
      // No host specified in URI.
      _handleError('Failed to parse URL from $uri.', null);
    } else {
      try {
        HttpClientRequest request = await getRequest(uri, options['method'], options['headers'], options['body']);
        if (_disposed) return Future.value('');
        HttpClientResponse response = await request.close();
        Uint8List? bytes = await consolidateHttpClientResponseBytes(response);
        callback(data: [EMPTY_STRING, response.statusCode, bytes]);
      } catch (error, stacktrace) {
        _handleError(error, stacktrace);
      }
    }

    return EMPTY_STRING;
  }
}
