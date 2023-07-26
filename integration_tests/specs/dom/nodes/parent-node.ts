describe('ParentNode append', function () {
  function test_append(node, nodeName) {
    test(function() {
      const parent = node.cloneNode();
      parent.append();
      expect(parent.childNodes.length).toBe(0);
    }, nodeName + '.append() without any argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      parent.append(null);
      assert_equals(parent.childNodes[0].textContent, 'null');
    }, nodeName + '.append() with null as an argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      parent.append(undefined);
      assert_equals(parent.childNodes[0].textContent, 'undefined');
    }, nodeName + '.append() with undefined as an argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      parent.append('text');
      assert_equals(parent.childNodes[0].textContent, 'text');
    }, nodeName + '.append() with only text as an argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      const x = document.createElement('x');
      parent.append(x);
      assert_equals(parent.childNodes[0], x);
    }, nodeName + '.append() with only one element as an argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      const child = document.createElement('test');
      parent.appendChild(child);
      parent.append(null);
      assert_equals(parent.childNodes[0], child);
      assert_equals(parent.childNodes[1].textContent, 'null');
    }, nodeName + '.append() with null as an argument, on a parent having a child.');

    test(function() {
      const parent = node.cloneNode();
      const x = document.createElement('x');
      const child = document.createElement('test');
      parent.appendChild(child);
      parent.append(x, 'text');
      assert_equals(parent.childNodes[0], child);
      assert_equals(parent.childNodes[1], x);
      assert_equals(parent.childNodes[2].textContent, 'text');
    }, nodeName + '.append() with one element and text as argument, on a parent having a child.');
  }

  test_append(document.createElement('div'), 'Element');
  test_append(document.createDocumentFragment(), 'DocumentFragment');
});

describe('ParentNode prepend', function () {

  function test_prepend(node, nodeName) {
    test(function() {
      const parent = node.cloneNode();
      parent.prepend();
      assert_equals(parent.childNodes.length, 0);
    }, nodeName + '.prepend() without any argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      parent.prepend(null);
      assert_equals(parent.childNodes[0].textContent, 'null');
    }, nodeName + '.prepend() with null as an argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      parent.prepend(undefined);
      assert_equals(parent.childNodes[0].textContent, 'undefined');
    }, nodeName + '.prepend() with undefined as an argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      parent.prepend('text');
      assert_equals(parent.childNodes[0].textContent, 'text');
    }, nodeName + '.prepend() with only text as an argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      const x = document.createElement('x');
      parent.prepend(x);
      assert_equals(parent.childNodes[0], x);
    }, nodeName + '.prepend() with only one element as an argument, on a parent having no child.');

    test(function() {
      const parent = node.cloneNode();
      const child = document.createElement('test');
      parent.appendChild(child);
      parent.prepend(null);
      assert_equals(parent.childNodes[0].textContent, 'null');
      assert_equals(parent.childNodes[1], child);
    }, nodeName + '.prepend() with null as an argument, on a parent having a child.');

    test(function() {
      const parent = node.cloneNode();
      const x = document.createElement('x');
      const child = document.createElement('test');
      parent.appendChild(child);
      parent.prepend(x, 'text');
      assert_equals(parent.childNodes[0], x);
      assert_equals(parent.childNodes[1].textContent, 'text');
      assert_equals(parent.childNodes[2], child);
    }, nodeName + '.prepend() with one element and text as argument, on a parent having a child.');
  }

  test_prepend(document.createElement('div'), 'Element');
  test_prepend(document.createDocumentFragment(), 'DocumentFragment');
});