async function checkDOMPointAsync(p, exp) {
  let x = await p.x_async;
  let y = await p.y_async;
  let z = await p.z_async;
  let w = await p.w_async;
  assert_equals(x, exp.x, "Expected value for x is " + exp.x);
  assert_equals(y, exp.y, "Expected value for y is " + exp.y);
  assert_equals(z, exp.z, "Expected value for z is " + exp.z);
  assert_equals(w, exp.w, "Expected value for w is " + exp.w);
}

test(async function(done) {
  checkDOMPointAsync(new DOMPoint(), {x:0, y:0, z:0, w:1});
  done();
},'async testConstructor0');
test(async function(done) {
  checkDOMPointAsync(new DOMPoint(1), {x:1, y:0, z:0, w:1});
  done();
},'async testConstructor1');
test(async function(done) {
  checkDOMPointAsync(new DOMPoint(1, 2), {x:1, y:2, z:0, w:1});
  done();
},'async testConstructor2');
test(async function(done) {
  checkDOMPointAsync(new DOMPoint(1, 2, 3), {x:1, y:2, z:3, w:1});
  done();
},'async testConstructor3');
test(async function(done) {
  checkDOMPointAsync(new DOMPoint(1, 2, 3, 4), {x:1, y:2, z:3, w:4});
  done();
},'async testConstructor4');
test(async function(done) {
  checkDOMPointAsync(new DOMPoint(1, 2, 3, 4, 5), {x:1, y:2, z:3, w:4});
  done();
},'async testConstructor5');
// test(async function(done) {
//   checkDOMPointAsync(new DOMPoint({}), {x:NaN, y:0, z:0, w:1});
//   done();
// },'async testConstructorDictionary0'); //TODO
// test(async function(done) {
//   checkDOMPointAsync(new DOMPoint({x:1}), {x:NaN, y:0, z:0, w:1});
//   done();
// },'async testConstructorDictionary1'); //TODO
// test(async function(done) {
//   checkDOMPointAsync(new DOMPoint({x:1, y:2}), {x:NaN, y:0, z:0, w:1});
//   done();
// },'async testConstructorDictionary2'); //TODO
test(async function(done) {
  checkDOMPointAsync(new DOMPoint(1, undefined), {x:1, y:0, z:0, w:1});
  done();
},'async testConstructor2undefined');
// test(async function(done) {
//   checkDOMPointAsync(new DOMPoint("a", "b"), {x:NaN, y:NaN, z:0, w:1});
// },'async testConstructorUndefined1'); //TODO
// test(async function(done) {
//   checkDOMPointAsync(new DOMPoint({x:"a", y:"b"}), {x:NaN, y:0, z:0, w:1});
//   done();
// },'async testConstructorUndefined2'); //TODO
test(async function(done) {
  checkDOMPointAsync(new DOMPointReadOnly(), {x:0, y:0, z:0, w:1});
  done();
},'async DOMPointReadOnly constructor with no values');
test(async function(done) {
  checkDOMPointAsync(new DOMPointReadOnly(1, 2, 3, 4), {x:1, y:2, z:3, w:4});
  done();
},'async DOMPointReadOnly constructor with 4 values');
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
  checkDOMPointAsync(p, {x:NaN, y:NaN, z:NaN, w:NaN});
  done();
},'async testAttributesUndefined'); //TODO
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
  checkDOMPointAsync(p, {x:NaN, y:Infinity, z:-Infinity, w:Infinity});
  done();
},'async testAttributesNaNInfinity');  //TODO