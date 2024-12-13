var epsilon = 0.0000000005;

function initialMatrix() {
  return new DOMMatrix([ 1, -0.5, 0.5, 0,  0.5, 2, -0.5, 0, 0, 0, 1, 0, 10, 20, 10, 1])

  // return {
  //   m11: 1, m12: -0.5, m13: 0.5, m14: 0,
  //   m21: 0.5, m22: 2, m23: -0.5, m24: 0,
  //   m31: 0, m32: 0, m33: 1, m34: 0,
  //   m41: 10, m42: 20, m43: 10, m44: 1,
  //   is2D: false
  // };
}

function initialDOMMatrix() {
  return DOMMatrixReadOnly.fromMatrix(initialMatrix())
  // return new DOMMatrixReadOnly([1, -0.5, 0.5, 0,0.5, 2, -0.5, 0, 0, 0, 1, 0,10, 20, 10, 1])
}

function identity() {
  return new DOMMatrix(
    [1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1]);
}

function update(matrix, f) {
  f(matrix);
  return matrix;
}

function deg2rad(degrees) {
  return degrees * Math.PI / 180;
}

function getRotationMatrix(x, y, z, alpha_in_degrees) {
  // Vector normalizing
  var nx = x;
  var ny = y;
  var nz = z;
  var length = Math.sqrt(x * x + y * y + z * z);
  if (length) {
    nx = x / length;
    ny = y / length;
    nz = z / length;
  }

  // The 3D rotation matrix is described in CSS Transforms with alpha.
  // Please see: https://drafts.csswg.org/css-transforms-2/#Rotate3dDefined
  var alpha_in_radians = deg2rad(alpha_in_degrees / 2);
  var sc = Math.sin(alpha_in_radians) * Math.cos(alpha_in_radians);
  var sq = Math.sin(alpha_in_radians) * Math.sin(alpha_in_radians);

  var m11 = 1 - 2 * (ny * ny + nz * nz) * sq;
  var m12 = 2 * (nx * ny * sq + nz * sc);
  var m13 = 2 * (nx * nz * sq - ny * sc);
  var m14 = 0;
  var m21 = 2 * (nx * ny * sq - nz * sc);
  var m22 = 1 - 2 * (nx * nx + nz * nz) * sq;
  var m23 = 2 * (ny * nz * sq + nx * sc);
  var m24 = 0;
  var m31 = 2 * (nx * nz * sq + ny * sc);
  var m32 = 2 * (ny * nz * sq - nx * sc);
  var m33 = 1 - 2 * (nx * nx + ny * ny) * sq;
  var m34 = 0;
  var m41 = 0;
  var m42 = 0;
  var m43 = 0;
  var m44 = 1;

  return new DOMMatrix([
    m11, m12, m13, m14,
    m21, m22, m23, m24,
    m31, m32, m33, m34,
    m41, m42, m43, m44]);
}

function getMatrixTransform(matrix, point) {
  var x = point.x * matrix.m11 + point.y * matrix.m21 + point.z * matrix.m31 + point.w * matrix.m41;
  var y = point.x * matrix.m12 + point.y * matrix.m22 + point.z * matrix.m32 + point.w * matrix.m42;
  var w = point.x * matrix.m13 + point.y * matrix.m23 + point.z * matrix.m33 + point.w * matrix.m43;
  var z = point.x * matrix.m14 + point.y * matrix.m24 + point.z * matrix.m34 + point.w * matrix.m44;
  return new DOMPoint(x, y, w, z)
}

test(async function () {
  var tx = 1;
  var ty = 5;
  var tz = 3;
  // @ts-ignore
  var result = initialDOMMatrix().translate_async(tx, ty, tz);
  var expected = update(initialMatrix(), function (m) {
    m.m41 += tx * m.m11 + ty * m.m21 + tz * m.m31;
    m.m42 += tx * m.m12 + ty * m.m22 + tz * m.m32;
    m.m43 += tx * m.m13 + ty * m.m23 + tz * m.m33;
    m.m44 += tx * m.m14 + ty * m.m24 + tz * m.m34;
  });
  checkDOMMatrix(result, expected);
}, "test translate()");

