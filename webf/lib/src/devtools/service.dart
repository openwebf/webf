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

void spawnIsolateInspectorServer(DevToolsService devTool, WebFController controller,
    {int port = INSPECTOR_DEFAULT_PORT, String? address}) {
  ReceivePort serverIsolateReceivePort = ReceivePort();

  serverIsolateReceivePort.listen((data) {
    if (data is SendPort) {
      devTool.isolateServerPort = data;
      String bundleURL = controller.url;
      if (bundleURL.isEmpty) {
        bundleURL = '<EmbedBundle>';
      }
      if (devTool is ChromeDevToolsService) {
        devTool.isolateServerPort!.send(InspectorServerInit(controller.view.contextId, port, '0.0.0.0', bundleURL));
      } else if (devTool is RemoteDevServerService) {
        devTool.isolateServerPort!.send(InspectorServerConnect(devTool.url));
      }
    } else if (data is InspectorFrontEndMessage) {
      devTool.uiInspector!.messageRouter(data.id, data.module, data.method, data.params);
    } else if (data is InspectorServerStart) {
      devTool.uiInspector!.onServerStart(port);
    } else if (data is InspectorClientConnected) {
      devTool.uiInspector!.onClientConnected();
    }
  });

  Isolate.spawn(serverIsolateEntryPoint, serverIsolateReceivePort.sendPort).then((Isolate isolate) {
    devTool.isolateServer = isolate;
  });
}

class ChromeDevToolsService extends DevToolsService {

}

class RemoteDevServerService extends DevToolsService {
  String url;
  RemoteDevServerService(this.url);
}
