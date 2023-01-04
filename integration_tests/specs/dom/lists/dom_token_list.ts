describe('DOMTokenList iterable', () => {
  var elementClasses = document.createElement('span').classList;
  elementClasses.add('foo');
  elementClasses.add('Foo');
  test(function() {
    assert_true('length' in elementClasses);
  }, 'DOMTokenList has length method.');
  test(function() {
    assert_true('values' in elementClasses);
  }, 'DOMTokenList has values method.');
  test(function() {
    assert_true('entries' in elementClasses);
  }, 'DOMTokenList has entries method.');
  test(function() {
    assert_true('forEach' in elementClasses);
  }, 'DOMTokenList has forEach method.');
  test(function() {
    assert_true(Symbol.iterator in elementClasses);
  }, 'DOMTokenList has Symbol.iterator.');
  test(function() {
    var classList = [];
    // @ts-ignore
    for (var className of elementClasses){
      // @ts-ignore
      classList.push(className);
    }
    assert_array_equals(classList, ['foo', 'Foo']);
  }, 'DOMTokenList is iterable via for-of loop.');
});

describe('DOMTokenList iteration', () => {
  let list = document.createElement('span');
  list.setAttribute('class', '   a  a b ');
  test(() => {
    // @ts-ignore
    assert_array_equals([...list.classList], ["a", "b"]);
  }, "classList");

  test(() => {
    // @ts-ignore
    var keys = list.classList.keys();
    assert_false(keys instanceof Array, "must not be Array");
    keys = [...keys];
    assert_array_equals(keys, [0, 1]);
  }, "classList.keys");

  test(() => {
    // @ts-ignore
    var values = list.classList.values();
    assert_false(values instanceof Array, "must not be Array");
    values = [...values];
    assert_array_equals(values, ["a", "b"]);
  }, "classList.values");

  test(() => {
    // @ts-ignore
    var entries = list.classList.entries();
    assert_false(entries instanceof Array, "must not be Array");
    entries = [...entries];
    // @ts-ignore
    var keys = [...list.classList.keys()];
    // @ts-ignore
    var values = [...list.classList.values()];
    assert_equals(entries.length, keys.length, "entries.length == keys.length");
    assert_equals(entries.length, values.length,
      "entries.length == values.length");
    for (var i = 0; i < entries.length; ++i) {
      assert_array_equals(entries[i], [keys[i], values[i]],
        "entries[" + i + "]");
    }
  }, "classList.entries");

  test(() => {
    var span = document.createElement('span');
    span.setAttribute('class', '   a  a b ');
    var list = span.classList;
    // @ts-ignore
    var values = [...list.values()];
    // @ts-ignore
    var keys = [...list.keys()];
    // @ts-ignore
    var entries = [...list.entries()];

    var cur = 0;
    var thisObj = {};
    list.forEach(function(value, key, listObj) {
      assert_equals(listObj, list, "Entry " + cur + " listObj");
      // @ts-ignore
      assert_equals(this, thisObj, "Entry " + cur + " this");
      assert_equals(value, values[cur], "Entry " + cur + " value");
      assert_equals(key, keys[cur], "Entry " + cur + " key");
      cur++;
    }, thisObj);
    assert_equals(cur, entries.length, "length");
  }, "classList.forEach");

  test(() => {
    var span = document.createElement('span');
    span.setAttribute('class', '   a  a b ');
    var list = span.classList;
    assert_equals(list[Symbol.iterator], Array.prototype[Symbol.iterator],
      "[Symbol.iterator]");
    // @ts-ignore
    assert_equals(list.keys, Array.prototype.keys, ".keys");
    if (Array.prototype.values) {
      // @ts-ignore
      assert_equals(list.values, Array.prototype.values, ".values");
    }
    // @ts-ignore
    assert_equals(list.entries, Array.prototype.entries, ".entries");
    assert_equals(list.forEach, Array.prototype.forEach, ".forEach");
  }, "classList inheritance from Array.prototype");
});

describe('DOMTokenList stringifier', () => {
  test(function() {
    assert_equals(String(document.createElement("span").classList), "",
      "String(classList) should return the empty list for an undefined class attribute");
    var span = document.createElement('span');
    span.setAttribute('class', '   a  a b ');
    assert_equals(span.getAttribute("class"), "   a  a b ",
      "getAttribute should return the literal value");
    assert_equals(span.className, "   a  a b ",
      "className should return the literal value");
    assert_equals(String(span.classList), "   a  a b ",
      "String(classList) should return the literal value");
    assert_equals(span.classList.toString(), "   a  a b ",
      "classList.toString() should return the literal value");
  }, 'test');
});

describe('DOMTokenList value', () => {
  test(function() {
    let span = document.createElement('span');

    assert_equals(String(span.classList.value), "",
      "classList.value should return the empty list for an undefined class attribute");
    span.setAttribute('class', '   a  a b ');
    assert_equals(span.classList.value, "   a  a b ",
      "value should return the literal value");
    span.classList.value = " foo bar foo ";
    assert_equals(span.classList.value, " foo bar foo ",
      "assigning value should set the literal value");
    assert_equals(span.classList.length, 2,
      "length should be the number of tokens");
  }, 'test');
});