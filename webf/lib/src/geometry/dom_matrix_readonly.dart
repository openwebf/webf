/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math_64.dart';
// import 'package:flutter/gestures.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';
import 'package:webf/geometry.dart';

class DOMMatrixReadonly extends DynamicBindingObject {

  // Matrix4 Values are stored in column major order.
  Matrix4 _matrix4 = Matrix4.identity();
  Matrix4 get matrix => _matrix4;
  bool _is2D = true;
  bool get is2D => _is2D;

  DOMMatrixReadonly.fromMatrix4(BindingContext context, Matrix4? matrix4) : super(context) {
    if(matrix4 != null) {
      _matrix4 = matrix4;
      // TODO _is2D ?
    } else {
      _matrix4 = Matrix4.zero();
      _is2D = false;
    }
  }

  DOMMatrixReadonly(BindingContext context, List<dynamic> domMatrixInit) : super(context) {
    if(!domMatrixInit.isNotEmpty ) {
      return;
    }
    if (domMatrixInit[0].runtimeType == List<dynamic>) {
      List<dynamic> list = domMatrixInit[0];
      if (list.isNotEmpty && list[0].runtimeType == double) {
        List<double> doubleList = List<double>.from(list);
        if (doubleList.length == 6) {
          _matrix4[0] = doubleList[0];
          _matrix4[1] = doubleList[1];
          _matrix4[4] = doubleList[2];
          _matrix4[5] = doubleList[3];
          _matrix4[12] = doubleList[4];
          _matrix4[13] = doubleList[5];
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
        multiply((domMatrix as DOMMatrix).matrix);
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
    // // scaleNonUniform(): DOMMatrix;
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
    // // toFloat32Array(): number[];
    // // toFloat64Array(): number[];
    // // toJSON(): DartImpl<JSON>;
    methods['toString'] = BindingObjectMethodSync(call: (args) => toString());
    // // TODO DOMPoint
    // // transformPoint(): DartImpl<DOMPoint>;
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
      print('m11 this.pointer->  ${this.pointer}');

      return _matrix4[0];
    }, setter: (value) {
      if (value is double) {
        _matrix4[0] = value;
      }
    });
    properties['a'] = BindingObjectProperty(getter: () => _matrix4[0], setter: (value) {
      if (value is double) {
        _matrix4[0] = value;
      }
    });
    // m12 = b
    properties['m12'] = BindingObjectProperty(getter: () => _matrix4[1], setter: (value) {
      if (value is double) {
        _matrix4[1] = value;
      }
    });
    properties['b'] = BindingObjectProperty(getter: () => _matrix4[1], setter: (value) {
      if (value is double) {
        _matrix4[1] = value;
      }
    });
    properties['m13'] = BindingObjectProperty(getter: () => _matrix4[2], setter: (value) {
      if (value is double) {
        _matrix4[2] = value;
      }
    });
    properties['m14'] = BindingObjectProperty(getter: () => _matrix4[3], setter: (value) {
      if (value is double) {
        _matrix4[3] = value;
      }
    });

    // m22 = c
    properties['m21'] = BindingObjectProperty(getter: () => _matrix4[4], setter: (value) {
      if (value is double) {
        _matrix4[4] = value;
      }
    });
    properties['c'] = BindingObjectProperty(getter: () => _matrix4[4], setter: (value) {
      if (value is double) {
        _matrix4[4] = value;
      }
    });
    // m22 = d
    properties['m22'] = BindingObjectProperty(getter: () => _matrix4[5], setter: (value) {
      if (value is double) {
        _matrix4[5] = value;
      }
    });
    properties['d'] = BindingObjectProperty(getter: () => _matrix4[5], setter: (value) {
      if (value is double) {
        _matrix4[5] = value;
      }
    });
    properties['m23'] = BindingObjectProperty(getter: () => _matrix4[6], setter: (value) {
      if (value is double) {
        _matrix4[6] = value;
      }
    });
    properties['m24'] = BindingObjectProperty(getter: () => _matrix4[7], setter: (value) {
      if (value is double) {
        _matrix4[7] = value;
      }
    });

    properties['m31'] = BindingObjectProperty(getter: () => _matrix4[8], setter: (value) {
      if (value is double) {
        _matrix4[8] = value;
      }
    });
    properties['m32'] = BindingObjectProperty(getter: () => _matrix4[9], setter: (value) {
      if (value is double) {
        _matrix4[9] = value;
      }
    });
    properties['m33'] = BindingObjectProperty(getter: () => _matrix4[10], setter: (value) {
      if (value is double) {
        _matrix4[10] = value;
      }
    });
    properties['m34'] = BindingObjectProperty(getter: () => _matrix4[11], setter: (value) {
      if (value is double) {
        _matrix4[11] = value;
      }
    });

    // m41 = e
    properties['m41'] = BindingObjectProperty(getter: () => _matrix4[12], setter: (value) {
      if (value is double) {
        _matrix4[12] = value;
      }
    });
    properties['e'] = BindingObjectProperty(getter: () => _matrix4[12], setter: (value) {
      if (value is double) {
        _matrix4[12] = value;
      }
    });
    // m42 = f
    properties['m42'] = BindingObjectProperty(getter: () => _matrix4[13], setter: (value) {
      if (value is double) {
        _matrix4[13] = value;
      }
    });
    properties['f'] = BindingObjectProperty(getter: () => _matrix4[13], setter: (value) {
      if (value is double) {
        _matrix4[13] = value;
      }
    });
    properties['m43'] = BindingObjectProperty(getter: () => _matrix4[14], setter: (value) {
      if (value is double) {
        _matrix4[14] = value;
      }
    });
    properties['m44'] = BindingObjectProperty(getter: () => _matrix4[15], setter: (value) {
      if (value is double) {
        _matrix4[15] = value;
      }
    });
  }

  DOMMatrix flipX() {
    Matrix4 m = Matrix4.identity()..setEntry(0, 0, -1);
    return DOMMatrix.fromMatrix4(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m);
  }

  DOMMatrix flipY() {
    Matrix4 m = Matrix4.identity()..setEntry(1, 1, -1);
    return DOMMatrix.fromMatrix4(
        BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m);
  }

  DOMMatrix inverse() {
    Matrix4 m = Matrix4.inverted(_matrix4);
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m);
  }

