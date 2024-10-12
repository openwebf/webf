/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:ffi';
import 'dart:html';

import 'package:ffi/ffi.dart';
import 'package:webf/foundation.dart';
import '../../bridge.dart';
import '../../launcher.dart';
import 'element.dart';
import 'intersection_observer_entry.dart';

class _IntersectionObserverDeliverContext {
  Completer completer;
  Stopwatch? stopwatch;

  // Pointer<NativeValue> method;
  Pointer<NativeValue> allocatedNativeArguments;
  Pointer<NativeValue> rawNativeEntries;
  WebFController controller;
  EvaluateOpItem? profileOp;

  _IntersectionObserverDeliverContext(
    this.completer,
    this.stopwatch,
    this.allocatedNativeArguments,
    this.rawNativeEntries,
    this.controller,
    this.profileOp,
  );
}

void _handleDeliverResult(_IntersectionObserverDeliverContext context, Pointer<NativeValue> returnValue) {
  Pointer<EventDispatchResult> dispatchResult =
      fromNativeValue(context.controller.view, returnValue).cast<EventDispatchResult>();

  if (enableWebFCommandLog && context.stopwatch != null) {
    print('deliver IntersectionObserverEntry to native side, time: ${context.stopwatch!.elapsedMicroseconds}us');
  }

  // Free the allocated arguments.
  malloc.free(context.allocatedNativeArguments);
  malloc.free(dispatchResult);
  malloc.free(returnValue);

  if (enableWebFProfileTracking) {
    WebFProfiler.instance.finishTrackEvaluate(context.profileOp!);
  }

  context.completer.complete();
}

class IntersectionObserver extends DynamicBindingObject {
  IntersectionObserver(BindingContext? context) : super(context);

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {}

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {}

  void observe(Element element) {
    _elementList.add(element);
    element.addIntersectionObserver(this);
  }

  void unobserve(Element element) {
    _elementList.remove(element);
    element.removeIntersectionObserver(this);
  }

  void disconnect() {
    if (_elementList.isEmpty) return;
    for (var element in _elementList) {
      element!.removeIntersectionObserver(this);
    }
    _elementList.clear();
  }

  bool HasObservations() {
    return _elementList.isNotEmpty;
  }

  void addEntry(DartIntersectionObserverEntry entry) {
    _entries.add(entry);
  }

  List<NativeIntersectionObserverEntry> takeRecords() {
    List<DartIntersectionObserverEntry> entries = _entries.map((entry) => entry.copy()).toList();
    _entries.clear();
    return toNativeEntries(entries);
  }

  List<NativeIntersectionObserverEntry> toNativeEntries(List<DartIntersectionObserverEntry> entries) {
    if (entries.isEmpty) {
      return [];
    }

    return List.generate(entries.length, (i) {
      return NativeIntersectionObserverEntry(
        BindingContext(
          entries[i].element.ownerView,
          entries[i].element.ownerView.contextId,
          allocateNewBindingObject(),
        ),
        entries[i].isIntersecting,
        entries[i].element,
      );
    });
  }

  Future<void> deliver(WebFController controller) async {
    if (pointer == null) return;

    List<NativeIntersectionObserverEntry> nativeEntries = takeRecords();
    if (nativeEntries.isNotEmpty) {
      Completer completer = Completer();

      EvaluateOpItem? currentProfileOp;
      if (enableWebFProfileTracking) {
        currentProfileOp = WebFProfiler.instance.startTrackEvaluate('_dispatchEventToNative');
      }

      BindingObject bindingObject = controller.view.getBindingObject(pointer!);
      // Call methods implements at C++ side.
      DartInvokeBindingMethodsFromDart? f = pointer!.ref.invokeBindingMethodFromDart.asFunction();

      Pointer<NativeValue> rawNativeEntries = malloc.allocate(sizeOf<NativeValue>());
      toNativeValue(rawNativeEntries, 'dispatchEvent');

      List<dynamic> dispatchEntryArguments = [rawNativeEntries];

      Stopwatch? stopwatch;
      if (enableWebFCommandLog) {
        stopwatch = Stopwatch()..start();
      }

      Pointer<NativeValue> allocatedNativeArguments = makeNativeValueArguments(bindingObject, dispatchEntryArguments);

      _IntersectionObserverDeliverContext context = _IntersectionObserverDeliverContext(
          completer, stopwatch, allocatedNativeArguments, rawNativeEntries, controller, currentProfileOp);

      Pointer<NativeFunction<NativeInvokeResultCallback>> resultCallback = Pointer.fromFunction(_handleDeliverResult);

      Future.microtask(() {
// typedef DartInvokeBindingMethodsFromDart = void Function(
//     Pointer<NativeBindingObject> binding_object,
//     int profileId,
//     Pointer<NativeValue> method,
//     int argc,
//     Pointer<NativeValue> argv,
//     Object bindingDartObject,
//     Pointer<NativeFunction<NativeInvokeResultCallback>> result_callback);
        f(pointer!, currentProfileOp?.hashCode ?? 0, nullptr, dispatchEntryArguments.length, allocatedNativeArguments,
            context, resultCallback);
      });

      return completer.future;
    }
  }

  final List<DartIntersectionObserverEntry> _entries = [];
  final List<Element> _elementList = [];
}
