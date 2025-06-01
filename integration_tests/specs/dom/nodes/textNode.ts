describe('TextNode', () => {
  it('should work with basic example', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('before modified');

    document.body.appendChild(div);
    div.appendChild(text);

    await snapshot();
  });

  it('should work with text update', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('before modified');

    document.body.appendChild(div);
    div.appendChild(text);

    text.data = 'after modified';

    await snapshot();
  });

  it('should work with style update of non empty text', async () => {
    const div = document.createElement('div');
    const child = document.createElement('div');
    setElementStyle(child, {
      backgroundColor: '#f40',
      width: '100px',
      height: '100px',
    });
    const text = document.createTextNode('Hello world');
    div.appendChild(child);
    div.appendChild(text);
    div.style.color = 'blue';
    document.body.appendChild(div);

    await snapshot();
  });

  it('should work with style update of empty text', async () => {
    const div = document.createElement('div');
    const child = document.createElement('div');
    setElementStyle(child, {
      backgroundColor: '#f40',
      width: '100px',
      height: '100px',
    });
    const text = document.createTextNode('');
    div.appendChild(child);
    div.appendChild(text);
    div.style.color = 'blue';
    document.body.appendChild(div);

    await snapshot();
  });

  it('the previous sibling is block, the left space of this textnode is hidden', async () => {
    const div = document.createElement('div');
    div.appendChild(document.createTextNode('text1'));
    document.body.appendChild(div);

    const text = document.createTextNode(' text2');
    document.body.appendChild(text);

    await snapshot();
  });

  it('the next sibling is block, the right space of this textnode is hidden', async () => {
    const text = document.createTextNode('text1 ');
    document.body.appendChild(text);

    const div = document.createElement('div');
    div.appendChild(document.createTextNode('text2'));
    document.body.appendChild(div);

    await snapshot();
  });

  it('should work with set textContent', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('before modified');

    document.body.appendChild(div);
    div.appendChild(text);

    text.textContent = 'after modified';

    await snapshot();
  });

  it('empty string of textNode set data should work', async () => {
    const text = document.createTextNode('');
    document.body.appendChild(text);
    text.data = 'aaa';

    await snapshot();
  });

  it('empty string of textNode should not attach the render object to parent.', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.justifyContent = 'space-between';
    container.style.alignItems = 'center';

    document.body.appendChild(container);

    container.appendChild(document.createTextNode(''));

    for (let i = 0; i < 3; i++) {
      const child = document.createElement('div');
      child.style.border = '1px solid red';
      child.textContent = `${i}`;
      container.appendChild(child);
    }

    container.appendChild(document.createTextNode(''));

    await snapshot();
  });

  it('createTextNode should not has height when the text is a empty string', async () => {
    const child = document.createElement('div');
    child.style.width = '10px';
    child.style.height = '10px';
    child.style.backgroundColor = 'blue';
    document.body.appendChild(child);
    const text = document.createTextNode("")
    document.body.appendChild(text);

    const child2 = document.createElement('div');
    child2.style.width = '10px';
    child2.style.height = '10px';
    child2.style.backgroundColor = 'red';
    document.body.appendChild(child2);

    await snapshot();
  });

  it('createTextNode should not has height when the text is a empty string and flex layout', async () => {
    const div = document.createElement('div');
    div.style.display = 'flex';

    document.body.appendChild(div);

    const child = document.createElement('div');
    child.style.width = '10px';
    child.style.height = '10px';
    child.style.backgroundColor = 'blue';
    div.appendChild(child);
    const text = document.createTextNode("")
    div.appendChild(text);


    const child2 = document.createElement('div');
    child2.style.width = '10px';
    child2.style.height = '10px';
    child2.style.backgroundColor = 'red';
    div.appendChild(child2);

    await snapshot();
  });

  describe('nodeValue', () => {
    it('assign nodeValue to update.', async () => {
      const text = document.createTextNode('');
      document.body.appendChild(text);

      const TEXT = 'HELLO WORLD!';
      text.nodeValue = TEXT;
      await snapshot();
      expect(text.nodeValue).toEqual(TEXT);
    });
  });

  it('should work with whitespace trim and collapse of space', async () => {
    let div;

    div = createElement(
      'div',
      {
        style: {
          font: '60px monospace',
        },
      },
      [createText(`\u0020  \u0020A\u0020  \u0020B`)]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('should work with whitespace trim and collapse of tab', async () => {
    let div;

    div = createElement(
      'div',
      {
        style: {
          font: '60px monospace',
        },
      },
      [createText(`\u0009\u0009\u0009A\u0009\u0009\u0009B`)]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('should work with whitespace trim and collapse of segment break', async () => {
    let div;

    div = createElement(
      'div',
      {
        style: {
          font: '60px monospace',
        },
      },
      [createText(`\u000a\u000a\u000aA\u000a\u000a\u000aB`)]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('should work with whitespace trim and collapse of carriage return', async () => {
    let div;

    div = createElement(
      'div',
      {
        style: {
          font: '60px monospace',
        },
      },
      [createText(`\u000d\u000d\u000dA\u000d\u000d\u000dB`)]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('should not work with whitespace trim and collapse of no-break space', async () => {
    let div;

    div = createElement(
      'div',
      {
        style: {
          font: '60px monospace',
        },
      },
      [createText(`\u00a0\u00a0\u00a0A\u00a0\u00a0\u00a0B`)]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('should update text data multiple times consecutively', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('Initial');
    div.appendChild(text);
    document.body.appendChild(div);

    await snapshot();

    // Multiple consecutive updates
    text.data = 'First update';
    text.data = 'Second update';
    text.data = 'Third update';
    text.data = 'Final update';

    await snapshot();
  });

  it('should handle special characters in data update', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('Normal text');
    div.appendChild(text);
    document.body.appendChild(div);

    await snapshot();

    // Update with special characters
    text.data = 'Text with <special> & "characters" \'quotes\'';

    await snapshot();

    // Update with unicode
    text.data = 'Unicode: 你好世界 🌍 😊';

    await snapshot();
  });

  it('should update text in deeply nested elements', async () => {
    const outer = document.createElement('div');
    const middle = document.createElement('span');
    const inner = document.createElement('b');
    const text = document.createTextNode('Deep nested text');

    outer.style.padding = '10px';
    outer.style.backgroundColor = '#f0f0f0';
    middle.style.color = 'blue';
    inner.style.fontSize = '20px';

    inner.appendChild(text);
    middle.appendChild(inner);
    outer.appendChild(middle);
    document.body.appendChild(outer);

    await snapshot();

    // Update deeply nested text
    text.data = 'Updated deep text';

    await snapshot();
  });

  it('should handle rapid data updates without memory leaks', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('Start');
    div.appendChild(text);
    document.body.appendChild(div);

    // Rapid updates
    for (let i = 0; i < 100; i++) {
      text.data = `Update ${i}`;
    }

    await snapshot();
    expect(text.data).toBe('Update 99');
  });

  it('should update text data when parent element is detached and reattached', async () => {
    const div = document.createElement('div');
    const text = document.createTextNode('Original text');
    div.appendChild(text);
    document.body.appendChild(div);

    await snapshot();

    // Detach from DOM
    document.body.removeChild(div);

    // Update while detached
    text.data = 'Updated while detached';

    // Reattach to DOM
    document.body.appendChild(div);

    await snapshot();
  });

  it('should handle text data update with whitespace preservation', async () => {
    const pre = document.createElement('pre');
    const text = document.createTextNode('Line 1\n  Line 2\n    Line 3');
    pre.appendChild(text);
    document.body.appendChild(pre);

    await snapshot();

    // Update with different whitespace
    text.data = 'Updated\n\tWith\n\t\tTabs';

    await snapshot();
  });

  it('should update text data in flex container', async () => {
    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.gap = '10px';
    flex.style.alignItems = 'center';

    const box1 = document.createElement('div');
    box1.style.width = '50px';
    box1.style.height = '50px';
    box1.style.backgroundColor = 'red';

    const text = document.createTextNode('Flex Text');

    const box2 = document.createElement('div');
    box2.style.width = '50px';
    box2.style.height = '50px';
    box2.style.backgroundColor = 'blue';

    flex.appendChild(box1);
    flex.appendChild(text);
    flex.appendChild(box2);
    document.body.appendChild(flex);

    await snapshot();

    // Update text in flex context
    text.data = 'Updated Flex';

    await snapshot();
  });

  xit('should handle text data update with CSS text-transform', async () => {
    const div = document.createElement('div');
    div.style.textTransform = 'uppercase';
    const text = document.createTextNode('lowercase text');
    div.appendChild(text);
    document.body.appendChild(div);

    await snapshot();

    // Update text
    text.data = 'new lowercase text';

    await snapshot();

    // Change text-transform
    div.style.textTransform = 'capitalize';

    await snapshot();
  });
});
