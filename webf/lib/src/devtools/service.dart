/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:isolate';
import 'dart:ffi';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';

typedef NativePostTaskToInspectorThread = Void Function(Int32 contextId, Pointer<Void> context, Pointer<Void> callback);
typedef DartPostTaskToInspectorThread = void Function(int contextId, Pointer<Void> context, Pointer<Void> callback);

void spawnIsolateInspectorServer(ChromeDevToolsService devTool, WebFController controller,
    {int port = INSPECTOR_DEFAULT_PORT, String? address}) {
  ReceivePort serverIsolateReceivePort = ReceivePort();

  serverIsolateReceivePort.listen((data) {
    if (data is SendPort) {
      devTool._isolateServerPort = data;
      String bundleURL = controller.url;
      if (bundleURL.isEmpty) {
        bundleURL = '<EmbedBundle>';
      }
      devTool._isolateServerPort!.send(InspectorServerInit(getAllocatedPage(controller.view.contextId)!.address, port, '0.0.0.0', bundleURL));
    } else if (data is InspectorFrontEndMessage) {
      devTool.uiInspector!.messageRouter(data.id, data.module, data.method, data.params);
    } else if (data is InspectorServerStart) {
      devTool.uiInspector!.onServerStart(data.port);
    } else if (data is InspectorPostTaskMessage) {
      if (devTool.isReloading) return;
      dispatchUITask(controller.view.contextId, Pointer.fromAddress(data.context), Pointer.fromAddress(data.callback));
    }
  });

  Isolate.spawn(serverIsolateEntryPoint, serverIsolateReceivePort.sendPort).then((Isolate isolate) {
    devTool._isolateServerIsolate = isolate;
  });
}

class ChromeDevToolsService extends DevToolsService {
  /// Design prevDevTool for reload page,
  /// do not use it in any other place.
  /// More detail see [InspectPageModule.handleReloadPage].
  static ChromeDevToolsService? prevDevTools;

  static final Map<int, ChromeDevToolsService> _contextDevToolMap = {};
  static ChromeDevToolsService? getDevToolOfContextId(int contextId) {
    return _contextDevToolMap[contextId];
  }

  late Isolate _isolateServerIsolate;
  SendPort? _isolateServerPort;
  SendPort? get isolateServerPort => _isolateServerPort;

  /// Used for debugger inspector.
  UIInspector? _uiInspector;
  UIInspector? get uiInspector => _uiInspector;

  WebFController? _controller;
  WebFController? get controller => _controller;

  bool get isReloading => _reloading;
  bool _reloading = false;

  @override
  void dispose() {
    _uiInspector?.dispose();
    _contextDevToolMap.remove(controller!.view.contextId);
    _controller?.view.debugDOMTreeChanged = null;
    _controller = null;
    _isolateServerPort = null;
    _isolateServerIsolate.kill();
  }

  @override
  void init(WebFController controller) {
    _contextDevToolMap[controller.view.contextId] = this;
    _controller = controller;
    spawnIsolateInspectorServer(this, controller);
    _uiInspector = UIInspector(this);
    controller.view.debugDOMTreeChanged = uiInspector!.onDOMTreeChanged;
  }

  @override
  void willReload() {
    _reloading = true;
  }

  @override
  void didReload() {
    _reloading = false;
    controller!.view.debugDOMTreeChanged = _uiInspector!.onDOMTreeChanged;
    _isolateServerPort!.send(InspectorReload(_controller!.view.contextId));
  }
}
