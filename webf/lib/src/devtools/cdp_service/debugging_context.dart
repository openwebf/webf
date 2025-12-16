/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'dart:ffi';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';

/// Abstract interface that provides debugging capabilities
/// This decouples DevToolsService from WebFController
abstract class DebuggingContext {
  /// Unique identifier for this debugging context
  int get contextId;

  /// The document being debugged
  Document? get document;

  /// The current URL
  String? get url;

  /// Check if the context is attached to Flutter
  bool get isFlutterAttached;

  /// Check if the context loading is complete
  bool get isComplete;

  /// Reload the context
  Future<void> reload();

  /// Get resource content by URL
  String? getResourceContent(String url);

  /// Get the owner Flutter view
  ui.FlutterView? get ownerFlutterView;

  /// Get binding object by pointer
  BindingObject? getBindingObject(Pointer pointer);

  /// Get target ID by node ID
  int? getTargetIdByNodeId(int nodeId);

  /// Generate devtools node ID for a node
  int forDevtoolsNodeId(Node node);

  /// Callback for DOM tree changes
  set debugDOMTreeChanged(void Function()? callback);

  /// Child node inserted: parent, node, previous sibling (may be null)
  set debugChildNodeInserted(void Function(Node parent, Node node, Node? previousSibling)? callback);

  /// Child node removed: parent, node
  set debugChildNodeRemoved(void Function(Node parent, Node node)? callback);

  /// Attribute modified (set or changed): element, name, value
  set debugAttributeModified(void Function(Element element, String name, String? value)? callback);

  /// Attribute removed: element, name
  set debugAttributeRemoved(void Function(Element element, String name)? callback);

  /// Character data (text node content) modified
  set debugCharacterDataModified(void Function(TextNode node)? callback);

  /// Get render object for element
  RenderBox? getRenderBox(Element element);

  /// Get the underlying WebFController (if available)
  WebFController? getController();

  /// Dispose resources
  void dispose();
}

/// WebFController adapter that implements DebuggingContext
class WebFControllerDebuggingAdapter implements DebuggingContext {
  final WebFController controller;

  WebFControllerDebuggingAdapter(this.controller);

  @override
  int get contextId => controller.view.contextId.toInt();

  @override
  Document? get document => controller.view.document;

  @override
  String? get url => controller.url;

  @override
  bool get isFlutterAttached => controller.isFlutterAttached;

  @override
  bool get isComplete => controller.isComplete;

  @override
  Future<void> reload() => controller.reload();

  @override
  String? getResourceContent(String url) => controller.getResourceContent(url);

  @override
  ui.FlutterView? get ownerFlutterView => controller.ownerFlutterView;

  @override
  BindingObject? getBindingObject(Pointer pointer) => controller.view.getBindingObject(pointer);

  @override
  int? getTargetIdByNodeId(int nodeId) => controller.view.getTargetIdByNodeId(nodeId);

  @override
  int forDevtoolsNodeId(Node node) => controller.view.forDevtoolsNodeId(node);

  @override
  set debugDOMTreeChanged(void Function()? callback) {
    controller.view.debugDOMTreeChanged = callback;
  }

  @override
  set debugChildNodeInserted(void Function(Node parent, Node node, Node? previousSibling)? callback) {
    controller.view.devtoolsChildNodeInserted = callback;
  }

  @override
  set debugChildNodeRemoved(void Function(Node parent, Node node)? callback) {
    controller.view.devtoolsChildNodeRemoved = callback;
  }

  @override
  set debugAttributeModified(void Function(Element element, String name, String? value)? callback) {
    controller.view.devtoolsAttributeModified = callback;
  }

  @override
  set debugAttributeRemoved(void Function(Element element, String name)? callback) {
    controller.view.devtoolsAttributeRemoved = callback;
  }

  @override
  set debugCharacterDataModified(void Function(TextNode node)? callback) {
    controller.view.devtoolsCharacterDataModified = callback;
  }

  @override
  RenderBox? getRenderBox(Element element) {
    final renderer = element.attachedRenderer;
    return renderer is RenderBox ? renderer : null;
  }

  @override
  WebFController? getController() => controller;

  @override
  void dispose() {
    // The controller lifecycle is managed elsewhere
  }
}

/// Registry for managing debugging contexts
class DebuggingContextRegistry {
  static final DebuggingContextRegistry _instance = DebuggingContextRegistry._();

  static DebuggingContextRegistry get instance => _instance;

  DebuggingContextRegistry._();

  final Map<int, DebuggingContext> _contexts = {};
  final Map<DebuggingContext, Set<Function(DebuggingContext)>> _listeners = {};

  /// Register a debugging context
  void register(DebuggingContext context) {
    _contexts[context.contextId] = context;
    _notifyListeners(context, true);
  }

  /// Unregister a debugging context
  void unregister(DebuggingContext context) {
    _contexts.remove(context.contextId);
    _notifyListeners(context, false);
    context.dispose();
  }

  /// Get context by ID
  DebuggingContext? getContext(int contextId) => _contexts[contextId];

  /// Get all contexts
  Iterable<DebuggingContext> get contexts => _contexts.values;

  /// Add listener for context registration/unregistration
  void addContextListener(DebuggingContext context, Function(DebuggingContext) listener) {
    _listeners.putIfAbsent(context, () => {}).add(listener);
  }

  /// Remove listener
  void removeContextListener(DebuggingContext context, Function(DebuggingContext) listener) {
    _listeners[context]?.remove(listener);
  }

  void _notifyListeners(DebuggingContext context, bool registered) {
    final listeners = _listeners[context];
    if (listeners != null) {
      for (final listener in listeners.toList()) {
        listener(context);
      }
    }
  }

  /// Clear all contexts
  void clear() {
    for (final context in _contexts.values.toList()) {
      unregister(context);
    }
  }
}
