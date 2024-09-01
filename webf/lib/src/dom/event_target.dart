/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/foundation.dart';
import 'package:webf/html.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

typedef EventHandler = Future<void> Function(Event event);

abstract class EventTarget extends DynamicBindingObject {
  EventTarget(BindingContext? context) : super(context);

  bool _disposed = false;
  bool get disposed => _disposed;

  @protected
  final Map<String, List<EventHandler>> _eventHandlers = {};

  @protected
  final Map<String, List<EventHandler>> _builtInEventHandlers = {};

  @protected
  final Map<String, List<EventHandler>> _eventCaptureHandlers = {};

  @protected
  final Map<String, List<EventHandler>> _builtInEventCaptureHandlers = {};

  Map<String, List<EventHandler>> getEventHandlers() => _eventHandlers;
  Map<String, List<EventHandler>> getBuiltInEventHandlers() => _builtInEventHandlers;

  Map<String, List<EventHandler>> getCaptureEventHandlers() => _eventCaptureHandlers;
  Map<String, List<EventHandler>> getBuiltInCaptureEventHandlers() => _builtInEventCaptureHandlers;

  @protected
  bool hasEventListener(String type) => _eventHandlers.containsKey(type) || _builtInEventHandlers.containsKey(type);

  // TODO: Support addEventListener options: capture, once, passive, signal.
  @mustCallSuper
  void addEventListener(String eventType, EventHandler eventHandler,
      {EventListenerOptions? addEventListenerOptions, bool builtInCallback = false}) {
    if (_disposed) return;
    bool capture = false;

    if (addEventListenerOptions != null) capture = addEventListenerOptions.capture;
    final eventCaptureHandlers = builtInCallback ? _builtInEventCaptureHandlers : _eventCaptureHandlers;
    final eventBubbleHandlers = builtInCallback ? _builtInEventHandlers : _eventHandlers;

    List<EventHandler>? existHandler = capture
        ? eventCaptureHandlers[eventType]
        : eventBubbleHandlers[eventType];
    if (existHandler == null) {
      if (capture)
        eventCaptureHandlers[eventType] = existHandler = [];
      else
        eventBubbleHandlers[eventType] = existHandler = [];
    }
    existHandler.add(eventHandler);
  }

  @mustCallSuper
  void removeEventListener(String eventType, EventHandler eventHandler, {bool isCapture = false, bool builtInCallback = false}) {
    if (_disposed) return;

    final eventCaptureHandlers = builtInCallback ? _builtInEventCaptureHandlers : _eventCaptureHandlers;
    final eventBubbleHandlers = builtInCallback ? _builtInEventHandlers : _eventHandlers;

    List<EventHandler>? currentHandlers = isCapture ? eventCaptureHandlers[eventType] : eventBubbleHandlers[eventType];
    if (currentHandlers != null) {
      currentHandlers.remove(eventHandler);
      if (currentHandlers.isEmpty) {
        if (isCapture) {
          eventCaptureHandlers.remove(eventType);
        } else {
          eventBubbleHandlers.remove(eventType);
        }
      }
    }
  }

  @mustCallSuper
  Future<void> dispatchEvent(Event event) async {
    if (_disposed) return;
    if (this is PseudoElement) {
      event.target = (this as PseudoElement).parent;
    } else {
      event.target = this;
    }

    await _handlerCaptureEvent(event);
    await _dispatchEventInDOM(event);

    await _handlerCaptureEvent(event, builtInCallback: true);
    await _dispatchEventInDOM(event, builtInCallback: true);
  }
  Future<void> _handlerCaptureEvent(Event event, { bool builtInCallback = false }) async {
    await parentEventTarget?._handlerCaptureEvent(event);
    String eventType = event.type;
    final eventCaptureHandlers = builtInCallback ? _builtInEventCaptureHandlers : _eventCaptureHandlers;
    List<EventHandler>? existHandler = eventCaptureHandlers[eventType];
    if (existHandler != null) {
      // Modify currentTarget before the handler call, otherwise currentTarget may be modified by the previous handler.
      event.currentTarget = this;
      // To avoid concurrent exception while prev handler modify the original handler list, causing list iteration
      // with error, copy the handlers here.
      try {
        for (EventHandler handler in [...existHandler]) {
          await handler(event);
        }
      } catch (e, stack) {
        print('$e\n$stack');
      }
      event.currentTarget = null;
    }
  }
  // Refs: https://github.com/WebKit/WebKit/blob/main/Source/WebCore/dom/EventDispatcher.cpp#L85
  Future<void> _dispatchEventInDOM(Event event, { bool builtInCallback = false }) async {
    // TODO: Invoke capturing event listeners in the reverse order.

    String eventType = event.type;
    final eventBubbleHandlers = builtInCallback ? _builtInEventHandlers : _eventHandlers;
    List<EventHandler>? existHandler = eventBubbleHandlers[eventType];
    if (existHandler != null) {
      // Modify currentTarget before the handler call, otherwise currentTarget may be modified by the previous handler.
      event.currentTarget = this;
      // To avoid concurrent exception while prev handler modify the original handler list, causing list iteration
      // with error, copy the handlers here.
      try {
        for (EventHandler handler in [...existHandler]) {
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
    _eventCaptureHandlers.clear();
    _builtInEventHandlers.clear();
    _builtInEventCaptureHandlers.clear();
    super.dispose();
  }

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
}

class EventListenerOptions {
  bool capture;
  bool passive;
  bool once;

  EventListenerOptions(this.capture, this.passive, this.once);
}
