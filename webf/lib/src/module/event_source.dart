/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/module.dart';

typedef EventSourceEventCallback = void Function(String id, Event event);

class _EventSourceConnection {
  StreamSubscription<String>? subscription;
  CancelToken? cancelToken;
  HttpClientRequest? httpRequest;
  Timer? reconnectTimer;
  String? lastEventId;
  int retryMs = 3000;
  bool closed = false;
  String currentEventType = 'message';
  StringBuffer dataBuffer = StringBuffer();
}

class EventSourceModule extends WebFBaseModule {
  @override
  String get name => 'EventSource';

  int _clientId = 0;
  final Map<String, _EventSourceConnection> _connectionMap = {};
  final Map<String, Map<String, bool>> _listenMap = {};

  EventSourceModule(super.moduleManager);

  @override
  String invoke(String method, List<dynamic> params) {
    switch (method) {
      case 'init':
        final String url = params[0];
        final bool withCredentials = params[1] == true || params[1] == 'true';
        return _init(url, withCredentials);
      case 'close':
        _close(params[0]);
        return '';
      case 'addEvent':
        _addEvent(params[0], params[1]);
        return '';
    }
    return '';
  }

  @override
  void dispose() {
    _connectionMap.forEach((id, conn) {
      conn.closed = true;
      conn.subscription?.cancel();
      conn.cancelToken?.cancel('disposed');
      conn.reconnectTimer?.cancel();
    });
    _connectionMap.clear();
    _listenMap.clear();
  }

  String _init(String url, bool withCredentials) {
    final id = (_clientId++).toString();
    _connectionMap[id] = _EventSourceConnection();

    final callback = _createCallback();
    final uri = _resolveUri(url);

    _connect(id, uri, withCredentials, callback);
    return id;
  }

  EventSourceEventCallback _createCallback() {
    return (String id, Event event) {
      if (moduleManager?.disposed == true) return;
      moduleManager!.emitModuleEvent(name, event: event, data: id);
    };
  }

  Uri _resolveUri(String input) {
    final Uri parsedUri = Uri.parse(input);
    if (moduleManager != null) {
      Uri base = Uri.parse(moduleManager!.controller.url);
      UriParser uriParser = moduleManager!.controller.uriParser!;
      return uriParser.resolve(base, parsedUri);
    }
    return parsedUri;
  }

  void _connect(String id, Uri uri, bool withCredentials, EventSourceEventCallback callback) {
    final conn = _connectionMap[id];
    if (conn == null || conn.closed) return;

    final useDio = WebFControllerManager.instance.useDioForNetwork;
    if (useDio) {
      _connectWithDio(id, uri, withCredentials, callback);
    } else {
      _connectWithHttpClient(id, uri, withCredentials, callback);
    }
  }

