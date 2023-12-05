/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
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

final HashMap<double, Pointer<Void>> _allocatedPages = HashMap();

Pointer<Void>? getAllocatedPage(double contextId) {
  return _allocatedPages[contextId];
}

WebFInfo getWebFInfo() {
  return _cachedInfo;
}

// Register Native Callback Port
final interactiveCppRequests = RawReceivePort((message) {
  requestExecuteCallback(message);
});

final int nativePort = interactiveCppRequests.sendPort.nativePort;

class NativeWork extends Opaque {}

final _executeNativeCallback = WebFDynamicLibrary.ref
    .lookupFunction<Void Function(Pointer<NativeWork>), void Function(Pointer<NativeWork>)>('executeNativeCallback');

Completer? _working_completer;

FutureOr<void> waitingSyncTaskComplete(double contextId) async {
  if (_working_completer != null) {
    return _working_completer!.future;
  }

  bool isBlocked = isJSThreadBlocked(contextId);
  if (isBlocked) {
    Completer completer = Completer();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await waitingSyncTaskComplete(contextId);
      completer.complete();
    });
    SchedulerBinding.instance.scheduleFrame();
    return completer.future;
  }
}

void requestExecuteCallback(message) {
  try {
    final List<dynamic> data = message;
    final bool isSync = data[0] == 1;
    if (isSync) {
      _working_completer = Completer();
    }

    final int workAddress = data[1];
    final work = Pointer<NativeWork>.fromAddress(workAddress);
    _executeNativeCallback(work);
    _working_completer?.complete();
    _working_completer = null;
  } catch (e, stack) {
    print('requestExecuteCallback error: $e\n$stack');
  }
}

// Register invokeEventListener
typedef NativeInvokeEventListener = Void Function(
    Pointer<Void>,
    Pointer<NativeString>,
    Pointer<Utf8> eventType,
    Pointer<Void> nativeEvent,
    Pointer<NativeValue>,
    Handle object,
    Pointer<NativeFunction<NativeInvokeModuleCallback>> returnCallback);
typedef DartInvokeEventListener = void Function(
    Pointer<Void>,
    Pointer<NativeString>,
    Pointer<Utf8> eventType,
    Pointer<Void> nativeEvent,
    Pointer<NativeValue>,
    Object object,
    Pointer<NativeFunction<NativeInvokeModuleCallback>> returnCallback);
typedef NativeInvokeModuleCallback = Void Function(Handle object, Pointer<NativeValue> result);

final DartInvokeEventListener _invokeModuleEvent =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeInvokeEventListener>>('invokeModuleEvent').asFunction();

void _invokeModuleCallback(_InvokeModuleCallbackContext context, Pointer<NativeValue> dispatchResult) {
  dynamic result = fromNativeValue(context.controller.view, dispatchResult);
  malloc.free(dispatchResult);
  malloc.free(context.extraData);
  context.completer.complete(result);
}

class _InvokeModuleCallbackContext {
  Completer completer;
  WebFController controller;
  Pointer<NativeValue> extraData;

  _InvokeModuleCallbackContext(this.completer, this.controller, this.extraData);
}

dynamic invokeModuleEvent(double contextId, String moduleName, Event? event, extra) {
  if (WebFController.getControllerOfJSContextId(contextId) == null) {
    return null;
  }
  Completer<dynamic> completer = Completer();
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  Pointer<NativeString> nativeModuleName = stringToNativeString(moduleName);
  Pointer<Void> rawEvent = event == null ? nullptr : event.toRaw().cast<Void>();
  Pointer<NativeValue> extraData = malloc.allocate(sizeOf<NativeValue>());
  toNativeValue(extraData, extra);
  assert(_allocatedPages.containsKey(contextId));

  Pointer<NativeFunction<NativeInvokeModuleCallback>> callback =
      Pointer.fromFunction<NativeInvokeModuleCallback>(_invokeModuleCallback);

  _InvokeModuleCallbackContext callbackContext = _InvokeModuleCallbackContext(completer, controller, extraData);

  scheduleMicrotask(() {
    _invokeModuleEvent(_allocatedPages[contextId]!, nativeModuleName, event == null ? nullptr : event.type.toNativeUtf8(),
        rawEvent, extraData, callbackContext, callback);
  });

  return completer.future;
}

