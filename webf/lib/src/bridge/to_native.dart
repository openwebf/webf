/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/webf.dart';

// Steps for using dart:ffi to call a C function from Dart:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the C function.
// 3. Create a typedef for the variable that you’ll use when calling the C function.
// 4. Open the dynamic library that contains the C function.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call the C function.

class WebFInfo {
  final Pointer<NativeWebFInfo> _nativeWebFInfo;

  WebFInfo(Pointer<NativeWebFInfo> info) : _nativeWebFInfo = info;

  String get appName {
    if (_nativeWebFInfo.ref.app_name == nullptr) return '';
    return _nativeWebFInfo.ref.app_name.toDartString();
  }

  String get appVersion {
    if (_nativeWebFInfo.ref.app_version == nullptr) return '';
    return _nativeWebFInfo.ref.app_version.toDartString();
  }

  String get appRevision {
    if (_nativeWebFInfo.ref.app_revision == nullptr) return '';
    return _nativeWebFInfo.ref.app_revision.toDartString();
  }

  String get systemName {
    if (_nativeWebFInfo.ref.system_name == nullptr) return '';
    return _nativeWebFInfo.ref.system_name.toDartString();
  }
}

typedef NativeGetWebFInfo = Pointer<NativeWebFInfo> Function();
typedef DartGetWebFInfo = Pointer<NativeWebFInfo> Function();

final DartGetWebFInfo _getWebFInfo =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeGetWebFInfo>>('getWebFInfo').asFunction();

final WebFInfo _cachedInfo = WebFInfo(_getWebFInfo());

final HashMap<int, Pointer<Void>> _allocatedPages = HashMap();

Pointer<Void>? getAllocatedPage(int contextId) {
  return _allocatedPages[contextId];
}

WebFInfo getWebFInfo() {
  return _cachedInfo;
}

// Register invokeEventListener
typedef NativeInvokeEventListener = Pointer<NativeValue> Function(
    Pointer<Void>, Pointer<NativeString>, Pointer<Utf8> eventType, Pointer<Void> nativeEvent, Pointer<NativeValue>);
typedef DartInvokeEventListener = Pointer<NativeValue> Function(
    Pointer<Void>, Pointer<NativeString>, Pointer<Utf8> eventType, Pointer<Void> nativeEvent, Pointer<NativeValue>);

final DartInvokeEventListener _invokeModuleEvent =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeInvokeEventListener>>('invokeModuleEvent').asFunction();

dynamic invokeModuleEvent(int contextId, String moduleName, Event? event, extra) {
  if (WebFController.getControllerOfJSContextId(contextId) == null) {
    return null;
  }
  Pointer<NativeString> nativeModuleName = stringToNativeString(moduleName);
  Pointer<Void> rawEvent = event == null ? nullptr : event.toRaw().cast<Void>();
  Pointer<NativeValue> extraData = malloc.allocate(sizeOf<NativeValue>());
  toNativeValue(extraData, extra);
  assert(_allocatedPages.containsKey(contextId));
  Pointer<NativeValue> dispatchResult = _invokeModuleEvent(
      _allocatedPages[contextId]!, nativeModuleName, event == null ? nullptr : event.type.toNativeUtf8(), rawEvent, extraData);
  freeNativeString(nativeModuleName);
  dynamic result = fromNativeValue(dispatchResult);
  malloc.free(dispatchResult);
  return result;
}

typedef DartDispatchEvent = int Function(int contextId, Pointer<NativeBindingObject> nativeBindingObject,
    Pointer<NativeString> eventType, Pointer<Void> nativeEvent, int isCustomEvent);

dynamic emitModuleEvent(int contextId, String moduleName, Event? event, extra) {
  return invokeModuleEvent(contextId, moduleName, event, extra);
}

// Register createScreen
typedef NativeCreateScreen = Pointer<Void> Function(Double, Double);
typedef DartCreateScreen = Pointer<Void> Function(double, double);

final DartCreateScreen _createScreen =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeCreateScreen>>('createScreen').asFunction();

Pointer<Void> createScreen(double width, double height) {
  return _createScreen(width, height);
}