test(async function () {
  var sx = 2;
  var sy = 5;
  var sz = 3;
  // @ts-ignore
  var result = initialDOMMatrix().scale_async(sx, sy, sz);
  var expected = update(initialMatrix(), function (m) {
    m.m11 *= sx;
    m.m12 *= sx;
    m.m13 *= sx;
    m.m14 *= sx;
    m.m21 *= sy;
    m.m22 *= sy;
    m.m23 *= sy;
    m.m24 *= sy;
    m.m31 *= sz;
    m.m32 *= sz;
    m.m33 *= sz;
    m.m34 *= sz;
  });
  checkDOMMatrix(result, expected);
}, "test scale() without offsets");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().scale_async(2, 5, 3, 11, 7, 13);
  var expected = initialDOMMatrix()
    .translate(11, 7, 13)
    .scale(2, 5, 3)
    .translate(-11, -7, -13);
  checkDOMMatrix(result, expected);
}, "test scale() with offsets");

test(async function () {
  // @ts-ignore
  var result = new DOMMatrixReadOnly([1, 2, 3, 4, 5, 6]).scale_async(1, 1, 1, 1, 1, 1);
  var expected = new DOMMatrixReadOnly([1, 2, 0, 0, 3, 4, 0, 0, 0, 0, 1, 0, 5, 6, 0, 1]);
  checkDOMMatrix(result, expected);
}, "test scale() with identity scale and nonzero originZ");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().scaleNonUniform_async();
  var expected = initialDOMMatrix()
    .scale(1, 1, 1, 0, 0, 0);
  checkDOMMatrix(result, expected);
}, "test scaleNonUniform()");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().scaleNonUniform_async(6);
  var expected = initialDOMMatrix().scale(6, 1, 1, 0, 0, 0);
  checkDOMMatrix(result, expected);
}, "test scaleNonUniform() with sx");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().scaleNonUniform_async(5, 7);
  var expected = initialDOMMatrix()
    .scale(5, 7, 1, 0, 0, 0);
  checkDOMMatrix(result, expected);
}, "test scaleNonUniform() with sx, sy");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().scale3d_async(7, 5, 2, 3);
  var expected = initialDOMMatrix()
    .translate(5, 2, 3)
    .scale(7, 7, 7)
    .translate(-5, -2, -3);
  checkDOMMatrix(result, expected);
}, "test scale3d()");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().rotate_async(-90);
  var expected = initialDOMMatrix().multiply(getRotationMatrix(0, 0, 1, -90));
  checkDOMMatrix(result, expected);
}, "test rotate() 2d");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().rotate_async(180, 180, 90);
  var expected = initialDOMMatrix().rotate(0, 0, -90);
  checkDOMMatrix(result, expected);
}, "test rotate()");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().rotate_async(90, 90, 90);
  var expected = initialDOMMatrix()
    .rotate(0, 0, 90)
    .rotate(0, 90, 0)
    .rotate(90, 0, 0);
  checkDOMMatrix(result, expected);
}, "test rotate() order");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().rotateFromVector_async(1, 1);
  var expected = initialDOMMatrix().rotate(45);
  checkDOMMatrix(result, expected);
}, "test rotateFromVector()"); // TODO Expected value for m11 is -1, actual value is 6.123233995736767e-17

test(asycn function () {
  // @ts-ignore
  var result = initialDOMMatrix().rotateFromVector_async(0, 1);
  var expected = initialDOMMatrix().rotate(90);
  checkDOMMatrix(result, expected);
}, "test rotateFromVector() with x being zero");  // TODO Expected value for m11 is 1.0606601717798214, actual value is 0.9507737510847889

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().rotateFromVector_async(1, 0);
  var expected = initialDOMMatrix()
  checkDOMMatrix(result, expected);
}, "test rotateFromVector() with y being zero");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().rotateFromVector_async(0, 0);
  var expected = initialDOMMatrix()
  checkDOMMatrix(result, expected);
}, "test rotateFromVector() with two zeros");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().rotateAxisAngle_async(3, 3, 3, 120);
  var expected = initialDOMMatrix().multiply(getRotationMatrix(3, 3, 3, 120));
  checkDOMMatrix(result, expected);
}, "test rotateAxisAngle() "); // TODO Expected value for m11 is 0.5000000000000002

test(async function () {
  var angleDeg = 75;
  // @ts-ignore
  var result = initialDOMMatrix().skewX_async(angleDeg);
  var tangent = Math.tan(angleDeg * Math.PI / 180);
  var skew = new DOMMatrix([
    1, 0, 0, 0,
    tangent, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1])
  var expected = initialDOMMatrix().multiply(skew);
  checkDOMMatrix(result, expected);
}, "test skewX()");

