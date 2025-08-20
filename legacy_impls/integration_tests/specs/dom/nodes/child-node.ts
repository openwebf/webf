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

describe('ChildNodes', () => {

  var check_parent_node = function(node) {
    assert_array_equals(node.childNodes, []);

    var children = node.childNodes;
    var child = document.createElement("p");
    node.appendChild(child);
    assert_equals(node.childNodes, children);
    assert_equals(children.item(0), child);

    var child2 = document.createComment("comment");
    node.appendChild(child2);
    expect(children.length).toBe(2);
    assert_equals(children.item(0), child);
    assert_equals(children.item(1), child2);

    assert_false(2 in children);
    assert_equals(children[2], undefined);
    assert_equals(children.item(2), null);
  };

  test(function() {
    var element = document.createElement("p");
    assert_equals(element.childNodes, element.childNodes);
  }, "Caching of Node.childNodes");

  test(function() {
    check_parent_node(document.createElement("p"));
  }, "Node.childNodes on an Element.");

  test(function() {
    check_parent_node(document.createDocumentFragment());
  }, "Node.childNodes on a DocumentFragment.");

  test(function() {
    var node = document.createElement("div");
    var kid1 = document.createElement("p");
    var kid2 = document.createTextNode("hey");
    var kid3 = document.createElement("span");
    node.appendChild(kid1);
    node.appendChild(kid2);
    node.appendChild(kid3);

    var list = node.childNodes;
    // @ts-ignore
    assert_array_equals([...list], [kid1, kid2, kid3]);

    // @ts-ignore
    var keys = list.keys();
    assert_false(keys instanceof Array);
    keys = [...keys];
    assert_array_equals(keys, [0, 1, 2]);

    // @ts-ignore
    var values = list.values();
    assert_false(values instanceof Array);
    values = [...values];
    assert_array_equals(values, [kid1, kid2, kid3]);

    // @ts-ignore
    var entries = list.entries();
    assert_false(entries instanceof Array);
    entries = [...entries];
    assert_equals(entries.length, keys.length);
    assert_equals(entries.length, values.length);
    for (var i = 0; i < entries.length; ++i) {
      assert_array_equals(entries[i], [keys[i], values[i]]);
    }

    var cur = 0;
    var thisObj = {};
    list.forEach(function(value, key, listObj) {
      assert_equals(listObj, list);
      // @ts-ignore
      assert_equals(this, thisObj);
      assert_equals(value, values[cur]);
      assert_equals(key, keys[cur]);
      cur++;
    }, thisObj);
    assert_equals(cur, entries.length);

    assert_equals(list[Symbol.iterator], Array.prototype[Symbol.iterator]);
    // @ts-ignore
    assert_equals(list.keys, Array.prototype.keys);
    if (Array.prototype.values) {
      // @ts-ignore
      assert_equals(list.values, Array.prototype.values);
    }
    // @ts-ignore
    assert_equals(list.entries, Array.prototype.entries);
    assert_equals(list.forEach, Array.prototype.forEach);
  }, "Iterator behavior of Node.childNodes");

});