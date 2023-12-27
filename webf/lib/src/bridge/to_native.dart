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
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  Pointer<NativeString> nativeModuleName = stringToNativeString(moduleName);
  Pointer<Void> rawEvent = event == null ? nullptr : event.toRaw().cast<Void>();
  Pointer<NativeValue> extraData = malloc.allocate(sizeOf<NativeValue>());
  toNativeValue(extraData, extra);
  assert(_allocatedPages.containsKey(contextId));
  Pointer<NativeValue> dispatchResult = _invokeModuleEvent(
      _allocatedPages[contextId]!, nativeModuleName, event == null ? nullptr : event.type.toNativeUtf8(), rawEvent, extraData);
  dynamic result = fromNativeValue(controller.view, dispatchResult);
  malloc.free(dispatchResult);
  malloc.free(extraData);
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
    Pointer<Void>, Pointer<Uint8> code, Uint64 code_len, Pointer<Pointer<Uint8>> parsedBytecodes, Pointer<Uint64> bytecodeLen, Pointer<Utf8> url, Int32 startLine);
typedef DartEvaluateScripts = int Function(
    Pointer<Void>, Pointer<Uint8> code, int code_len, Pointer<Pointer<Uint8>> parsedBytecodes, Pointer<Uint64> bytecodeLen, Pointer<Utf8> url, int startLine);

// Register parseHTML
typedef NativeParseHTML = Void Function(Pointer<Void>, Pointer<Uint8> code, Int32 length);
typedef DartParseHTML = void Function(Pointer<Void>, Pointer<Uint8> code, int length);

final DartEvaluateScripts _evaluateScripts =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeEvaluateScripts>>('evaluateScripts').asFunction();

final DartParseHTML _parseHTML =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeParseHTML>>('parseHTML').asFunction();

typedef NativeParseSVGResult = Pointer<NativeGumboOutput> Function(Pointer<Utf8> code, Int32 length);
typedef DartParseSVGResult = Pointer<NativeGumboOutput> Function(Pointer<Utf8> code, int length);

final _parseSVGResult = WebFDynamicLibrary.ref.lookupFunction<NativeParseSVGResult, DartParseSVGResult>('parseSVGResult');

typedef NativeFreeSVGResult = Void Function(Pointer<NativeGumboOutput> ptr);
typedef DartFreeSVGResult = void Function(Pointer<NativeGumboOutput> ptr);

final _freeSVGResult = WebFDynamicLibrary.ref.lookupFunction<NativeFreeSVGResult, DartFreeSVGResult>('freeSVGResult');

int _anonymousScriptEvaluationId = 0;

class ScriptByteCode {
  ScriptByteCode();
  late Uint8List bytes;
}