  /// Create a Dio configured for SSE streaming.
  ///
  /// SSE requires a dedicated Dio instance with [IOHttpClientAdapter] because:
  /// - The shared pool may use [CupertinoAdapter] (macOS/iOS) whose underlying
  ///   NSURLSession URLCache can buffer responses before delivering them, which
  ///   blocks indefinitely on infinite SSE streams.
  /// - SSE streams must not be cached or subject to receive timeouts.
  /// - Interceptors from the shared pool (cache, cookies, logging) are not needed
  ///   for SSE and can interfere with streaming delivery.
  Dio _createStreamingDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: Duration.zero,
      sendTimeout: const Duration(seconds: 60),
      responseType: ResponseType.stream,
    ));
    dio.httpClientAdapter = IOHttpClientAdapter();
    return dio;
  }

  Future<void> _connectWithDio(String id, Uri uri, bool withCredentials, EventSourceEventCallback callback) async {
    final conn = _connectionMap[id];
    if (conn == null || conn.closed) return;

    try {
      final dio = _createStreamingDio();
      final cancelToken = CancelToken();
      conn.cancelToken = cancelToken;

      final headers = <String, dynamic>{
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      };
      if (conn.lastEventId != null) {
        headers['Last-Event-ID'] = conn.lastEventId!;
      }

      final response = await dio.getUri<ResponseBody>(
        uri,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
          receiveTimeout: Duration.zero,
        ),
        cancelToken: cancelToken,
      );

      if (conn.closed) return;

      // Dispatch 'open' event
      if (_hasListener(id, EVENT_OPEN)) {
        callback(id, Event(EVENT_OPEN));
      }

      // Listen to the stream, parse SSE format.
      // Cast Stream<Uint8List> to Stream<List<int>> for utf8.decoder compatibility.
      final stream = response.data!.stream.cast<List<int>>();
      conn.subscription = stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          _processLine(id, line, callback);
        },
        onError: (e) {
          _handleError(id, uri, withCredentials, callback);
        },
        onDone: () {
          _handleDone(id, uri, withCredentials, callback);
        },
      );
    } catch (e, stack) {
      networkLogger.warning('EventSource connect error for $uri', e, stack);
      _handleError(id, uri, withCredentials, callback);
    }
  }

  Future<void> _connectWithHttpClient(
      String id, Uri uri, bool withCredentials, EventSourceEventCallback callback) async {
    final conn = _connectionMap[id];
    if (conn == null || conn.closed) return;

    try {
      final httpClient = createWebFHttpClient();
      final request = await httpClient.getUrl(uri);
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');
      if (conn.lastEventId != null) {
        request.headers.set('Last-Event-ID', conn.lastEventId!);
      }
      conn.httpRequest = request;

      final response = await request.close();

      if (conn.closed) return;

      // Dispatch 'open' event
      if (_hasListener(id, EVENT_OPEN)) {
        callback(id, Event(EVENT_OPEN));
      }

      // HttpClientResponse implements Stream<List<int>>
      conn.subscription = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          _processLine(id, line, callback);
        },
        onError: (e) {
          _handleError(id, uri, withCredentials, callback);
        },
        onDone: () {
          _handleDone(id, uri, withCredentials, callback);
        },
      );
    } catch (e, stack) {
      networkLogger.warning('EventSource connect error for $uri', e, stack);
      _handleError(id, uri, withCredentials, callback);
    }
  }

  void _processLine(String id, String line, EventSourceEventCallback callback) {
    final conn = _connectionMap[id];
    if (conn == null || conn.closed) return;

    if (line.isEmpty) {
      // Empty line = dispatch event
      _dispatchEvent(id, conn, callback);
      return;
    }
    if (line.startsWith(':')) return; // Comment, ignore

    String field;
    String value;
    final colonIndex = line.indexOf(':');
    if (colonIndex == -1) {
      field = line;
      value = '';
    } else {
      field = line.substring(0, colonIndex);
      value = line.substring(colonIndex + 1);
      if (value.startsWith(' ')) value = value.substring(1); // Strip leading space per spec
    }

    switch (field) {
      case 'event':
        conn.currentEventType = value;
      case 'data':
        if (conn.dataBuffer.isNotEmpty) conn.dataBuffer.write('\n');
        conn.dataBuffer.write(value);
      case 'id':
        if (!value.contains('\u0000')) conn.lastEventId = value;
      case 'retry':
        final retry = int.tryParse(value);
        if (retry != null) conn.retryMs = retry;
    }
  }

  void _dispatchEvent(String id, _EventSourceConnection conn, EventSourceEventCallback callback) {
    if (conn.dataBuffer.isEmpty) {
      // No data accumulated, reset event type and skip
      conn.currentEventType = 'message';
      return;
    }

    final eventType = conn.currentEventType;
    final data = conn.dataBuffer.toString();
    conn.dataBuffer.clear();
    conn.currentEventType = 'message';

    if (_hasListener(id, eventType)) {
      final event = MessageEvent(data, lastEventId: conn.lastEventId ?? '');
      // Don't override event.type for named events — the bridge uses the type
      // string to choose the JS constructor, and non-standard types like 'update'
      // would produce a plain Event without .data. Instead, encode the named
      // event type in the data parameter so the JS polyfill can re-dispatch.
      final moduleData = eventType == 'message' ? id : '$id\n$eventType';
      callback(moduleData, event);
    }
  }

  void _handleError(String id, Uri uri, bool withCredentials, EventSourceEventCallback callback) {
    final conn = _connectionMap[id];
    if (conn == null || conn.closed) return;

    if (_hasListener(id, EVENT_ERROR)) {
      callback(id, Event(EVENT_ERROR));
    }

    // Schedule reconnection
    _scheduleReconnect(id, uri, withCredentials, callback);
  }

  void _handleDone(String id, Uri uri, bool withCredentials, EventSourceEventCallback callback) {
    final conn = _connectionMap[id];
    if (conn == null || conn.closed) return;

    // Connection closed by server, dispatch error event per spec
    if (_hasListener(id, EVENT_ERROR)) {
      callback(id, Event(EVENT_ERROR));
    }

    // Schedule reconnection
    _scheduleReconnect(id, uri, withCredentials, callback);
  }

  void _scheduleReconnect(String id, Uri uri, bool withCredentials, EventSourceEventCallback callback) {
    final conn = _connectionMap[id];
    if (conn == null || conn.closed) return;

    conn.subscription?.cancel();
    conn.subscription = null;
    conn.cancelToken = null;
    conn.httpRequest = null;

    conn.reconnectTimer = Timer(Duration(milliseconds: conn.retryMs), () {
      if (conn.closed) return;
      _connect(id, uri, withCredentials, callback);
    });
  }

  void _close(String id) {
    final conn = _connectionMap[id];
    if (conn == null) return;

    conn.closed = true;
    conn.subscription?.cancel();
    conn.cancelToken?.cancel('closed');
    conn.reconnectTimer?.cancel();
    _connectionMap.remove(id);
    _listenMap.remove(id);
  }

  bool _hasListener(String id, String type) {
    if (!_listenMap.containsKey(id)) return false;
    return _listenMap[id]!.containsKey(type);
  }

  void _addEvent(String id, String type) {
    if (moduleManager?.disposed == true) return;

    if (!_listenMap.containsKey(id)) {
      _listenMap[id] = {};
    }
    _listenMap[id]![type] = true;
  }
}
