/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/launcher.dart';
import 'package:webf/dom.dart';

class UICommand {
  late final UICommandType type;
  late final String args;
  late final Pointer nativePtr;
  late final Pointer nativePtr2;

  @override
  String toString() {
    return 'UICommand(type: $type, args: $args, nativePtr: $nativePtr, nativePtr2: $nativePtr2)';
  }
}

const int nodeCreationFlag = 1;
const int nodeMutationFlag = 1 << 2;
const int styleUpdateFlag = 1 << 3;
const int eventFlag = 1 << 4;
const int attributeUpdateFlag = 1 << 5;
const int disposeBindingObjectFlag = 1 << 6;
const int otherOperationFlag = 1 << 7;

bool isCommandsContainsNodeCreation(int flag) {
  return flag & nodeCreationFlag != 0;
}

bool isCommandsContainsNodeMutation(int flag) {
  return flag & nodeMutationFlag != 0;
}

bool isCommandsContainsStyleUpdate(int flag) {
  return flag & styleUpdateFlag != 0;
}

const int standardUICommandReason = 1;
const int dependentOnElementUICommandReason = 1 << 2;
const int dependentOnLayoutUICommandReason = 1 << 3;

bool isFlushUICommandReasonDependsOnElement(int reason) {
  return reason & dependentOnElementUICommandReason != 0;
}

bool isFlushUICommandReasonDependsLayoutStyle(int reason) {
  return reason & dependentOnLayoutUICommandReason != 0;
}

// struct UICommandItem {
//   int32_t type;             // offset: 0 ~ 0.5
//   int32_t args_01_length;   // offset: 0.5 ~ 1
//   const uint16_t *string_01;// offset: 1
//   void* nativePtr;          // offset: 2
//   void* nativePtr2;         // offset: 3
// };
const int nativeCommandSize = 4;
const int typeAndArgs01LenMemOffset = 0;
const int args01StringMemOffset = 1;
const int nativePtrMemOffset = 2;
const int native2PtrMemOffset = 3;

const int commandBufferPrefix = 1;

bool enableWebFCommandLog = !kReleaseMode && Platform.environment['ENABLE_WEBF_JS_LOG'] == 'true';

// We found there are performance bottleneck of reading native memory with Dart FFI API.
// So we align all UI instructions to a whole block of memory, and then convert them into a dart array at one time,
// To ensure the fastest subsequent random access.
List<UICommand> nativeUICommandToDart(List<int> rawMemory, int commandLength, double contextId) {
  List<UICommand> results = List.generate(commandLength, (int _i) {
    int i = _i * nativeCommandSize;
    UICommand command = UICommand();

    int typeArgs01Combine = rawMemory[i + typeAndArgs01LenMemOffset];

    //      int32_t        int32_t
    // +-------------+-----------------+
    // |      type     | args_01_length  |
    // +-------------+-----------------+
    int args01Length = (typeArgs01Combine >> 32).toSigned(32);
    int type = (typeArgs01Combine ^ (args01Length << 32)).toSigned(32);

    command.type = UICommandType.values[type];

    int args01StringMemory = rawMemory[i + args01StringMemOffset];
    if (args01StringMemory != 0) {
      Pointer<Uint16> args_01 = Pointer.fromAddress(args01StringMemory);
      command.args = uint16ToString(args_01, args01Length);
      malloc.free(args_01);
    } else {
      command.args = '';
    }

    int nativePtrValue = rawMemory[i + nativePtrMemOffset];
    command.nativePtr = nativePtrValue != 0 ? Pointer.fromAddress(rawMemory[i + nativePtrMemOffset]) : nullptr;

    int nativePtr2Value = rawMemory[i + native2PtrMemOffset];
    command.nativePtr2 = nativePtr2Value != 0 ? Pointer.fromAddress(nativePtr2Value) : nullptr;
    return command;
  }, growable: false);

  return results;
}

bool shouldExecUICommands(WebFViewController view, bool isFinishedRecording, Pointer<NativeBindingObject> self, int commandFlag, int operationReason) {
  if (isFinishedRecording) {
    SchedulerBinding.instance.scheduleFrame();
  }

  bool isElementCreation = isCommandsContainsNodeCreation(commandFlag);
  bool isElementMutation = isCommandsContainsNodeMutation(commandFlag);

  bool isDependsOnElement = isFlushUICommandReasonDependsOnElement(operationReason);
  if (isDependsOnElement) {
    isDependsOnElement = !view.hasBindingObject(self);
  }

  bool isDependsOnStyleLayout = isFlushUICommandReasonDependsLayoutStyle(operationReason);

  if (enableWebFCommandLog) {
    print('''
UI COMMAND CONDITION CHECK:
  REASON: $operationReason
  isElementCreation: $isElementCreation
  isElementMutation: $isElementMutation
  isDependsOnElement: $isDependsOnElement
  isDependsOnStyleLayout: $isDependsOnStyleLayout
  ''');
  }
  return isElementCreation || isElementMutation || isDependsOnElement || isDependsOnStyleLayout;
}

void execUICommands(WebFViewController view, UICommandIterator commands) {
  Map<int, bool> pendingStylePropertiesTargets = {};
  Set<int> pendingRecalculateTargets = {};

  final iterable = UICommandIterable(commands);

  for(UICommand? command in iterable) {
    if (command == null) continue;

    UICommandType commandType = command.type;

    if (enableWebFCommandLog) {
      String printMsg;
      switch(command.type) {
        case UICommandType.setStyle:
          printMsg = 'nativePtr: ${command.nativePtr} type: ${command.type} key: ${command.args} value: ${nativeStringToString(command.nativePtr2.cast<NativeString>())}';
          break;
        case UICommandType.setAttribute:
          printMsg = 'nativePtr: ${command.nativePtr} type: ${command.type} key: ${nativeStringToString(command.nativePtr2.cast<NativeString>())} value: ${command.args}';
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
          view.disposeBindingObject(view, nativePtr.cast<NativeBindingObject>());
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
          pendingRecalculateTargets.add(nativePtr.address);
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

  for (var address in pendingRecalculateTargets) {
    try {
      view.recalculateStyle(address);
    } catch (e, stack) {
      print('$e\n$stack');
    }
  }
  pendingRecalculateTargets.clear();
}