test(async function () {
  var angleDeg = 18;
  // @ts-ignore
  var result = initialDOMMatrix().skewY_async(angleDeg);
  var tangent = Math.tan(angleDeg * Math.PI / 180);
  var skew = new DOMMatrix([
    1, tangent, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1])
  var expected = initialDOMMatrix().multiply(skew);
  checkDOMMatrix(result, expected);
}, "test skewY()"); // TODO 'Expected value for m11 is 1.1624598481164532

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().multiply_async(initialDOMMatrix().inverse());
  checkDOMMatrix(result, identity());
}, "test multiply with inverse is identity");

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().flipX_async();
  var expected = initialDOMMatrix().multiply(new DOMMatrix([-1, 0, 0, 1, 0, 0]));
  checkDOMMatrix(result, expected);
}, "test flipX()"); //Expected false to be true, 'Expected value for is2D is true'

test(async function () {
  // @ts-ignore
  var result = initialDOMMatrix().flipY_async();
  var expected = initialDOMMatrix().multiply(new DOMMatrix([1, 0, 0, -1, 0, 0]));
  checkDOMMatrix(result, expected);
}, "test flipY()"); //  Expected false to be true, 'Expected value for is2D is true'.

test(async function () {
  var point = new DOMPointReadOnly(1, 2, 3, 4);
  var matrix = new DOMMatrix([1, 2, 3, 4, 5, 6]);
  // @ts-ignore
  var result = matrix.transformPoint_async(point);
  var expected = getMatrixTransform(matrix, point);
  checkDOMPoint(result, expected);
}, "test transformPoint() - 2d matrix");

test(async function () {
  var point = new DOMPointReadOnly(1, 2, 3, 4);
  var matrix = new DOMMatrix([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
  // @ts-ignore
  var result = matrix.transformPoint_async(point);
  var expected = getMatrixTransform(matrix, point);
  checkDOMPoint(result, expected);
}, "test transformPoint() - 3d matrix");

async function checkDOMMatrix(m, exp) {
  let m11 = await m.m11_async;
  let m12 = await m.m12_async;
  let m13 = await m.m13_async;
  let m14 = await m.m14_async;
  let m21 = await m.m21_async;
  let m22 = await m.m22_async;
  let m23 = await m.m23_async;
  let m24 = await m.m24_async;
  let m31 = await m.m31_async;
  let m32 = await m.m32_async;
  let m33 = await m.m33_async;
  let m34 = await m.m34_async;
  let m41 = await m.m41_async;
  let m42 = await m.m42_async;
  let m43 = await m.m43_async;
  let m44 = await m.m44_async;
  
  assert_approx_equals(m11, exp.m11, epsilon, "Expected value for m11 is " + exp.m11);
  assert_approx_equals(m12, exp.m12, epsilon, "Expected value for m12 is " + exp.m12);
  assert_approx_equals(m13, exp.m13, epsilon, "Expected value for m13 is " + exp.m13);
  assert_approx_equals(m14, exp.m14, epsilon, "Expected value for m14 is " + exp.m14);
  assert_approx_equals(m21, exp.m21, epsilon, "Expected value for m21 is " + exp.m21);
  assert_approx_equals(m22, exp.m22, epsilon, "Expected value for m22 is " + exp.m22);
  assert_approx_equals(m23, exp.m23, epsilon, "Expected value for m23 is " + exp.m23);
  assert_approx_equals(m24, exp.m24, epsilon, "Expected value for m24 is " + exp.m24);
  assert_approx_equals(m31, exp.m31, epsilon, "Expected value for m31 is " + exp.m31);
  assert_approx_equals(m32, exp.m32, epsilon, "Expected value for m32 is " + exp.m32);
  assert_approx_equals(m33, exp.m33, epsilon, "Expected value for m33 is " + exp.m33);
  assert_approx_equals(m34, exp.m34, epsilon, "Expected value for m34 is " + exp.m34);
  assert_approx_equals(m41, exp.m41, epsilon, "Expected value for m41 is " + exp.m41);
  assert_approx_equals(m42, exp.m42, epsilon, "Expected value for m42 is " + exp.m42);
  assert_approx_equals(m43, exp.m43, epsilon, "Expected value for m43 is " + exp.m43);
  assert_approx_equals(m44, exp.m44, epsilon, "Expected value for m44 is " + exp.m44);
  // assert_equals(m.is2D, exp.is2D, "Expected value for is2D is " + exp.is2D);
}

function checkDOMPoint(p, exp) {
  assert_equals(p.x, exp.x, "x is not matched");
  assert_equals(p.y, exp.y, "y is not matched");
  assert_equals(p.z, exp.z, "z is not matched");
  assert_equals(p.w, exp.w, "w is not matched");
}