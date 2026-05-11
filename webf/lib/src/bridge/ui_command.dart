/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/devtools/panel/performance_tracker.dart';
import 'package:webf/src/devtools/panel/performance_subtypes.dart';
import 'package:webf/src/bridge/dom_lifecycle_tracker.dart';

class UICommand {
  late final UICommandType type;
  late final String args;
  late final Pointer nativePtr;
  late final Pointer nativePtr2;

  UICommand();
  UICommand.from(this.type, this.args, this.nativePtr, this.nativePtr2);

  @override
  String toString() {
    return 'UICommand(type: $type, args: $args, nativePtr: $nativePtr, nativePtr2: $nativePtr2)';
  }
}

final class UICommandBufferPack extends Struct {
  external Pointer<Void> head;
  external Pointer<Void> data;

  @Int64()
  external int length;
}

// FFI struct matching C++ UICommandItem structure
final class UICommandItemFFI extends Struct {
  @Int32()
  external int type;

  @Int32()
  external int args01Length;

  @Int64()
  external int string_01;

  @Int64()
  external int nativePtr;

  @Int64()
  external int nativePtr2;
}

bool enableWebFCommandLog = !kReleaseMode && Platform.environment['ENABLE_WEBF_JS_LOG'] == 'true';

typedef NativeFreeActiveCommandBuffer = Void Function(Pointer<Void>);
typedef DartFreeActiveCommandBuffer = void Function(Pointer<Void>);

final DartClearUICommandItems _freeActiveCommandBuffer =
WebFDynamicLibrary.ref.lookup<NativeFunction<NativeClearUICommandItems>>('freeActiveCommandBuffer').asFunction();

// New FFI-based implementation using Dart FFI structs
List<UICommand> nativeUICommandToDartFFI(double contextId) {
  Pointer<UICommandBufferPack> nativeCommandPack = getUICommandItems(getAllocatedPage(contextId)!);
  int commandLength = nativeCommandPack.ref.length;
  Pointer<UICommandItemFFI> commandBuffer = nativeCommandPack.ref.data.cast<UICommandItemFFI>();
  List<UICommand> results = List.generate(commandLength, (int index) {
    UICommand command = UICommand();

    // Access the struct at the current index
    UICommandItemFFI commandItem = commandBuffer[index];

    // Extract type
    command.type = UICommandType.values[commandItem.type];

    // Extract args string
    if (commandItem.string_01 != 0) {
      Pointer<Uint16> args_01 = Pointer.fromAddress(commandItem.string_01);
      command.args = uint16ToString(args_01, commandItem.args01Length);
      malloc.free(args_01);
    } else {
      command.args = '';
    }

    // Extract native pointers
    command.nativePtr = commandItem.nativePtr != 0 ? Pointer.fromAddress(commandItem.nativePtr) : nullptr;
    command.nativePtr2 = commandItem.nativePtr2 != 0 ? Pointer.fromAddress(commandItem.nativePtr2) : nullptr;

    return command;
  }, growable: false);

  _freeActiveCommandBuffer(nativeCommandPack.ref.head);
  malloc.free(nativeCommandPack);
  return results;
}

