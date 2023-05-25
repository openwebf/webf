describe('ChildNode before', function () {
  function test_before(child, nodeName, innerHTML) {

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.before();
      assert_equals(parent.innerHTML, innerHTML);
    }, nodeName + '.before() without any argument.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.before(null);
      var expected = 'null' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with null as an argument.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.before(undefined);
      var expected = 'undefined' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with undefined as an argument.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.before('');
      assert_equals(parent.firstChild.data, '');
    }, nodeName + '.before() with the empty string as an argument.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.before('text');
      var expected = 'text' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with only text as an argument.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      parent.appendChild(child);
      child.before(x);
      var expected = '<x></x>' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with only one element as an argument.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      parent.appendChild(child);
      child.before(x, 'text');
      var expected = '<x></x>text' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with one element and text as arguments.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.before('text', child);
      var expected = 'text' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with context object itself as the argument.');

    test(function() {
      var parent = document.createElement('div')
      var x = document.createElement('x');
      parent.appendChild(child);
      parent.appendChild(x);
      child.before(x, child);
      var expected = '<x></x>' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with context object itself and node as the arguments, switching positions.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      var y = document.createElement('y');
      var z = document.createElement('z');
      parent.appendChild(y);
      parent.appendChild(child);
      parent.appendChild(x);
      child.before(x, y, z);
      var expected = '<x></x><y></y><z></z>' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with all siblings of child as arguments.');

    test(function() {
      var parent = document.createElement('div')
      var x = document.createElement('x');
      var y = document.createElement('y');
      var z = document.createElement('z');
      parent.appendChild(x);
      parent.appendChild(y);
      parent.appendChild(z);
      parent.appendChild(child);
      child.before(y, z);
      var expected = '<x></x><y></y><z></z>' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with some siblings of child as arguments; no changes in tree; viable sibling is first child.');

    test(function() {
      var parent = document.createElement('div')
      var v = document.createElement('v');
      var x = document.createElement('x');
      var y = document.createElement('y');
      var z = document.createElement('z');
      parent.appendChild(v);
      parent.appendChild(x);
      parent.appendChild(y);
      parent.appendChild(z);
      parent.appendChild(child);
      child.before(y, z);
      var expected = '<v></v><x></x><y></y><z></z>' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with some siblings of child as arguments; no changes in tree.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      var y = document.createElement('y');
      parent.appendChild(x);
      parent.appendChild(y);
      parent.appendChild(child);
      child.before(y, x);
      var expected = '<y></y><x></x>' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() when pre-insert behaves like prepend.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      parent.appendChild(x);
      parent.appendChild(document.createTextNode('1'));
      var y = document.createElement('y');
      parent.appendChild(y);
      parent.appendChild(child);
      child.before(x, '2');
      var expected = '1<y></y><x></x>2' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with one sibling of child and text as arguments.');

    test(function() {
      var x = document.createElement('x');
      var y = document.createElement('y');
      x.before(y);
      assert_equals(x.previousSibling, null);
    }, nodeName + '.before() on a child without any parent.');
  }

  test_before(document.createComment('test'), 'Comment', '<!--test-->');
  test_before(document.createElement('test'), 'Element', '<test></test>');
  test_before(document.createTextNode('test'), 'Text', 'test');

});

describe('ChildNode after', function() {

  function test_after(child, nodeName, innerHTML) {

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.after();
      assert_equals(parent.innerHTML, innerHTML);
    }, nodeName + '.after() without any argument.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.after(null);
      var expected = innerHTML + 'null';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with null as an argument.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.after(undefined);
      var expected = innerHTML + 'undefined';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with undefined as an argument.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.after('');
      assert_equals(parent.lastChild.data, '');
    }, nodeName + '.after() with the empty string as an argument.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.after('text');
      var expected = innerHTML + 'text';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with only text as an argument.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      parent.appendChild(child);
      child.after(x);
      var expected = innerHTML + '<x></x>';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with only one element as an argument.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      parent.appendChild(child);
      child.after(x, 'text');
      var expected = innerHTML + '<x></x>text';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with one element and text as arguments.');

    test(function() {
      var parent = document.createElement('div');
      parent.appendChild(child);
      child.after('text', child);
      var expected = 'text' + innerHTML;
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with context object itself as the argument.');

    test(function() {
      var parent = document.createElement('div')
      var x = document.createElement('x');
      parent.appendChild(x);
      parent.appendChild(child);
      child.after(child, x);
      var expected = innerHTML + '<x></x>';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with context object itself and node as the arguments, switching positions.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      var y = document.createElement('y');
      var z = document.createElement('z');
      parent.appendChild(y);
      parent.appendChild(child);
      parent.appendChild(x);
      child.after(x, y, z);
      var expected = innerHTML + '<x></x><y></y><z></z>';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with all siblings of child as arguments.');

    test(function() {
      var parent = document.createElement('div')
      var x = document.createElement('x');
      var y = document.createElement('y');
      var z = document.createElement('z');
      parent.appendChild(child);
      parent.appendChild(x);
      parent.appendChild(y);
      parent.appendChild(z);
      child.after(x, y);
      var expected = innerHTML + '<x></x><y></y><z></z>';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.before() with some siblings of child as arguments; no changes in tree; viable sibling is first child.');

    test(function() {
      var parent = document.createElement('div')
      var v = document.createElement('v');
      var x = document.createElement('x');
      var y = document.createElement('y');
      var z = document.createElement('z');
      parent.appendChild(child);
      parent.appendChild(v);
      parent.appendChild(x);
      parent.appendChild(y);
      parent.appendChild(z);
      child.after(v, x);
      var expected = innerHTML + '<v></v><x></x><y></y><z></z>';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with some siblings of child as arguments; no changes in tree.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      var y = document.createElement('y');
      parent.appendChild(child);
      parent.appendChild(x);
      parent.appendChild(y);
      child.after(y, x);
      var expected = innerHTML + '<y></y><x></x>';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() when pre-insert behaves like append.');

    test(function() {
      var parent = document.createElement('div');
      var x = document.createElement('x');
      var y = document.createElement('y');
      parent.appendChild(child);
      parent.appendChild(x);
      parent.appendChild(document.createTextNode('1'));
      parent.appendChild(y);
      child.after(x, '2');
      var expected = innerHTML + '<x></x>21<y></y>';
      assert_equals(parent.innerHTML, expected);
    }, nodeName + '.after() with one sibling of child and text as arguments.');

    test(function() {
      var x = document.createElement('x');
      var y = document.createElement('y');
      x.after(y);
      assert_equals(x.nextSibling, null);
    }, nodeName + '.after() on a child without any parent.');
  }

  test_after(document.createComment('test'), 'Comment', '<!--test-->');
  test_after(document.createElement('test'), 'Element', '<test></test>');
  test_after(document.createTextNode('test'), 'Text', 'test');
});