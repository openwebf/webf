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

class UICommandBufferPack extends Struct {
  external Pointer<Void> head;
  external Pointer<Void> data;

  @Int64()
  external int length;
}

// FFI struct matching C++ UICommandItem structure
class UICommandItemFFI extends Struct {
  @Int32()
  external int type;

  @Int32()
  external int args_01_length;

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
      command.args = uint16ToString(args_01, commandItem.args_01_length);
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
      print(printMsg);
    }

    if (commandType == UICommandType.startRecordingCommand || commandType == UICommandType.finishRecordingCommand) continue;

    Pointer nativePtr = command.nativePtr;

    try {
      switch (commandType) {
        case UICommandType.createElement:
          view.createElement(nativePtr.cast<NativeBindingObject>(), command.args);

          break;
        case UICommandType.createDocument:
          view.initDocument(view, nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.createWindow:
          view.initWindow(view, nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.createTextNode:
          view.createTextNode(nativePtr.cast<NativeBindingObject>(), command.args);
          break;
        case UICommandType.createComment:
          view.createComment(nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.disposeBindingObject:
          WebFViewController.disposeBindingObject(view, nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.addEvent:
          Pointer<AddEventListenerOptions> eventListenerOptions = command.nativePtr2.cast<AddEventListenerOptions>();
          view.addEvent(nativePtr.cast<NativeBindingObject>(), command.args,
              addEventListenerOptions: eventListenerOptions);
          break;
        case UICommandType.removeEvent:
          bool isCapture = command.nativePtr2.address == 1;
          view.removeEvent(nativePtr.cast<NativeBindingObject>(), command.args, isCapture: isCapture);
          break;
        case UICommandType.insertAdjacentNode:
          view.insertAdjacentNode(
              nativePtr.cast<NativeBindingObject>(), command.args, command.nativePtr2.cast<NativeBindingObject>());
          break;
        case UICommandType.removeNode:
          view.removeNode(nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.cloneNode:
          view.cloneNode(nativePtr.cast<NativeBindingObject>(), command.nativePtr2.cast<NativeBindingObject>());
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
          break;
        case UICommandType.clearStyle:
          view.clearInlineStyle(nativePtr);
          pendingStylePropertiesTargets[nativePtr.address] = true;
          break;
        case UICommandType.setAttribute:
          Pointer<NativeString> nativeKey = command.nativePtr2.cast<NativeString>();
          String key = nativeStringToString(nativeKey);
          freeNativeString(nativeKey);
          view.setAttribute(nativePtr.cast<NativeBindingObject>(), key, command.args);
          break;
        case UICommandType.setProperty:
          BindingObject? target = view.getBindingObject<BindingObject>(nativePtr.cast<NativeBindingObject>());
          if (target == null) {
            break;
          }

          List<dynamic> args = [command.args, fromNativeValue(view, command.nativePtr2.cast<NativeValue>())];
          setterBindingCall(target, args);
          break;
        case UICommandType.removeAttribute:
          String key = command.args;
          view.removeAttribute(nativePtr, key);
          break;
        case UICommandType.createDocumentFragment:
          view.createDocumentFragment(nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.createSVGElement:
          view.createElementNS(nativePtr.cast<NativeBindingObject>(), SVG_ELEMENT_URI, command.args);
          break;
        case UICommandType.createElementNS:
          Pointer<NativeString> nativeNameSpaceUri = command.nativePtr2.cast<NativeString>();
          String namespaceUri = nativeStringToString(nativeNameSpaceUri);
          freeNativeString(nativeNameSpaceUri);

          view.createElementNS(nativePtr.cast<NativeBindingObject>(), namespaceUri, command.args);
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
      print('$e\n$stack');
    }
  }
  // For pending style properties, we needs to flush to render style.
  for (int address in pendingStylePropertiesTargets.keys) {
    try {
      view.flushPendingStyleProperties(address);
    } catch (e, stack) {
      print('$e\n$stack');
    }
  }
  pendingStylePropertiesTargets.clear();
}
