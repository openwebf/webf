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
    // TODO: implement initializeProperties
  }
}
