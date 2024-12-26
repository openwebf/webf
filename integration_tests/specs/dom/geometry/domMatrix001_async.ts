function checkMatrix(actual, expected, { epsilon = Number.MIN_VALUE } = {}) {
  for (let member in expected) {
    if (epsilon && typeof expected[member] === "number") {
      assert_approx_equals(actual[member], expected[member], epsilon, member);
    } else {
      assert_equals(actual[member], expected[member], member);
    }
  }
}

async function checkDOMMatrix(m: any, exp: any, is2D: any = undefined) {
  if (is2D === undefined) {
    is2D = exp.is2D;
  }
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
  let val_is2D = await m.is2D;
  let val_isIdentity = await m.isIdentity;

  assert_equals(m11, exp.m11, "Expected value for m11 is " + exp.m11);
  assert_equals(m12, exp.m12, "Expected value for m12 is " + exp.m12);
  assert_equals(m13, exp.m13, "Expected value for m13 is " + exp.m13);
  assert_equals(m14, exp.m14, "Expected value for m14 is " + exp.m14);
  assert_equals(m21, exp.m21, "Expected value for m21 is " + exp.m21);
  assert_equals(m22, exp.m22, "Expected value for m22 is " + exp.m22);
  assert_equals(m23, exp.m23, "Expected value for m23 is " + exp.m23);
  assert_equals(m24, exp.m24, "Expected value for m24 is " + exp.m24);
  assert_equals(m31, exp.m31, "Expected value for m31 is " + exp.m31);
  assert_equals(m32, exp.m32, "Expected value for m32 is " + exp.m32);
  assert_equals(m33, exp.m33, "Expected value for m33 is " + exp.m33);
  assert_equals(m34, exp.m34, "Expected value for m34 is " + exp.m34);
  assert_equals(m41, exp.m41, "Expected value for m41 is " + exp.m41);
  assert_equals(m42, exp.m42, "Expected value for m42 is " + exp.m42);
  assert_equals(m43, exp.m43, "Expected value for m43 is " + exp.m43);
  assert_equals(m44, exp.m44, "Expected value for m44 is " + exp.m44);
  assert_equals(val_is2D, is2D, "Expected value for is2D is " + is2D);
  assert_equals(val_isIdentity, exp.isIdentity, "Expected value for isIdentity is " + exp.isIdentity);
}

function checkDOMMatrixSync(m: any, exp: any, is2D: any = undefined) {
  if (is2D === undefined) {
    is2D = exp.is2D;
  }

  assert_equals(m.m11, exp.m11, "Expected value for m11 is " + exp.m11);
  assert_equals(m.m12, exp.m12, "Expected value for m12 is " + exp.m12);
  assert_equals(m.m13, exp.m13, "Expected value for m13 is " + exp.m13);
  assert_equals(m.m14, exp.m14, "Expected value for m14 is " + exp.m14);
  assert_equals(m.m21, exp.m21, "Expected value for m21 is " + exp.m21);
  assert_equals(m.m22, exp.m22, "Expected value for m22 is " + exp.m22);
  assert_equals(m.m23, exp.m23, "Expected value for m23 is " + exp.m23);
  assert_equals(m.m24, exp.m24, "Expected value for m24 is " + exp.m24);
  assert_equals(m.m31, exp.m31, "Expected value for m31 is " + exp.m31);
  assert_equals(m.m32, exp.m32, "Expected value for m32 is " + exp.m32);
  assert_equals(m.m33, exp.m33, "Expected value for m33 is " + exp.m33);
  assert_equals(m.m34, exp.m34, "Expected value for m34 is " + exp.m34);
  assert_equals(m.m41, exp.m41, "Expected value for m41 is " + exp.m41);
  assert_equals(m.m42, exp.m42, "Expected value for m42 is " + exp.m42);
  assert_equals(m.m43, exp.m43, "Expected value for m43 is " + exp.m43);
  assert_equals(m.m44, exp.m44, "Expected value for m44 is " + exp.m44);
  assert_equals(m.is2D, is2D, "Expected value for is2D is " + is2D);
  assert_equals(m.isIdentity, exp.isIdentity, "Expected value for isIdentity is " + exp.isIdentity);
}

function identity() {
  return new DOMMatrix(
    [1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1]);
}