void execUICommands(WebFViewController view, List<UICommand> commands) {
  Map<int, bool> pendingStylePropertiesTargets = {};

  // Per-batch operation tallies. Surfaced as metadata on the
  // `domConstruction` span so the analysis script can detect wasted DOM
  // work without engine-side element-identity tracking.
  //
  // Cross-batch lifecycle (orphan / ephemeral detection) is also recorded
  // on the session-wide `DomLifecycleTracker` so the JSON export carries
  // an aggregate summary at session end.
  int createCount = 0;
  int insertCount = 0;
  int removeCount = 0;
  int disposeCount = 0;
  int setAttrCount = 0;
  int setStyleCount = 0;
  int setPropCount = 0;
  int eventCount = 0;
  int cloneCount = 0;

  // Pointers created in THIS batch — used to detect ephemerals (a node
  // created and removed/disposed before the batch closes never lives long
  // enough to be painted).
  final Set<int> createdInBatch = {};
  final Set<int> insertedInBatch = {};
  final Set<int> removedInBatch = {};

  final lifecycle = DomLifecycleTracker.instance;
  final handle = PerformanceTracker.instance.beginSpan(
      kSubTypeDomConstruction, 'execUICommands',
      metadata: {'commandCount': commands.length});

  for(UICommand command in commands) {
    UICommandType commandType = command.type;

    if (enableWebFCommandLog) {
      String printMsg;
      switch(command.type) {
        case UICommandType.setStyle:
          printMsg = 'nativePtr: ${command.nativePtr} type: ${command.type} key: ${command.args} value: ${command.nativePtr2 != nullptr ? nativeStringToString(command.nativePtr2.cast<NativeString>()) : null}';
          break;
        case UICommandType.setAttribute:
          printMsg = 'nativePtr: ${command.nativePtr} type: ${command.type} key: ${nativeStringToString(command.nativePtr2.cast<NativeString>())} value: ${command.args}';
          break;
        case UICommandType.createTextNode:
          printMsg = 'nativePtr: ${command.nativePtr} type: ${command.type} data: ${command.args}';
          break;
        default:
          printMsg = 'nativePtr: ${command.nativePtr} type: ${command.type} args: ${command.args} nativePtr2: ${command.nativePtr2}';
      }
      bridgeLogger.fine(printMsg);
    }

    if (commandType == UICommandType.startRecordingCommand || commandType == UICommandType.finishRecordingCommand) continue;

    Pointer nativePtr = command.nativePtr;
    final int ptrAddr = nativePtr.address;

    try {
      switch (commandType) {
        case UICommandType.createElement:
          view.createElement(nativePtr.cast<NativeBindingObject>(), command.args);
          createCount++;
          createdInBatch.add(ptrAddr);
          lifecycle.recordCreate(ptrAddr, command.args);
          break;
        case UICommandType.createDocument:
          view.initDocument(view, nativePtr.cast<NativeBindingObject>());
          createCount++;
          createdInBatch.add(ptrAddr);
          lifecycle.recordCreate(ptrAddr, '#document');
          break;
        case UICommandType.createWindow:
          view.initWindow(view, nativePtr.cast<NativeBindingObject>());
          createCount++;
          createdInBatch.add(ptrAddr);
          lifecycle.recordCreate(ptrAddr, '#window');
          break;
        case UICommandType.createTextNode:
          view.createTextNode(nativePtr.cast<NativeBindingObject>(), command.args);
          createCount++;
          createdInBatch.add(ptrAddr);
          lifecycle.recordCreate(ptrAddr, '#text');
          break;
        case UICommandType.createComment:
          view.createComment(nativePtr.cast<NativeBindingObject>());
          createCount++;
          createdInBatch.add(ptrAddr);
          lifecycle.recordCreate(ptrAddr, '#comment');
          break;
        case UICommandType.disposeBindingObject:
          WebFViewController.disposeBindingObject(view, nativePtr.cast<NativeBindingObject>());
          disposeCount++;
          lifecycle.recordDispose(ptrAddr);
          break;
        case UICommandType.addEvent:
          Pointer<AddEventListenerOptions> eventListenerOptions = command.nativePtr2.cast<AddEventListenerOptions>();
          view.addEvent(nativePtr.cast<NativeBindingObject>(), command.args,
              addEventListenerOptions: eventListenerOptions);
          eventCount++;
          break;
        case UICommandType.removeEvent:
          bool isCapture = command.nativePtr2.address == 1;
          view.removeEvent(nativePtr.cast<NativeBindingObject>(), command.args, isCapture: isCapture);
          eventCount++;
          break;
        case UICommandType.insertAdjacentNode:
          view.insertAdjacentNode(
              nativePtr.cast<NativeBindingObject>(), command.args, command.nativePtr2.cast<NativeBindingObject>());
          insertCount++;
          // For insertAdjacentNode, `nativePtr` is the parent target and
          // `nativePtr2` is the new child being inserted into the tree.
          // The lifecycle tracker keys on the child's identity — that's
          // the node whose "did it ever get used" we want to answer.
          final childAddr = command.nativePtr2.address;
          insertedInBatch.add(childAddr);
          lifecycle.recordInsert(childAddr);
          break;
        case UICommandType.removeNode:
          view.removeNode(nativePtr.cast<NativeBindingObject>());
          removeCount++;
          removedInBatch.add(ptrAddr);
          lifecycle.recordRemove(ptrAddr);
          break;
        case UICommandType.cloneNode:
          view.cloneNode(nativePtr.cast<NativeBindingObject>(), command.nativePtr2.cast<NativeBindingObject>());
          cloneCount++;
          createCount++;
          createdInBatch.add(command.nativePtr2.address);
          lifecycle.recordCreate(command.nativePtr2.address, 'cloneNode');
          break;
        case UICommandType.setStyle:
          String value;
          if (command.nativePtr2 != nullptr) {
            Pointer<NativeString> nativeValue = command.nativePtr2.cast<NativeString>();
            value = nativeStringToString(nativeValue);
            freeNativeString(nativeValue);
          } else {
            value = '';
          }
          view.setInlineStyle(nativePtr, command.args, value);
          pendingStylePropertiesTargets[nativePtr.address] = true;
          setStyleCount++;
          break;
        case UICommandType.clearStyle:
          view.clearInlineStyle(nativePtr);
          pendingStylePropertiesTargets[nativePtr.address] = true;
          setStyleCount++;
          break;
        case UICommandType.setAttribute:
          Pointer<NativeString> nativeKey = command.nativePtr2.cast<NativeString>();
          String key = nativeStringToString(nativeKey);
          freeNativeString(nativeKey);
          view.setAttribute(nativePtr.cast<NativeBindingObject>(), key, command.args);
          setAttrCount++;
          break;
        case UICommandType.setProperty:
          BindingObject? target = view.getBindingObject<BindingObject>(nativePtr.cast<NativeBindingObject>());
          if (target == null) {
            break;
          }

          List<dynamic> args = [command.args, fromNativeValue(view, command.nativePtr2.cast<NativeValue>())];
          setterBindingCall(target, args);
          setPropCount++;
          break;
        case UICommandType.removeAttribute:
          String key = command.args;
          view.removeAttribute(nativePtr, key);
          setAttrCount++;
          break;
        case UICommandType.createDocumentFragment:
          view.createDocumentFragment(nativePtr.cast<NativeBindingObject>());
          createCount++;
          createdInBatch.add(ptrAddr);
          lifecycle.recordCreate(ptrAddr, '#fragment');
          break;
        case UICommandType.createSVGElement:
          view.createElementNS(nativePtr.cast<NativeBindingObject>(), SVG_ELEMENT_URI, command.args);
          createCount++;
          createdInBatch.add(ptrAddr);
          lifecycle.recordCreate(ptrAddr, command.args);
          break;
        case UICommandType.createElementNS:
          Pointer<NativeString> nativeNameSpaceUri = command.nativePtr2.cast<NativeString>();
          String namespaceUri = nativeStringToString(nativeNameSpaceUri);
          freeNativeString(nativeNameSpaceUri);

          view.createElementNS(nativePtr.cast<NativeBindingObject>(), namespaceUri, command.args);
          createCount++;
          createdInBatch.add(ptrAddr);
          lifecycle.recordCreate(ptrAddr, command.args);
          break;
        case UICommandType.asyncCaller:
          Pointer<BindingObjectAsyncCallContext> asyncCallContext =
              command.nativePtr2.cast<BindingObjectAsyncCallContext>();

          asyncInvokeBindingMethodFromNativeImpl(
            view, asyncCallContext,
            command.nativePtr.cast<NativeBindingObject>(),
          );
          break;
        default:
          break;
      }
    } catch (e, stack) {
      bridgeLogger.severe('Error executing UI command', e, stack);
    }
  }
  // For pending style properties, we needs to flush to render style.
  for (int address in pendingStylePropertiesTargets.keys) {
    try {
      view.flushPendingStyleProperties(address);
    } catch (e, stack) {
      bridgeLogger.severe('Error executing UI command', e, stack);
    }
  }
  pendingStylePropertiesTargets.clear();

  // Ephemeral pointers within this batch — created and removed/disposed
  // before the batch even closed. These nodes will never be painted.
  final ephemeralInBatch =
      createdInBatch.intersection(removedInBatch).length;

  handle?.end(metadata: {
    'created': createCount,
    'inserted': insertCount,
    'removed': removeCount,
    'disposed': disposeCount,
    'setAttribute': setAttrCount,
    'setStyle': setStyleCount,
    'setProperty': setPropCount,
    'event': eventCount,
    'cloneNode': cloneCount,
    'ephemeralInBatch': ephemeralInBatch,
  });
}
