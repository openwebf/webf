/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:ffi';
import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';
import 'package:webf/launcher.dart';

typedef NativeBindingObjectAsyncCallCallback = Void Function(Pointer<Void> resolver, Pointer<NativeValue> successResult, Pointer<Utf8> errorMsg);
typedef DartBindingObjectAsyncCallCallback = void Function(Pointer<Void> resolver, Pointer<NativeValue> successResult, Pointer<Utf8> errorMsg);

class BindingObjectAsyncCallContext extends Struct {
  external Pointer<NativeValue> method_name;
  @Int32()
  external int argc;
  external Pointer<NativeValue> argv;
  external Pointer<Void> resolver;
  external Pointer<NativeFunction<NativeBindingObjectAsyncCallCallback>> callback;
}

typedef BindingObjectOperation = void Function(WebFViewController? view, BindingObject bindingObject);

class BindingContext {
  final double contextId;
  final WebFViewController view;
  final Pointer<NativeBindingObject> pointer;

  const BindingContext(this.view, this.contextId, this.pointer);
}

typedef BindingPropertyGetter = dynamic Function();
// ignore: avoid_annotating_with_dynamic
typedef BindingPropertySetter = void Function(dynamic value);
typedef BindingMethodCallback = dynamic Function(List args);
typedef AsyncBindingMethodCallback = Future<dynamic> Function(List args);

class BindingObjectProperty {
  BindingObjectProperty({required this.getter, this.setter});

  final BindingPropertyGetter getter;
  final BindingPropertySetter? setter;
}

abstract class BindingObjectMethod {
}

class BindingObjectMethodSync extends BindingObjectMethod {
  BindingObjectMethodSync({
    required this.call
  });

  final BindingMethodCallback call;
}

class AsyncBindingObjectMethod extends BindingObjectMethod {
  AsyncBindingObjectMethod({
    required this.call
  });

  final AsyncBindingMethodCallback call;
}


abstract class BindingObject<T> extends Iterable<T> {
  static BindingObjectOperation? bind;
  static BindingObjectOperation? unbind;

  final BindingContext? _context;

  double? get contextId => _context?.contextId;
  final WebFViewController? _ownerView;
  WebFViewController get ownerView => _ownerView!;

  Pointer<NativeBindingObject>? get pointer => _context?.pointer;

  BindingObject([BindingContext? context]) : _context = context, _ownerView = context?.view {
    _bind(_ownerView);
  }

  // Bind dart side object method to receive invoking from native side.
  void _bind(WebFViewController? ownerView) {
    if (bind != null) {
      bind!(ownerView, this);
    }
  }

  void _unbind(WebFViewController? ownerView) {
    if (unbind != null) {
      unbind!(ownerView, this);
    }
  }

  @override
  Iterator<T> get iterator => Iterable<T>.empty().iterator;

  @mustCallSuper
  void dispose() {
    _unbind(_ownerView);
  }
}

abstract class StaticBindingObject extends BindingObject {
  StaticBindingObject(BindingContext context): super(context) {
    context.pointer.ref.extra = buildExtraNativeData();
  }

  Pointer<Void> buildExtraNativeData();

  @override
  void dispose() {
    malloc.free(pointer!.ref.extra);
  }
}


typedef _StaticDefinedBindingPropertyGetter = dynamic Function(BindingObject);
// ignore: avoid_annotating_with_dynamic
typedef _StaticDefinedBindingPropertySetter = void Function(BindingObject, dynamic value);

class StaticDefinedBindingProperty {
  StaticDefinedBindingProperty({required this.getter, this.setter});

  final _StaticDefinedBindingPropertyGetter getter;
  final _StaticDefinedBindingPropertySetter? setter;
}

typedef _StaticDefinedSyncBindingMethodCallback = dynamic Function(BindingObject, List args);
typedef _StaticDefinedAsyncBindingMethodCallback= Future<dynamic> Function(BindingObject, List args);

class StaticDefinedSyncBindingObjectMethod {
  StaticDefinedSyncBindingObjectMethod({
    required this.call
  });

  final _StaticDefinedSyncBindingMethodCallback call;
}

class StaticDefinedAsyncBindingObjectMethod {
  StaticDefinedAsyncBindingObjectMethod({
    required this.call
  });

  final _StaticDefinedAsyncBindingMethodCallback call;
}

typedef StaticDefinedBindingPropertyMap = Map<String, StaticDefinedBindingProperty>;
// typedef StaticDefinedBindingAttributeMap = Map<String, >
typedef StaticDefinedSyncBindingObjectMethodMap = Map<String, StaticDefinedSyncBindingObjectMethod>;
typedef StaticDefinedAsyncBindingObjectMethodMap = Map<String, StaticDefinedAsyncBindingObjectMethod>;

