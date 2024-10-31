describe('DOMMatrix Tag', () => {

  function checkDOMMatrix(m: any, exp: any, is2D: any = undefined) {
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

  it('constructor', async () => {
    ["DOMMatrix", "DOMMatrixReadOnly"].forEach(function (constr) {
      test(function () {
        checkDOMMatrix(new self[constr](), initial);
      }, `new ${constr}()`);

      test(function () {
        checkDOMMatrix(new self[constr](undefined), initial);
      }, `new ${constr}(undefined)`);

      test(function () {
        checkDOMMatrix(new self[constr](new self[constr]()), initial);
      }, `new ${constr}(new ${constr}())`);

      test(function () {
        var float32Array = new Float32Array([
          2.0, 0.0, 0.0, 0.0,
          0.0, 2.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          10.0, 10.0, 0.0, 1.0]);
        checkDOMMatrix(new self[constr](float32Array), scaleTranslate2D, false);
      }, `new ${constr}(float32Array) 16 elements`);
  
      test(function () {
        var float32Array = new Float32Array([2.0, 0.0, 0.0, 2.0, 10.0, 10.0]);
        checkDOMMatrix(new self[constr](float32Array), scaleTranslate2D);
      }, `new ${constr}(float32Array) 6 elements`);
  
      test(function () {
        var float64Array = new Float64Array([
          2.0, 0.0, 0.0, 0.0,
          0.0, 2.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          10.0, 10.0, 0.0, 1.0]);
        checkDOMMatrix(new self[constr](float64Array), scaleTranslate2D, false);
      }, `new ${constr}(float64Array) 16 elements`);
  
      test(function () {
        var float64Array = new Float64Array([2.0, 0.0, 0.0, 2.0, 10.0, 10.0]);
        checkDOMMatrix(new self[constr](float64Array), scaleTranslate2D);
      }, `new ${constr}((float64Array) 6 elements`);
    });
  });
});
