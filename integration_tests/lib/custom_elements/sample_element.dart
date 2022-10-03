import 'dart:async';

import 'package:webf/dom.dart' as dom;
import 'package:webf/foundation.dart';

class SampleElement extends dom.Element implements BindingObject {
  SampleElement(BindingContext? context) : super(context);

  getBindingProperty(String key) {
    switch (key) {
      case 'ping':
        return ping;
      case 'fake':
        return fake;
      case 'fn':
        return fn;
      case 'asyncFn':
        return asyncFn;
      case 'asyncFnFailed':
        return asyncFnFailed;
      case 'asyncFnNotComplete':
        return asyncFnNotComplete;
      default:
        return super.getBindingProperty(key);
    }
  }

  @override
  void getAllBindingPropertyNames(List<String> properties) {
    super.getAllBindingPropertyNames(properties);
    properties.addAll([
      'ping',
      'fake',
      'fn',
      'asyncFn',
      'asyncFnFailed',
      'asyncFnNotComplete'
    ]);
  }

  String get ping => 'pong';

  int get fake => 1234;

  Function get fn => (List<dynamic> args) {
    return List.generate(args.length, (index) {
      return args[index] * 2;
    });
  };

  Function get asyncFn => (List<dynamic> argv) async {
    Completer<dynamic> completer = Completer();
    Timer(Duration(milliseconds: 200), () {
      completer.complete(argv[0]);
    });
    return completer.future;
  };

  Function get asyncFnNotComplete => (List<dynamic> argv) async {
    Completer<dynamic> completer = Completer();
    return completer.future;
  };

  Function get asyncFnFailed => (List<dynamic> args) async {
    Completer<String> completer = Completer();
    Timer(Duration(milliseconds: 100), () {
      completer.completeError(AssertionError('Asset error'));
    });
    return completer.future;
  };
}