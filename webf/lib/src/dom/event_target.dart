/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/html.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';

typedef EventHandler = Future<void> Function(Event event);

abstract class EventTarget extends DynamicBindingObject with StaticDefinedBindingObject {
  EventTarget(BindingContext? context) : super(context);

  bool _disposed = false;
  bool get disposed => _disposed;

  @protected
  final Map<String, List<EventHandler>> _eventHandlers = {};

  @protected
  final Map<String, List<EventHandler>> _eventCaptureHandlers = {};

  Map<String, List<EventHandler>> getEventHandlers() => _eventHandlers;

  Map<String, List<EventHandler>> getCaptureEventHandlers() => _eventCaptureHandlers;

  final Map<String, List<Event>> _eventDeps = {};
  
  // Track pending dispatchEvent futures to ensure safe disposal
  final List<Future<void>> _pendingDispatchEvents = [];

  bool hasEventListener(String type) => _eventHandlers.containsKey(type);
  
  /// Wait for all pending dispatchEvent operations to complete
  Future<void> waitForPendingEvents() async {
    if (_pendingDispatchEvents.isEmpty) return;
    
    // Create a copy of current pending events to avoid concurrent modification
    List<Future<void>> currentPending = List.from(_pendingDispatchEvents);
    await Future.wait(currentPending);
  }
  
  /// Check if there are any pending dispatchEvent operations
  bool hasPendingEvents() => _pendingDispatchEvents.isNotEmpty;

  static final StaticDefinedSyncBindingObjectMethodMap _eventTargetSyncMethods = {
    'addEvent':
    StaticDefinedSyncBindingObjectMethod(call: (eventTarget, args) => castToType<EventTarget>(eventTarget)._addEventListenerFromBindingCall(args)),
  };

