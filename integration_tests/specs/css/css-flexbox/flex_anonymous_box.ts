describe('Flex Anonymous Box', () => {
  it('should create separate anonymous flex items for text nodes', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.width = '600px';
    container.style.height = '100px';
    container.style.backgroundColor = '#f0f0f0';
    container.style.gap = '10px';

    // Add text node
    container.appendChild(document.createTextNode('First text'));

    // Add span element
    const span = document.createElement('span');
    span.textContent = 'Span element';
    span.style.backgroundColor = 'lightblue';
    span.style.padding = '5px';
    container.appendChild(span);

    // Add another text node
    container.appendChild(document.createTextNode('Last text'));

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle mixed inline and block elements in flex', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.width = '600px';
    container.style.backgroundColor = '#f0f0f0';
    container.style.alignItems = 'center';
    container.style.gap = '10px';

    // Text before
    container.appendChild(document.createTextNode('Text before'));

    // Inline span
    const span = document.createElement('span');
    span.textContent = 'Inline span';
    span.style.backgroundColor = 'yellow';
    span.style.padding = '5px';
    container.appendChild(span);

    // Block div
    const div = document.createElement('div');
    div.textContent = 'Block div';
    div.style.backgroundColor = 'lightgreen';
    div.style.padding = '10px';
    div.style.width = '100px';
    container.appendChild(div);

    // Text after
    container.appendChild(document.createTextNode('Text after'));

    document.body.appendChild(container);

    await snapshot();
  });

  it('should create anonymous flex items for contiguous text and inline elements', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.width = '600px';
    container.style.backgroundColor = '#f0f0f0';
    container.style.gap = '10px';

    // First text
    container.appendChild(document.createTextNode('Start '));

    // Inline element (should be in same anonymous box in regular flow, but separate flex item)
    const em = document.createElement('em');
    em.textContent = 'emphasis';
    container.appendChild(em);

    // More text
    container.appendChild(document.createTextNode(' middle '));

    // Another inline element
    const strong = document.createElement('strong');
    strong.textContent = 'strong';
    container.appendChild(strong);

    // End text
    container.appendChild(document.createTextNode(' end'));

    document.body.appendChild(container);

    await snapshot();
  });

  it('inline-flex should also create anonymous flex items', async () => {
    const p = document.createElement('p');
    p.style.fontSize = '16px';
    p.textContent = 'This is a paragraph with an ';

    const inlineFlex = document.createElement('span');
    inlineFlex.style.display = 'inline-flex';
    inlineFlex.style.backgroundColor = '#e0e0e0';
    inlineFlex.style.gap = '5px';
    inlineFlex.style.padding = '2px';

    // Add content to inline-flex
    inlineFlex.appendChild(document.createTextNode('inline'));

    const span = document.createElement('span');
    span.textContent = 'flex';
    span.style.backgroundColor = 'lightcoral';
    span.style.padding = '2px';
    inlineFlex.appendChild(span);

    inlineFlex.appendChild(document.createTextNode('container'));

    p.appendChild(inlineFlex);
    p.appendChild(document.createTextNode(' in the middle.'));

    document.body.appendChild(p);

    await snapshot();
  });
});
