/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

/// Chrome DevTools Service - Refactored Implementation
///
/// This service provides Chrome DevTools debugging capabilities for WebF controllers.
/// The refactored implementation:
/// - Runs entirely in the main Dart thread (no isolates)
/// - Supports multiple WebF controllers through a unified service
/// - Integrates with WebFControllerManager for centralized management
/// - Provides a single DevTools endpoint for all controllers

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';

/// Abstract base class for implementing DevTools debugging services for WebF content.
///
/// Provides the infrastructure needed to connect Chrome DevTools to a WebF instance,
/// enabling inspection of DOM elements, JavaScript debugging, network monitoring,
/// and other developer tools features.
abstract class DevToolsService {
  /// Previous instance of DevToolsService during a page reload.
  ///
  /// Design prevDevTool for reload page,
  /// do not use it in any other place.
  /// More detail see [InspectPageModule.handleReloadPage].
  static DevToolsService? prevDevTools;

  static final Map<double, DevToolsService> _contextDevToolMap = {};

  /// Retrieves the DevTools service instance associated with a specific JavaScript context ID.
  ///
  /// @param contextId The unique identifier for a JavaScript context
  /// @return The DevToolsService instance for the context, or null if none exists
  static DevToolsService? getDevToolOfContextId(double contextId) {
    return _contextDevToolMap[contextId];
  }

  /// Used for debugger inspector.
  UIInspector? _uiInspector;

  /// Provides access to the UI inspector for debugging DOM elements.
  ///
  /// The UI inspector enables visualization and inspection of the DOM structure
  /// and rendered elements in DevTools.
  UIInspector? get uiInspector => _uiInspector;

  /// The Dart isolate running the DevTools server.
  ///
  /// DevTools runs in a separate isolate to avoid impacting the performance
  /// of the main Flutter application.
  Isolate? _isolateServer;

  /// Access to the isolate running the DevTools server.
  ///
  /// This isolate handles communication with Chrome DevTools.
  Isolate get isolateServer => _isolateServer!;

  /// Sets the isolate for the DevTools server.
  ///
  /// @param isolate The Dart isolate instance handling DevTools communication
  set isolateServer(Isolate isolate) {
    _isolateServer = isolate;
  }

  SendPort? _isolateServerPort;

  SendPort? get isolateServerPort => _isolateServerPort;

  set isolateServerPort(SendPort? value) {
    _isolateServerPort = value;
  }

  WebFController? _controller;

  WebFController? get controller => _controller;

  /// Initializes the DevTools service for a WebF controller.
  ///
  /// Sets up the inspector server and UI inspector, enabling Chrome DevTools
  /// to connect to and debug the WebF content.
  ///
  /// @param controller The WebFController instance to enable debugging for
  void init(WebFController controller) {
    _contextDevToolMap[controller.view.contextId] = this;
    _controller = controller;
    _uiInspector = UIInspector(this);
    controller.view.debugDOMTreeChanged = uiInspector!.onDOMTreeChanged;
  }

  /// Indicates whether the WebF content is currently being reloaded.
  ///
  /// Used to manage DevTools state during page reloads.
  bool get isReloading => _reloading;

  /// Internal flag to track reload state.
  bool _reloading = false;

  /// Called before WebF content is reloaded to prepare DevTools.
  ///
  /// Sets the reloading flag to true to prevent DevTools operations during reload.
  void willReload() {
    _reloading = true;
  }

  /// Called after WebF content has been reloaded to reconnect DevTools.
  ///
  /// Updates the DOM tree change handlers and notifies the inspector server
  /// about the reload completion.
  void didReload() {
    _reloading = false;
    controller!.view.debugDOMTreeChanged = _uiInspector!.onDOMTreeChanged;
    _isolateServerPort!.send(InspectorReload(_controller!.view.contextId));
  }

  /// Disposes the DevTools service and releases all resources.
  ///
  /// Cleans up the UI inspector, removes context mappings, and terminates
  /// the inspector isolate server.
  void dispose() {
    _uiInspector?.dispose();
    _contextDevToolMap.remove(controller?.view.contextId);
    _controller = null;
    _isolateServerPort = null;
    _isolateServer?.kill();
  }
}

