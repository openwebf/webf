/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:webf/foundation.dart';
import '../../bridge.dart';
import '../../launcher.dart';
import 'element.dart';
import 'intersection_observer_entry.dart';
import 'package:flutter/foundation.dart';

class _IntersectionObserverDeliverContext {
  Completer completer;
  Stopwatch? stopwatch;

  // Pointer<NativeValue> method;
  Pointer<NativeValue> allocatedNativeArguments;

  //Pointer<NativeValue> rawNativeEntries;
  WebFController controller;
  EvaluateOpItem? profileOp;

  _IntersectionObserverDeliverContext(
    this.completer,
    this.stopwatch,
    this.allocatedNativeArguments,
    //this.rawNativeEntries,
    this.controller,
    this.profileOp,
  );
}

void _handleDeliverResult(Object handle, Pointer<NativeValue> returnValue) {
  _IntersectionObserverDeliverContext context = handle as _IntersectionObserverDeliverContext;
  Pointer<EventDispatchResult> dispatchResult =
      fromNativeValue(context.controller.view, returnValue).cast<EventDispatchResult>();

  if (enableWebFCommandLog && context.stopwatch != null) {
    debugPrint('deliver IntersectionObserverEntry to native side, time: ${context.stopwatch!.elapsedMicroseconds}us');
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
    if (!element.addIntersectionObserver(this)) {
      return;
    }
    _elementList.add(element);
    debugPrint('Dom.IntersectionObserver.observe');

    // TODO(pengfei12.guo): test deliver
    Future.delayed(Duration(milliseconds: 1000), () async {
      addEntry(DartIntersectionObserverEntry(true, element));
      await deliver(element.ownerView.rootController);
    });
  }

  void unobserve(Element element) {
    _elementList.remove(element);
    element.removeIntersectionObserver(this);
    debugPrint('Dom.IntersectionObserver.unobserve');
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
    debugPrint('Dom.IntersectionObserver.addEntry entry:$entry');
    _entries.add(entry);
  }

  List<DartIntersectionObserverEntry> takeRecords() {
    List<DartIntersectionObserverEntry> entries = _entries.map((entry) => entry.copy()).toList();
    _entries.clear();
    return entries;
  }

  Future<void> deliver(WebFController controller) async {
    if (pointer == null) return;
    debugPrint('Dom.IntersectionObserver.deliver pointer:$pointer');
    List<DartIntersectionObserverEntry> entries = takeRecords();
    if (entries.isNotEmpty) {
      Completer completer = Completer();

      EvaluateOpItem? currentProfileOp;
      if (enableWebFProfileTracking) {
        currentProfileOp = WebFProfiler.instance.startTrackEvaluate('_dispatchEventToNative');
      }

      BindingObject bindingObject = controller.view.getBindingObject(pointer!);
      // Call methods implements at C++ side.
      DartInvokeBindingMethodsFromDart? f = pointer!.ref.invokeBindingMethodFromDart.asFunction();

      Stopwatch? stopwatch;
      if (enableWebFCommandLog) {
        stopwatch = Stopwatch()..start();
      }

      // Allocate an chunk of memory for an list of NativeIntersectionObserverEntry
      Pointer<NativeIntersectionObserverEntry> head =
          malloc.allocate(sizeOf<NativeIntersectionObserverEntry>() * entries.length);

      // Write the native memory from dart objects.
      for(int i = 0; i < entries.length; i ++) {
        (head + i).ref.isIntersecting = entries[i].isIntersecting ? 1 : 0;
        (head + i).ref.target = entries[i].element.pointer!;
      }

      List<dynamic> dispatchEntryArguments = [
        head,
        entries.length
      ];

      Pointer<NativeValue> allocatedNativeArguments = makeNativeValueArguments(bindingObject, dispatchEntryArguments);

      _IntersectionObserverDeliverContext context = _IntersectionObserverDeliverContext(
          completer, stopwatch, allocatedNativeArguments, controller, currentProfileOp);

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
        malloc.free(head);
      });

      return completer.future;
    }
  }

  final List<DartIntersectionObserverEntry> _entries = [];
  final List<Element> _elementList = [];
}
