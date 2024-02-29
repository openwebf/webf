/**
 * Test DOM API for
 * - Element.prototype.nodeName
 * - Element.prototype.getBoundingClientRect
 * - Element.prototype.setAttribute
 * - Element.prototype.getAttribute
 * - Element.prototype.hasAttribute
 * - Element.prototype.removeAttribute
 * - Element.prototype.click
 * - Element.prototype.toBlob
 * - Element.prototype.firstElementChild
 * - Element.prototype.lastElementChild
 * - Element.prototype.parentElement
 */
describe('DOM Element API', () => {
  it('should work', () => {
    const div = document.createElement('div');
    expect(div.nodeName === 'DIV').toBeTrue();

    div.style.width = div.style.height = '200px';
    div.style.border = '1px solid red';
    div.style.padding = '10px';
    div.style.margin = '20px';
    div.style.backgroundColor = 'grey';
    document.body.appendChild(div);

    const boundingClientRect = div.getBoundingClientRect();
    expect(JSON.parse(JSON.stringify(boundingClientRect))).toEqual({
      x: 20.0,
      y: 20.0,
      width: 200.0,
      height: 200.0,
      top: 20.0,
      left: 20.0,
      right: 220.0,
      bottom: 220.0,
    } as any);

    div.setAttribute('foo', 'bar');
    expect(div.getAttribute('foo')).toBe('bar');
    expect(div.hasAttribute('foo')).toBeTrue();

    div.removeAttribute('foo');
    expect(div.hasAttribute('foo')).toBeFalse();
  });

  it('should work with scroll', () => {
    const div = document.createElement('div');

    div.style.width = div.style.height = '200px';
    div.style.padding = '10px';
    div.style.margin = '20px';
    div.style.backgroundColor = 'grey';
    div.style.overflow = 'scroll';
    document.body.appendChild(div);

    const scrollDiv = document.createElement('div');
    scrollDiv.style.width = '100px';
    scrollDiv.style.height = '1000px';
    div.appendChild(scrollDiv)

    const childDiv = document.createElement('div');
    childDiv.style.width = childDiv.style.height = '30px';
    childDiv.style.marginTop = '150px';
    childDiv.style.backgroundColor = 'yellow';
    scrollDiv.appendChild(childDiv);

    expect(JSON.parse(JSON.stringify(childDiv.getBoundingClientRect()))).toEqual({
      bottom: 210, height: 30, left: 30, right: 60, top: 180, width: 30, x: 30, y: 180
    } as any);

    div.scrollBy(0, 10);

    expect(JSON.parse(JSON.stringify(childDiv.getBoundingClientRect()))).toEqual({
      bottom: 200, height: 30, left: 30, right: 60, top: 170, width: 30, x: 30, y: 170
    } as any);

  });

  it('should works when getting multiple zero rects', () => {
    const div = document.createElement('div');
    expect(JSON.parse(JSON.stringify(div.getBoundingClientRect()))).toEqual({bottom: 0, height: 0, left: 0, right: 0, top: 0, width: 0, x: 0, y: 0});
    expect(JSON.parse(JSON.stringify(div.getBoundingClientRect()))).toEqual({bottom: 0, height: 0, left: 0, right: 0, top: 0, width: 0, x: 0, y: 0});
  });

  it('children should only contain elements', () => {
    let container = document.createElement('div');
    let a = document.createElement('div');
    let b = document.createElement('div');
    let text = document.createTextNode('test');
    let comment = document.createTextNode('#comment');
    container.appendChild(a);
    container.appendChild(text);
    container.appendChild(b);
    container.appendChild(comment);

    expect(container.childNodes.length).toBe(4);
    expect(container.children.length).toBe(2);
    expect(container.children[0]).toBe(a);
    expect(container.children[1]).toBe(b);
  });

  it('should work with string value property', () => {
    let input = document.createElement('input');
    input.value = 'helloworld';
    expect(input.value).toBe('helloworld');
  });

  it('property default to undefined value', () => {
    const el = document.createElement('div');
    expect(typeof el['foo']).toEqual('undefined');

    el['foo'] = 123;
    expect(typeof el['foo']).toEqual('number');
  });

  it('should work with firstElementChild', () => {
    const el = document.createElement('div');
    document.body.appendChild(el);

    el.appendChild(document.createTextNode('text'));
    el.appendChild(document.createComment('comment'));
    for (let i = 0; i < 20; i ++) {
      el.appendChild(document.createElement('span'));
    }

    var target = el.firstElementChild;
    expect(target.tagName).toEqual('SPAN');
  });

  it('should work with lastElementChild', () => {
    const el = document.createElement('div');
    document.body.appendChild(el);

    for (let i = 0; i < 20; i ++) {
      el.appendChild(document.createElement('span'));
    }
    el.appendChild(document.createTextNode('text'));
    el.appendChild(document.createComment('comment'));

    var target = el.lastElementChild;
    expect(target.tagName).toEqual('SPAN');
  });

  it('should work with matches', () => {
    const el = document.createElement('div');
    el.setAttribute('class', 'a1 b1');
    document.body.appendChild(el);
    expect(el.matches('.a1')).toBeTrue();
  });

  it('should have constructor property for DOM elements', () => {
    const div = document.createElement('div');
    expect(div.constructor.prototype.addEventListener).toEqual(div.addEventListener);

    function isObject(o) {
      return typeof o === 'object' && o !== null && o.constructor && o.constructor === Object;
    }
    expect(isObject(div)).toBe(false);
  });

  it('should have className for DOM elements', () => {
    function isObject(o) {
      return typeof o === "object" && o !== null && o.constructor && Object.prototype.toString.call(o).slice(8, -1) === "Object";
    }
    const div = document.createElement('div');
    expect(isObject(div)).toBe(false);
    expect(Object.prototype.toString.call(div)).toBe('[object HTMLDivElement]');
  });

  it('should work with parentElement', () => {
    const el = document.createElement('div');
    document.body.appendChild(el);
    el.appendChild(document.createElement('span'));
    var target = el.lastElementChild?.parentElement;
    expect(target.tagName).toEqual('DIV');
  
    let childDiv = document.createDocumentFragment().appendChild(document.createElement('div'));
    expect(childDiv.parentElement).toEqual(null);
  
    expect(document.documentElement.parentElement).toEqual(null);
  });
});

describe('children', () => {
  test(function() {
    var container = document.createElement('div');
    container.innerHTML = '<img id=foo><img id=foo><img name="bar">';
    var list = container.children;
    var result: any[] = [];
    for (var p in list) {
      if (list.hasOwnProperty(p)) {
        result.push(p);
      }
    }
    assert_array_equals(result, ['0', '1', '2', 'item', 'length']);
  }, '');
});