// Register evaluateScripts
typedef NativeEvaluateScripts = Int8 Function(
    Pointer<Void>, Pointer<NativeString> code, Pointer<Pointer<Uint8>> parsedBytecodes, Pointer<Uint64> bytecodeLen, Pointer<Utf8> url, Int32 startLine);
typedef DartEvaluateScripts = int Function(
    Pointer<Void>, Pointer<NativeString> code, Pointer<Pointer<Uint8>> parsedBytecodes, Pointer<Uint64> bytecodeLen, Pointer<Utf8> url, int startLine);

// Register parseHTML
typedef NativeParseHTML = Void Function(Pointer<Void>, Pointer<Utf8> code, Int32 length);
typedef DartParseHTML = void Function(Pointer<Void>, Pointer<Utf8> code, int length);

final DartEvaluateScripts _evaluateScripts =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeEvaluateScripts>>('evaluateScripts').asFunction();

final DartParseHTML _parseHTML =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeParseHTML>>('parseHTML').asFunction();

int _anonymousScriptEvaluationId = 0;

class ScriptByteCode {
  ScriptByteCode();
  late Uint8List bytes;
}

Future<bool> evaluateScripts(int contextId, String code, {String? url, int line = 0}) async {
  if (WebFController.getControllerOfJSContextId(contextId) == null) {
    return false;
  }
  // Assign `vm://$id` for no url (anonymous scripts).
  if (url == null) {
    url = 'vm://$_anonymousScriptEvaluationId';
    _anonymousScriptEvaluationId++;
  }

  // QuickJSByteCodeCacheObject cacheObject = await QuickJSByteCodeCache.getCacheObject(code);
  //
  // if (cacheObject.valid && cacheObject.bytes != null) {
  //   return evaluateQuickjsByteCode(contextId, cacheObject.bytes!);
  // } else {
    Pointer<NativeString> nativeString = stringToNativeString(code);
    Pointer<Utf8> _url = url.toNativeUtf8();
    try {
      assert(_allocatedPages.containsKey(contextId));
      int result;

      // if (QuickJSByteCodeCache.isCodeNeedCache(code)) {
      //   // Export the bytecode from scripts
      //   Pointer<Pointer<Uint8>> bytecodes = malloc.allocate(sizeOf<Pointer<Uint8>>());
      //   Pointer<Uint64> bytecodeLen = malloc.allocate(sizeOf<Uint64>());
      //   result = _evaluateScripts(_allocatedPages[contextId]!, nativeString, bytecodes, bytecodeLen, _url, line);
      //   Uint8List bytes = bytecodes.value.asTypedList(bytecodeLen.value);
      //
      //   print('orignal source: ${code.length / 1024}KB --> bytecode size: ${bytecodeLen.value / 1024}KB');
      //
      //   // Save to disk cache
      //   QuickJSByteCodeCache.putObject(code, bytes);
      // } else {
        result = _evaluateScripts(_allocatedPages[contextId]!, nativeString, nullptr, nullptr, _url, line);
      // }

      return result == 1;
    } catch (e, stack) {
      print('$e\n$stack');
    }
    freeNativeString(nativeString);
  // }
  return false;
}

typedef NativeEvaluateQuickjsByteCode = Int8 Function(Pointer<Void>, Pointer<Uint8> bytes, Int32 byteLen);
typedef DartEvaluateQuickjsByteCode = int Function(Pointer<Void>, Pointer<Uint8> bytes, int byteLen);

final DartEvaluateQuickjsByteCode _evaluateQuickjsByteCode = WebFDynamicLibrary.ref
    .lookup<NativeFunction<NativeEvaluateQuickjsByteCode>>('evaluateQuickjsByteCode')
    .asFunction();

bool evaluateQuickjsByteCode(int contextId, Uint8List bytes) {
  if (WebFController.getControllerOfJSContextId(contextId) == null) {
    return false;
  }
  Pointer<Uint8> byteData = malloc.allocate(sizeOf<Uint8>() * bytes.length);
  byteData.asTypedList(bytes.length).setAll(0, bytes);
  assert(_allocatedPages.containsKey(contextId));
  int result = _evaluateQuickjsByteCode(_allocatedPages[contextId]!, byteData, bytes.length);
  malloc.free(byteData);
  return result == 1;
}

