/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:ffi';
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:webf/bridge.dart';
import 'package:webf/widget.dart';
import 'package:webf/launcher.dart';

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


void _onSyncPropertiesComplete(_SyncPropertiesContext context, Pointer<NativeValue> returnValue) {
  malloc.free(context.arguments);
  context.completer.complete(fromNativeValue(context.ownerView, returnValue) == true);
}

class _SyncPropertiesContext {
  Completer<bool> completer;
  Pointer<NativeValue> arguments;
  WebFViewController ownerView;

  _SyncPropertiesContext(this.completer, this.arguments, this.ownerView);
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
  void dispose();
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

abstract class DynamicBindingObject extends BindingObject {
  DynamicBindingObject([BindingContext? context]): super(context) {
    initializeProperties(_properties);
    initializeMethods(_methods);
    if (this is WidgetElement && !_alreadySyncWidgetElements.containsKey(runtimeType)) {
      _syncPropertiesAndMethodsToNativeSlow().then((success) {
        if (success) {
          _alreadySyncWidgetElements[runtimeType] = true;
        }
      });
    }
  }

  final Map<String, BindingObjectProperty> _properties = {};
  final Map<String, BindingObjectMethod> _methods = {};

  @mustCallSuper
  void initializeProperties(Map<String, BindingObjectProperty> properties);

  @mustCallSuper
  void initializeMethods(Map<String, BindingObjectMethod> methods);

  Future<bool> _syncPropertiesAndMethodsToNativeSlow() async {
    assert(pointer != null);
    if (pointer!.ref.invokeBindingMethodFromDart == nullptr) return false;

    Completer<bool> completer = Completer();

    List<String> properties = _properties.keys.toList(growable: false);
    List<String> syncMethods = [];
    List<String> asyncMethods = [];

    _methods.forEach((key, method) {
      if (method is BindingObjectMethodSync) {
        syncMethods.add(key);
      } else if (method is AsyncBindingObjectMethod) {
        asyncMethods.add(key);
      }
    });

    Pointer<NativeValue> arguments = malloc.allocate(sizeOf<NativeValue>() * 3);
    toNativeValue(arguments.elementAt(0), properties);
    toNativeValue(arguments.elementAt(1), syncMethods);
    toNativeValue(arguments.elementAt(2), asyncMethods);

    DartInvokeBindingMethodsFromDart f = pointer!.ref.invokeBindingMethodFromDart.asFunction();

    Pointer<NativeValue> method = malloc.allocate(sizeOf<NativeValue>());
    toNativeValue(method, 'syncPropertiesAndMethods');

    _SyncPropertiesContext context = _SyncPropertiesContext(completer, arguments, ownerView);

    Pointer<NativeFunction<NativeInvokeResultCallback>> completeCallback = Pointer.fromFunction(_onSyncPropertiesComplete);

    f(pointer!, method, 3, arguments, context, completeCallback);

    return completer.future;
  }

  // Call a method, eg:
  //   el.getContext('2x');
  dynamic _invokeBindingMethodSync(String method, List args) {
    BindingObjectMethod? fn = _methods[method];
    if (fn == null) {
      return;
    }

    if (fn is BindingObjectMethodSync) {
      return fn.call(args);
    }

    return null;
  }
  // To make sure same kind of WidgetElement only sync once.
  static final Map<Type, bool> _alreadySyncWidgetElements = {};

  dynamic _invokeBindingMethodAsync(String method, List<dynamic> args) {
    BindingObjectMethod? fn = _methods[method];
    if (fn == null) {
      return;
    }

    if (fn is AsyncBindingObjectMethod) {
      double contextId = args[0];
      // Async callback should hold a context to store the current execution environment.
      Pointer<Void> callbackContext = (args[1] as Pointer).cast<Void>();
      DartAsyncAnonymousFunctionCallback callback =
      (args[2] as Pointer).cast<NativeFunction<NativeAsyncAnonymousFunctionCallback>>().asFunction();
      List<dynamic> functionArguments = args.sublist(3);
      Future<dynamic> p = fn.call(functionArguments);
      p.then((result) {
        Stopwatch? stopwatch;
        if (enableWebFCommandLog) {
          stopwatch = Stopwatch()..start();
        }
        Pointer<NativeValue> nativeValue = malloc.allocate(sizeOf<NativeValue>());
        toNativeValue(nativeValue, result, this);
        callback(callbackContext, nativeValue, contextId, nullptr);
        if (enableWebFCommandLog) {
          print('AsyncAnonymousFunction call resolved callback: $method arguments:[$result] time: ${stopwatch!.elapsedMicroseconds}us');
        }
      }).catchError((e, stack) {
        String errorMessage = '$e\n$stack';
        Stopwatch? stopwatch;
        if (enableWebFCommandLog) {
          stopwatch = Stopwatch()..start();
        }
        callback(callbackContext, nullptr, contextId, errorMessage.toNativeUtf8());
        if (enableWebFCommandLog) {
          print('AsyncAnonymousFunction call rejected callback: $method, arguments:[$errorMessage] time: ${stopwatch!.elapsedMicroseconds}us');
        }
      });
    }

    return null;
  }

