import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/foundation.dart';

class SampleElement extends WidgetElement {
  SampleElement(BindingContext? context) : super(context);

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);

    properties['ping'] = BindingObjectProperty(getter: () => ping);
    properties['fake'] = BindingObjectProperty(getter: () => fake);
  }

  @override
  Map<String, dynamic> get defaultStyle => {
    'display': 'block'
  };

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);
    methods['fn'] = BindingObjectMethodSync(call: fn);
    methods['asyncFn'] = AsyncBindingObjectMethod(call: asyncFn);
    methods['asyncFnFailed'] = AsyncBindingObjectMethod(call: asyncFnFailed);
    methods['asyncFnNotComplete'] = AsyncBindingObjectMethod(call: asyncFnNotComplete);
  }

  String get ping => 'pong';

  int get fake => 1234;

  get fn => (List<dynamic> args) {
    return List.generate(args.length, (index) {
      return args[index] * 2;
    });
  };

  get asyncFn => (List<dynamic> argv) async {
    Completer<dynamic> completer = Completer();
    Timer(Duration(milliseconds: 200), () {
      completer.complete(argv[0]);
    });
    return completer.future;
  };

  get asyncFnNotComplete => (List<dynamic> argv) async {
    Completer<dynamic> completer = Completer();
    return completer.future;
  };

  get asyncFnFailed => (List<dynamic> args) async {
    Completer<String> completer = Completer();
    Timer(Duration(milliseconds: 100), () {
      completer.completeError(AssertionError('Asset error'));
    });
    return completer.future;
  };

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return Container();
  }
}