typedef DartDispatchEvent = int Function(double contextId, Pointer<NativeBindingObject> nativeBindingObject,
    Pointer<NativeString> eventType, Pointer<Void> nativeEvent, int isCustomEvent);

dynamic emitModuleEvent(double contextId, String moduleName, Event? event, extra) {
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
typedef NativeEvaluateScripts = Void Function(
    Pointer<Void>,
    Pointer<Uint8> code,
    Uint64 code_len,
    Pointer<Pointer<Uint8>> parsedBytecodes,
    Pointer<Uint64> bytecodeLen,
    Pointer<Utf8> url,
    Int32 startLine,
    Handle object,
    Pointer<NativeFunction<NativeEvaluateJavaScriptCallback>> resultCallback);
typedef DartEvaluateScripts = void Function(
    Pointer<Void>,
    Pointer<Uint8> code,
    int code_len,
    Pointer<Pointer<Uint8>> parsedBytecodes,
    Pointer<Uint64> bytecodeLen,
    Pointer<Utf8> url,
    int startLine,
    Object object,
    Pointer<NativeFunction<NativeEvaluateJavaScriptCallback>> resultCallback);

typedef NativeEvaluateJavaScriptCallback = Void Function(Handle object, Int8 result);

// Register parseHTML
typedef NativeParseHTML = Void Function(Pointer<Void>, Pointer<Uint8> code, Int32 length);
typedef DartParseHTML = void Function(Pointer<Void>, Pointer<Uint8> code, int length);

final DartEvaluateScripts _evaluateScripts =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeEvaluateScripts>>('evaluateScripts').asFunction();

final DartParseHTML _parseHTML =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeParseHTML>>('parseHTML').asFunction();

typedef NativeParseSVGResult = Pointer<NativeGumboOutput> Function(Pointer<Utf8> code, Int32 length);
typedef DartParseSVGResult = Pointer<NativeGumboOutput> Function(Pointer<Utf8> code, int length);

final _parseSVGResult =
    WebFDynamicLibrary.ref.lookupFunction<NativeParseSVGResult, DartParseSVGResult>('parseSVGResult');

typedef NativeFreeSVGResult = Void Function(Pointer<NativeGumboOutput> ptr);
typedef DartFreeSVGResult = void Function(Pointer<NativeGumboOutput> ptr);

final _freeSVGResult = WebFDynamicLibrary.ref.lookupFunction<NativeFreeSVGResult, DartFreeSVGResult>('freeSVGResult');

int _anonymousScriptEvaluationId = 0;

class ScriptByteCode {
  ScriptByteCode();

  late Uint8List bytes;
}

class _EvaluateScriptsContext {
  Completer completer;
  Pointer<Uint8> codePtr;
  Pointer<Utf8> url;
  Pointer<Pointer<Uint8>>? bytecodes;
  Pointer<Uint64>? bytecodeLen;
  Uint8List originalCodeBytes;
  _EvaluateScriptsContext(this.completer, this.originalCodeBytes, this.codePtr, this.url);
}

void handleEvaluateScriptsResult(_EvaluateScriptsContext context, int result) {
  if (context.bytecodes != null) {
    Uint8List bytes = context.bytecodes!.value.asTypedList(context.bytecodeLen!.value);
    // Save to disk cache
    QuickJSByteCodeCache.putObject(context.originalCodeBytes, bytes).then((_) {
      malloc.free(context.codePtr);
      malloc.free(context.url);
      context.completer.complete(result == 1);
    });
  } else {
    malloc.free(context.codePtr);
    malloc.free(context.url);
    context.completer.complete(result == 1);
  }
}

Future<bool> evaluateScripts(double contextId, Uint8List codeBytes, {String? url, int line = 0}) async {
  if (WebFController.getControllerOfJSContextId(contextId) == null) {
    return false;
  }
  // Assign `vm://$id` for no url (anonymous scripts).
  if (url == null) {
    url = 'vm://$_anonymousScriptEvaluationId';
    _anonymousScriptEvaluationId++;
  }

  QuickJSByteCodeCacheObject cacheObject = await QuickJSByteCodeCache.getCacheObject(codeBytes);
  if (QuickJSByteCodeCacheObject.cacheMode == ByteCodeCacheMode.DEFAULT &&
      cacheObject.valid &&
      cacheObject.bytes != null) {
    bool result = await evaluateQuickjsByteCode(contextId, cacheObject.bytes!);
    // If the bytecode evaluate failed, remove the cached file and fallback to raw javascript mode.
    if (!result) {
      await cacheObject.remove();
    }

    return result;
  } else {
    Pointer<Utf8> _url = url.toNativeUtf8();
    Pointer<Uint8> codePtr = uint8ListToPointer(codeBytes);
    Completer<bool> completer = Completer();

    _EvaluateScriptsContext context = _EvaluateScriptsContext(completer, codeBytes, codePtr, _url);
    Pointer<NativeFunction<NativeEvaluateJavaScriptCallback>> resultCallback = Pointer.fromFunction(handleEvaluateScriptsResult);

    try {
      assert(_allocatedPages.containsKey(contextId));
      if (QuickJSByteCodeCache.isCodeNeedCache(codeBytes)) {
        // Export the bytecode from scripts
        Pointer<Pointer<Uint8>> bytecodes = malloc.allocate(sizeOf<Pointer<Uint8>>());
        Pointer<Uint64> bytecodeLen = malloc.allocate(sizeOf<Uint64>());

        context.bytecodes = bytecodes;
        context.bytecodeLen = bytecodeLen;

        _evaluateScripts(
            _allocatedPages[contextId]!, codePtr, codeBytes.length, bytecodes, bytecodeLen, _url, line, context, resultCallback);
      } else {
        _evaluateScripts(_allocatedPages[contextId]!, codePtr, codeBytes.length, nullptr, nullptr, _url, line, context, resultCallback);
      }
      return completer.future;
    } catch (e, stack) {
      print('$e\n$stack');
    }

    return completer.future;
  }
}

typedef NativeEvaluateQuickjsByteCode = Void Function(Pointer<Void>, Pointer<Uint8> bytes, Int32 byteLen, Handle object,
    Pointer<NativeFunction<NativeEvaluateQuickjsByteCodeCallback>> callback);
typedef DartEvaluateQuickjsByteCode = void Function(Pointer<Void>, Pointer<Uint8> bytes, int byteLen, Object object,
    Pointer<NativeFunction<NativeEvaluateQuickjsByteCodeCallback>> callback);

typedef NativeEvaluateQuickjsByteCodeCallback = Void Function(Handle object, Int8 result);

final DartEvaluateQuickjsByteCode _evaluateQuickjsByteCode = WebFDynamicLibrary.ref
    .lookup<NativeFunction<NativeEvaluateQuickjsByteCode>>('evaluateQuickjsByteCode')
    .asFunction();

class _EvaluateQuickjsByteCodeContext {
  Completer<bool> completer;
  Pointer<Uint8> bytes;

  _EvaluateQuickjsByteCodeContext(this.completer, this.bytes);
}

void handleEvaluateQuickjsByteCodeResult(_EvaluateQuickjsByteCodeContext context, int result) {
  malloc.free(context.bytes);
  context.completer.complete(result == 1);
}

Future<bool> evaluateQuickjsByteCode(double contextId, Uint8List bytes) async {
  if (WebFController.getControllerOfJSContextId(contextId) == null) {
    return false;
  }
  Completer<bool> completer = Completer();
  Pointer<Uint8> byteData = malloc.allocate(sizeOf<Uint8>() * bytes.length);
  byteData.asTypedList(bytes.length).setAll(0, bytes);
  assert(_allocatedPages.containsKey(contextId));

  _EvaluateQuickjsByteCodeContext context = _EvaluateQuickjsByteCodeContext(completer, byteData);

  Pointer<NativeFunction<NativeEvaluateQuickjsByteCodeCallback>> nativeCallback =
      Pointer.fromFunction(handleEvaluateQuickjsByteCodeResult);

  _evaluateQuickjsByteCode(_allocatedPages[contextId]!, byteData, bytes.length, context, nativeCallback);

  return completer.future;
}

void parseHTML(double contextId, Uint8List codeBytes) {
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
typedef NativeInitDartIsolateContext = Pointer<Void> Function(
    Int64 sendPort, Pointer<Uint64> dartMethods, Int32 methodsLength);
typedef DartInitDartIsolateContext = Pointer<Void> Function(
    int sendPort, Pointer<Uint64> dartMethods, int methodsLength);

final DartInitDartIsolateContext _initDartIsolateContext = WebFDynamicLibrary.ref
    .lookup<NativeFunction<NativeInitDartIsolateContext>>('initDartIsolateContextSync')
    .asFunction();

Pointer<Void> initDartIsolateContext(List<int> dartMethods) {
  Pointer<Uint64> bytes = malloc.allocate<Uint64>(sizeOf<Uint64>() * dartMethods.length);
  Uint64List nativeMethodList = bytes.asTypedList(dartMethods.length);
  nativeMethodList.setAll(0, dartMethods);
  return _initDartIsolateContext(nativePort, bytes, dartMethods.length);
}

typedef NativeDisposePage = Void Function(Double contextId, Pointer<Void>, Pointer<Void> page);
typedef DartDisposePage = void Function(double, Pointer<Void>, Pointer<Void> page);

final DartDisposePage _disposePage =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeDisposePage>>('disposePageSync').asFunction();

FutureOr<void> disposePage(double contextId) async {
  await waitingSyncTaskComplete(contextId);
  Pointer<Void> page = _allocatedPages[contextId]!;
  _disposePage(contextId, dartContext!.pointer, page);
  _allocatedPages.remove(contextId);
}

typedef NativeNewPageId = Int64 Function();
typedef DartNewPageId = int Function();

final DartNewPageId _newPageId =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeNewPageId>>('newPageIdSync').asFunction();

int newPageId() {
  return _newPageId();
}

typedef NativeAllocateNewPage = Pointer<Void> Function(Double, Pointer<Void>);
typedef DartAllocateNewPage = Pointer<Void> Function(double, Pointer<Void>);

final DartAllocateNewPage _allocateNewPage =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeAllocateNewPage>>('allocateNewPageSync').asFunction();

FutureOr<void> allocateNewPage(double newContextId) async {
  await waitingSyncTaskComplete(newContextId);

  Pointer<Void> page = _allocateNewPage(newContextId, dartContext!.pointer);
  assert(!_allocatedPages.containsKey(newContextId));
  _allocatedPages[newContextId] = page;
}

typedef NativeInitDartDynamicLinking = Void Function(Pointer<Void> data);
typedef DartInitDartDynamicLinking = void Function(Pointer<Void> data);

final DartInitDartDynamicLinking _initDartDynamicLinking = WebFDynamicLibrary.ref
    .lookup<NativeFunction<NativeInitDartDynamicLinking>>('init_dart_dynamic_linking')
    .asFunction();

void initDartDynamicLinking() {
  _initDartDynamicLinking(NativeApi.initializeApiDLData);
}

typedef NativeRegisterDartContextFinalizer = Void Function(Handle object, Pointer<Void> dart_context);
typedef DartRegisterDartContextFinalizer = void Function(Object object, Pointer<Void> dart_context);

final DartRegisterDartContextFinalizer _registerDartContextFinalizer = WebFDynamicLibrary.ref
    .lookup<NativeFunction<NativeRegisterDartContextFinalizer>>('register_dart_context_finalizer')
    .asFunction();

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

typedef NativeDispatchUITask = Void Function(Double contextId, Pointer<Void> context, Pointer<Void> callback);
typedef DartDispatchUITask = void Function(double contextId, Pointer<Void> context, Pointer<Void> callback);

void dispatchUITask(double contextId, Pointer<Void> context, Pointer<Void> callback) {
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

typedef NativeAcquireUiCommandLocks = Pointer<Void> Function(Pointer<Void>);
typedef DartAcquireUiCommandLocks = Pointer<void> Function(Pointer<Void>);

final DartAcquireUiCommandLocks _acquireUiCommandLocks =
WebFDynamicLibrary.ref.lookup<NativeFunction<NativeAcquireUiCommandLocks>>('acquireUiCommandLocks').asFunction();

void acquireUICommandLocks(double contextId) {
  // Stop the mutations from JavaScript thread.
  _acquireUiCommandLocks(_allocatedPages[contextId]!);
}

typedef NativeReleaseUiCommandLocks = Pointer<Void> Function(Pointer<Void>);
typedef DartReleaseUiCommandLocks = Pointer<void> Function(Pointer<Void>);

final DartReleaseUiCommandLocks _releaseUiCommandLocks =
WebFDynamicLibrary.ref.lookup<NativeFunction<NativeReleaseUiCommandLocks>>('releaseUiCommandLocks').asFunction();

void releaseUICommandLocks(double contextId) {
  // Stop the mutations from JavaScript thread.
  _releaseUiCommandLocks(_allocatedPages[contextId]!);
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

typedef NativeIsJSThreadBlocked = Int8 Function(Pointer<Void>, Double);
typedef DartIsJSThreadBlocked = int Function(Pointer<Void>, double);

final DartIsJSThreadBlocked _isJSThreadBlocked =
WebFDynamicLibrary.ref.lookup<NativeFunction<NativeIsJSThreadBlocked>>('isJSThreadBlocked').asFunction();

bool isJSThreadBlocked(double contextId) {
  return _isJSThreadBlocked(dartContext!.pointer, contextId) == 1;
}

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
    return command;
  }, growable: false);

  return results;
}

void clearUICommand(double contextId) {
  assert(_allocatedPages.containsKey(contextId));

  // Stop the mutations from JavaScript thread.
  acquireUICommandLocks(contextId);

  _clearUICommandItems(_allocatedPages[contextId]!);

  // Release the mutations from JavaScript thread.
  releaseUICommandLocks(contextId);
}

void flushUICommandWithContextId(double contextId) {
  WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
  if (controller != null) {
    flushUICommand(controller.view);
  }
}

class _NativeCommandData {
  static _NativeCommandData empty() { return _NativeCommandData(0, []); }

  int length;
  List<int> rawMemory;
  _NativeCommandData(this.length, this.rawMemory);
}

_NativeCommandData readNativeUICommandMemory(double contextId) {
  // Stop the mutations from JavaScript thread.
  acquireUICommandLocks(contextId);

  Pointer<Uint64> nativeCommandItemPointer = _getUICommandItems(_allocatedPages[contextId]!);
  int commandLength = _getUICommandItemSize(_allocatedPages[contextId]!);

  if (commandLength == 0 || nativeCommandItemPointer == nullptr) {
    releaseUICommandLocks(contextId);
    return _NativeCommandData.empty();
  }

  List<int> rawMemory = nativeCommandItemPointer.cast<Int64>().asTypedList(commandLength * nativeCommandSize).toList(growable: false);
  _clearUICommandItems(_allocatedPages[contextId]!);

  // Release the mutations from JavaScript thread.
  releaseUICommandLocks(contextId);

  return _NativeCommandData(commandLength, rawMemory);
}

void flushUICommand(WebFViewController view) {
  assert(_allocatedPages.containsKey(view.contextId));

  _NativeCommandData commandData = readNativeUICommandMemory(view.contextId);

  if (commandData.rawMemory.isEmpty) return;

  List<UICommand> commands = nativeUICommandToDart(commandData.rawMemory, commandData.length, view.contextId);

  SchedulerBinding.instance.scheduleFrame();

  Map<int, bool> pendingStylePropertiesTargets = {};
  Set<int> pendingRecalculateTargets = {};

  // For new ui commands, we needs to tell engine to update frames.
  for (int i = 0; i < commandData.length; i++) {
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
