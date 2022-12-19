/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ffi';

import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:ffi/ffi.dart';

const String CONTENT_TYPE = 'Content-Type';
const String CONTENT_LENGTH = 'Content-Length';
const String FAVICON = 'https://gw.alicdn.com/tfs/TB1tTwGAAL0gK0jSZFxXXXWHVXa-144-144.png';

typedef MessageCallback = void Function(Map<String, dynamic>?);

typedef NativeInspectorMessageCallback = Void Function(Pointer<Void> rpcSession, Pointer<Utf8> message);
typedef DartInspectorMessageCallback = void Function(Pointer<Void> rpcSession, Pointer<Utf8> message);
typedef NativeRegisterInspectorMessageCallback = Void Function(Int32 contextId, Pointer<Void> rpcSession,
    Pointer<NativeFunction<NativeInspectorMessageCallback>> inspectorMessageCallback);
typedef NativeAttachInspector = Void Function(Int32);
typedef DartAttachInspector = void Function(int);
typedef NativeInspectorMessage = Void Function(Int32 contextId, Pointer<Utf8>);
typedef NativePostTaskToUIThread = Void Function(Int32 contextId, Pointer<Void> context, Pointer<Void> callback);
typedef NativeDispatchInspectorTask = Void Function(Int32 contextId, Pointer<Void> context, Pointer<Void> callback);
typedef DartDispatchInspectorTask = void Function(int? contextId, Pointer<Void> context, Pointer<Void> callback);

void serverIsolateEntryPoint(SendPort isolateToMainStream) {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);
  IsolateInspector? inspector;
  mainToIsolateStream.listen((data) {
    handleFrontEndMessage(Map<String, dynamic>? frontEndMessage) {
      int? id = frontEndMessage!['id'];
      String _method = frontEndMessage['method'];
      Map<String, dynamic>? params = frontEndMessage['params'];

      List<String> moduleMethod = _method.split('.');
      String module = moduleMethod[0];
      String method = moduleMethod[1];

      // Runtime、Log、Debugger methods should handled on inspector isolate.
      if (module == 'Runtime' || module == 'Log' || module == 'Debugger') {
        inspector!.messageRouter(id, module, method, params);
      } else {
        isolateToMainStream.send(InspectorFrontEndMessage(id, module, method, params));
      }
    }

    if (data is InspectorServerInit) {
      IsolateInspectorServer server = IsolateInspectorServer(data.port, data.address, data.bundleURL);
      server.onStarted = () {
        isolateToMainStream.send(InspectorServerStart());
      };
      server.onFrontendMessage = handleFrontEndMessage;
      server.start();
      inspector = server;
    } else if (data is InspectorServerConnect) {
      IsolateInspectorClient client = IsolateInspectorClient(data.url);
      client.onStarted = () {
        isolateToMainStream.send(InspectorClientConnected());
      };
      client.onFrontendMessage = handleFrontEndMessage;
      client.start();
      inspector = client;
    } else if (inspector != null && inspector!.connected) {
      if (data is InspectorEvent) {
        inspector!.sendEventToFrontend(data);
      } else if (data is InspectorMethodResult) {
        inspector!.sendToFrontend(data.id, data.result);
      }
    }
  });
}

class IsolateInspector {
  final Map<String, IsolateInspectorModule> moduleRegistrar = {};
  MessageCallback? onFrontendMessage;

  WebSocket? _ws;

  WebSocket? get ws => _ws;

  bool get connected => false;

  void messageRouter(int? id, String module, String method, Map<String, dynamic>? params) {
    if (moduleRegistrar.containsKey(module)) {
      moduleRegistrar[module]!.invoke(id, method, params);
    }
  }

  void registerModule(IsolateInspectorModule module) {
    moduleRegistrar[module.name] = module;
  }

  void sendToFrontend(int? id, Map? result) {
    String data = jsonEncode({
      if (id != null) 'id': id,
      // Give an empty object for response.
      'result': result ?? {},
    });
    _ws?.add(data);
  }

  void sendEventToFrontend(InspectorEvent event) {
    _ws?.add(jsonEncode(event));
  }

  void sendRawJSONToFrontend(String message) {
    _ws?.add(message);
  }

  void dispose() async {
    onFrontendMessage = null;
  }

