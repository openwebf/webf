/*
 * Copyright (C) 2020-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
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
typedef NativeEvaluateTestScripts = Int8 Function(Pointer<Void> testContext, Pointer<NativeString>, Pointer<Utf8>, Int32);
typedef DartEvaluateTestScripts = int Function(Pointer<Void> testContext, Pointer<NativeString>, Pointer<Utf8>, int);

final DartEvaluateTestScripts _evaluateTestScripts =
    WebFDynamicLibrary.testRef.lookup<NativeFunction<NativeEvaluateTestScripts>>('evaluateTestScripts').asFunction();

void evaluateTestScripts(double contextId, String code, {String url = 'test://', int line = 0}) {
  Pointer<Utf8> _url = (url).toNativeUtf8();
  _evaluateTestScripts(getAllocatedPage(contextId)!, stringToNativeString(code), _url, line);
}

typedef NativeExecuteCallback = Void Function(Double contextId, Pointer<NativeString> status);
typedef DartExecuteCallback = void Function(double);
typedef NativeExecuteTest = Void Function(Pointer<Void>, Pointer<NativeFunction<NativeExecuteCallback>>);
typedef DartExecuteTest = void Function(Pointer<Void>, Pointer<NativeFunction<NativeExecuteCallback>>);

final DartExecuteTest _executeTest =
    WebFDynamicLibrary.testRef.lookup<NativeFunction<NativeExecuteTest>>('executeTest').asFunction();

List<Completer<String>?> completerList = List.filled(10, null);

void _executeTestCallback(double contextId, Pointer<NativeString> status) {
  if (completerList[contextId.toInt()] == null) return;
  completerList[contextId.toInt()]!.complete(nativeStringToString(status));
  completerList[contextId.toInt()] = null;
}

Future<String> executeTest(Pointer<Void> testContext, double contextId) async {
  completerList[contextId.toInt()] = Completer();
  Pointer<NativeFunction<NativeExecuteCallback>> callback = Pointer.fromFunction(_executeTestCallback);
  _executeTest(testContext, callback);
  return completerList[contextId.toInt()]!.future;
}
