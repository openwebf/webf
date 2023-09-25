/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/foundation.dart';
import 'package:webf/html.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

typedef EventHandler = void Function(Event event);

abstract class EventTarget extends BindingObject {
  EventTarget(BindingContext? context) : super(context);

  bool _disposed = false;
  bool get disposed => _disposed;

  @protected
  final Map<String, List<EventHandler>> _eventHandlers = {};

  @protected
  final Map<String, List<EventHandler>> _eventCaptureHandlers = {};

  Map<String, List<EventHandler>> getEventHandlers() => _eventHandlers;

  Map<String, List<EventHandler>> getCaptureEventHandlers() => _eventCaptureHandlers;

  @protected
  bool hasEventListener(String type) => _eventHandlers.containsKey(type);

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

  @mustCallSuper
  void dispatchEvent(Event event) {
    if (_disposed) return;
    if (this is PseudoElement) {
      event.target = (this as PseudoElement).parent;
    } else {
      event.target = this;
    }

    _handlerCaptureEvent(event);
    _dispatchEventInDOM(event);
  }
  void _handlerCaptureEvent(Event event) {

    parentEventTarget?._handlerCaptureEvent(event);
    String eventType = event.type;
    List<EventHandler>? existHandler = _eventCaptureHandlers[eventType];
    if (existHandler != null) {
      // Modify currentTarget before the handler call, otherwise currentTarget may be modified by the previous handler.
      event.currentTarget = this;
      // To avoid concurrent exception while prev handler modify the original handler list, causing list iteration
      // with error, copy the handlers here.
      try {
        for (EventHandler handler in [...existHandler]) {
          handler(event);
        }
      } catch (e, stack) {
        print('$e\n$stack');
      }
      event.currentTarget = null;
    }
  }
  // Refs: https://github.com/WebKit/WebKit/blob/main/Source/WebCore/dom/EventDispatcher.cpp#L85
  void _dispatchEventInDOM(Event event) {
    // TODO: Invoke capturing event listeners in the reverse order.

    String eventType = event.type;
    List<EventHandler>? existHandler = _eventHandlers[eventType];
    if (existHandler != null) {
      // Modify currentTarget before the handler call, otherwise currentTarget may be modified by the previous handler.
      event.currentTarget = this;
      // To avoid concurrent exception while prev handler modify the original handler list, causing list iteration
      // with error, copy the handlers here.
      try {
        for (EventHandler handler in [...existHandler]) {
          handler(event);
        }
      } catch (e, stack) {
        print('$e\n$stack');
      }
      event.currentTarget = null;
    }

    // Invoke bubbling event listeners.
    if (event.bubbles && !event.propagationStopped) {
      parentEventTarget?._dispatchEventInDOM(event);
    }
  }

  @override
  @mustCallSuper
  void dispose() async {
    _disposed = true;
    _eventHandlers.clear();
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
