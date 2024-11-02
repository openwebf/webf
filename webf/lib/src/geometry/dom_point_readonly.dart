/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';
import 'package:webf/geometry.dart';
import 'package:webf/src/css/matrix.dart';

class DOMPointReadonly extends DynamicBindingObject {
  final List<double> _data = [0,0,0,1];
  DOMPointReadonly(BindingContext context, List<dynamic> domPointInit) : super(context) {
    for(int i = 0; i < domPointInit.length; i ++) {
      if(domPointInit.runtimeType == double) {
        _data[i] = domPointInit[i];
      }
    }
  }

  double get x  => _data[0];
  double get y  => _data[1];
  double get w  => _data[2];
  double get z  => _data[3];

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    // TODO: implement initializeMethods
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    properties['x'] = BindingObjectProperty(
      getter: () => _data[0],
      setter: (value) => _data[0] = castToType<num>(value).toDouble()
    );
    properties['y'] = BindingObjectProperty(
        getter: () => _data[1],
        setter: (value) => _data[1] = castToType<num>(value).toDouble()
    );
    properties['z'] = BindingObjectProperty(
        getter: () => _data[2],
        setter: (value) => _data[2] = castToType<num>(value).toDouble()
    );
    properties['w'] = BindingObjectProperty(
        getter: () => _data[3],
        setter: (value) => _data[3] = castToType<num>(value).toDouble()
    );
  }
}