Future<bool> evaluateScripts(int contextId, Uint8List codeBytes, {String? url, int line = 0}) async {
  if (WebFController.getControllerOfJSContextId(contextId) == null) {
    return false;
  }
  // Assign `vm://$id` for no url (anonymous scripts).
  if (url == null) {
    url = 'vm://$_anonymousScriptEvaluationId';
    _anonymousScriptEvaluationId++;
  }

  QuickJSByteCodeCacheObject cacheObject = await QuickJSByteCodeCache.getCacheObject(codeBytes);
  if (QuickJSByteCodeCacheObject.cacheMode == ByteCodeCacheMode.DEFAULT && cacheObject.valid && cacheObject.bytes != null) {
    bool result = evaluateQuickjsByteCode(contextId, cacheObject.bytes!);
    // If the bytecode evaluate failed, remove the cached file and fallback to raw javascript mode.
    if (!result) {
      await cacheObject.remove();
    }

    return result;
  } else {
    Pointer<Utf8> _url = url.toNativeUtf8();
    Pointer<Uint8> codePtr = uint8ListToPointer(codeBytes);
    try {
      assert(_allocatedPages.containsKey(contextId));
      int result;
      if (QuickJSByteCodeCache.isCodeNeedCache(codeBytes)) {
        // Export the bytecode from scripts
        Pointer<Pointer<Uint8>> bytecodes = malloc.allocate(sizeOf<Pointer<Uint8>>());
        Pointer<Uint64> bytecodeLen = malloc.allocate(sizeOf<Uint64>());
        result = _evaluateScripts(_allocatedPages[contextId]!, codePtr, codeBytes.length, bytecodes, bytecodeLen, _url, line);
        Uint8List bytes = bytecodes.value.asTypedList(bytecodeLen.value);
        // Save to disk cache
        QuickJSByteCodeCache.putObject(codeBytes, bytes);
      } else {
        result = _evaluateScripts(_allocatedPages[contextId]!, codePtr, codeBytes.length, nullptr, nullptr, _url, line);
      }
      return result == 1;
    } catch (e, stack) {
      print('$e\n$stack');
    }
    malloc.free(codePtr);
    malloc.free(_url);
  }
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

void parseHTML(int contextId, Uint8List codeBytes) {
  if (WebFController.getControllerOfJSContextId(contextId) == null) {
    return;
  }
  Pointer<Uint8> codePtr = uint8ListToPointer(codeBytes);
  try {
    assert(_allocatedPages.containsKey(contextId));
    _parseHTML(_allocatedPages[contextId]!, codePtr, codeBytes.length);
  } catch (e, stack) {
    print('$e\n$stack');
  }
  malloc.free(codePtr);
}

class GumboOutput {
  final Pointer<NativeGumboOutput> ptr;
  final Pointer<Utf8> source;
  GumboOutput(this.ptr, this.source);
}

GumboOutput parseSVGResult(String code) {
  Pointer<Utf8> nativeCode = code.toNativeUtf8();
  final ptr = _parseSVGResult(nativeCode, nativeCode.length);
  return GumboOutput(ptr, nativeCode);
}

void freeSVGResult(GumboOutput gumboOutput) {
  _freeSVGResult(gumboOutput.ptr);
  malloc.free(gumboOutput.source);
}

// Register initJsEngine
typedef NativeInitDartIsolateContext = Pointer<Void> Function(Pointer<Uint64> dartMethods, Int32 methodsLength);
typedef DartInitDartIsolateContext = Pointer<Void> Function(Pointer<Uint64> dartMethods, int methodsLength);

final DartInitDartIsolateContext _initDartIsolateContext =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeInitDartIsolateContext>>('initDartIsolateContext').asFunction();

Pointer<Void> initDartIsolateContext(List<int> dartMethods) {
  Pointer<Uint64> bytes = malloc.allocate<Uint64>(sizeOf<Uint64>() * dartMethods.length);
  Uint64List nativeMethodList = bytes.asTypedList(dartMethods.length);
  nativeMethodList.setAll(0, dartMethods);
  return _initDartIsolateContext(bytes, dartMethods.length);
}

typedef NativeDisposePage = Void Function(Pointer<Void>, Pointer<Void> page);
typedef DartDisposePage = void Function(Pointer<Void>, Pointer<Void> page);

final DartDisposePage _disposePage =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeDisposePage>>('disposePage').asFunction();

void disposePage(int contextId) {
  Pointer<Void> page = _allocatedPages[contextId]!;
  _disposePage(dartContext.pointer, page);
  _allocatedPages.remove(contextId);
}

typedef NativeNewPageId = Int64 Function();
typedef DartNewPageId = int Function();

final DartNewPageId _newPageId = WebFDynamicLibrary.ref.lookup<NativeFunction<NativeNewPageId>>('newPageId').asFunction();

int newPageId() {
  return _newPageId();
}

typedef NativeAllocateNewPage = Pointer<Void> Function(Pointer<Void>, Int32);
typedef DartAllocateNewPage = Pointer<Void> Function(Pointer<Void>, int);

final DartAllocateNewPage _allocateNewPage =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeAllocateNewPage>>('allocateNewPage').asFunction();

void allocateNewPage(int targetContextId) {
  Pointer<Void> page = _allocateNewPage(dartContext.pointer, targetContextId);
  assert(!_allocatedPages.containsKey(targetContextId));
  _allocatedPages[targetContextId] = page;
}

typedef NativeInitDartDynamicLinking = Void Function(Pointer<Void> data);
typedef DartInitDartDynamicLinking = void Function(Pointer<Void> data);

final DartInitDartDynamicLinking _initDartDynamicLinking =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeInitDartDynamicLinking>>('init_dart_dynamic_linking').asFunction();

void initDartDynamicLinking() {
  _initDartDynamicLinking(NativeApi.initializeApiDLData);
}

typedef NativeRegisterDartContextFinalizer = Void Function(Handle object, Pointer<Void> dart_context);
typedef DartRegisterDartContextFinalizer = void Function(Object object, Pointer<Void> dart_context);

final DartRegisterDartContextFinalizer _registerDartContextFinalizer =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeRegisterDartContextFinalizer>>('register_dart_context_finalizer').asFunction();

void registerDartContextFinalizer(DartContext dartContext) {
  _registerDartContextFinalizer(dartContext, dartContext.pointer);
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
  disposeBindingObject,
  addEvent,
  removeNode,
  insertAdjacentNode,
  setStyle,
  clearStyle,
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
  late final String args;
  late final Pointer nativePtr;
  late final Pointer nativePtr2;

  @override
  String toString() {
    return 'UICommand(type: $type, args: $args, nativePtr: $nativePtr, nativePtr2: $nativePtr2)';
  }
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

    if (isEnabledLog) {
      String printMsg = 'nativePtr: ${command.nativePtr} type: ${command.type} args: ${command.args} nativePtr2: ${command.nativePtr2}';
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

  List<UICommand> commands = readNativeUICommandToDart(nativeCommandItems, commandLength, view.contextId);

  SchedulerBinding.instance.scheduleFrame();

  Map<int, bool> pendingStylePropertiesTargets = {};
  Set<int> pendingRecalculateTargets = {};

  // For new ui commands, we needs to tell engine to update frames.
  for (int i = 0; i < commandLength; i++) {
    UICommand command = commands[i];
    UICommandType commandType = command.type;
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
          view.addEvent(nativePtr.cast<NativeBindingObject>(), command.args, addEventListenerOptions: eventListenerOptions);
          break;
        case UICommandType.removeEvent:
          bool isCapture = command.nativePtr2.address == 1;
          view.removeEvent(nativePtr.cast<NativeBindingObject>(), command.args, isCapture: isCapture);
          break;
        case UICommandType.insertAdjacentNode:
          view.insertAdjacentNode(
            nativePtr.cast<NativeBindingObject>(),
            command.args,
            command.nativePtr2.cast<NativeBindingObject>()
          );
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
    } catch(e, stack) {
      print('$e\n$stack');
    }
  }
  pendingRecalculateTargets.clear();
}