  @override
  void dispose() async {
    _unbind(_ownerView);
    _properties.clear();
    _methods.clear();
  }
}

dynamic getterBindingCall(BindingObject bindingObject, List<dynamic> args) {
  assert(args.length == 1);

  BindingObjectProperty? property = (bindingObject as DynamicBindingObject)._properties[args[0]];

  Stopwatch? stopwatch;
  if (enableWebFCommandLog && property != null) {
    stopwatch = Stopwatch()..start();
  }

  if (property != null) {
    dynamic result = property.getter();
    if (enableWebFCommandLog) {
      print('$bindingObject getBindingProperty key: ${args[0]} result: ${property.getter()} time: ${stopwatch!.elapsedMicroseconds}us');
    }
    return result;
  }
  return null;
}

dynamic setterBindingCall(BindingObject bindingObject, List<dynamic> args) {
  assert(args.length == 2);
  if (enableWebFCommandLog) {
    print('$bindingObject setBindingProperty key: ${args[0]} value: ${args[1]}');
  }

  String key = args[0];
  dynamic value = args[1];
  BindingObjectProperty? property = (bindingObject as DynamicBindingObject)._properties[key];
  if (property != null && property.setter != null) {
    property.setter!(value);

    if (bindingObject is WidgetElement) {
      bool shouldElementRebuild = bindingObject.shouldElementRebuild(key, property.getter(), value);
      if (shouldElementRebuild) {
        bindingObject.setState(() {});
      }
      bindingObject.propertyDidUpdate(key, value);
    }
  }

  return true;
}

dynamic getPropertyNamesBindingCall(BindingObject bindingObject, List<dynamic> args) {
  assert(bindingObject is DynamicBindingObject);
  List<String> properties = (bindingObject as DynamicBindingObject)._properties.keys.toList();
  List<String> methods = bindingObject._methods.keys.toList();
  properties.addAll(methods);

  if (enableWebFCommandLog) {
    print('$bindingObject getPropertyNamesBindingCall value: $properties');
  }

  return properties;
}

dynamic invokeBindingMethodSync(BindingObject bindingObject, List<dynamic> args) {
  Stopwatch? stopwatch;
  if (enableWebFCommandLog) {
    stopwatch = Stopwatch()..start();
  }
  assert(bindingObject is DynamicBindingObject);
  dynamic result = (bindingObject as DynamicBindingObject)._invokeBindingMethodSync(args[0], args.slice(1));
  if (enableWebFCommandLog) {
    print('$bindingObject invokeBindingMethodSync method: ${args[0]} args: ${args.slice(1)} time: ${stopwatch!.elapsedMilliseconds}ms');
  }
  return result;
}

dynamic invokeBindingMethodAsync(BindingObject bindingObject, List<dynamic> args) {
  if (enableWebFCommandLog) {
    print('$bindingObject invokeBindingMethodSync method: ${args[0]} args: ${args.slice(1)}');
  }
  return (bindingObject as DynamicBindingObject)._invokeBindingMethodAsync(args[0], args.slice(1));
}

// This function receive calling from binding side.
void invokeBindingMethodFromNativeImpl(double contextId, Pointer<NativeBindingObject> nativeBindingObject,
    Pointer<NativeValue> returnValue, Pointer<NativeValue> nativeMethod, int argc, Pointer<NativeValue> argv) {
  WebFController controller = WebFController.getControllerOfJSContextId(contextId)!;
  dynamic method = fromNativeValue(controller.view, nativeMethod);
  List<dynamic> values = List.generate(argc, (i) {
    Pointer<NativeValue> nativeValue = argv.elementAt(i);
    return fromNativeValue(controller.view, nativeValue);
  });

  BindingObject bindingObject = controller.view.getBindingObject(nativeBindingObject);

  var result = null;
  try {
    // Method is binding call method operations from internal.
    if (method is int) {
      // Get and setter ops
      result = bindingCallMethodDispatchTable[method](bindingObject, values);
    } else {
      BindingObject bindingObject = controller.view.getBindingObject(nativeBindingObject);
      // invokeBindingMethod directly
      Stopwatch? stopwatch;
      if (enableWebFCommandLog) {
        stopwatch = Stopwatch()..start();
      }
      result = (bindingObject as DynamicBindingObject)._invokeBindingMethodSync(method, values);
      if (enableWebFCommandLog) {
        print('$bindingObject invokeBindingMethod method: $method args: $values result: $result time: ${stopwatch!.elapsedMicroseconds}us');
      }
    }
  } catch (e, stack) {
    print('$e\n$stack');
  } finally {
    toNativeValue(returnValue, result, bindingObject);
  }
}
