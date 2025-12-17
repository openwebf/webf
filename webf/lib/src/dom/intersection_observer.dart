/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:ffi';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:webf/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/launcher.dart';
import 'bounding_client_rect.dart';
import 'element.dart';
import 'intersection_observer_entry.dart';
import 'package:flutter/foundation.dart';

class _IntersectionObserverDeliverContext {
  Completer completer;
  Stopwatch? stopwatch;

  Pointer<NativeValue> allocatedNativeArguments;
  Pointer<NativeIntersectionObserverEntry> rawEntries;
  WebFController controller;

  _IntersectionObserverDeliverContext(
    this.completer,
    this.stopwatch,
    this.allocatedNativeArguments,
    this.rawEntries,
    this.controller,
  );
}

void _handleDeliverResult(Object handle, Pointer<NativeValue> returnValue) {
  _IntersectionObserverDeliverContext context = handle as _IntersectionObserverDeliverContext;

  if (enableWebFCommandLog && context.stopwatch != null) {
    debugPrint('deliver IntersectionObserverEntry to native side, time: ${context.stopwatch!.elapsedMicroseconds}us');
  }

  // Free the allocated arguments.
  malloc.free(context.allocatedNativeArguments);
  malloc.free(context.rawEntries);
  malloc.free(returnValue);

  context.completer.complete();
}

class IntersectionObserver extends DynamicBindingObject {
  IntersectionObserver(super.context, List<dynamic> thresholds_) {
    if (thresholds_.isNotEmpty) {
      _thresholds = thresholds_.map((e) => (e as num).toDouble()).toList();
    }
    if (enableWebFCommandLog) {
      domLogger.fine('[IntersectionObserver] ctor observer=$pointer thresholds=$_thresholds');
    }
  }

  @override
  void initializeDynamicMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeDynamicMethods(methods);
    methods['takeRecords'] = BindingObjectMethodSync(call: (_) {
      if (_entries.isEmpty) return null;

      final view = ownerView;
      final entries = takeRecords();
      if (entries.isEmpty) return null;

      final Pointer<NativeIntersectionObserverEntryList> entryList =
          malloc.allocate(sizeOf<NativeIntersectionObserverEntryList>());
      final Pointer<NativeIntersectionObserverEntry> nativeEntries =
          malloc.allocate(sizeOf<NativeIntersectionObserverEntry>() * entries.length);

      entryList.ref.entries = nativeEntries;
      entryList.ref.length = entries.length;

      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];

        final boundingClientRect = _createBoundingClientRect(view, entry.boundingClientRect);
        final rootBounds = _createBoundingClientRect(view, entry.rootBounds);
        final intersectionRect = _createBoundingClientRect(view, entry.intersectionRect);

        (nativeEntries + i).ref.isIntersecting = entry.isIntersecting ? 1 : 0;
        (nativeEntries + i).ref.intersectionRatio = entry.intersectionRatio;
        (nativeEntries + i).ref.element = entry.element.pointer!;
        (nativeEntries + i).ref.boundingClientRect = boundingClientRect.pointer!;
        (nativeEntries + i).ref.rootBounds = rootBounds.pointer!;
        (nativeEntries + i).ref.intersectionRect = intersectionRect.pointer!;
      }

