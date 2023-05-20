describe('Dataset get', function () {
  function testGet(attr, expected)
  {
    var d = document.createElement("div");
    d.setAttribute(attr, "value");
    return d.dataset[expected] == "value";
  }

  test(function() { assert_true(testGet('data-foo', 'foo')); },
    "Getting element.dataset['foo'] should return the value of element.getAttribute('data-foo')'");
  test(function() { assert_true(testGet('data-foo-bar', 'fooBar')); },
    "Getting element.dataset['fooBar'] should return the value of element.getAttribute('data-foo-bar')'");
  test(function() { assert_true(testGet('data--', '-')); },
    "Getting element.dataset['-'] should return the value of element.getAttribute('data--')'");
  test(function() { assert_true(testGet('data--foo', 'Foo')); },
    "Getting element.dataset['Foo'] should return the value of element.getAttribute('data--foo')'");
  test(function() { assert_true(testGet('data---foo', '-Foo')); },
    "Getting element.dataset['-Foo'] should return the value of element.getAttribute('data---foo')'");
  test(function() { assert_true(testGet('data-Foo', 'foo')); },
    "Getting element.dataset['foo'] should return the value of element.getAttribute('data-Foo')'");
  test(function() { assert_true(testGet('data-', '')); },
    "Getting element.dataset[''] should return the value of element.getAttribute('data-')'");
  test(function() { assert_true(testGet('data-\xE0', '\xE0')); },
    "Getting element.dataset['\xE0'] should return the value of element.getAttribute('data-\xE0')'");
  // test(function() { assert_true(testGet('data-to-string', 'toString')); },
  //   "Getting element.dataset['toString'] should return the value of element.getAttribute('data-to-string')'");

  function matchesNothingInDataset(attr)
  {
    var d = document.createElement("div");
    d.setAttribute(attr, "value");

    if (!d.dataset)
      return false;

    var count = 0;
    for (var item in d.dataset)
      count++;
    return count == 0;
  }

  test(function() { assert_true(matchesNothingInDataset('dataFoo')); },
    "Tests that an attribute named dataFoo does not make an entry in the dataset DOMStringMap.");
});

describe('Dataset delete', function () {
  function testDelete(attr, prop)
  {
    var d = document.createElement("div");
    d.setAttribute(attr, "value");
    delete d.dataset[prop];
    return d.hasAttribute(attr) === false && d.getAttribute(attr) != "value";
  }

  function testDeleteNoAdd(prop)
  {
    var d = document.createElement("div");
    delete d.dataset[prop];
    return true;
  }

  test(function() { assert_true(testDelete('data-foo', 'foo')); },
    "Deleting element.dataset['foo'] should also remove an attribute with name 'data-foo' should it exist.");
  test(function() { assert_true(testDelete('data-foo-bar', 'fooBar')); },
    "Deleting element.dataset['fooBar'] should also remove an attribute with name 'data-foo-bar' should it exist.");
  test(function() { assert_true(testDelete('data--', '-')); },
    "Deleting element.dataset['-'] should also remove an attribute with name 'data--' should it exist.");
  test(function() { assert_true(testDelete('data--foo', 'Foo')); },
    "Deleting element.dataset['Foo'] should also remove an attribute with name 'data--foo' should it exist.");
  test(function() {
    var d = document.createElement("div");
    d.setAttribute('data--foo', "value");
    assert_equals(d.dataset['-foo'], '');
    assert_false('-foo' in d.dataset);
    delete d.dataset['-foo'];
    assert_true(d.hasAttribute('data--foo'));
    assert_equals(d.getAttribute('data--foo'), "value");
  }, "Deleting element.dataset['-foo'] should not remove an attribute with name 'data--foo' should it exist.");
  test(function() { assert_true(testDelete('data---foo', '-Foo')); },
    "Deleting element.dataset['-Foo'] should also remove an attribute with name 'data---foo' should it exist.");
  test(function() { assert_true(testDelete('data-', '')); },
    "Deleting element.dataset[''] should also remove an attribute with name 'data-' should it exist.");
  test(function() { assert_true(testDelete('data-\xE0', '\xE0')); },
    "Deleting element.dataset['\xE0'] should also remove an attribute with name 'data-\xE0' should it exist.");
  test(function() { assert_true(testDeleteNoAdd('foo')); },
    "Deleting element.dataset['foo'] should not throw if even if the element does now have an attribute with the name data-foo.");
});

