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

class DOMPointData {
  double x = 0;
  double y = 0;
  double z = 0;
  double w = 1;
}

class DOMPointReadonly extends DynamicBindingObject {
  final DOMPointData data = DOMPointData();
  DOMPointReadonly(BindingContext context, List<dynamic> domPointInit) : super(context) {
    if (!domPointInit.isNotEmpty) {
      return;
    }
    if (domPointInit.runtimeType == List<double>) {}
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    // TODO: implement initializeMethods
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    properties['x'] = BindingObjectProperty(
      getter: () => data.x,
      setter: (value) => data.x = castToType<num>(value).toDouble()
    );
    properties['y'] = BindingObjectProperty(
        getter: () => data.y,
        setter: (value) => data.y = castToType<num>(value).toDouble()
    );
    properties['z'] = BindingObjectProperty(
        getter: () => data.z,
        setter: (value) => data.z = castToType<num>(value).toDouble()
    );
    properties['w'] = BindingObjectProperty(
        getter: () => data.w,
        setter: (value) => data.w = castToType<num>(value).toDouble()
    );
  }
}
