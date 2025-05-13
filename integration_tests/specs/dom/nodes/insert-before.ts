describe('Insert before', () => {
  it('with node is not a type of node', () => {
    let container = document.createElement('div');
    let node = document.createElement('div');
    container.appendChild(node);

    expect(() => {
      // @ts-ignore
      container.insertBefore(new Event('1234'), null);
    }).toThrowError('parameter 1 is not of type \'Node\'.');
  });
  it('with node is a child of another parent', () => {
    let container = document.createElement('div');
    let node = document.createElement('div');
    container.appendChild(node);
    let otherContainer = document.createElement('div');
    otherContainer.insertBefore(node, null);
    expect(node.parentNode === otherContainer).toBe(true);
    expect(container.childNodes.length).toBe(0);
  });
  it('basic', async () => {
    var div = document.createElement('div');
    var span = document.createElement('span');
    var textNode = document.createTextNode('Hello');
    span.appendChild(textNode);
    div.appendChild(span);
    document.body.appendChild(div);

    var insertText = document.createTextNode('World');
    var insertSpan = document.createElement('span');
    insertSpan.appendChild(insertText);
    div.insertBefore(insertSpan, span);

    await snapshot();
  });

  it('referenceNode is null', async () => {
    let n1;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      }
    );
    BODY.insertBefore(n1, null);

    await snapshot();
  });

  it('with orphan element', async () => {
    let n1;
    let n2;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      }
    );
    n2 = createElementWithStyle(
      'div',
      {
        width: '200px',
        height: '200px',
        backgroundColor: 'blue',
      },
    );
    BODY.appendChild(n1);
    BODY.insertBefore(n2, n1);

    await snapshot();
  });

  it('with element which has parent and connected', async () => {
    let n1;
    let n2;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      },
    );

    n2 = createElementWithStyle(
      'div',
      {
        width: '200px',
        height: '200px',
        backgroundColor: 'blue',
      },
    );

    BODY.appendChild(n1);
    BODY.appendChild(n2);
    n1.insertBefore(n2, null);

    await snapshot();
  });

  it('with element which has parent but not connected', async () => {
    let n1;
    let n2;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      },
      [
        (n2 = createElementWithStyle(
          'div',
          {
            width: '200px',
            height: '200px',
            backgroundColor: 'blue',
          },
        ))
      ]
    );
    BODY.appendChild(n1);
    BODY.insertBefore(n2, n1);

    await snapshot();
  });

  it('insert before position fixed element', async () => {
    let child1 = createElement('div', {
      style: {
        position: 'fixed',
        top: '100px',
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    let child2;
    const container = createElement('div', {
      style: {
        width: '200px',
        height: '200px',
        background: 'yellow'
      }
    }, [
      (child2 = createElement('div', {
        style: {
          position: 'fixed',
          width: '100px',
          height: '100px',
          background: 'green'
        }
      }))
    ]);

    document.body.appendChild(container);

    container.insertBefore(child1, child2);

    await snapshot();
  });

  it('insert before position absolute element', async () => {
    let child1 = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    let child2;
    const container = createElement('div', {
      style: {
        width: '200px',
        height: '200px',
        background: 'yellow'
      }
    }, [
      (child2 = createElement('div', {
        style: {
          position: 'absolute',
          width: '100px',
          height: '100px',
          background: 'green'
        }
      }))
    ]);

    document.body.appendChild(container);

    container.insertBefore(child1, child2);

    await snapshot();
  });

  it('insert before referenceNode is comment', async () => {
    var container = document.createElement('div');
    document.body.appendChild(container);
    container.style.display = 'flex';
    container.style.flexDirection = 'column';

    var ref;
    container.appendChild(document.createTextNode('text1'));
    container.appendChild(ref = document.createComment('comment1'));
    container.appendChild(document.createTextNode('text2'));

    container.insertBefore(document.createTextNode('This line should between text1 and text2'), ref);

    await snapshot();
  });

  xit('insert before when new child is SVG element', async () => {
    var text1 = document.createTextNode('Hello webf!');
    var br = document.createElement('br');
    var text2 = document.createTextNode('你好，webf！');
    var p = document.createElement('p');
    p.className = 'p';
    p.style.display = 'inline-block';
    p.style.textAlign = 'center';
    p.style.animation = '3s ease-in 1s 1 reverse both running example';
    p.appendChild(text1);
    p.appendChild(br);
    p.appendChild(text2);

    var div = document.createElement('div');
    div.style.width = '10px';
    div.style.height = '10px';

    document.body.appendChild(p);
    p.appendChild(div);

    const svg_wrapper = document.createElement('div');
    svg_wrapper.innerHTML = `<svg class="icon" viewBox="0 0 1024 1024"><path d="M64 512c0 195.2 124.8 361.6 300.8 422.4 22.4 6.4 19.2-9.6 19.2-22.4v-76.8c-134.4 16-140.8-73.6-150.4-89.6-19.2-32-60.8-38.4-48-54.4 32-16 64 3.2 99.2 57.6 25.6 38.4 76.8 32 105.6 25.6 6.4-22.4 19.2-44.8 35.2-60.8-144-22.4-201.6-108.8-201.6-211.2 0-48 16-96 48-131.2-22.4-60.8 0-115.2 3.2-121.6 57.6-6.4 118.4 41.6 124.8 44.8 32-9.6 70.4-12.8 112-12.8 41.6 0 80 6.4 112 12.8 12.8-9.6 67.2-48 121.6-44.8 3.2 6.4 25.6 57.6 6.4 118.4 32 38.4 48 83.2 48 131.2 0 102.4-57.6 188.8-201.6 214.4 22.4 22.4 38.4 54.4 38.4 92.8v112c0 9.6 0 19.2 16 19.2C832 876.8 960 710.4 960 512c0-246.4-201.6-448-448-448S64 265.6 64 512z" fill="#040000" p-id="3824"></path></svg>`;
    const svg = svg_wrapper.firstChild as SVGElement;
    p.insertBefore(svg, div);

    await snapshot();
  });
});
