/*
 * Copyright (C) 2020-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:webf/foundation.dart';
import 'package:webf/bridge.dart';

// Steps for using dart:ffi to call a C function from Dart:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the C function.
// 3. Create a typedef for the variable that you’ll use when calling the C function.
// 4. Open the dynamic library that contains the C function.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call the C function.

// Init Test Framework
typedef NativeInitTestFramework = Pointer<Void> Function(Pointer<Void> page);
typedef DartInitTestFramework = Pointer<Void> Function(Pointer<Void> page);

final DartInitTestFramework _initTestFramework =
    WebFDynamicLibrary.testRef.lookup<NativeFunction<NativeInitTestFramework>>('initTestFramework').asFunction();

Pointer<Void> initTestFramework(double contextId) {
  return _initTestFramework(getAllocatedPage(contextId)!);
}

// Register evaluteTestScripts
typedef NativeEvaluateTestScripts = Int8 Function(
    Pointer<Void> testContext, Pointer<NativeString>, Pointer<Utf8>, Int32);
typedef DartEvaluateTestScripts = int Function(Pointer<Void> testContext, Pointer<NativeString>, Pointer<Utf8>, int);

final DartEvaluateTestScripts _evaluateTestScripts =
    WebFDynamicLibrary.testRef.lookup<NativeFunction<NativeEvaluateTestScripts>>('evaluateTestScripts').asFunction();

void evaluateTestScripts(double contextId, String code, {String url = 'test://', int line = 0}) {
  Pointer<Utf8> _url = (url).toNativeUtf8();
  _evaluateTestScripts(getAllocatedPage(contextId)!, stringToNativeString(code), _url, line);
}

typedef ExecuteCallbackResultCallback = Void Function(Handle context, Pointer<NativeString> result);
typedef DartExecuteCallback = void Function(double);
typedef NativeExecuteTest = Void Function(Pointer<Void>, Int64 profileId, Handle context,
    Pointer<NativeFunction<ExecuteCallbackResultCallback>> resultCallback);
typedef DartExecuteTest = void Function(Pointer<Void>, int profileId, Object context,
    Pointer<NativeFunction<ExecuteCallbackResultCallback>> resultCallback);

final DartExecuteTest _executeTest =
    WebFDynamicLibrary.testRef.lookup<NativeFunction<NativeExecuteTest>>('executeTest').asFunction();

class _ExecuteTestContext {
  Completer<String> completer;
  EvaluateOpItem? profileOp;
  _ExecuteTestContext(this.completer, this.profileOp);
}

void _handleExecuteTestResult(Object handle, Pointer<NativeString> resultData) {
  _ExecuteTestContext context = handle as _ExecuteTestContext;
  String status = nativeStringToString(resultData);
  context.completer.complete(status);

  if (enableWebFProfileTracking) {
    WebFProfiler.instance.finishTrackEvaluate(context.profileOp!);
  }
}

Future<String> executeTest(Pointer<Void> testContext, double contextId) async {
  Completer<String> completer = Completer();

  EvaluateOpItem? currentProfileOp;
  if (enableWebFProfileTracking) {
    currentProfileOp = WebFProfiler.instance.startTrackEvaluate('executeTest');
  }

  _ExecuteTestContext context = _ExecuteTestContext(completer, currentProfileOp);
  Pointer<NativeFunction<ExecuteCallbackResultCallback>> callback = Pointer.fromFunction(_handleExecuteTestResult);
  _executeTest(testContext, currentProfileOp?.hashCode ?? 0, context, callback);
  return completer.future;
}