class ChromeDevToolsService extends DevToolsService {
  static UnifiedChromeDevToolsService? _unifiedService;

  /// Get or create the unified DevTools service
  static UnifiedChromeDevToolsService get unifiedService {
    _unifiedService ??= UnifiedChromeDevToolsService._();
    return _unifiedService!;
  }

  @override
  void init(WebFController controller) {
    // Call parent init to set up the controller and UI inspector
    super.init(controller);

    // Register this controller with the unified service
    unifiedService._registerController(controller, this);

    // Start the unified service if not already running
    if (!unifiedService.isRunning) {
      unifiedService.start().then((_) {
        print('Chrome DevTools service started');
      }).catchError((error) {
        print('Failed to start DevTools service: $error');
      });
    }
  }

  @override
  void dispose() {
    // Unregister from unified service
    if (controller != null) {
      unifiedService._unregisterController(controller!);
    }

    // Call parent dispose
    super.dispose();
  }

}

class RemoteDevServerService extends DevToolsService {
  final String url;
  RemoteDevServerService(this.url);

  @override
  void init(WebFController controller) {
    // TODO: Implement remote dev server connection
    // For now, just initialize the base class
    super.init(controller);
  }
}

/// Unified DevTools service that manages debugging for all WebF controllers
class UnifiedChromeDevToolsService {
  // Private constructor for singleton
  UnifiedChromeDevToolsService._();

  // Server configuration
  String _address = '0.0.0.0';
  int _port = INSPECTOR_DEFAULT_PORT;
  HttpServer? _httpServer;
  bool _isRunning = false;
  String? _devToolsUrl;

  // WebSocket connections
  final Map<String, WebSocketChannel> _connections = {};

  // Inspector modules (both UI and isolate modules unified)
  final Map<String, dynamic> _modules = {};

  // Currently selected controller for inspection
  WebFController? _currentController;
  ChromeDevToolsService? _currentService;

  // Registered controllers and their services
  final Map<WebFController, ChromeDevToolsService> _controllerServices = {};

  // Module instances that handle inspector functionality
  RuntimeInspectorModule? _runtimeModule;
  DebuggerInspectorModule? _debuggerModule;
  LogInspectorModule? _logModule;

  bool get isRunning => _isRunning;

  /// Gets the DevTools connection URL if the server is running
  String? get devToolsUrl => _devToolsUrl;

  void _registerController(WebFController controller, ChromeDevToolsService service) {
    _controllerServices[controller] = service;

    // If no controller is selected, select this one
    if (_currentController == null) {
      _selectController(controller);
    }

    // Notify connected clients about new controller
    _broadcastTargetListUpdate();
  }

  void _unregisterController(WebFController controller) {
    _controllerServices.remove(controller);

    // If this was the current controller, select another one
    if (_currentController == controller) {
      _currentController = null;
      _currentService = null;
      if (_controllerServices.isNotEmpty) {
        _selectController(_controllerServices.keys.first);
      }
    }

    // Notify connected clients about controller removal
    _broadcastTargetListUpdate();
  }

  void _selectController(WebFController controller) {
    if (!_controllerServices.containsKey(controller)) return;

    _currentController = controller;
    _currentService = _controllerServices[controller];

    // Notify all modules about controller change
    _runtimeModule?.onControllerChanged(controller);
    _debuggerModule?.onControllerChanged(controller);
    _logModule?.onControllerChanged(controller);

    // Notify connected clients
    _broadcastTargetListUpdate();
  }

  /// Start the DevTools server
  Future<void> start({String? address, int? port}) async {
    if (_isRunning) return;

    _address = address ?? _address;
    _port = port ?? _port;

    // Initialize modules
    _initializeModules();

    // Start HTTP server
    await _startServer();

    _isRunning = true;
  }

