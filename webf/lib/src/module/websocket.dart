/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'dart:io';

import 'package:webf/dom.dart';
import 'package:webf/module.dart';
import 'package:web_socket_channel/io.dart';

enum _ConnectionState { closed }

typedef WebSocketEventCallback = void Function(String id, Event event);

class _WebSocketState {
  _ConnectionState status;
  late dynamic data;

  _WebSocketState(this.status);
}

class WebSocketModule extends BaseModule {
  @override
  String get name => 'WebSocket';

  final Map<String, IOWebSocketChannel> _clientMap = {};
  final Map<String?, _WebSocketState> _stateMap = {};
  int _clientId = 0;

  WebSocketModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  String invoke(String method, List<dynamic> params) {
    if (method == 'init') {
      String? protocols = params.length > 1 ? params[1] : null;
      return init(params[0], (String id, Event event) {
        moduleManager!.emitModuleEvent(name, event: event, data: id);
      }, protocols: protocols);
    } else if (method == 'send') {
      send(params[0], params[1]);
    } else if (method == 'close') {
      close(params[0], params[1], params[2]);
    }
    return '';
  }

  @override
  void dispose() {
    _clientMap.forEach((id, socket) {
      socket.sink.close();
    });
    _clientMap.clear();
    _stateMap.clear();
  }

  String init(String url, WebSocketEventCallback callback, {String? protocols}) {
    var id = (_clientId++).toString();
    WebSocket.connect(url,
        protocols: protocols != null ? [protocols] : null,
        headers: {'origin': moduleManager!.controller.url}).then((webSocket) {
      if (moduleManager?.disposed == true) return;
      IOWebSocketChannel client = IOWebSocketChannel(webSocket);
      _WebSocketState? state = _stateMap[id];
      if (state != null && state.status == _ConnectionState.closed) {
        dynamic data = state.data;
        webSocket.close(data[0], data[1]);
        CloseEvent event = CloseEvent(data[0] ?? 0, data[1] ?? '', true);
        callback(id, event);
        _stateMap.remove(id);
        return;
      }
      _clientMap[id] = client;
      // Listen all events
      _listen(id, callback);
      // Unconditionally fire open event; JS-side EventTarget will dispatch
      // only if a listener is registered (no need for a Dart-side gate).
      callback(id, Event(EVENT_OPEN));
    }).catchError((e, stack) {
      // print connection error internally and trigger error event.
      print(e);
      callback(id, Event(EVENT_ERROR));
    });

    return id;
  }

  void send(String? id, String? message) {
    IOWebSocketChannel? client = _clientMap[id!];

    if (client == null) return;

    client.sink.add(message);
  }

  void close(String? id, [int? closeCode, String? closeReason]) {
    IOWebSocketChannel? client = _clientMap[id!];
    // has not connect
    if (client == null) {
      if (!_stateMap.containsKey(id)) {
        _WebSocketState state = _WebSocketState(_ConnectionState.closed);
        state.data = [closeCode, closeReason];
        _stateMap[id] = state;
      } else {
        _WebSocketState state = _stateMap[id]!;
        state.status = _ConnectionState.closed;
        state.data = [closeCode, closeReason];
      }
      return;
    }
    // connected
    client.sink.close(closeCode, closeReason);
  }

  void _listen(String id, WebSocketEventCallback callback) {
    IOWebSocketChannel client = _clientMap[id]!;

    client.stream.listen((message) {
      callback(id, MessageEvent(message));
    }, onError: (error) {
      // print error internally and trigger error event;
      print(error);
      callback(id, Event(EVENT_ERROR));
    }, onDone: () {
      if (moduleManager?.disposed == true) return;

      // CloseEvent https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent/CloseEvent
      callback(id, CloseEvent(client.closeCode ?? 1000, client.closeReason ?? '', false));
      // Clear instance after close
      _clientMap.remove(id);
      _stateMap.remove(id);
    });
  }
}