describe('Dataset enumeration', function () {
  function testEnumeration(array)
  {
    var d = document.createElement("div");
    for (var i = 0; i < array.length; ++i)
      d.setAttribute(array[i], "value");

    var count = 0;
    for (var item in d.dataset)
      count++;

    return count;
  }

  test(function() { assert_equals(testEnumeration(['data-foo', 'data-bar', 'data-baz']), 3); },
    "A dataset should be enumeratable.");
  test(function() { assert_equals(testEnumeration(['data-foo', 'data-bar', 'dataFoo']), 2); },
    "Only attributes who qualify as dataset properties should be enumeratable in the dataset.");
});

describe('Dataset set', function () {
  function testSet(prop, expected)
  {
    var d = document.createElement("div");
    d.dataset[prop] = "value";
    return d.getAttribute(expected) == "value";
  }

  test(function() { assert_true(testSet('foo', 'data-foo')); },
    "Setting element.dataset['foo'] should also change the value of element.getAttribute('data-foo')");
  test(function() { assert_true(testSet('fooBar', 'data-foo-bar')); },
    "Setting element.dataset['fooBar'] should also change the value of element.getAttribute('data-foo-bar')");
  test(function() { assert_true(testSet('-', 'data--')); },
    "Setting element.dataset['-'] should also change the value of element.getAttribute('data--')");
  test(function() { assert_true(testSet('Foo', 'data--foo')); },
    "Setting element.dataset['Foo'] should also change the value of element.getAttribute('data--foo')");
  test(function() { assert_true(testSet('-Foo', 'data---foo')); },
    "Setting element.dataset['-Foo'] should also change the value of element.getAttribute('data---foo')");
  test(function() { assert_true(testSet('', 'data-')); },
    "Setting element.dataset[''] should also change the value of element.getAttribute('data-')");
  test(function() { assert_true(testSet('\xE0', 'data-\xE0')); },
    "Setting element.dataset['\xE0'] should also change the value of element.getAttribute('data-\xE0')");
  test(function() { assert_true(testSet('\u0BC6foo', 'data-\u0BC6foo')); },
    "Setting element.dataset['\u0BC6foo'] should also change the value of element.getAttribute('\u0BC6foo')");
});

describe('DataSet', function () {
  var div = document.createElement("div");
  test(function() {
    assert_true(div.dataset instanceof DOMStringMap);
  }, "HTML elements should have a .dataset");
  xtest(function() {
    assert_false("foo" in div.dataset);
    assert_equals(div.dataset.foo, undefined);
  }, "Should return 'undefined' before setting an attribute")
  test(function() {
    div.setAttribute("data-foo", "value");
    assert_true("foo" in div.dataset);
    assert_equals(div.dataset.foo, "value");
  }, "Should return 'value' if that's the value")
  test(function() {
    div.setAttribute("data-foo", "");
    assert_true("foo" in div.dataset);
    assert_equals(div.dataset.foo, "");
  }, "Should return the empty string if that's the value")
  xtest(function() {
    div.removeAttribute("data-foo");
    assert_false("foo" in div.dataset);
    assert_equals(div.dataset.foo, undefined);
  }, "Should return 'undefined' after removing an attribute")
  test(function() {
    var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")
    assert_true(svg.dataset instanceof DOMStringMap);
  }, "SVG elements should have a .dataset");
});