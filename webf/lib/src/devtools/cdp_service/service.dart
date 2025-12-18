/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

/// Chrome DevTools Service - Refactored Implementation
///
/// This service provides Chrome DevTools debugging capabilities for WebF controllers.
/// The refactored implementation:
/// - Runs entirely in the main Dart thread (no isolates)
/// - Supports multiple WebF controllers through a unified service
/// - Integrates with WebFControllerManager for centralized management
/// - Provides a single DevTools endpoint for all controllers
library;


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart';
import 'package:webf/devtools.dart';
import 'debugging_context.dart';
// Import for DOMClearEvent and DOMEmptyDocumentEvent

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

  static final Map<int, DevToolsService> _contextDevToolMap = {};

  /// Retrieves the DevTools service instance associated with a specific JavaScript context ID.
  ///
  /// @param contextId The unique identifier for a JavaScript context
  /// @return The DevToolsService instance for the context, or null if none exists
  static DevToolsService? getDevToolOfContextId(int contextId) {
    return _contextDevToolMap[contextId];
  }

  /// Used for debugger inspector.
  UIInspector? _uiInspector;

  /// Provides access to the UI inspector for debugging DOM elements.
  ///
  /// The UI inspector enables visualization and inspection of the DOM structure
  /// and rendered elements in DevTools.
  UIInspector? get uiInspector => _uiInspector;

  DebuggingContext? _context;
  WebFController? _controller; // Keep for backward compatibility

  DebuggingContext? get context => _context;

  WebFController? get controller =>
      _controller; // Deprecated, use context instead

  /// Initializes the DevTools service with a debugging context.
  ///
  /// Sets up the inspector server and UI inspector, enabling Chrome DevTools
  /// to connect to and debug the WebF content.
  ///
  /// @param context The DebuggingContext instance to enable debugging for
  void initWithContext(DebuggingContext context) {
    _contextDevToolMap[context.contextId] = this;
    _context = context;
    _uiInspector = UIInspector(this);
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] initWithContext: ctx=${context.contextId} url=${context.url ?? ''}');
    }
    // Legacy full refresh callback
    context.debugDOMTreeChanged = () => uiInspector!.onDOMTreeChanged();
    // Incremental mutation callbacks (only used by new DOM incremental update logic).
    context.debugChildNodeInserted = (parent, node, previousSibling) {
      if (this is ChromeDevToolsService) {
        bool didSeed = false;
        // Skip whitespace-only text nodes to keep Elements clean
        try {
          if (node is TextNode && node.data.trim().isEmpty) {
            if (DebugFlags.enableDevToolsProtocolLogs) {
              final pId = context.forDevtoolsNodeId(parent);
              devToolsProtocolLogger.finer(
                  '[DevTools] (skip) DOM.childNodeInserted whitespace-only text under parent=$pId');
            }
            // Even if skipping the insertion event, ensure the parent is seeded
            // so that any subsequent characterDataModified for this text node
            // references a node already known by the frontend.
            try {
              final pId = context.forDevtoolsNodeId(parent);
              if (!ChromeDevToolsService.unifiedService._isParentSeeded(pId)) {
                final children = <Map>[];
                for (final c in parent.childNodes) {
                  if (c is Element || (c is TextNode && c.data.trim().isNotEmpty)) {
                    children.add(InspectorNode(c).toJson());
                  }
                }
                ChromeDevToolsService.unifiedService.sendEventToFrontend(
                    DOMSetChildNodesEvent(parentId: pId, nodes: children));
                if (DebugFlags.enableDevToolsProtocolLogs) {
                  try {
                    final ids = children.map((m) => m['nodeId']).toList();
                    devToolsProtocolLogger.finer(
                        '[DevTools] -> DOM.setChildNodes parent=$pId count=${children.length} (seed) ids=$ids');
                  } catch (_) {
                    devToolsProtocolLogger.finer(
                        '[DevTools] -> DOM.setChildNodes parent=$pId count=${children.length} (seed)');
                  }
                }
                ChromeDevToolsService.unifiedService._markParentSeeded(pId);
                didSeed = true;
              }
            } catch (_) {}
            return;
          }
        } catch (_) {}
        // Ensure the parent has an established children list in DevTools.
        try {
          final pId = context.forDevtoolsNodeId(parent);
          if (!ChromeDevToolsService.unifiedService._isParentSeeded(pId)) {
            final children = <Map>[];
            for (final c in parent.childNodes) {
              if (c is Element || (c is TextNode && c.data.trim().isNotEmpty)) {
                children.add(InspectorNode(c).toJson());
              }
            }
            ChromeDevToolsService.unifiedService.sendEventToFrontend(
                DOMSetChildNodesEvent(parentId: pId, nodes: children));
            if (DebugFlags.enableDevToolsProtocolLogs) {
              try {
                final ids = children.map((m) => m['nodeId']).toList();
                devToolsProtocolLogger.finer(
                    '[DevTools] -> DOM.setChildNodes parent=$pId count=${children.length} (seed) ids=$ids');
              } catch (_) {
                devToolsProtocolLogger
                    .finer('[DevTools] -> DOM.setChildNodes parent=$pId count=${children.length} (seed)');
              }
            }
            ChromeDevToolsService.unifiedService._markParentSeeded(pId);
            didSeed = true;
          }
        } catch (_) {}

        // If we just seeded the children list, do not also emit an insert for the same node.
        if (didSeed) {
          // Still update child count since structure changed
          try {
            final count = parent.childNodes
                .where((c) => c is Element || (c is TextNode && c.data.trim().isNotEmpty))
                .length;
            ChromeDevToolsService.unifiedService.sendEventToFrontend(
                DOMChildNodeCountUpdatedEvent(node: parent, childNodeCount: count));
          } catch (_) {}
          return;
        }
        if (DebugFlags.enableDevToolsProtocolLogs) {
          try {
            final pId = context.forDevtoolsNodeId(parent);
            final nId = context.forDevtoolsNodeId(node);
            final prevId = previousSibling != null ? context.forDevtoolsNodeId(previousSibling) : 0;
            final name = node.nodeName;
            devToolsProtocolLogger.finer(
                '[DevTools] -> DOM.childNodeInserted parent=$pId prev=$prevId node=$nId name=$name');
          } catch (_) {}
        }
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMChildNodeInsertedEvent(
          parent: parent,
          node: node,
          previousSibling: previousSibling,
        ));
        // Update child count for the parent
        try {
          final count = parent.childNodes
              .where((c) => c is Element || (c is TextNode && c.data.trim().isNotEmpty))
              .length;
          ChromeDevToolsService.unifiedService.sendEventToFrontend(
              DOMChildNodeCountUpdatedEvent(node: parent, childNodeCount: count));
        } catch (_) {}
      }
    };
    context.debugChildNodeRemoved = (parent, node) {
      if (this is ChromeDevToolsService) {
        bool didSeed = false;
        // Skip whitespace-only text nodes (never sent to frontend)
        try {
          if (node is TextNode && node.data.trim().isEmpty) {
            if (DebugFlags.enableDevToolsProtocolLogs) {
              final pId = context.forDevtoolsNodeId(parent);
              devToolsProtocolLogger.finer(
                  '[DevTools] (skip) DOM.childNodeRemoved whitespace-only text under parent=$pId');
            }
            return;
          }
        } catch (_) {}
        // Ensure the parent has an established children list in DevTools.
        try {
          final pId = context.forDevtoolsNodeId(parent);
          if (!ChromeDevToolsService.unifiedService._isParentSeeded(pId)) {
            final children = <Map>[];
            for (final c in parent.childNodes) {
              if (c is Element || (c is TextNode && c.data.trim().isNotEmpty)) {
                children.add(InspectorNode(c).toJson());
              }
            }
            ChromeDevToolsService.unifiedService.sendEventToFrontend(
                DOMSetChildNodesEvent(parentId: pId, nodes: children));
            if (DebugFlags.enableDevToolsProtocolLogs) {
              try {
                final ids = children.map((m) => m['nodeId']).toList();
                devToolsProtocolLogger.finer(
                    '[DevTools] -> DOM.setChildNodes parent=$pId count=${children.length} (seed) ids=$ids');
              } catch (_) {
                devToolsProtocolLogger
                    .finer('[DevTools] -> DOM.setChildNodes parent=$pId count=${children.length} (seed)');
              }
            }
            ChromeDevToolsService.unifiedService._markParentSeeded(pId);
            didSeed = true;
          }
        } catch (_) {}
        // If we just seeded with the current children (which no longer includes the removed node),
        // still update the count and skip removal event for unknown node.
        if (didSeed) {
          try {
            final count = parent.childNodes
                .where((c) => c is Element || (c is TextNode && c.data.trim().isNotEmpty))
                .length;
            ChromeDevToolsService.unifiedService.sendEventToFrontend(
                DOMChildNodeCountUpdatedEvent(node: parent, childNodeCount: count));
          } catch (_) {}
          return;
        }
        if (DebugFlags.enableDevToolsProtocolLogs) {
          try {
            final pId = context.forDevtoolsNodeId(parent);
            final nId = context.forDevtoolsNodeId(node);
            final name = node.nodeName;
            devToolsProtocolLogger
                .finer('[DevTools] -> DOM.childNodeRemoved parent=$pId node=$nId name=$name');
          } catch (_) {}
        }
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMChildNodeRemovedEvent(
          parent: parent,
          node: node,
        ));
        // Update child count for the parent
        try {
          final count = parent.childNodes
              .where((c) => c is Element || (c is TextNode && c.data.trim().isNotEmpty))
              .length;
          ChromeDevToolsService.unifiedService.sendEventToFrontend(
              DOMChildNodeCountUpdatedEvent(node: parent, childNodeCount: count));
        } catch (_) {}
      }
    };
    context.debugAttributeModified = (element, name, value) {
      if (this is ChromeDevToolsService) {
        if (DebugFlags.enableDevToolsProtocolLogs) {
          try {
            final id = context.forDevtoolsNodeId(element);
            devToolsProtocolLogger
                .finer('[DevTools] -> DOM.attributeModified node=$id name=$name value=${value ?? ''}');
          } catch (_) {}
        }
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMAttributeModifiedEvent(
          element: element,
          name: name,
          value: value,
        ));
        // Also notify CSS module tracking that the element's computed style may be updated
        final cssModule = uiInspector?.moduleRegistrar['CSS'];
        if (cssModule is InspectCSSModule) {
          final nodeId = context.forDevtoolsNodeId(element);
          cssModule.markComputedStyleDirtyByNodeId(nodeId);
        }
      }
    };
    context.debugAttributeRemoved = (element, name) {
      if (this is ChromeDevToolsService) {
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMAttributeRemovedEvent(
          element: element,
          name: name,
        ));
        if (DebugFlags.enableDevToolsProtocolLogs) {
          devToolsProtocolLogger.finer('[DevTools] -> DOM.attributeRemoved name=$name');
        }
        final cssModule = uiInspector?.moduleRegistrar['CSS'];
        if (cssModule is InspectCSSModule) {
          final nodeId = context.forDevtoolsNodeId(element);
          cssModule.markComputedStyleDirtyByNodeId(nodeId);
        }
      }
    };
    context.debugCharacterDataModified = (textNode) {
      if (this is ChromeDevToolsService) {
        // Ignore modifications that make a text node whitespace-only
        try {
          if (textNode.data.trim().isEmpty) {
            if (DebugFlags.enableDevToolsProtocolLogs) {
              final id = context.forDevtoolsNodeId(textNode);
              devToolsProtocolLogger
                  .finer('[DevTools] (skip) DOM.characterDataModified node=$id (whitespace-only)');
            }
            return;
          }
        } catch (_) {}
        // Ensure parent is seeded so frontend knows the text node
        try {
          final parent = textNode.parentNode;
          if (parent != null) {
            final pId = context.forDevtoolsNodeId(parent);
            if (!ChromeDevToolsService.unifiedService._isParentSeeded(pId)) {
              final children = <Map>[];
              for (final c in parent.childNodes) {
                if (c is Element || (c is TextNode && c.data.trim().isNotEmpty)) {
                  children.add(InspectorNode(c).toJson());
                }
              }
              ChromeDevToolsService.unifiedService.sendEventToFrontend(
                  DOMSetChildNodesEvent(parentId: pId, nodes: children));
              if (DebugFlags.enableDevToolsProtocolLogs) {
                try {
                  final ids = children.map((m) => m['nodeId']).toList();
                  devToolsProtocolLogger.finer(
                      '[DevTools] -> DOM.setChildNodes parent=$pId count=${children.length} (seed) ids=$ids');
                } catch (_) {
                  devToolsProtocolLogger.finer(
                      '[DevTools] -> DOM.setChildNodes parent=$pId count=${children.length} (seed)');
                }
              }
              ChromeDevToolsService.unifiedService._markParentSeeded(pId);
            }
            // If the text node hasn't been announced yet (e.g., was whitespace when inserted),
            // send an insertion now before characterDataModified so the frontend can track it.
            try {
              final nId = context.forDevtoolsNodeId(textNode);
              if (!ChromeDevToolsService.unifiedService._isNodeKnown(nId)) {
                Node? prev = textNode.previousSibling;
                Node? chosenPrev;
                while (prev != null) {
                  try {
                    final pid = context.forDevtoolsNodeId(prev);
                    if (ChromeDevToolsService.unifiedService._isNodeKnown(pid)) {
                      chosenPrev = prev;
                      break;
                    }
                  } catch (_) {}
                  prev = prev.previousSibling;
                }
                ChromeDevToolsService.unifiedService.sendEventToFrontend(
                    DOMChildNodeInsertedEvent(
                        parent: parent,
                        node: textNode,
                        previousSibling: chosenPrev));
                if (DebugFlags.enableDevToolsProtocolLogs) {
                  try {
                    final prevId = chosenPrev != null ? context.forDevtoolsNodeId(chosenPrev) : 0;
                    devToolsProtocolLogger.finer(
                        '[DevTools] -> DOM.childNodeInserted parent=$pId prev=$prevId node=$nId name=#text');
                  } catch (_) {}
                }
              }
            } catch (_) {}
          }
        } catch (_) {}
        if (DebugFlags.enableDevToolsProtocolLogs) {
          try {
            final id = context.forDevtoolsNodeId(textNode);
            final preview = textNode.data.length > 30
                ? '${textNode.data.substring(0, 30)}…'
                : textNode.data;
            devToolsProtocolLogger
                .finer('[DevTools] -> DOM.characterDataModified node=$id data="$preview"');
          } catch (_) {}
        }
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMCharacterDataModifiedEvent(
          node: textNode,
        ));
        final cssModule = uiInspector?.moduleRegistrar['CSS'];
        if (cssModule is InspectCSSModule) {
          final nodeId = context.forDevtoolsNodeId(textNode);
          cssModule.markComputedStyleDirtyByNodeId(nodeId);
        }
      }
    };
  }

  /// Legacy initialization method for backward compatibility
  /// @deprecated Use initWithContext instead
  void init(WebFController controller) {
    _controller = controller;
    final adapter = WebFControllerDebuggingAdapter(controller);
    initWithContext(adapter);
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
    if (_context != null) {
      _context!.debugDOMTreeChanged = () => _uiInspector!.onDOMTreeChanged();
    }
    // For unified service, send DOM updated event directly
    if (this is ChromeDevToolsService) {
      ChromeDevToolsService.unifiedService
          .sendEventToFrontend(DOMUpdatedEvent());
      if (DebugFlags.enableDevToolsProtocolLogs) {
        devToolsProtocolLogger.finer('[DevTools] -> DOM.documentUpdated (didReload)');
      }
    }
  }

  /// Disposes the DevTools service and releases all resources.
  ///
  /// Cleans up the UI inspector, removes context mappings, and terminates
  /// the inspector isolate server.
  void dispose() {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] dispose context=${_context?.contextId}');
    }
    _uiInspector?.dispose();
    if (_context != null) {
      _contextDevToolMap.remove(_context!.contextId);
      _context!.dispose();
    }
    _context = null;
    _controller = null;
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
  void initWithContext(DebuggingContext context) {
    // Call parent init to set up the context and UI inspector
    super.initWithContext(context);

    // Register this context with the unified service
    unifiedService._registerContext(context, this);

    // Start the unified service if not already running
    if (!unifiedService.isRunning) {
      unifiedService.start().then((_) {
        debugPrint('Chrome DevTools service started');
      }).catchError((error) {
        debugPrint('Failed to start DevTools service: $error');
      });
    }
  }


  @override
  void dispose() {
    // Unregister from unified service
    if (_context != null) {
      unifiedService._unregisterContext(_context!);
    }

    // Call parent dispose
    super.dispose();
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

  // Test hooks: listeners to observe outbound events without a WS client
  final List<void Function(InspectorEvent)> _testEventListeners = [];
  void addEventListenerForTest(void Function(InspectorEvent) listener) {
    _testEventListeners.add(listener);
  }
  void clearEventListenersForTest() {
    _testEventListeners.clear();
  }

  // Inspector modules (both UI and isolate modules unified)
  final Map<String, dynamic> _modules = {};

  // Currently selected context for inspection
  DebuggingContext? _currentContext;
  ChromeDevToolsService? _currentService;

  // Flag to indicate if we're in the middle of a context switch
  bool _isContextSwitching = false;

  // Track which parent nodes have had their child lists seeded to the frontend
  final Set<int> _seededParentIds = {};

  // Track nodes that the frontend already knows about (via setChildNodes/childNodeInserted)
  final Set<int> _knownNodeIds = {};

  // Queue of incoming messages (decoded) received before a context exists, to replay after first context selection.
  final List<Map<String, dynamic>> _preContextMessageQueue = [];

  // Registered contexts and their services
  final Map<DebuggingContext, ChromeDevToolsService> _contextServices = {};

  // Keep controller mapping for backward compatibility
  final Map<WebFController, DebuggingContext> _controllerToContext = {};

  bool get isRunning => _isRunning;

  /// Gets the DevTools connection URL if the server is running
  String? get devToolsUrl => _devToolsUrl;

  void _registerContext(
      DebuggingContext context, ChromeDevToolsService service) {
    _contextServices[context] = service;
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] register context=${context.contextId} total=${_contextServices.length}');
    }

    // If this context comes from a controller, track the mapping
    if (context is WebFControllerDebuggingAdapter) {
      _controllerToContext[context.controller] = context;
    }

    // If no context is selected, select this one
    if (_currentContext == null) {
      _selectContext(context);
    } else {
      // Notify connected clients about new context
      _broadcastTargetListUpdate();
    }
  }

  void _unregisterContext(DebuggingContext context) {
    _contextServices.remove(context);
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] unregister context=${context.contextId} remaining=${_contextServices.length}');
    }

    // Remove controller mapping if exists
    if (context is WebFControllerDebuggingAdapter) {
      _controllerToContext.remove(context.controller);
    }

    // If this was the current context, clear DOM immediately on detach
    if (_currentContext == context) {
      // Clear the DOM panel immediately when controller detaches
      _sendDOMClearEvent();

      _currentContext = null;
      _currentService = null;

      // If there are other contexts, switch to one after clearing
      if (_contextServices.isNotEmpty) {
        // Delay the context switch to allow DOM clear to take effect
        Future.delayed(Duration(milliseconds: 150), () {
          _selectContextWithoutClear(_contextServices.keys.first);
        });
      }
    }

    // Notify connected clients about context removal
    _broadcastTargetListUpdate();
  }

  void _selectContext(DebuggingContext context) {
    if (!_contextServices.containsKey(context)) return;

    // If switching between different contexts, clear DOM first
    bool isContextSwitch = _currentContext != null && _currentContext != context;
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] select context=${context.contextId} switch=$isContextSwitch');
    }
    if (isContextSwitch) {
      _sendDOMClearEvent();
    }

    _selectContextInternal(context, isContextSwitch);
  }

  /// Internal method to select context without triggering DOM clear
  void _selectContextWithoutClear(DebuggingContext context) {
    if (!_contextServices.containsKey(context)) return;
    _selectContextInternal(context, false);
  }

  void _selectContextInternal(DebuggingContext context, bool isContextSwitch) {
    // Get the old Page module to transfer screencast state
    InspectPageModule? oldPageModule = _currentService
        ?.uiInspector?.moduleRegistrar['Page'] as InspectPageModule?;
    final Map<String, UIInspectorModule>? previousRegistrar =
        _currentService?.uiInspector?.moduleRegistrar;

    _currentContext = context;
    _currentService = _contextServices[context];

    // Transfer screencast state to new Page module if screencast was active
    if (oldPageModule != null && _currentService?.uiInspector != null) {
      InspectPageModule? newPageModule = _currentService!
          .uiInspector!.moduleRegistrar['Page'] as InspectPageModule?;
      if (newPageModule != null && oldPageModule.isScreencastActive) {
        newPageModule.transferScreencastState(oldPageModule);
      }
    }

    // Sync enable state for all modules that extend _InspectorModule
    final Map<String, UIInspectorModule>? currentRegistrar =
        _currentService?.uiInspector?.moduleRegistrar;
    if (previousRegistrar != null && currentRegistrar != null) {
      previousRegistrar.forEach((name, prevModule) {
        final currModule = currentRegistrar[name];
        if (currModule != null) {
          // Sync only when the module types match
          if (currModule.runtimeType == prevModule.runtimeType) {
            currModule.setEnabled(prevModule.isEnabled);
          }
        }
      });
    }

    // Notify all UI modules about context change
    if (currentRegistrar != null) {
      for (var module in currentRegistrar.values) {
        module.onContextChanged();
      }
    }

    // Notify connected clients
    _broadcastTargetListUpdate();

    // Replay any queued pre-context messages (only once)
    if (_preContextMessageQueue.isNotEmpty) {
      final queued = List<Map<String, dynamic>>.from(_preContextMessageQueue);
      _preContextMessageQueue.clear();

      // Wait a bit for DOM to be fully loaded before replaying messages
      Future.delayed(Duration(milliseconds: 300), () {
        for (final msg in queued) {
          try {
            final id = msg['id'];
            final method = msg['method'] as String;
            final parts = method.split('.');
            if (parts.length >= 2) {
              final module = parts[0];
              final command = parts.skip(1).join('.');
              final params = msg['params'] as Map<String, dynamic>?;

              if (_modules.containsKey(module)) {
                _modules[module].invoke(id, command, params);
              } else if (_currentService?.uiInspector != null) {
                _currentService!.uiInspector!
                    .messageRouter(id, module, command, params);
              }
            }
          } catch (e) {
            debugPrint('Error replaying queued message: $e');
          }
        }
      });
    }

    // For context switches, delay DOM update to allow clear event to take effect
    if (isContextSwitch) {
      Future.delayed(Duration(milliseconds: 200), () {
        _isContextSwitching = false; // Clear the switching flag
        _seededParentIds.clear();
        _knownNodeIds.clear();
        sendEventToFrontend(DOMUpdatedEvent());
      });
    } else {
      _isContextSwitching = false; // Ensure flag is cleared
      // Send DOM update immediately for new context attach
      Future.delayed(Duration(milliseconds: 100), () {
        _seededParentIds.clear();
        _knownNodeIds.clear();
        sendEventToFrontend(DOMUpdatedEvent());
      });
    }
  }

  /// Switch DevTools to a specific controller (called when controller is attached)
  void switchToController(WebFController controller) {
    // Check if we have a context for this controller
    final context = _controllerToContext[controller];
    if (context != null && _contextServices.containsKey(context)) {
      // For controller attach, don't clear DOM - just switch to new context
      _selectContextWithoutClear(context);
    }
  }

  /// Switch DevTools to a specific context
  void switchToContext(DebuggingContext context) {
    if (_contextServices.containsKey(context)) {
      // For manual context switch, clear DOM first then switch
      _selectContext(context);
    }
  }

  /// Start the DevTools server
  Future<void> start({String? address, int? port}) async {
    if (_isRunning) return;

    _address = address ?? _address;
    _port = port ?? _port;
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.info('[DevTools] Starting CDP server address=$_address port=$_port');
    }

    // Initialize modules
    _initializeModules();

    // Start HTTP server
    await _startServer();

    _isRunning = true;
  }

  /// Stop the DevTools server
  Future<void> stop() async {
    if (!_isRunning) return;
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.info('[DevTools] Stopping CDP server');
    }

    // Close all WebSocket connections
    for (final connection in _connections.values) {
      await connection.sink.close();
    }
    _connections.clear();

    // Stop HTTP server
    await _httpServer?.close();
    _httpServer = null;
    _devToolsUrl = null;

    // Clear modules
    _modules.clear();

    _isRunning = false;
  }

  void _initializeModules() {
    // Don't register any modules here - let all messages route to UIInspector
    // which has the actual implementation of Log, Network, CSS, DOM, etc.
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
          (ip) =>
              ip.startsWith('192.168.') ||
              ip.startsWith('10.') ||
              ip.startsWith('172.'),
          orElse: () =>
              availableIPs.isNotEmpty ? availableIPs.first : 'localhost');

      connectAddress = primaryIP;
    } else {
      availableIPs.add(connectAddress);
    }

    // Store the primary DevTools URL
    _devToolsUrl =
        'devtools://devtools/bundled/inspector.html?ws=$connectAddress:${_httpServer!.port}';

    debugPrint(
        '╔════════════════════════════════════════════════════════════════════╗');
    debugPrint(
        '║                Chrome DevTools Server Started                       ║');
    debugPrint(
        '╚════════════════════════════════════════════════════════════════════╝');
    debugPrint('');
    debugPrint(
        'DevTools is listening on port ${_httpServer!.port} on all network interfaces.');
    debugPrint('');
    debugPrint(
        'To debug your WebF application, open Chrome or Edge and navigate to:');
    debugPrint('');
    debugPrint('  $_devToolsUrl');
    debugPrint('');

    if (availableIPs.length > 1) {
      debugPrint('Available on multiple network interfaces:');
      for (final ip in availableIPs) {
        debugPrint(
            '  • devtools://devtools/bundled/inspector.html?ws=$ip:${_httpServer!.port}');
      }
      debugPrint('');
    }

    debugPrint('You can also use localhost:');
    debugPrint(
        '  • devtools://devtools/bundled/inspector.html?ws=localhost:${_httpServer!.port}');
    debugPrint('');
    debugPrint('For debugging tools, visit:');
    debugPrint('  • http://$connectAddress:${_httpServer!.port}/json/version');
    debugPrint('  • http://$connectAddress:${_httpServer!.port}/json/list');
    debugPrint('');
    debugPrint('─' * 70);
  }

  Future<shelf.Response> _handleRequest(shelf.Request request) async {
    final path = request.url.path;
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.fine('[DevTools] HTTP ${request.method} /$path');
    }

    if (path == '') {
      final handler = webSocketHandler(_handleWebSocket);
      return await handler(request);
    }

    return shelf.Response.notFound('Not found');
  }

  void _handleWebSocket(WebSocketChannel webSocket) {
    final connectionId = DateTime.now().millisecondsSinceEpoch.toString();
    _connections[connectionId] = webSocket;
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.info('[DevTools] WS connected id=$connectionId active=${_connections.length}');
    }

    webSocket.stream.listen(
      (message) => _handleWebSocketMessage(connectionId, message),
      onError: (error) {
        debugPrint('WebSocket error: $error');
        _connections.remove(connectionId);
        if (DebugFlags.enableDevToolsLogs) {
          devToolsLogger.warning('[DevTools] WS error id=$connectionId err=$error');
        }
      },
      onDone: () {
        _connections.remove(connectionId);
        if (DebugFlags.enableDevToolsLogs) {
          devToolsLogger.info('[DevTools] WS closed id=$connectionId active=${_connections.length}');
        }
      },
    );
  }

  void _handleWebSocketMessage(String connectionId, message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);

      final method = data['method'] as String?;
      final id = data['id'];
      // jsonDecode returns Map<String,dynamic>, but defensive: user agents may send mixed key maps.
      Map<String, dynamic>? params;
      final rawParams = data['params'];
      if (rawParams is Map) {
        params = rawParams.map((k, v) => MapEntry(k.toString(), v));
      }

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
      } else if (_currentService != null &&
          _currentService!.uiInspector != null) {
        // Route to UI inspector for DOM, CSS, etc.
        _currentService!.uiInspector!
            .messageRouter(id, module, command, params);
      } else {
        // Try pre-context stub handling so DevTools frontend can initialize without a controller.
        // If no context, record enable-like messages to replay later.
        if (_currentService == null &&
            _shouldQueueMessage(module, command, params)) {
          _preContextMessageQueue
              .add({'id': id, 'method': method, 'params': params ?? {}});
        }
        if (!_handlePreContextMessage(
            connectionId, id, module, command, params)) {
          _sendErrorResponse(
              connectionId, id, 'No controller selected or module not found');
        }
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  /// Handle a subset of DevTools protocol messages before any debugging context exists.
  /// Returns true if the message was handled (stubbed) and no error should be sent.
  bool _handlePreContextMessage(String connectionId, dynamic id, String module,
      String command, Map<String, dynamic>? params) {
    // Only act when there is really no current service yet.
    if (_currentService != null) return false;

    // Common enable / config style commands: reply with empty result so frontend proceeds.
    bool isEnableLike() =>
        command == 'enable' ||
        command.startsWith('set') ||
        command.startsWith('track') ||
        command.startsWith('take');

    // Modules we allow stubbing prior to real context.
    const preContextModules = {
      'Page',
      'DOM',
      'CSS',
      'Overlay',
      'Animation',
      'Autofill',
      'Profiler',
      'Audits',
      'ServiceWorker',
      'Inspector',
      'Emulation',
      'Accessibility',
      'Network',
      'Log',
      'Target'
    };
    if (!preContextModules.contains(module)) return false;

    // Special query style commands that require shaped responses.
    dynamic result;
    switch ('$module.$command') {
      case 'Page.getResourceTree':
        result = {
          'frameTree': {
            'frame': {
              'id': 'temp-frame',
              'loaderId': 'temp-loader',
              'url': 'about:blank',
              'securityOrigin': '',
              'mimeType': 'text/html'
            },
            'resources': []
          }
        };
        break;
      case 'Page.getNavigationHistory':
        result = {'currentIndex': 0, 'entries': []};
        break;
      case 'Page.startScreencast':
        // Acknowledge immediately; queue actual start so frames begin once context arrives.
        result = {};
        // Queue with null id to avoid duplicate response later.
        _preContextMessageQueue.add({
          'id': null,
          'method': 'Page.startScreencast',
          'params': params ?? {}
        });
        break;
      case 'Page.stopScreencast':
        result = {};
        _preContextMessageQueue.add({
          'id': null,
          'method': 'Page.stopScreencast',
          'params': params ?? {}
        });
        break;
      case 'DOM.getDocument':
        // Don't provide a stub response for getDocument - queue it for proper handling
        // when the actual context is available
        _preContextMessageQueue.add({
          'id': id,
          'method': 'DOM.getDocument',
          'params': params ?? {}
        });
        return true; // Handled, but no response sent yet
      case 'CSS.takeComputedStyleUpdates':
        result = {'computedStyleUpdates': []};
        break;
      case 'Target.getTargets':
        result = {'targetInfos': _getTargetList()}; // Likely empty now.
        break;
      case 'Target.attachToTarget':
        // No real target yet – queue intention? For now return an error-style stub success so frontend keeps listening.
        // When a target later appears, the frontend will request again after targetCreated event.
        result = {'sessionId': 'pending'};
        break;
      default:
        if (isEnableLike()) {
          result = {};
        }
    }

    if (result != null) {
      _sendResponse(connectionId, id, result);
      return true;
    }
    return false;
  }

  bool _shouldQueueMessage(
      String module, String command, Map<String, dynamic>? params) {
    // Queue only stateless enable/config commands to re-run once real context exists.
    if (command == 'enable') return true;
    if (module == 'Page' &&
        (command == 'getResourceTree' || command == 'getNavigationHistory')) {
      return true;
    }
    if (module == 'Page' &&
        (command == 'startScreencast' || command == 'stopScreencast')) {
      return true;
    }
    if (module == 'DOM' && (command == 'getDocument')) return true;
    if (module == 'CSS' && (command == 'enable' || command.startsWith('track'))) {
      return true;
    }
    if (module == 'Overlay' && command.startsWith('setShow')) return true;
    return false;
  }

  void _handleTargetMethod(String connectionId, int? id, String method,
      Map<String, dynamic>? params) {
    switch (method) {
      case 'getTargets':
        if (DebugFlags.enableDevToolsLogs) {
          devToolsLogger.fine('[DevTools] Target.getTargets');
        }
        _sendResponse(connectionId, id, {
          'targetInfos': _getTargetList(),
        });
        break;
      case 'setAutoAttach':
      case 'setDiscoverTargets':
      case 'setRemoteLocations':
        // Gracefully acknowledge unimplemented Target features so frontend doesn't spam errors pre-context.
        if (DebugFlags.enableDevToolsLogs) {
          devToolsLogger.fine('[DevTools] Target.$method');
        }
        _sendResponse(connectionId, id, {});
        break;

      case 'attachToTarget':
        if (DebugFlags.enableDevToolsLogs) {
          devToolsLogger.fine('[DevTools] Target.attachToTarget tid=${params?['targetId']}');
        }
        final targetId = params?['targetId'] as String?;
        if (targetId != null) {
          final context = _findContextById(targetId);
          if (context != null) {
            _selectContext(context);
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

  DebuggingContext? _findContextById(String targetId) {
    // Try to find by context ID
    for (final entry in _contextServices.entries) {
      if (entry.key.contextId.toString() == targetId) {
        return entry.key;
      }
    }

    // Try to find by controller name in manager (backward compatibility)
    final manager = WebFControllerManager.instance;
    if (manager.hasController(targetId)) {
      final controller = manager.getControllerSync(targetId);
      if (controller != null) {
        return _controllerToContext[controller];
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _getTargetList() {
    final manager = WebFControllerManager.instance;
    final targets = <Map<String, dynamic>>[];

    // Add contexts with controller names
    for (final name in manager.controllerNames) {
      final controller = manager.getControllerSync(name);
      if (controller != null) {
        final context = _controllerToContext[controller];
        if (context != null && _contextServices.containsKey(context)) {
          targets.add({
            'id': name,
            'title': 'WebF Page - $name',
            'url': context.url ?? '',
            'attached': context == _currentContext,
          });
        }
      }
    }

    // Add any contexts not tied to named controllers
    for (final entry in _contextServices.entries) {
      final context = entry.key;
      bool found = false;

      // Check if this context is from a named controller
      if (context is WebFControllerDebuggingAdapter) {
        final name = manager.getControllerName(context.controller);
        if (name != null) {
          found = true;
        }
      }

      if (!found) {
        targets.add({
          'id': context.contextId.toString(),
          'title': 'WebF Page',
          'url': context.url ?? '',
          'attached': context == _currentContext,
        });
      }
    }

    return targets;
  }

  Map<String, dynamic> _getCurrentTargetInfo() {
    if (_currentContext == null) {
      return {
        'id': '',
        'title': 'No context selected',
        'url': '',
      };
    }

    final manager = WebFControllerManager.instance;

    // Check if this context is from a named controller
    if (_currentContext is WebFControllerDebuggingAdapter) {
      final adapter = _currentContext as WebFControllerDebuggingAdapter;
      final name = manager.getControllerName(adapter.controller);
      if (name != null) {
        return {
          'id': name,
          'title': 'WebF Page - $name',
          'url': _currentContext!.url ?? '',
          'attached': _currentContext!.isFlutterAttached,
        };
      }
    }

    return {
      'id': _currentContext!.contextId.toString(),
      'title': 'WebF Page',
      'url': _currentContext!.url ?? '',
      'attached': _currentContext!.isFlutterAttached,
    };
  }

  void _sendResponse(
      String connectionId, int? id, Map<String, dynamic> result) {
    if (id == null) return;

    final response = {
      'id': id,
      'result': result,
    };

    final connection = _connections[connectionId];
    final message = jsonEncode(response);

    connection?.sink.add(message);
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
    final result = jsonEncode(response);

    connection?.sink.add(result);
    if (DebugFlags.enableDevToolsProtocolLogs) {
      devToolsProtocolLogger.finer('[DevTools] -> (error) id=$id $message');
    }
  }

  void sendEventToFrontend(InspectorEvent event) {
    final bool hasConnections = _connections.isNotEmpty;

    // Notify test listeners when there are no websocket clients
    if (!hasConnections) {
      try {
        for (final tap in _testEventListeners) {
          tap(event);
        }
      } catch (_) {}
    }

    // Maintain known-node bookkeeping for incremental DOM coherence
    try {
      if (event is DOMSetChildNodesEvent) {
        final ids = <int>[];
        for (final n in event.nodes) {
          final v = n['nodeId'];
          if (v is int) ids.add(v);
        }
        if (ids.isNotEmpty) _markNodesKnown(ids);
      } else if (event is DOMChildNodeInsertedEvent) {
        final id = event.node.ownerView.forDevtoolsNodeId(event.node);
        _markNodeKnown(id);
      } else if (event is DOMChildNodeRemovedEvent) {
        final id = event.node.ownerView.forDevtoolsNodeId(event.node);
        _unmarkNodeKnown(id);
      } else if (event is DOMClearEvent || event is DOMUpdatedEvent) {
        _knownNodeIds.clear();
        _seededParentIds.clear();
      }
    } catch (_) {}

    // If there are active websocket clients, also mirror events to test listeners
    if (hasConnections) {
      try {
        for (final tap in _testEventListeners) {
          tap(event);
        }
      } catch (_) {}
    }

    // Broadcast to websocket clients
    if (hasConnections) {
      final message = jsonEncode(event.toJson());
      for (final connection in _connections.values) {
        try {
          connection.sink.add(message);
        } catch (e) {
          debugPrint('Error sending event: $e');
        }
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
        debugPrint('Error sending result: $e');
      }
    }
  }

  void _broadcastTargetListUpdate() {
    sendEventToFrontend(TargetCreatedEvent(
      targetInfo: _getCurrentTargetInfo(),
    ));
  }

  /// Send DOM clear event to clear the Elements panel before switching contexts
  void _sendDOMClearEvent() {
    // Set context switching flag
    _isContextSwitching = true;
    _seededParentIds.clear();
    _knownNodeIds.clear();

    // Send DOM.documentUpdated to clear the existing DOM tree
    // Chrome DevTools will then request DOM.getDocument, and we can return empty/null
    sendEventToFrontend(DOMClearEvent());
  }

  /// Public method to clear DOM panel (called from controller detach)
  void clearDOMPanel() {
    _sendDOMClearEvent();
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
  DebuggingContext? get currentContext => _currentContext;

  ChromeDevToolsService? get currentService => _currentService;

  /// Returns true if currently switching between contexts
  bool get isContextSwitching => _isContextSwitching;

  // Parent seed tracking helpers
  bool _isParentSeeded(int nodeId) => _seededParentIds.contains(nodeId);
  void _markParentSeeded(int nodeId) => _seededParentIds.add(nodeId);

  // Known node helpers
  bool _isNodeKnown(int nodeId) => _knownNodeIds.contains(nodeId);
  void _markNodeKnown(int nodeId) => _knownNodeIds.add(nodeId);
  void _markNodesKnown(Iterable<int> nodeIds) => _knownNodeIds.addAll(nodeIds);
  void _unmarkNodeKnown(int nodeId) => _knownNodeIds.remove(nodeId);

  // Backward compatibility
  WebFController? get currentController {
    if (_currentContext is WebFControllerDebuggingAdapter) {
      return (_currentContext as WebFControllerDebuggingAdapter).controller;
    }
    return null;
  }
}

// Event classes for DevTools protocol
class TargetCreatedEvent extends InspectorEvent {
  final Map<String, dynamic> targetInfo;

  TargetCreatedEvent({required this.targetInfo});

  @override
  String get method => 'Target.targetCreated';

  @override
  JSONEncodable? get params => JSONEncodableMap({'targetInfo': targetInfo});
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
