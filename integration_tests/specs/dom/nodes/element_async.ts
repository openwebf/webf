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
describe('DOM Element API async', () => {
  it('should work', async () => {
    const div = document.createElement('div');
    expect(div.nodeName === 'DIV').toBeTrue();

    div.style.width = div.style.height = '200px';
    div.style.border = '1px solid red';
    div.style.padding = '10px';
    div.style.margin = '20px';
    div.style.backgroundColor = 'grey';
    document.body.appendChild(div);
    
    // @ts-ignore
    const boundingClientRect = await div.getBoundingClientRect_async();
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

  it('should work with scroll', async () => {
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

    // @ts-ignore
    let boundingClientRect = await div.getBoundingClientRect_async();
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

    // @ts-ignore
    await div.scrollBy_async(0, 10);

    // @ts-ignore
    boundingClientRect = await div.getBoundingClientRect_async();
    expect(JSON.parse(JSON.stringify(childDiv.getBoundingClientRect()))).toEqual({
      bottom: 200, height: 30, left: 30, right: 60, top: 170, width: 30, x: 30, y: 170
    } as any);

  });

  it('should works when getting multiple zero rects', async() => {
    const div = document.createElement('div');
    // @ts-ignore
    let boundingClientRect = await div.getBoundingClientRect_async();
    expect(JSON.parse(JSON.stringify(boundingClientRect))).toEqual({bottom: 0, height: 0, left: 0, right: 0, top: 0, width: 0, x: 0, y: 0});
    // @ts-ignore
    boundingClientRect = await div.getBoundingClientRect_async();
    expect(JSON.parse(JSON.stringify(boundingClientRect))).toEqual({bottom: 0, height: 0, left: 0, right: 0, top: 0, width: 0, x: 0, y: 0});
  });

  it('should work with string value property', async () => {
    let input = document.createElement('input');
    // @ts-ignore
    input.value_async = 'helloworld';
    // @ts-ignore
    let value = await input.value_async;
    expect(value).toBe('helloworld');
  });

  it('should work with matches', async () => {
    const el = document.createElement('div');
    el.setAttribute('class', 'a1 b1');
    document.body.appendChild(el);
    // @ts-ignore
    let matches = await el.matches_async('.a1');
    expect(matches).toBeTrue();
  });
});