void parseHTML(int contextId, String code) {
  if (WebFController.getControllerOfJSContextId(contextId) == null) {
    return;
  }
  Pointer<Utf8> nativeCode = code.toNativeUtf8();
  try {
    assert(_allocatedPages.containsKey(contextId));
    _parseHTML(_allocatedPages[contextId]!, nativeCode, nativeCode.length);
  } catch (e, stack) {
    print('$e\n$stack');
  }
  malloc.free(nativeCode);
}

// Register initJsEngine
typedef NativeInitDartContext = Void Function(Pointer<Uint64> dartMethods, Int32 methodsLength);
typedef DartInitDartContext = void Function(Pointer<Uint64> dartMethods, int methodsLength);

final DartInitDartContext _initDartContext =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeInitDartContext>>('initDartContext').asFunction();

void initDartContext(List<int> dartMethods) {
  Pointer<Uint64> bytes = malloc.allocate<Uint64>(sizeOf<Uint64>() * dartMethods.length);
  Uint64List nativeMethodList = bytes.asTypedList(dartMethods.length);
  nativeMethodList.setAll(0, dartMethods);
  _initDartContext(bytes, dartMethods.length);
}

typedef NativeDisposePage = Void Function(Pointer<Void> page);
typedef DartDisposePage = void Function(Pointer<Void> page);

final DartDisposePage _disposePage =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeDisposePage>>('disposePage').asFunction();

void disposePage(int contextId) {
  Pointer<Void> page = _allocatedPages[contextId]!;
  _disposePage(page);
  _allocatedPages.remove(contextId);
}

typedef NativeAllocateNewPage = Pointer<Void> Function(Int32);
typedef DartAllocateNewPage = Pointer<Void> Function(int);

final DartAllocateNewPage _allocateNewPage =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeAllocateNewPage>>('allocateNewPage').asFunction();

void allocateNewPage(int targetContextId) {
  Pointer<Void> page = _allocateNewPage(targetContextId);
  assert(!_allocatedPages.containsKey(targetContextId));
  _allocatedPages[targetContextId] = page;
}

typedef NativeRegisterPluginByteCode = Void Function(Pointer<Uint8> bytes, Int32 length, Pointer<Utf8> pluginName);
typedef DartRegisterPluginByteCode = void Function(Pointer<Uint8> bytes, int length, Pointer<Utf8> pluginName);

final DartRegisterPluginByteCode _registerPluginByteCode =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeRegisterPluginByteCode>>('registerPluginByteCode').asFunction();

void registerPluginByteCode(Uint8List bytecode, String name) {
  Pointer<Uint8> bytes = malloc.allocate(sizeOf<Uint8>() * bytecode.length);
  bytes.asTypedList(bytecode.length).setAll(0, bytecode);
  _registerPluginByteCode(bytes, bytecode.length, name.toNativeUtf8());
}

typedef NativeProfileModeEnabled = Int32 Function();
typedef DartProfileModeEnabled = int Function();

final DartProfileModeEnabled _profileModeEnabled =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeProfileModeEnabled>>('profileModeEnabled').asFunction();

const _CODE_ENABLED = 1;

bool profileModeEnabled() {
  return _profileModeEnabled() == _CODE_ENABLED;
}

typedef NativeDispatchUITask = Void Function(Int32 contextId, Pointer<Void> context, Pointer<Void> callback);
typedef DartDispatchUITask = void Function(int contextId, Pointer<Void> context, Pointer<Void> callback);

void dispatchUITask(int contextId, Pointer<Void> context, Pointer<Void> callback) {
  // _dispatchUITask(contextId, context, callback);
}

enum UICommandType {
  createElement,
  createTextNode,
  createComment,
  createDocument,
  createWindow,
  disposeEventTarget,
  addEvent,
  removeNode,
  insertAdjacentNode,
  setStyle,
  setAttribute,
  removeAttribute,
  cloneNode,
  removeEvent,
  createDocumentFragment,
  // perf optimize
  createSVGElement,
  createElementNS,
}

class UICommandItem extends Struct {
  @Int64()
  external int type;

  external Pointer<Pointer<NativeString>> args;

  @Int64()
  external int id;

  @Int64()
  external int length;

  external Pointer nativePtr;
}

