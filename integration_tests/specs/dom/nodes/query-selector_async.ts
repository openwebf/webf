/**
 * Test DOM API for
 * - document.querySelector
 * - document.querySelectorAll
 */
describe('querySelector api', () => {
  it('document querySelector cant find element', async(done) => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });
    // @ts-ignore
    let span = await document.querySelector_async('span')
    expect(span).toBeNull();
    done();
  });

  it('document querySelector find first element', async(done) => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    // @ts-ignore
    const ele = await document.querySelector_async('div');
    expect(ele?.getAttribute('id')).toBe('id-0');
    done();
  });

  it('document querySelectorAll length of elements', async (done) => {
    const szEle = ['red', 'black', 'green', 'yellow', 'blue'];
    szEle.forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    // @ts-ignore
    const eles = await document.querySelectorAll_async('div');
    expect(eles.length).toBe(szEle.length);
    done();
  });

  it('document querySelectorAll first element', async (done) => {
    const szEle = ['red', 'black', 'green', 'yellow', 'blue'];
    szEle.forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    // @ts-ignore
    const eles = await document.querySelectorAll_async('div');
    expect(eles[0].getAttribute('id')).toBe('id-0');
    done();
  });

  it('document querySelectorAll cant find element by tag name', async (done) => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });
    // @ts-ignore
    const span = await document.querySelectorAll_async('span')
    expect(span.length).toBe(0);
    done();
  });

  it('document querySelector find element by id', async (done) => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      document.body.appendChild(div);
    });

    // @ts-ignore
    const elem = await document.querySelector_async('#id-1')
    expect(elem?.style.backgroundColor).toBe('black');
    done();
  });

  it('document querySelector find element by className', async(done) => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      div.className = `class-${index} cc`;
      document.body.appendChild(div);
    });

    // @ts-ignore
    const elem = await document.querySelector_async('.class-2')
    expect(elem?.style.backgroundColor).toBe('green');
    done();
  });

  it('document querySelectorAll find all element', async (done) => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;
      div.setAttribute('id', `id-${index}`);
      div.className = `class-${index} cc`;
      document.body.appendChild(div);
    });

    // @ts-ignore
    const elems = await document.querySelectorAll_async('*')
    expect(elems.length).toBe(8);
    done();
  });

  it('element closest cant find element', async (done) => {
    const parentDiv = document.createElement('div')
    parentDiv.style.width = '100px';
    parentDiv.style.height = '100px';
    parentDiv.style.backgroundColor = 'red';
    parentDiv.setAttribute('id', 'id-0');
    parentDiv.className = 'class-parent';

    const childDiv = document.createElement('div')
    childDiv.style.width = '50px';
    childDiv.style.height = '50px';
    childDiv.style.backgroundColor = 'yellow';
    childDiv.setAttribute('id', 'id-1');

    parentDiv.appendChild(childDiv);
    document.body.appendChild(parentDiv);
    // @ts-ignore
    const ele = await childDiv.closest_async('.class-parent');
    expect(ele?.getAttribute('id')).toBe('id-0');
    done();
  });
});