  void _addEventListenerFromBindingCall(List<dynamic> args) {
    String eventType = args[0];
    Pointer<AddEventListenerOptions> eventListenerOptions = args[1] as Pointer<AddEventListenerOptions>;
    ownerView.addEvent(pointer!, eventType, addEventListenerOptions: eventListenerOptions);
  }

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _eventTargetSyncMethods];


  // TODO: Support addEventListener options: capture, once, passive, signal.
  @mustCallSuper
  void addEventListener(String eventType, EventHandler eventHandler, {EventListenerOptions? addEventListenerOptions}) {
    if (_disposed) return;
    bool capture = false;
    if (addEventListenerOptions != null)
      capture = addEventListenerOptions.capture;
    List<EventHandler>? existHandler = capture ? _eventCaptureHandlers[eventType] : _eventHandlers[eventType];
    if (existHandler == null) {
      if (capture)
        _eventCaptureHandlers[eventType] = existHandler = [];
      else
        _eventHandlers[eventType] = existHandler = [];
    }
    existHandler.add(eventHandler);
    if (this is Element) {
      scheduleMicrotask(() {
        if (_eventHandlers[eventType]?.isNotEmpty == true && !(this as Element).hasEvent) {
          (this as Element).renderStyle.requestWidgetToRebuild(AddEventUpdateReason());
        }
      });
    }
    if (_eventWaitingCompleter.containsKey(eventType)) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _eventWaitingCompleter[eventType]!();
        _eventWaitingCompleter.remove(eventType);
      });
    }
  }

  @mustCallSuper
  void removeEventListener(String eventType, EventHandler eventHandler, {bool isCapture = false}) {
    if (_disposed) return;

    List<EventHandler>? currentHandlers = isCapture ? _eventCaptureHandlers[eventType] : _eventHandlers[eventType];
    if (currentHandlers != null) {
      currentHandlers.remove(eventHandler);
      if (currentHandlers.isEmpty) {
        if (isCapture) {
          _eventCaptureHandlers.remove(eventType);
        } else {
          _eventHandlers.remove(eventType);
        }
      }
    }
  }

  @protected
  final Map<String, VoidCallback> _eventWaitingCompleter = {};

  Future<void> dispatchEventUtilAdded(Event event) async {
    bool hasEvent = hasEventListener(event.type);
    if (hasEvent) {
      await dispatchEvent(event);
    } else {
      Completer completer = Completer();
      _eventWaitingCompleter[event.type] = () async {
        await dispatchEvent(event);
        completer.complete();
      };
      return completer.future;
    }
  }

  Future<void> dispatchEventByDeps(Event event, String dep) async {
    if (!_eventDeps.containsKey(dep)) {
      _eventDeps[dep] = [];
    }
    _eventDeps[dep]!.add(event);
  }

  @mustCallSuper
  Future<void> dispatchEvent(Event event) async {
    if (_disposed) return;
    if (this is PseudoElement) {
      event.target = (this as PseudoElement).parent;
    } else {
      event.target = this;
    }

    // Track this dispatch operation
    Future<void> dispatchFuture = _executeDispatchEvent(event);
    _pendingDispatchEvents.add(dispatchFuture);
    
    // Wait for completion and clean up
    try {
      await dispatchFuture;
    } finally {
      _pendingDispatchEvents.remove(dispatchFuture);
    }
  }
  
  void _finalizeLCPOnUserInteraction(Event event) {
    // Finalize LCP when user interacts with the page
    if (event.type == EVENT_CLICK || 
        event.type == EVENT_TOUCH_START || 
        event.type == 'mousedown' || 
        event.type == EVENT_KEY_DOWN) {
      if (this is Node) {
        final Node node = this as Node;
        node.ownerDocument.controller.finalizeLCP();
      } else if (this is Window) {
        final Window window = this as Window;
        window.document.controller.finalizeLCP();
      }
    }
  }
  
  Future<void> _executeDispatchEvent(Event event) async {
    // Finalize LCP on user interaction
    _finalizeLCPOnUserInteraction(event);
    
    await _handlerCaptureEvent(event);
    await _dispatchEventInDOM(event);

    if (_eventDeps.containsKey(event.type)) {
      _eventDeps[event.type]!.forEach((e) {
        dispatchEventUtilAdded(e);
      });
      _eventDeps.clear();
    }
  }
  Future<void> _handlerCaptureEvent(Event event) async {
    // Avoid dispatch event to JS when the node was created by Flutter widgets.
    if (this is Node && (this as Node).isWidgetOwned) return;
    await parentEventTarget?._handlerCaptureEvent(event);
    String eventType = event.type;
    List<EventHandler>? existHandler = _eventCaptureHandlers[eventType];
    if (existHandler != null) {
      // Modify currentTarget before the handler call, otherwise currentTarget may be modified by the previous handler.
      event.currentTarget = this;
      // To avoid concurrent exception while prev handler modify the original handler list, causing list iteration
      // with error, copy the handlers here.
      try {
        List<EventHandler> handlers = [...existHandler];
        for (int i = handlers.length - 1; i >= 0; i --) {
          final handler = handlers[i];
          await handler(event);
        }
      } catch (e, stack) {
        print('$e\n$stack');
      }
      event.currentTarget = null;
    }
  }
  // Refs: https://github.com/WebKit/WebKit/blob/main/Source/WebCore/dom/EventDispatcher.cpp#L85
  Future<void> _dispatchEventInDOM(Event event) async {
    // Avoid dispatch event to JS when the node was created by Flutter widgets.
    if (this is Node && (this as Node).isWidgetOwned) return;

    String eventType = event.type;
    List<EventHandler>? existHandler = _eventHandlers[eventType];
    if (existHandler != null) {
      // Modify currentTarget before the handler call, otherwise currentTarget may be modified by the previous handler.
      event.currentTarget = this;
      // To avoid concurrent exception while prev handler modify the original handler list, causing list iteration
      // with error, copy the handlers here.
      try {
        List<EventHandler> handlers = [...existHandler];
        for (int i = handlers.length - 1; i >= 0; i --) {
          final handler = handlers[i];
          await handler(event);
        }
      } catch (e, stack) {
        print('$e\n$stack');
      }
      event.currentTarget = null;
    }

    // Invoke bubbling event listeners.
    if (event.bubbles && !event.propagationStopped) {
      await parentEventTarget?._dispatchEventInDOM(event);
    }
  }

  @override
  @mustCallSuper
  void dispose() async {
    _disposed = true;
    _eventHandlers.clear();
    _eventWaitingCompleter.clear();
    _eventDeps.clear();
    _pendingDispatchEvents.clear(); // Clear pending events tracking
    super.dispose();
  }

  @pragma('vm:prefer-inline')
  EventTarget? get parentEventTarget;

  List<EventTarget> get eventPath {
    List<EventTarget> path = [];
    EventTarget? current = this;
    while (current != null) {
      path.add(current);
      current = current.parentEventTarget;
    }
    return path;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('disposed', disposed));
    if (_eventHandlers.isNotEmpty) {
      properties.add(IterableProperty('eventHandlers', _eventHandlers.keys.toList()));
    }
    if (_eventCaptureHandlers.isNotEmpty) {
      properties.add(IterableProperty('eventCaptureHandlers', _eventCaptureHandlers.keys.toList()));
    }
  }
}

class EventListenerOptions {

  bool capture;
  bool passive;
  bool once;

  EventListenerOptions(this.capture, this.passive, this.once);
}