typedef NativeGetUICommandItems = Pointer<Uint64> Function(Pointer<Void>);
typedef DartGetUICommandItems = Pointer<Uint64> Function(Pointer<Void>);

final DartGetUICommandItems _getUICommandItems =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeGetUICommandItems>>('getUICommandItems').asFunction();

typedef NativeGetUICommandItemSize = Int64 Function(Pointer<Void>);
typedef DartGetUICommandItemSize = int Function(Pointer<Void>);

final DartGetUICommandItemSize _getUICommandItemSize =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeGetUICommandItemSize>>('getUICommandItemSize').asFunction();

typedef NativeClearUICommandItems = Void Function(Pointer<Void>);
typedef DartClearUICommandItems = void Function(Pointer<Void>);

final DartClearUICommandItems _clearUICommandItems =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeClearUICommandItems>>('clearUICommandItems').asFunction();

class UICommand {
  late final UICommandType type;
  late final int id;
  late final List<String> args;
  late final Pointer nativePtr;

  @override
  String toString() {
    return 'UICommand(type: $type, id: $id, args: $args, nativePtr: $nativePtr)';
  }
}

// struct UICommandItem {
//   int32_t type;             // offset: 0 ~ 0.5
//   int32_t id;               // offset: 0.5 ~ 1
//   int32_t args_01_length;   // offset: 1 ~ 1.5
//   int32_t args_02_length;   // offset: 1.5 ~ 2
//   const uint16_t *string_01;// offset: 2
//   const uint16_t *string_02;// offset: 3
//   void* nativePtr;          // offset: 4
// };
const int nativeCommandSize = 5;
const int typeAndIdMemOffset = 0;
const int args01And02LengthMemOffset = 1;
const int args01StringMemOffset = 2;
const int args02StringMemOffset = 3;
const int nativePtrMemOffset = 4;

final bool isEnabledLog = !kReleaseMode && Platform.environment['ENABLE_WEBF_JS_LOG'] == 'true';

// We found there are performance bottleneck of reading native memory with Dart FFI API.
// So we align all UI instructions to a whole block of memory, and then convert them into a dart array at one time,
// To ensure the fastest subsequent random access.
List<UICommand> readNativeUICommandToDart(Pointer<Uint64> nativeCommandItems, int commandLength, int contextId) {
  List<int> rawMemory =
      nativeCommandItems.cast<Int64>().asTypedList(commandLength * nativeCommandSize).toList(growable: false);
  List<UICommand> results = List.generate(commandLength, (int _i) {
    int i = _i * nativeCommandSize;
    UICommand command = UICommand();

    int typeIdCombine = rawMemory[i + typeAndIdMemOffset];

    // int32_t  int32_t
    // +-------+-------+
    // |  id   | type  |
    // +-------+-------+
    int id = (typeIdCombine >> 32).toSigned(32);
    int type = (typeIdCombine ^ (id << 32)).toSigned(32);

    command.type = UICommandType.values[type];
    command.id = id;
    int nativePtrValue = rawMemory[i + nativePtrMemOffset];
    command.nativePtr = nativePtrValue != 0 ? Pointer.fromAddress(rawMemory[i + nativePtrMemOffset]) : nullptr;
    command.args = List.empty(growable: true);

    int args01And02Length = rawMemory[i + args01And02LengthMemOffset];
    int args01Length;
    int args02Length;

    if (args01And02Length == 0) {
      args01Length = args02Length = 0;
    } else {
      args02Length = (args01And02Length >> 32).toSigned(32);
      args01Length = (args01And02Length ^ (args02Length << 32)).toSigned(32);
    }

    int args01StringMemory = rawMemory[i + args01StringMemOffset];
    if (args01StringMemory != 0) {
      Pointer<Uint16> args_01 = Pointer.fromAddress(args01StringMemory);
      command.args.add(uint16ToString(args_01, args01Length));

      int args02StringMemory = rawMemory[i + args02StringMemOffset];
      if (args02StringMemory != 0) {
        Pointer<Uint16> args_02 = Pointer.fromAddress(args02StringMemory);
        command.args.add(uint16ToString(args_02, args02Length));
      }
    }

    if (isEnabledLog) {
      String printMsg = '${command.type}, id: ${command.id}';
      for (int i = 0; i < command.args.length; i++) {
        printMsg += ' args[$i]: ${command.args[i]}';
      }
      printMsg += ' nativePtr: ${command.nativePtr}';
      print(printMsg);
    }
    return command;
  }, growable: false);

  // Clear native command.
  _clearUICommandItems(_allocatedPages[contextId]!);

  return results;
}