      return entryList;
    });
  }


  void observe(Element element) {
    if (enableWebFCommandLog) {
      domLogger.fine('[IntersectionObserver] observe observer=$pointer target=${element.pointer} thresholds=$_thresholds');
    }
    if (!element.addIntersectionObserver(this, _thresholds)) {
      return;
    }
    _elementList.add(element);
  }

  void unobserve(Element element) {
    if (enableWebFCommandLog) {
      domLogger.fine('[IntersectionObserver] unobserve observer=$pointer target=${element.pointer}');
    }
    _elementList.remove(element);
    element.removeIntersectionObserver(this);
  }

  void disconnect() {
    if (enableWebFCommandLog) {
      domLogger.fine('[IntersectionObserver] disconnect observer=$pointer targets=${_elementList.length}');
    }
    if (_elementList.isEmpty) return;
    for (var element in _elementList) {
      element.removeIntersectionObserver(this);
    }
    _elementList.clear();
  }

  bool hasObservations() {
    return _elementList.isNotEmpty;
  }

  void addEntry(DartIntersectionObserverEntry entry) {
    if (enableWebFCommandLog) {
      domLogger.fine(
          '[IntersectionObserver] addEntry observer=$pointer target=${entry.element.pointer} isIntersecting=${entry.isIntersecting} ratio=${entry.intersectionRatio}');
    }
    _entries.add(entry);
  }

  bool get hasPendingRecords => _entries.isNotEmpty;

  List<DartIntersectionObserverEntry> takeRecords() {
    List<DartIntersectionObserverEntry> entries = _entries.map((entry) => entry.copy()).toList();
    _entries.clear();
    return entries;
  }

  Future<void> deliver(WebFController controller) async {
    if (pointer == null) {
      if (enableWebFCommandLog) {
        domLogger.fine('[IntersectionObserver] deliver skipped: observer has no native pointer');
      }
      return;
    }

    if (_entries.isEmpty) return;

    final BindingObject? bindingObject = controller.view.getBindingObject<BindingObject>(pointer!);
    if (bindingObject == null) {
      if (enableWebFCommandLog) {
        domLogger.warning('[IntersectionObserver] deliver skipped: missing binding object for observer=$pointer');
      }
      return;
    }

    List<DartIntersectionObserverEntry> entries = takeRecords();
    if (entries.isEmpty) {
      return;
    }
    Completer completer = Completer();
    // Call methods implements at C++ side.
    DartInvokeBindingMethodsFromDart? invokeBindingMethodsFromDart =
        pointer!.ref.invokeBindingMethodFromDart.asFunction();

    Stopwatch? stopwatch;
    if (enableWebFCommandLog) {
      stopwatch = Stopwatch()..start();
    }

    // Allocate an chunk of memory for an list of NativeIntersectionObserverEntry
    Pointer<NativeIntersectionObserverEntry> nativeEntries =
        malloc.allocate(sizeOf<NativeIntersectionObserverEntry>() * entries.length);

    // Write the native memory from dart objects.
    for (int i = 0; i < entries.length; i++) {
      (nativeEntries + i).ref.isIntersecting = entries[i].isIntersecting ? 1 : 0;
      (nativeEntries + i).ref.intersectionRatio = entries[i].intersectionRatio;
      (nativeEntries + i).ref.element = entries[i].element.pointer!;

      final boundingClientRect = _createBoundingClientRect(controller.view, entries[i].boundingClientRect);
      final rootBounds = _createBoundingClientRect(controller.view, entries[i].rootBounds);
      final intersectionRect = _createBoundingClientRect(controller.view, entries[i].intersectionRect);
      (nativeEntries + i).ref.boundingClientRect = boundingClientRect.pointer!;
      (nativeEntries + i).ref.rootBounds = rootBounds.pointer!;
      (nativeEntries + i).ref.intersectionRect = intersectionRect.pointer!;
    }

    List<dynamic> dispatchEntryArguments = [nativeEntries, entries.length];
    Pointer<NativeValue> allocatedNativeArguments = makeNativeValueArguments(bindingObject, dispatchEntryArguments);

    _IntersectionObserverDeliverContext context = _IntersectionObserverDeliverContext(
        completer, stopwatch, allocatedNativeArguments, nativeEntries, controller);

    Pointer<NativeFunction<NativeInvokeResultCallback>> resultCallback = Pointer.fromFunction(_handleDeliverResult);

    if (enableWebFCommandLog) {
      domLogger.fine('[IntersectionObserver] deliver observer=$pointer entries=${entries.length}');
    }

    Future.microtask(() {
      invokeBindingMethodsFromDart(pointer!, contextId!, nullptr, dispatchEntryArguments.length,
          allocatedNativeArguments, context, resultCallback);
    });
    // debugPrint('Dom.IntersectionObserver.deliver this:$pointer end');
    return completer.future;
  }

  final List<DartIntersectionObserverEntry> _entries = [];
  final List<Element> _elementList = [];
  List<double> _thresholds = [0.0];

  BoundingClientRect _createBoundingClientRect(WebFViewController view, Rect rect) {
    return BoundingClientRect(
        context: BindingContext(view, view.contextId, allocateNewBindingObject()),
        x: rect.left,
        y: rect.top,
        width: rect.width,
        height: rect.height,
        top: rect.top,
        right: rect.right,
        bottom: rect.bottom,
        left: rect.left);
  }
}