var initial = {
  m11: 1, m21: 0, m31: 0, m41: 0,
  m12: 0, m22: 1, m32: 0, m42: 0,
  m13: 0, m23: 0, m33: 1, m43: 0,
  m14: 0, m24: 0, m34: 0, m44: 1,
  is2D: true,
  isIdentity: true
};
var scaleTranslate2D = {
  m11: 2, m21: 0, m31: 0, m41: 10,
  m12: 0, m22: 2, m32: 0, m42: 10,
  m13: 0, m23: 0, m33: 1, m43: 0,
  m14: 0, m24: 0, m34: 0, m44: 1,
  is2D: true,
  isIdentity: false
};



["DOMMatrix", "DOMMatrixReadOnly"].forEach(function (constr) {
  // TODO Test DOMMatrixReadOnly methods do not mutate the object
  function initialMatrix(){
    // return DOMMatrixReadOnly.fromMatrix(
    //   {
    //     m11:1,   m12:-0.5, m13: 0.5,  m14:0,
    //     m21:0.5, m22:2,    m23: -0.5, m24:0,
    //     m31:0,   m32:0,    m33: 1,    m34:0,
    //     m41:0,   m42:0,    m43: 0,    m44:1,
    //     is2D: false
    //   }
    // );
    return new DOMMatrixReadOnly(
        [
          1, -0.5, 0.5, 0, 
          0.5,2,-0.5,0,
          0,0,1,0,
          0,0,0,1
        ]
    );
  }

  test(async function(done) {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.translate_async(1,5,3);
    checkDOMMatrixSync(matrix, initialMatrix());
    done();
  },"test translate() doesn't mutate");

  test(async function(done) {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.scale_async(1,5,3,0,1,3);
    checkDOMMatrixSync(matrix, initialMatrix());
    done();
  },"test scale() doesn't mutate");

  test(async function(done) {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.scaleNonUniform_async(1,5);
    checkDOMMatrixSync(matrix, initialMatrix());
    done();
  },"test scaleNonUniform() doesn't mutate");

  test(async function(done) {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.scale3d_async(3,2,1,1);
    checkDOMMatrixSync(matrix, initialMatrix());
    done();
  },"test scale3d() doesn't mutate");

  test(async function(done) {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.rotate_async(Math.PI, Math.PI/2, Math.PI/6);
    checkDOMMatrixSync(matrix, initialMatrix());
  },"test rotate() doesn't mutate");

  test(async function() {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.rotateFromVector_async(10,-4);
    checkDOMMatrixSync(matrix, initialMatrix());
  },"test rotateFromVector() doesn't mutate");

  test(async function() {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.rotateAxisAngle_async(3,4,5, Math.PI/6);
    checkDOMMatrixSync(matrix, initialMatrix());
  },"test rotateAxisAngle() doesn't mutate");

  test(async function() {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.skewX_async(20);
    checkDOMMatrixSync(matrix, initialMatrix());
  },"test skewX() doesn't mutate");

  test(async function() {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.skewY_async(20);
    checkDOMMatrixSync(matrix, initialMatrix());
  },"test skewY() doesn't mutate");

  test(async function() {
    var matrix = initialMatrix();
    var m = new DOMMatrix([1,2,0,0,-1,2,-1,0,0,0,1,0,5,0,2,1])
    // matrix.multiply({ m11:1, m12:2, m13: 0, m14:0,
    //                   m21:-1, m22:2, m23: -1, m24:0,
    //                   m31:0, m32:0, m33: 1, m34:0,
    //                   m41:5, m42:0, m43: 2, m44:1,
    //                   is2D: false,
    //                   isIdentity:false });
    // @ts-ignore
    await matrix.multiply_async(m)
    checkDOMMatrixSync(matrix, initialMatrix());
  },"test multiply() doesn't mutate");

  test(async function() {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.flipX_async();
    checkDOMMatrixSync(matrix, initialMatrix());
  },"test flipX() doesn't mutate");

  test(async function() {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.flipY_async();
    checkDOMMatrixSync(matrix, initialMatrix());
  },"test flipY() doesn't mutate");

  test(async function() {
    var matrix = initialMatrix();
    // @ts-ignore
    await matrix.inverse_async();
    checkDOMMatrixSync(matrix, initialMatrix());
  },"test inverse() doesn't mutate");
  
});