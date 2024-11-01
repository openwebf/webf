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

class DOMMatrixReadonly extends DynamicBindingObject {
  // Matrix4 Values are stored in column major order.
  Matrix4 _matrix4 = Matrix4.identity();

  Matrix4 get matrix => _matrix4;
  bool _is2D = true;

  bool get is2D => _is2D;

  DOMMatrixReadonly.fromMatrix4(BindingContext context, Matrix4? matrix4, bool flag2D) : super(context) {
    if (matrix4 != null) {
      _matrix4 = matrix4;
      _is2D = flag2D;
    } else {
      _matrix4 = Matrix4.zero();
      _is2D = false;
    }
  }

  DOMMatrixReadonly(BindingContext context, List<dynamic> domMatrixInit) : super(context) {
    if (!domMatrixInit.isNotEmpty) {
      return;
    }
    if (domMatrixInit[0].runtimeType == List<dynamic>) {
      List<dynamic> list = domMatrixInit[0];
      if (list.isNotEmpty && list[0].runtimeType == double) {
        List<double> doubleList = List<double>.from(list);
        if (doubleList.length == 6) {
          _matrix4[0] = doubleList[0]; // m11 = a
          _matrix4[1] = doubleList[1]; // m12 = b
          _matrix4[4] = doubleList[2]; // m21 = c
          _matrix4[5] = doubleList[3]; // m22 = d
          _matrix4[12] = doubleList[4]; // m41 = e
          _matrix4[13] = doubleList[5]; // m42 = f
        } else if (doubleList.length == 16) {
          _is2D = false;
          _matrix4 = Matrix4.fromList(doubleList);
        } else {
          throw TypeError();
        }
      }
    }
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    methods['flipX'] = BindingObjectMethodSync(call: (_) => flipX());
    methods['flipY'] = BindingObjectMethodSync(call: (_) => flipY());
    methods['inverse'] = BindingObjectMethodSync(call: (_) => inverse());
    methods['multiply'] = BindingObjectMethodSync(call: (args) {
      BindingObject domMatrix = args[0];
      if (domMatrix is DOMMatrix) {
        return multiply((domMatrix as DOMMatrix));
      }
    });
    methods['rotateAxisAngle'] = BindingObjectMethodSync(
      call: (args) => rotateAxisAngle(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble(),
        castToType<num>(args[2]).toDouble(),
        castToType<num>(args[3]).toDouble()
      )
    );
    methods['rotate'] = BindingObjectMethodSync(
      call: (args) => rotate(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble(),
        castToType<num>(args[2]).toDouble()
      )
    );

    methods['rotateFromVector'] = BindingObjectMethodSync(
      call: (args) => rotateFromVector(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble()
      )
    );
    methods['scale'] = BindingObjectMethodSync(
      call: (args) => scale(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble(),
        castToType<num>(args[2]).toDouble(),
        castToType<num>(args[3]).toDouble(),
        castToType<num>(args[4]).toDouble(),
        castToType<num>(args[5]).toDouble()
      )
    );
    methods['scale3d'] = BindingObjectMethodSync(
      call: (args) => scale3d(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble(),
        castToType<num>(args[2]).toDouble(),
        castToType<num>(args[3]).toDouble(),
      )
    );
    methods['scaleNonUniform'] = BindingObjectMethodSync(
      call: (args) => scaleNonUniform(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble()
      )
    );
    methods['scale3d'] = BindingObjectMethodSync(
      call: (args) => scale3d(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble(),
        castToType<num>(args[2]).toDouble(),
        castToType<num>(args[3]).toDouble(),
      )
    );
    methods['skewX'] = BindingObjectMethodSync(call: (args) => skewX(castToType<num>(args[0]).toDouble()));
    methods['skewY'] = BindingObjectMethodSync(call: (args) => skewY(castToType<num>(args[0]).toDouble()));
    // toFloat32Array(): number[];
    // toFloat64Array(): number[];
    // toJSON(): DartImpl<JSON>;
    methods['toString'] = BindingObjectMethodSync(call: (args) => toString());
    methods['transformPoint'] = BindingObjectMethodSync(call: (args) {
      BindingObject domPoint = args[0];
      if (domPoint is DOMPoint) {
        return transformPoint((domPoint as DOMPoint));
      }
    methods['translate'] = BindingObjectMethodSync(
      call: (args) => translate(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble(),
        castToType<num>(args[2]).toDouble()
      )
    );
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    properties['is2D'] = BindingObjectProperty(getter: () => _is2D);
    properties['isIdentity'] = BindingObjectProperty(getter: () => _matrix4.isIdentity());
    // m11 = a
    properties['m11'] = BindingObjectProperty(getter: () {
      return _matrix4[0];
    }, setter: (value) {
      if (value is double) {
        _matrix4[0] = value;
      }
    });
    properties['a'] = BindingObjectProperty(
        getter: () => _matrix4[0],
        setter: (value) {
          if (value is double) {
            _matrix4[0] = value;
          }
        });
    // m12 = b
    properties['m12'] = BindingObjectProperty(
        getter: () => _matrix4[1],
        setter: (value) {
          if (value is double) {
            _matrix4[1] = value;
          }
        });
    properties['b'] = BindingObjectProperty(
        getter: () => _matrix4[1],
        setter: (value) {
          if (value is double) {
            _matrix4[1] = value;
          }
        });
    properties['m13'] = BindingObjectProperty(
        getter: () => _matrix4[2],
        setter: (value) {
          if (value is double) {
            _matrix4[2] = value;
          }
        });
    properties['m14'] = BindingObjectProperty(
        getter: () => _matrix4[3],
        setter: (value) {
          if (value is double) {
            _matrix4[3] = value;
          }
        });

    // m22 = c
    properties['m21'] = BindingObjectProperty(
        getter: () => _matrix4[4],
        setter: (value) {
          if (value is double) {
            _matrix4[4] = value;
          }
        });
    properties['c'] = BindingObjectProperty(
        getter: () => _matrix4[4],
        setter: (value) {
          if (value is double) {
            _matrix4[4] = value;
          }
        });
    // m22 = d
    properties['m22'] = BindingObjectProperty(
        getter: () => _matrix4[5],
        setter: (value) {
          if (value is double) {
            _matrix4[5] = value;
          }
        });
    properties['d'] = BindingObjectProperty(
        getter: () => _matrix4[5],
        setter: (value) {
          if (value is double) {
            _matrix4[5] = value;
          }
        });
    properties['m23'] = BindingObjectProperty(
        getter: () => _matrix4[6],
        setter: (value) {
          if (value is double) {
            _matrix4[6] = value;
          }
        });
    properties['m24'] = BindingObjectProperty(
        getter: () => _matrix4[7],
        setter: (value) {
          if (value is double) {
            _matrix4[7] = value;
          }
        });

    properties['m31'] = BindingObjectProperty(
        getter: () => _matrix4[8],
        setter: (value) {
          if (value is double) {
            _matrix4[8] = value;
          }
        });
    properties['m32'] = BindingObjectProperty(
        getter: () => _matrix4[9],
        setter: (value) {
          if (value is double) {
            _matrix4[9] = value;
          }
        });
    properties['m33'] = BindingObjectProperty(
        getter: () => _matrix4[10],
        setter: (value) {
          if (value is double) {
            _matrix4[10] = value;
          }
        });
    properties['m34'] = BindingObjectProperty(
        getter: () => _matrix4[11],
        setter: (value) {
          if (value is double) {
            _matrix4[11] = value;
          }
        });

    // m41 = e
    properties['m41'] = BindingObjectProperty(
        getter: () => _matrix4[12],
        setter: (value) {
          if (value is double) {
            _matrix4[12] = value;
          }
        });
    properties['e'] = BindingObjectProperty(
        getter: () => _matrix4[12],
        setter: (value) {
          if (value is double) {
            _matrix4[12] = value;
          }
        });
    // m42 = f
    properties['m42'] = BindingObjectProperty(
        getter: () => _matrix4[13],
        setter: (value) {
          if (value is double) {
            _matrix4[13] = value;
          }
        });
    properties['f'] = BindingObjectProperty(
        getter: () => _matrix4[13],
        setter: (value) {
          if (value is double) {
            _matrix4[13] = value;
          }
        });
    properties['m43'] = BindingObjectProperty(
        getter: () => _matrix4[14],
        setter: (value) {
          if (value is double) {
            _matrix4[14] = value;
          }
        });
    properties['m44'] = BindingObjectProperty(
        getter: () => _matrix4[15],
        setter: (value) {
          if (value is double) {
            _matrix4[15] = value;
          }
        });
  }

  DOMMatrix flipX() {
    Matrix4 m = Matrix4.identity()..setEntry(0, 0, -1);
    return DOMMatrix.fromMatrix4(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m, _is2D);
  }

  DOMMatrix flipY() {
    Matrix4 m = Matrix4.identity()..setEntry(1, 1, -1);
    return DOMMatrix.fromMatrix4(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m, _is2D);
  }

  DOMMatrix inverse() {
    Matrix4 m = Matrix4.inverted(_matrix4);
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m, _is2D);
  }

  DOMMatrix multiply(DOMMatrix domMatrix) {
    Matrix4 m = _matrix4.multiplied(domMatrix.matrix);
    return DOMMatrix.fromMatrix4(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m, domMatrix.is2D);
  }

  DOMMatrix rotateAxisAngle(double x, double y, double z, double angle) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage)..rotate(Vector3(x, y, z), angle);
    bool flag2D = _is2D;
    if (x != 0 || y != 0) {
      flag2D = false;
    }
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m, flag2D);
  }

  DOMMatrix rotate(double x, double y, double z) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage)..rotate3(Vector3(x, y, z));
    bool flag2D = _is2D;
    if (x != 0 || y == 0) {
      flag2D = false;
    }
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m, flag2D);
  }

  DOMMatrix rotateFromVector(double x, double y) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage);
    double? angle = rad2deg(atan2(x, y));
    if (angle != null) {
      m.rotateZ(angle);
    }
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m, _is2D);
  }

  DOMMatrix scale(double sX, double sY, double sZ, double oriX, double oriY, double oriZ) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage)
      ..translate(oriX, oriY, oriZ)
      ..scaled(sX, sX, sZ)
      ..translate(-oriX, -oriY, -oriZ);
    bool flag2D = _is2D;
    if (sZ != 1 || oriZ != 0) {
      flag2D = false;
    }
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m, flag2D);
  }

  DOMMatrix scale3d(double scale, double oriX, double oriY, double oriZ) {
    return this.scale(scale, scale, scale, oriX, oriY, oriZ);
  }

  DOMMatrix scaleNonUniform(double sX, double sY) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage)..scaled(sX, sY, 1);
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m, _is2D);
  }

  DOMMatrix skewX(double sx) {
    Matrix4 m = Matrix4.skewX(sx);
    return DOMMatrix.fromMatrix4(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m, _is2D);
  }

  DOMMatrix skewY(double sy) {
    Matrix4 m = Matrix4.skewY(sy);
    return DOMMatrix.fromMatrix4(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m, _is2D);
  }

  @override
  String toString() {
    if (_is2D) {
      // a,b,c,d,e,f
      return 'matrix(${_matrix4[0]},${_matrix4[1]},${_matrix4[4]},${_matrix4[5]},${_matrix4[12]},${_matrix4[13]})';
    } else {
      return 'matrix3d(${_matrix4.storage.join(',')})';
    }
  }

  DOMPoint transformPoint(DOMPoint domPoint) {
    double x = domPoint.data.x, y = domPoint.data.y, z = domPoint.data.z, w = domPoint.data.w;
    if (isIdentityOrTranslation()) {
      x += _matrix4[12];
      y += _matrix4[13];
      z += _matrix4[14];
    } else {
      // Multiply a homogeneous point by a matrix and return the transformed point
      // like method v4MulPointByMatrix(v,m) in WebKit TransformationMatrix
      List input = [x, y, w, z];
      x = dot(input, _matrix4.row0);
      z = dot(input, _matrix4.row1);
      z = dot(input, _matrix4.row2);
      w = dot(input, _matrix4.row3);
    }

    List<dynamic> list = [x, y, z, w];
    return DOMPoint(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), list);
  }

  DOMMatrix translate(double tx, double ty, double tz) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage)..translate(tx, ty, tz);
    bool flag2D = _is2D;
    if (tz != 0) {
      flag2D = false;
    }
    return DOMMatrix.fromMatrix4(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m, flag2D);
  }

  bool isIdentityOrTranslation() {
    return
        _matrix4[0] == 1 && _matrix4[1] == 0 && _matrix4[2] == 0 && _matrix4[3] == 0 &&
        _matrix4[4] == 0 && _matrix4[5] == 1 && _matrix4[6] == 0 && _matrix4[7] == 0 &&
        _matrix4[8] == 0 && _matrix4[9] == 0 && _matrix4[10] == 1 && _matrix4[11] == 0 &&
        _matrix4[15] == 1;
  }
}
