function getMatrixTransform(matrix, point) {
  var x = point.x * matrix.m11 + point.y * matrix.m21 + point.z * matrix.m31 + point.w * matrix.m41;
  var y = point.x * matrix.m12 + point.y * matrix.m22 + point.z * matrix.m32 + point.w * matrix.m42;
  var w = point.x * matrix.m13 + point.y * matrix.m23 + point.z * matrix.m33 + point.w * matrix.m43;
  var z = point.x * matrix.m14 + point.y * matrix.m24 + point.z * matrix.m34 + point.w * matrix.m44;
  return new DOMPoint(x, y, w, z)
}

// test(async function(done) {
//   var point = new DOMPoint(5, 4);
//   var matrix = new DOMMatrix([2, 0, 0, 2, 10, 10]);
//   // @ts-ignore
//   var result = await point.matrixTransform_async(matrix);
//   var expected = getMatrixTransform(matrix, point);
//   checkDOMPointAsync(result, expected);
//   done()
// },'async test DOMPoint matrixTransform');
test(async function(done) {
  var p = new DOMPoint(0, 0, 0, 1);
  // @ts-ignore
  p.x_async = undefined;
  // @ts-ignore
  p.y_async = undefined;
  // @ts-ignore
  p.z_async = undefined;
  // @ts-ignore
  p.w_async = undefined;
  await checkDOMPointAsync(p, {x:NaN, y:NaN, z:NaN, w:NaN});
  done()
},'async test DOMPoint Attributes undefined');
test(async function(done) {
  var p = new DOMPoint(0, 0, 0, 1);
  // @ts-ignore
  p.x_async = NaN;
  // @ts-ignore
  p.y_async = Number.POSITIVE_INFINITY;
  // @ts-ignore
  p.z_async = Number.NEGATIVE_INFINITY;
  // @ts-ignore
  p.w_async = Infinity;
  await checkDOMPointAsync(p, {x:NaN, y:Infinity, z:-Infinity, w:Infinity});
  done();
},'async test DOMPoint Attributes NaN Infinity');
// test(async function(done) {
//   var point = new DOMPointReadOnly(5, 4);
//   var matrix = new DOMMatrix([1, 2, 3, 4, 5, 6]);
//   // @ts-ignore
//   var result = await point.matrixTransform_async(matrix);
//   var expected = getMatrixTransform(matrix, point);
//   checkDOMPointAsync(result, expected);
//   done();
// },'async test DOMPointReadOnly matrixTransform');
test(async function(done) {
  var p = new DOMPointReadOnly(0, 0, 0, 1);
  // @ts-ignore
  p.x_async = undefined;
  // @ts-ignore
  p.y_async = undefined;
  // @ts-ignore
  p.z_async = undefined;
  // @ts-ignore
  p.w_async = undefined;
  await checkDOMPointAsync(p, {x:0, y:0, z:0, w:1});
  done();
},'async test DOMPointReadOnly Attributes undefined');

async function checkDOMPointAsync(p, exp) {
  let x = await p.x_async;
  let y = await p.y_async;
  let z = await p.z_async;
  let w = await p.w_async;
  assert_equals(x, exp.x, "x is not matched");
  assert_equals(y, exp.y, "y is not matched");
  assert_equals(z, exp.z, "z is not matched");
  assert_equals(w, exp.w, "w is not matched");
}