void clearUICommand(int contextId) {
  assert(_allocatedPages.containsKey(contextId));
  _clearUICommandItems(_allocatedPages[contextId]!);
}

void flushUICommandWithContextId(int contextId) {
  WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
  if (controller != null) {
    flushUICommand(controller.view);
  }
}

void flushUICommand(WebFViewController view) {
  assert(_allocatedPages.containsKey(view.contextId));
  Pointer<Uint64> nativeCommandItems = _getUICommandItems(_allocatedPages[view.contextId]!);
  int commandLength = _getUICommandItemSize(_allocatedPages[view.contextId]!);

  if (commandLength == 0 || nativeCommandItems == nullptr) {
    return;
  }

  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_FLUSH_UI_COMMAND_START);
  }

  List<UICommand> commands = readNativeUICommandToDart(nativeCommandItems, commandLength, view.contextId);

  SchedulerBinding.instance.scheduleFrame();

  if (kProfileMode) {
    PerformanceTiming.instance().mark(PERF_FLUSH_UI_COMMAND_END);
  }

  Map<int, bool> pendingStylePropertiesTargets = {};

  // For new ui commands, we needs to tell engine to update frames.
  for (int i = 0; i < commandLength; i++) {
    UICommand command = commands[i];
    UICommandType commandType = command.type;
    int id = command.id;
    Pointer nativePtr = command.nativePtr;

    try {
      switch (commandType) {
        case UICommandType.createElement:
          view.createElement(id, nativePtr.cast<NativeBindingObject>(), command.args[0]);
          break;
        case UICommandType.createDocument:
          view.initDocument(id, nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.createWindow:
          view.initWindow(id, nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.createTextNode:
          view.createTextNode(id, nativePtr.cast<NativeBindingObject>(), command.args[0]);
          break;
        case UICommandType.createComment:
          view.createComment(id, nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.disposeEventTarget:
          view.disposeEventTarget(id, nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.addEvent:
          view.addEvent(id, command.args[0]);
          break;
        case UICommandType.removeEvent:
          view.removeEvent(id, command.args[0]);
          break;
        case UICommandType.insertAdjacentNode:
          int childId = int.parse(command.args[0]);
          String position = command.args[1];
          view.insertAdjacentNode(id, position, childId);
          break;
        case UICommandType.removeNode:
          view.removeNode(id);
          break;
        case UICommandType.cloneNode:
          int newId = int.parse(command.args[0]);
          view.cloneNode(id, newId);
          break;
        case UICommandType.setStyle:
          String key = command.args[0];
          String value = command.args[1];
          view.setInlineStyle(id, key, value);
          pendingStylePropertiesTargets[id] = true;
          break;
        case UICommandType.setAttribute:
          String key = command.args[0];
          String value = command.args[1];
          view.setAttribute(id, key, value);
          break;
        case UICommandType.removeAttribute:
          String key = command.args[0];
          view.removeAttribute(id, key);
          break;
        case UICommandType.createDocumentFragment:
          view.createDocumentFragment(id, nativePtr.cast<NativeBindingObject>());
          break;
        case UICommandType.createSVGElement:
          view.createElementNS(id, nativePtr.cast<NativeBindingObject>(), SVG_ELEMENT_URI, command.args[0]);
          break;
        case UICommandType.createElementNS:
          view.createElementNS(id, nativePtr.cast<NativeBindingObject>(), command.args[0], command.args[1]);
          break;
        default:
          break;
      }
    } catch (e, stack) {
      print('$e\n$stack');
    }
  }

  // For pending style properties, we needs to flush to render style.
  for (int id in pendingStylePropertiesTargets.keys) {
    try {
      view.flushPendingStyleProperties(id);
    } catch (e, stack) {
      print('$e\n$stack');
    }
  }
  pendingStylePropertiesTargets.clear();
}