  DOMMatrix multiply(Matrix4 matrix) {
    Matrix4 m = _matrix4.multiplied(matrix);
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m);
  }

  DOMMatrix rotateAxisAngle(double x, double y, double z, double angle) {
    //TODO
    Matrix4 m = _matrix4;
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m);
  }

  DOMMatrix rotate(double x, double y, double z) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage)..rotate3(Vector3(x, y, z));
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m);
  }

  DOMMatrix rotateFromVector(double x, double y) {
    //TODO
    Matrix4 m = _matrix4;
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m);
  }

  DOMMatrix scale(double sX, double sY, double sZ, double oriX, double oriY, double oriZ) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage).scaled(sX, sX, sZ)..translate(oriX, oriY, oriZ);
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m);
  }

  DOMMatrix scale3d(double scale, double oriX, double oriY, double oriZ) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage).scaled(scale)..translate(oriX, oriY, oriZ);
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), m);
  }

  DOMMatrix skewX(double sx) {
    Matrix4 m = Matrix4.skewX(sx);
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m);
  }

  DOMMatrix skewY(double sy) {
    Matrix4 m = Matrix4.skewY(sy);
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m);
  }

  String toString() {
    if (_is2D) {
      // a,b,c,d,e,f
      return 'matrix(${_matrix4[0]},${_matrix4[1]},${_matrix4[4]},${_matrix4[5]},${_matrix4[12]},${_matrix4[13]})';
    } else {
      return 'matrix3d(${_matrix4.storage.join(',')})';
    }
  }

  DOMMatrix translate(double tx, double ty, double tz) {
    Matrix4 m = Matrix4.fromFloat64List(_matrix4.storage)..translate(tx, ty, tz);
    return DOMMatrix.fromMatrix4(BindingContext(ownerView, ownerView.contextId, allocateNewBindingObject()), _matrix4 * m);
  }
}