mixin StaticDefinedBindingObject<T> on BindingObject<T>{
  List<StaticDefinedBindingPropertyMap> get properties => [];
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [];
  List<StaticDefinedAsyncBindingObjectMethodMap> get asyncMethods => [];
}

abstract class DynamicBindingObject<T> extends BindingObject<T> {
  DynamicBindingObject([BindingContext? context]): super(context) {
    initializeProperties(_dynamicProperties);
    initializeMethods(_dynamicMethods);
  }

  final Map<String, BindingObjectProperty> _dynamicProperties = {};
  Map<String, BindingObjectProperty> get dynamicProperties => _dynamicProperties;

  final Map<String, BindingObjectMethod> _dynamicMethods = {};
  Map<String, BindingObjectMethod> get dynamicMethods => _dynamicMethods;

  @mustCallSuper
  void initializeProperties(Map<String, BindingObjectProperty> properties) {}

  @mustCallSuper
  void initializeMethods(Map<String, BindingObjectMethod> methods) {}

  dynamic _invokeBindingMethod(String method, List<dynamic> args) {
    BindingObjectMethod? fn = _dynamicMethods[method];
    if (fn == null) {
      return;
    }

    if (fn is BindingObjectMethodSync) {
      return fn.call(args);
    }

    if (fn is AsyncBindingObjectMethod) {
      Future<dynamic> p = fn.call(args);
      return p;
    }

    return null;
  }

  @override
  void dispose() async {
    super.dispose();
    _dynamicProperties.clear();
    _dynamicMethods.clear();
  }
}

dynamic getterBindingCall(BindingObject bindingObject, List<dynamic> args, { BindingOpItem? profileOp }) {
  assert(args.length == 1);

  Stopwatch? stopwatch;
  dynamic result = null;
  String key = args[0];

  if (enableWebFProfileTracking && profileOp != null) {
    WebFProfiler.instance.startTrackBindingSteps(profileOp, 'getterBindingCall');
  }

  if (bindingObject is StaticDefinedBindingObject) {
    StaticDefinedBindingObject staticDefinedBindingObject = bindingObject;
    StaticDefinedBindingPropertyMap? targetPropertyMap =
      staticDefinedBindingObject.properties.firstWhereOrNull((map) { return map.containsKey(key); });
    if (targetPropertyMap != null) {
      if (enableWebFCommandLog) {
        stopwatch = Stopwatch()..start();
      }
      result = targetPropertyMap[key]!.getter(bindingObject);
    }
  } else {
    BindingObjectProperty? property = (bindingObject as DynamicBindingObject)._dynamicProperties[args[0]];
    if (property != null) {
      if (enableWebFCommandLog) {
        stopwatch = Stopwatch()..start();
      }

      result = property.getter();
    }
  }

  if (enableWebFCommandLog && stopwatch != null) {
    print('$bindingObject getBindingProperty key: $key result: $result time: ${stopwatch.elapsedMicroseconds}us');
  }

  if (enableWebFProfileTracking && profileOp != null) {
    WebFProfiler.instance.finishTrackBindingSteps(profileOp);
  }

  return result;
}

dynamic setterBindingCall(BindingObject bindingObject, List<dynamic> args, { BindingOpItem? profileOp }) {
  assert(args.length == 2);
  if (enableWebFCommandLog) {
    print('$bindingObject setBindingProperty key: ${args[0]} value: ${args[1]}');
  }

  if (enableWebFProfileTracking && profileOp != null) {
    WebFProfiler.instance.startTrackBindingSteps(profileOp, 'setterBindingCall');
  }

  String key = args[0];
  dynamic value = args[1];
  dynamic originalValue;

  if (bindingObject is StaticDefinedBindingObject) {
    StaticDefinedBindingObject staticDefinedBindingObject = bindingObject;
    StaticDefinedBindingPropertyMap? targetPropertyMap =
      staticDefinedBindingObject.properties.firstWhereOrNull((map) { return map.containsKey(key); });
    if (targetPropertyMap != null && targetPropertyMap[key]!.setter != null) {
      targetPropertyMap[key]!.setter!(bindingObject, value);
    }
  } else {
    BindingObjectProperty? property = (bindingObject as DynamicBindingObject)._dynamicProperties[key];
    if (property != null && property.setter != null) {
      originalValue = property.getter();
      property.setter!(value);
    }
  }

  if (bindingObject is WidgetElement) {
    bool shouldElementRebuild = bindingObject.shouldElementRebuild(key, originalValue, value);
    if (shouldElementRebuild) {
      bindingObject.setState(() {});
    }
    bindingObject.propertyDidUpdate(key, value);
  }

  if (enableWebFProfileTracking && profileOp != null) {
    WebFProfiler.instance.finishTrackBindingSteps(profileOp);
  }

  return true;
}

