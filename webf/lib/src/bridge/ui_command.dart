/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
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

  for(UICommand command in commands) {
    UICommandType commandType = command.type;

    if (enableWebFCommandLog) {
      String printMsg;
      switch(command.type) {
        case UICommandType.setStyle:
          String? valueLog;
          String? baseHrefLog;
          if (command.nativePtr2 != nullptr) {
            try {
              final Pointer<NativeStyleValueWithHref> payload =
                  command.nativePtr2.cast<NativeStyleValueWithHref>();
              final Pointer<NativeString> valuePtr = payload.ref.value;
              final Pointer<NativeString> hrefPtr = payload.ref.href;
              if (valuePtr != nullptr) {
                valueLog = nativeStringToString(valuePtr);
              }
              if (hrefPtr != nullptr) {
                baseHrefLog = nativeStringToString(hrefPtr);
              }
            } catch (_) {
              valueLog = '<error>';
              baseHrefLog = '<error>';
            }
          }
          printMsg =
              'nativePtr: ${command.nativePtr} type: ${command.type} key: ${command.args} value: $valueLog baseHref: ${baseHrefLog ?? 'null'}';
          break;
        case UICommandType.setPseudoStyle:
          if (command.nativePtr2 != nullptr) {
            final (:key, :value) = nativePairToPairRecord(command.nativePtr2.cast());
            printMsg =
              'nativePtr: ${command.nativePtr} type: ${command.type} pseudo: ${command.args} property: $key=$value';
          } else {
            printMsg =
              'nativePtr: ${command.nativePtr} type: ${command.type} pseudo: ${command.args} property: <null>';
          }
          break;
        case UICommandType.removePseudoStyle:
          printMsg = 'nativePtr: ${command.nativePtr} type: ${command.type} pseudo: ${command.args} remove: ${command.nativePtr2 != nullptr ? nativeStringToString(command.nativePtr2.cast<NativeString>()) : null}';
          break;
        case UICommandType.clearPseudoStyle:
          printMsg = 'nativePtr: ${command.nativePtr} type: ${command.type} pseudo: ${command.args}';
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

    try {
      switch (commandType) {
        case UICommandType.requestAnimationFrame:
          // args carries the requestId generated on C++ side
          int requestId = 0;
          if (command.args.isNotEmpty) {
            requestId = int.tryParse(command.args) ?? 0;
          }
          // nativePtr2 is a function pointer: NativeRAFAsyncCallback
          final Pointer<NativeFunction<NativeRAFAsyncCallback>> rafCallbackPtr =
              command.nativePtr2.cast<NativeFunction<NativeRAFAsyncCallback>>();
          final DartRAFAsyncCallback rafCallback = rafCallbackPtr.asFunction();

          // Schedule a frame and invoke native callback on frame
          view.rootController.module.requestAnimationFrame(requestId, (double highResTimeStamp) {
            try {
              rafCallback(command.nativePtr.cast<Void>(), view.contextId, highResTimeStamp, nullptr);
            } catch (e, stack) {
              Pointer<Utf8> nativeErrorMessage = ('Error: $e\n$stack').toNativeUtf8();
              rafCallback(command.nativePtr.cast<Void>(), view.contextId, highResTimeStamp, nativeErrorMessage);
            }
          });
          break;
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
          String value = '';
          String? baseHref;
          if (command.nativePtr2 != nullptr) {
            final Pointer<NativeStyleValueWithHref> payload =
                command.nativePtr2.cast<NativeStyleValueWithHref>();
            final Pointer<NativeString> valuePtr = payload.ref.value;
            final Pointer<NativeString> hrefPtr = payload.ref.href;
            if (valuePtr != nullptr) {
              final Pointer<NativeString> nativeValue = valuePtr.cast<NativeString>();
              value = nativeStringToString(nativeValue);
              freeNativeString(nativeValue);
            }
            if (hrefPtr != nullptr) {
              final Pointer<NativeString> nativeHref = hrefPtr.cast<NativeString>();
              final String raw = nativeStringToString(nativeHref);
              freeNativeString(nativeHref);
              baseHref = raw.isEmpty ? null : raw;
            }
            malloc.free(payload);
          }

          view.setInlineStyle(nativePtr, command.args, value, baseHref: baseHref);
          pendingStylePropertiesTargets[nativePtr.address] = true;
          break;
        case UICommandType.clearStyle:
          view.clearInlineStyle(nativePtr);
          pendingStylePropertiesTargets[nativePtr.address] = true;
          break;
        case UICommandType.setPseudoStyle:
          if (command.nativePtr2 != nullptr) {
            final (:key, :value) = nativePairToPairRecord(command.nativePtr2.cast(), free: true);
            if (key.isNotEmpty) {
              view.setPseudoStyle(nativePtr, command.args, key, value);
            }
          }
          break;
        case UICommandType.removePseudoStyle:
          if (command.nativePtr2 != nullptr) {
            Pointer<NativeString> nativeKey = command.nativePtr2.cast<NativeString>();
            String key = nativeStringToString(nativeKey);
            freeNativeString(nativeKey);
            view.removePseudoStyle(nativePtr, command.args, key);
          }
          break;
        case UICommandType.clearPseudoStyle:
          view.clearPseudoStyle(nativePtr, command.args);
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
          view.createElementNS(nativePtr.cast<NativeBindingObject>(), svgElementUri, command.args);
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
        case UICommandType.requestCanvasPaint:
          view.requestCanvasPaint(nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.addIntersectionObserver:
          view.addIntersectionObserver(
              nativePtr.cast<NativeBindingObject>(), command.nativePtr2.cast<NativeBindingObject>());
          break;
        case UICommandType.removeIntersectionObserver:
          view.removeIntersectionObserver(
              nativePtr.cast<NativeBindingObject>(), command.nativePtr2.cast<NativeBindingObject>());
          break;
        case UICommandType.disconnectIntersectionObserver:
          view.disconnectIntersectionObserver(nativePtr.cast<NativeBindingObject>());
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
}
