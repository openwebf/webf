import 'dart:async';

import 'package:webf/dom.dart' as dom;
import 'package:webf/foundation.dart';

class SampleElement extends dom.Element implements BindingObject {
  SampleElement(BindingContext? context) : super(context);

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);

    properties['ping'] = BindingObjectProperty(getter: () => ping);
    properties['fake'] = BindingObjectProperty(getter: () => fake);
    properties['fn'] = BindingObjectProperty(getter: () => fn);
    properties['asyncFn'] = BindingObjectProperty(getter: () => asyncFn);
    properties['asyncFnFailed'] = BindingObjectProperty(getter: () => asyncFnFailed);
    properties['asyncFnNotComplete'] = BindingObjectProperty(getter: () => asyncFnNotComplete);
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