Future<void> _invokeBindingMethodFromNativeImpl(double contextId, int profileId, Pointer<NativeBindingObject> nativeBindingObject,
    Pointer<NativeValue> returnValue, Pointer<NativeValue> nativeMethod, int argc, Pointer<NativeValue> argv) async {

  BindingOpItem? currentProfileOp;
  if (enableWebFProfileTracking && profileId != -1) {
    currentProfileOp = WebFProfiler.instance.startTrackBinding(profileId);
  }

  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;

  if (enableWebFProfileTracking && currentProfileOp != null) {
    WebFProfiler.instance.startTrackBindingSteps(currentProfileOp, 'fromNativeValue');
  }

  // Make sure the dart object related to nativeBindingObject had been created.
  flushUICommand(controller.view, nullptr);

  dynamic method = fromNativeValue(controller.view, nativeMethod);
  List<dynamic> values = List.generate(argc, (i) {
    Pointer<NativeValue> nativeValue = argv + i;
    return fromNativeValue(controller.view, nativeValue);
  });

  if (enableWebFProfileTracking && currentProfileOp != null) {
    WebFProfiler.instance.finishTrackBindingSteps(currentProfileOp);
  }

  BindingObject bindingObject = controller.view.getBindingObject(nativeBindingObject);

  if (enableWebFProfileTracking && currentProfileOp != null) {
    WebFProfiler.instance.startTrackBindingSteps(currentProfileOp, 'invokeDartMethods');
  }

  var result = null;
  try {
    // Method is binding call method operations from internal.
    if (method is int) {
      // Get and setter ops
      result = bindingCallMethodDispatchTable[method](bindingObject, values, profileOp: currentProfileOp);
    } else {
      BindingObject bindingObject = controller.view.getBindingObject(nativeBindingObject);
      // invokeBindingMethod directly
      Stopwatch? stopwatch;
      if (enableWebFCommandLog) {
        stopwatch = Stopwatch()..start();
      }
      result = (bindingObject as DynamicBindingObject)._invokeBindingMethod(method, values);

      if (result is Future) {
        result = await result;
      }

      if (enableWebFCommandLog) {
        print('$bindingObject invokeBindingMethod method: $method args: $values result: $result time: ${stopwatch!.elapsedMicroseconds}us');
      }
    }
  } catch (e, stack) {
    print('$e\n$stack');
    rethrow;
  } finally {
    if (result is Future) {
      result = await result;
    }
    toNativeValue(returnValue, result, bindingObject);
  }

  if (enableWebFProfileTracking && currentProfileOp != null) {
    WebFProfiler.instance.finishTrackBindingSteps(currentProfileOp);
  }

  if (enableWebFProfileTracking && profileId != -1) {
    WebFProfiler.instance.finishTrackBinding(profileId);
  }
}

// This function receive calling from binding side.
void invokeBindingMethodFromNativeSync(double contextId, int profileId, Pointer<NativeBindingObject> nativeBindingObject,
    Pointer<NativeValue> returnValue, Pointer<NativeValue> nativeMethod, int argc, Pointer<NativeValue> argv) {
  _invokeBindingMethodFromNativeImpl(contextId, profileId, nativeBindingObject, returnValue, nativeMethod, argc, argv);
}

Future<void> asyncInvokeBindingMethodFromNativeImpl(WebFViewController view, Pointer<BindingObjectAsyncCallContext> asyncCallContext,
    Pointer<NativeBindingObject> nativeBindingObject) async {

  Pointer<NativeValue> returnValue = malloc.allocate(sizeOf<NativeValue>());
  DartBindingObjectAsyncCallCallback f = asyncCallContext.ref.callback.asFunction(isLeaf: true);

  try {
    await _invokeBindingMethodFromNativeImpl(view.contextId, -1, nativeBindingObject, returnValue,
        asyncCallContext.ref.method_name, asyncCallContext.ref.argc, asyncCallContext.ref.argv);

    f(asyncCallContext.ref.resolver, returnValue, nullptr);
  } catch (e, stack) {
    f(asyncCallContext.ref.resolver, nullptr, '$e\n$stack'.toNativeUtf8());
  }

  malloc.free(asyncCallContext);
}