  Map<String, dynamic>? _parseMessage(message) {
    try {
      Map<String, dynamic>? data = jsonDecode(message);
      return data;
    } catch (err) {
      print('Error while decoding frontend message: $message');
      rethrow;
    }
  }

  void onWebSocketRequest(message) {
    if (message is String) {
      Map<String, dynamic>? data = _parseMessage(message);
      if (onFrontendMessage != null) {
        onFrontendMessage!(data);
      }
    }
  }
}

class IsolateInspectorServer extends IsolateInspector {
  IsolateInspectorServer(this.port, this.address, this.bundleURL);

  // final Inspector inspector;
  final String address;
  final String bundleURL;
  int port;

  VoidCallback? onStarted;
  late HttpServer _httpServer;

  /// InspectServer has connected frontend.
  @override
  bool get connected => _ws?.readyState == WebSocket.open;

  int _bindServerRetryTime = 0;

  Future<void> _bindServer(int port) async {
    try {
      _httpServer = await HttpServer.bind(address, port);
      this.port = port;
    } on SocketException {
      if (_bindServerRetryTime < 10) {
        _bindServerRetryTime++;
        await _bindServer(port + 1);
      } else {
        rethrow;
      }
    }
  }

  Future<void> start() async {
    await _bindServer(port);

    if (onStarted != null) {
      onStarted!();
    }

    _httpServer.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request, compression: CompressionOptions.compressionOff)
            .then((WebSocket webSocket) {
          _ws = webSocket;
          webSocket.listen(onWebSocketRequest, onDone: () {
            _ws = null;
          }, onError: (obj, stack) {
            _ws = null;
          });
        });
      } else {
        onHTTPRequest(request);
      }
    });
  }

  Future<void> onHTTPRequest(HttpRequest request) async {
    switch (request.requestedUri.path) {
      case '/json/version':
        onRequestVersion(request);
        break;

      case '/json':
      case '/json/list':
        onRequestList(request);
        break;

      case '/json/new':
        onRequestNew(request);
        break;

      case '/json/close':
        onRequestClose(request);
        break;

      case '/json/protocol':
        onRequestProtocol(request);
        break;

      default:
        onRequestFallback(request);
        break;
    }
    await request.response.close();
  }

  void _writeJSONObject(HttpRequest request, Object obj) {
    String body = jsonEncode(obj);
    // Must preserve header case, or chrome devtools inspector will drop data.
    request.response.headers.set(CONTENT_TYPE, 'application/json; charset=UTF-8', preserveHeaderCase: true);
    request.response.headers.set(CONTENT_LENGTH, body.length, preserveHeaderCase: true);
    request.response.write(body);
  }

  void onRequestVersion(HttpRequest request) {
    request.response.headers.clear();
    _writeJSONObject(request, {
      'Browser': '${NavigatorModule.getAppName()}/${NavigatorModule.getAppVersion()}',
      'Protocol-Version': '1.3',
      'User-Agent': NavigatorModule.getUserAgent(),
    });
  }

  void onRequestList(HttpRequest request) {
    request.response.headers.clear();
    String pageId = hashCode.toString();
    String entryURL = '$address:$port/devtools/page/$pageId';
    _writeJSONObject(request, [
      {
        'faviconUrl': FAVICON,
        'devtoolsFrontendUrl': '$INSPECTOR_URL?ws=$entryURL',
        'title': 'WebF App',
        'id': pageId,
        'type': 'page',
        'url': bundleURL,
        'webSocketDebuggerUrl': 'ws://$entryURL'
      }
    ]);
  }

  void onRequestClose(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestActivate(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestNew(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestProtocol(HttpRequest request) {
    onRequestFallback(request);
  }

  void onRequestFallback(HttpRequest request) {
    request.response.statusCode = 404;
    request.response.write('Unknown request.');
  }

  @override
  void dispose() async {
    super.dispose();
    onStarted = null;

    await _ws?.close();
    await _httpServer.close();
  }
}

class IsolateInspectorClient extends IsolateInspector {
  final String url;

  IsolateInspectorClient(this.url);

  @override
  bool get connected => _ws?.readyState == WebSocket.open;

  VoidCallback? onStarted;

  void start() async {
    _ws = await WebSocket.connect(url, protocols: ['echo-protocol']);
    _ws!.listen((data) {
      onWebSocketRequest(data);
    });
  }
}
