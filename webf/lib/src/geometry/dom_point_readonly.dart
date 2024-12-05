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
import 'package:webf/src/geometry/dom_point.dart';

class DOMPointReadOnly extends DynamicBindingObject with StaticDefinedBindingObject {
  final List<double> _data = [0, 0, 0, 1];

  DOMPointReadOnly(BindingContext context, List<dynamic> domPointInit) : super(context) {
    for (int i = 0; i < domPointInit.length; i++) {
      if (domPointInit[i].runtimeType == double) {
        _data[i] = domPointInit[i];
      }
    }
  }

  DOMPointReadOnly.fromPoint(BindingContext context, DOMPoint? point) : super(context) {
    if (point != null) {
      _data[0] = point.x;
      _data[1] = point.y;
      _data[2] = point.z;
      _data[3] = point.w;
    }
  }

  double get x => _data[0];
  double get y => _data[1];
  double get z => _data[2];
  double get w => _data[3];

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    methods['matrixTransform'] = BindingObjectMethodSync(call: (args) {
      BindingObject domMatrix = args[0];
      if (domMatrix is DOMMatrix) {
        return matrixTransform(domMatrix);
      }
    });
  }

  static final StaticDefinedBindingPropertyMap _domPointReadonlyProperties = {
    'x': StaticDefinedBindingProperty<DOMPointReadOnly>(
        getter: (point) => point._data[0],
        setter: (point, value) => point._data[0] = castToType<num>(value).toDouble()),
    'y': StaticDefinedBindingProperty<DOMPointReadOnly>(
        getter: (point) => point._data[1],
        setter: (point, value) => point._data[1] = castToType<num>(value).toDouble()),
    'z': StaticDefinedBindingProperty<DOMPointReadOnly>(
        getter: (point) => point._data[2],
        setter: (point, value) => point._data[2] = castToType<num>(value).toDouble()),
    'w': StaticDefinedBindingProperty<DOMPointReadOnly>(
        getter: (point) => point._data[3],
        setter: (point, value) => point._data[3] = castToType<num>(value).toDouble()),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _domPointReadonlyProperties];

  DOMPoint matrixTransform(DOMMatrix domMatrix) {
    Matrix4 matrix = domMatrix.matrix;
    double x = _data[0], y = _data[1], z = _data[2], w = _data[3];
    if (DOMMatrixReadOnly.isIdentityOrTranslation(matrix)) {
      x += matrix[12];
      y += matrix[13];
      z += matrix[14];
    } else {
      // Multiply a homogeneous point by a matrix and return the transformed point
      // like method v4MulPointByMatrix(v,m) in WebKit TransformationMatrix
      List input = [x, y, z, w];
      x = dot(input, matrix.row0);
      y = dot(input, matrix.row1);
      z = dot(input, matrix.row2);
      w = dot(input, matrix.row3);
    }

    List<dynamic> list = [x, y, z, w];
    return DOMPoint(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), list);
  }
}
