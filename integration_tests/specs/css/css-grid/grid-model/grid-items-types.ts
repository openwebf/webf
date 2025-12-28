describe('CSS Grid different item types', () => {
  it('treats div elements as grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 120px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `Div ${i + 1}`;
      item.style.backgroundColor = `hsl(${i * 60}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);
    expect(items[0].getBoundingClientRect().width).toBe(120);

    grid.remove();
  });

  it('treats span elements as grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('span');
      item.textContent = `Span ${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);
    // Spans become grid items even though they're normally inline
    expect(items[0].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('treats images as grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 120px)';
    grid.style.gridTemplateRows = 'repeat(2, 90px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 4; i++) {
      const img = document.createElement('img');
      img.width = 100;
      img.height = 70;
      img.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      img.style.objectFit = 'cover';
      grid.appendChild(img);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);

    grid.remove();
  });

  it('treats text nodes as anonymous grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'auto auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.fontSize = '14px';

    grid.appendChild(document.createTextNode('Text 1'));

    const div = document.createElement('div');
    div.textContent = 'Div';
    div.style.backgroundColor = '#FFB74D';
    div.style.display = 'flex';
    div.style.alignItems = 'center';
    div.style.justifyContent = 'center';
    div.style.color = 'white';
    grid.appendChild(div);

    grid.appendChild(document.createTextNode('Text 2'));

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Text nodes become anonymous grid items
    expect(grid.childNodes.length).toBe(3);

    grid.remove();
  });

  it('treats button elements as grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 140px)';
    grid.style.gridTemplateRows = 'repeat(2, 50px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 4; i++) {
      const button = document.createElement('button');
      button.textContent = `Button ${i + 1}`;
      button.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      button.style.color = 'white';
      button.style.border = 'none';
      button.style.cursor = 'pointer';
      grid.appendChild(button);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);
    expect(items[0].getBoundingClientRect().width).toBe(140);

    grid.remove();
  });

  it('treats input elements as grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 40px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';
    grid.style.padding = '10px';

    for (let i = 0; i < 4; i++) {
      const input = document.createElement('input');
      input.type = 'text';
      input.placeholder = `Input ${i + 1}`;
      input.style.width = '100%';
      input.style.boxSizing = 'border-box';
      grid.appendChild(input);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);
    expect(items[0].getBoundingClientRect().width).toBe(150);

    grid.remove();
  });
});