  /// Stop the DevTools server
  Future<void> stop() async {
    if (!_isRunning) return;

    // Close all WebSocket connections
    for (final connection in _connections.values) {
      await connection.sink.close();
    }
    _connections.clear();

    // Stop HTTP server
    await _httpServer?.close();
    _httpServer = null;
    _devToolsUrl = null;

    // Dispose modules
    _runtimeModule = null;
    _debuggerModule = null;
    _logModule = null;
    _modules.clear();

    _isRunning = false;
  }

  void _initializeModules() {
    // Initialize inspector modules that previously ran in isolate
    _runtimeModule = RuntimeInspectorModule(this);
    _debuggerModule = DebuggerInspectorModule(this);
    _logModule = LogInspectorModule(this);

    // Register modules
    _modules['Runtime'] = _runtimeModule;
    _modules['Debugger'] = _debuggerModule;
    _modules['Log'] = _logModule;
  }

  Future<void> _startServer() async {
    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(_handleRequest);

    _httpServer = await io.serve(handler, _address, _port);

    // Get actual IP addresses
    String connectAddress = _httpServer!.address.host;
    List<String> availableIPs = [];

    if (connectAddress == '0.0.0.0' || connectAddress == '::') {
      // When bound to all interfaces, get the actual IP addresses
      final interfaces = await NetworkInterface.list();

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.address.startsWith('127.') && // Skip loopback
              addr.address != '0.0.0.0') {
            availableIPs.add(addr.address);
          }
        }
      }

      // Find the most likely LAN IP (usually starts with 192.168, 10., or 172.)
      String? primaryIP = availableIPs.firstWhere(
        (ip) => ip.startsWith('192.168.') || ip.startsWith('10.') || ip.startsWith('172.'),
        orElse: () => availableIPs.isNotEmpty ? availableIPs.first : 'localhost'
      );

      connectAddress = primaryIP;
    } else {
      availableIPs.add(connectAddress);
    }

    // Store the primary DevTools URL
    _devToolsUrl = 'devtools://devtools/bundled/inspector.html?ws=$connectAddress:${_httpServer!.port}';

    print('╔════════════════════════════════════════════════════════════════════╗');
    print('║                Chrome DevTools Server Started                       ║');
    print('╚════════════════════════════════════════════════════════════════════╝');
    print('');
    print('DevTools is listening on port ${_httpServer!.port} on all network interfaces.');
    print('');
    print('To debug your WebF application, open Chrome or Edge and navigate to:');
    print('');
    print('  $_devToolsUrl');
    print('');

    if (availableIPs.length > 1) {
      print('Available on multiple network interfaces:');
      for (final ip in availableIPs) {
        print('  • devtools://devtools/bundled/inspector.html?ws=$ip:${_httpServer!.port}');
      }
      print('');
    }

    print('You can also use localhost:');
    print('  • devtools://devtools/bundled/inspector.html?ws=localhost:${_httpServer!.port}');
    print('');
    print('For debugging tools, visit:');
    print('  • http://$connectAddress:${_httpServer!.port}/json/version');
    print('  • http://$connectAddress:${_httpServer!.port}/json/list');
    print('');
    print('─' * 70);
  }

  Future<shelf.Response> _handleRequest(shelf.Request request) async {
    final path = request.url.path;

    if (path == 'json/version') {
      return _handleVersion(request);
    } else if (path == 'json' || path == 'json/list') {
      return _handleList(request);
    } else if (path == '') {
      final handler = webSocketHandler(_handleWebSocket);
      return await handler(request);
    }

    return shelf.Response.notFound('Not found');
  }

  shelf.Response _handleVersion(shelf.Request request) {
    final version = {
      'Browser': 'WebF/0.17.0',
      'Protocol-Version': '1.3',
      'User-Agent': 'WebF DevTools Service',
      'V8-Version': '9.1.269.36',
      'WebKit-Version': '537.36',
      'webSocketDebuggerUrl': 'ws://${request.headers['host']}',
    };

    return shelf.Response.ok(
      jsonEncode(version),
      headers: {'Content-Type': 'application/json'},
    );
  }

  shelf.Response _handleList(shelf.Request request) {
    final targets = _getTargetList().map((target) {
      return {
        'id': target['id'],
        'type': 'page',
        'title': target['title'],
        'url': target['url'],
        'devtoolsFrontendUrl': 'devtools://devtools/bundled/js_app.html?ws=${request.headers['host']}',
        'webSocketDebuggerUrl': 'ws://${request.headers['host']}',
      };
    }).toList();

    return shelf.Response.ok(
      jsonEncode(targets),
      headers: {'Content-Type': 'application/json'},
    );
  }

  void _handleWebSocket(WebSocketChannel webSocket) {
    final connectionId = DateTime.now().millisecondsSinceEpoch.toString();
    _connections[connectionId] = webSocket;

    webSocket.stream.listen(
      (message) => _handleWebSocketMessage(connectionId, message),
      onError: (error) {
        print('WebSocket error: $error');
        _connections.remove(connectionId);
      },
      onDone: () {
        _connections.remove(connectionId);
      },
    );
  }

  void _handleWebSocketMessage(String connectionId, message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final method = data['method'] as String?;
      final id = data['id'];
      final params = data['params'] as Map<String, dynamic>?;

      if (method == null) return;

      // Parse method to get module and command
      final parts = method.split('.');
      if (parts.length < 2) return;

      final module = parts[0];
      final command = parts[1];

      // Handle Target domain specially for multi-controller support
      if (module == 'Target') {
        _handleTargetMethod(connectionId, id, command, params);
        return;
      }

      // Route to appropriate module or UI inspector
      if (_modules.containsKey(module)) {
        // Handle modules that run in the main thread
        final moduleInstance = _modules[module];
        moduleInstance.invoke(id, command, params);
      } else if (_currentService != null && _currentService!.uiInspector != null) {
        // Route to UI inspector for DOM, CSS, etc.
        _currentService!.uiInspector!.messageRouter(id, module, command, params);
      } else {
        // Send error response
        _sendErrorResponse(connectionId, id, 'No controller selected or module not found');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _handleTargetMethod(String connectionId, int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'getTargets':
        _sendResponse(connectionId, id, {
          'targetInfos': _getTargetList(),
        });
        break;

      case 'attachToTarget':
        final targetId = params?['targetId'] as String?;
        if (targetId != null) {
          final controller = _findControllerById(targetId);
          if (controller != null) {
            _selectController(controller);
            _sendResponse(connectionId, id, {
              'sessionId': targetId,
            });
          } else {
            _sendErrorResponse(connectionId, id, 'Target not found');
          }
        } else {
          _sendErrorResponse(connectionId, id, 'Missing targetId');
        }
        break;

      default:
        _sendErrorResponse(connectionId, id, 'Unknown Target method: $method');
    }
  }

  WebFController? _findControllerById(String targetId) {
    // Try to find by context ID
    for (final entry in _controllerServices.entries) {
      if (entry.key.view.contextId.toString() == targetId) {
        return entry.key;
      }
    }

    // Try to find by controller name in manager
    final manager = WebFControllerManager.instance;
    if (manager.hasController(targetId)) {
      final controller = manager.getControllerSync(targetId);
      if (controller != null && _controllerServices.containsKey(controller)) {
        return controller;
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _getTargetList() {
    final manager = WebFControllerManager.instance;
    final targets = <Map<String, dynamic>>[];

    // Add controllers from manager
    for (final name in manager.controllerNames) {
      final controller = manager.getControllerSync(name);
      if (controller != null && _controllerServices.containsKey(controller)) {
        targets.add({
          'id': name,
          'title': 'WebF Page - $name',
          'url': controller.url ?? '',
          'attached': controller == _currentController,
        });
      }
    }

    // Add any controllers not in manager
    for (final entry in _controllerServices.entries) {
      final controller = entry.key;
      final name = manager.getControllerName(controller);
      if (name == null) {
        targets.add({
          'id': controller.view.contextId.toString(),
          'title': 'WebF Page',
          'url': controller.url ?? '',
          'attached': controller == _currentController,
        });
      }
    }

    return targets;
  }

  void _sendResponse(String connectionId, int? id, Map<String, dynamic> result) {
    if (id == null) return;

    final response = {
      'id': id,
      'result': result,
    };

    final connection = _connections[connectionId];
    connection?.sink.add(jsonEncode(response));
  }

  void _sendErrorResponse(String connectionId, int? id, String message) {
    if (id == null) return;

    final response = {
      'id': id,
      'error': {
        'code': -32000,
        'message': message,
      },
    };

    final connection = _connections[connectionId];
    connection?.sink.add(jsonEncode(response));
  }

  void sendEventToFrontend(InspectorEvent event) {
    final message = jsonEncode(event.toJson());

    for (final connection in _connections.values) {
      try {
        connection.sink.add(message);
      } catch (e) {
        print('Error sending event: $e');
      }
    }
  }

  void sendMethodResult(int id, Map<String, dynamic> result) {
    // Find the connection that made this request
    // For now, broadcast to all connections
    final response = {
      'id': id,
      'result': result,
    };

    final message = jsonEncode(response);
    for (final connection in _connections.values) {
      try {
        connection.sink.add(message);
      } catch (e) {
        print('Error sending result: $e');
      }
    }
  }

  void _broadcastTargetListUpdate() {
    sendEventToFrontend(TargetCreatedEvent(
      targetInfos: _getTargetList(),
    ));
  }

  shelf.Middleware _corsMiddleware() {
    return (shelf.Handler innerHandler) {
      return (shelf.Request request) async {
        final response = await innerHandler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Methods': '*',
        });
      };
    };
  }

  // Getters for current state
  WebFController? get currentController => _currentController;
  ChromeDevToolsService? get currentService => _currentService;
}

// Inspector module classes
class RuntimeInspectorModule {
  final UnifiedChromeDevToolsService service;

  RuntimeInspectorModule(this.service);

  void onControllerChanged(WebFController controller) {
    // Handle controller change
  }

  void invoke(int? id, String method, Map<String, dynamic>? params) {
    // TODO: Implement Runtime methods
    if (id != null) {
      service.sendMethodResult(id, {});
    }
  }
}

class DebuggerInspectorModule {
  final UnifiedChromeDevToolsService service;

  DebuggerInspectorModule(this.service);

  void onControllerChanged(WebFController controller) {
    // Handle controller change
  }

  void invoke(int? id, String method, Map<String, dynamic>? params) {
    // TODO: Implement Debugger methods
    if (id != null) {
      service.sendMethodResult(id, {});
    }
  }
}

class LogInspectorModule {
  final UnifiedChromeDevToolsService service;

  LogInspectorModule(this.service);

  void onControllerChanged(WebFController controller) {
    // Handle controller change
  }

  void invoke(int? id, String method, Map<String, dynamic>? params) {
    // TODO: Implement Log methods
    if (id != null) {
      service.sendMethodResult(id, {});
    }
  }
}

// Event classes for DevTools protocol
class TargetCreatedEvent extends InspectorEvent {
  final List<Map<String, dynamic>> targetInfos;

  TargetCreatedEvent({required this.targetInfos});

  @override
  String get method => 'Target.targetCreated';

  @override
  JSONEncodable? get params => JSONEncodableMap({'targetInfos': targetInfos});
}

/// Usage Instructions:
///
/// DevTools is automatically enabled in debug mode and disabled in profile/release builds.
///
/// 1. Using WebFControllerManager (recommended):
///    ```dart
///    WebFControllerManager.instance.initialize(
///      WebFControllerManagerConfig(
///        // enableDevTools: true by default in debug mode
///        devToolsPort: 9222,
///      ),
///    );
///    ```
///
/// 2. To explicitly control DevTools:
///    ```dart
///    WebFControllerManager.instance.initialize(
///      WebFControllerManagerConfig(
///        enableDevTools: false, // Disable even in debug mode
///        // or
///        enableDevTools: true,  // Enable even in release mode
///      ),
///    );
///    ```
///
/// 3. Connect Chrome DevTools to the URL printed in console:
///    devtools://devtools/bundled/inspector.html?ws=localhost:9222
