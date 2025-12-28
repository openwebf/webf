describe('CSS Grid display property', () => {
  it('establishes grid formatting context with display: grid', async () => {
    const container = document.createElement('div');
    container.style.display = 'grid';
    container.style.gridTemplateColumns = 'repeat(2, 100px)';
    container.style.gridTemplateRows = 'repeat(2, 70px)';
    container.style.gap = '10px';
    container.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${i * 60}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      container.appendChild(item);
    }

    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(container);
    expect(computed.display).toBe('grid');

    // Verify items are laid out in grid
    const items = Array.from(container.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().left).toBe(items[0].getBoundingClientRect().right + 10);

    container.remove();
  });

  it('establishes inline-level grid with display: inline-grid', async () => {
    const wrapper = document.createElement('div');
    wrapper.textContent = 'Text before ';

    const grid = document.createElement('div');
    grid.style.display = 'inline-grid';
    grid.style.gridTemplateColumns = 'repeat(2, 60px)';
    grid.style.gridTemplateRows = 'repeat(2, 50px)';
    grid.style.gap = '5px';
    grid.style.backgroundColor = '#e3f2fd';
    grid.style.verticalAlign = 'middle';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '11px';
      grid.appendChild(item);
    }

    wrapper.appendChild(grid);
    wrapper.appendChild(document.createTextNode(' text after'));
    document.body.appendChild(wrapper);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.display).toBe('inline-grid');

    wrapper.remove();
  });

  it('switches between display values', async () => {
    const container = document.createElement('div');
    container.style.display = 'block';
    container.style.gridTemplateColumns = 'repeat(2, 100px)';
    container.style.gridTemplateRows = 'repeat(2, 70px)';
    container.style.gap = '10px';
    container.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      container.appendChild(item);
    }

    document.body.appendChild(container);
    await waitForFrame();

    // Initially block layout
    const items = Array.from(container.children) as HTMLElement[];
    const blockTop0 = items[0].getBoundingClientRect().top;
    const blockTop1 = items[1].getBoundingClientRect().top;

    // Switch to grid
    container.style.display = 'grid';
    await waitForFrame();
    await snapshot();

    const gridTop0 = items[0].getBoundingClientRect().top;
    const gridTop1 = items[1].getBoundingClientRect().top;

    // In grid, items 0 and 1 should be on same row
    expect(gridTop0).toBe(gridTop1);
    // In block, items were stacked
    expect(blockTop1).toBeGreaterThan(blockTop0);

    container.remove();
  });

  it('inherits display: grid from parent', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'repeat(2, 150px)';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const child = document.createElement('div');
    child.style.display = 'inherit';
    child.style.gridTemplateColumns = 'repeat(2, 60px)';
    child.style.gap = '5px';
    child.style.backgroundColor = '#FFB74D';
    child.style.padding = '10px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '11px';
      child.appendChild(item);
    }

    parent.appendChild(child);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const childComputed = getComputedStyle(child);
    expect(childComputed.display).toBe('grid');

    parent.remove();
  });

  it('handles display: none on grid container', async () => {
    const container = document.createElement('div');
    container.style.display = 'grid';
    container.style.gridTemplateColumns = 'repeat(2, 100px)';
    container.style.gridTemplateRows = 'repeat(2, 70px)';
    container.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      container.appendChild(item);
    }

    document.body.appendChild(container);
    await waitForFrame();

    expect(container.getBoundingClientRect().width).toBeGreaterThan(0);

    container.style.display = 'none';
    await waitForFrame();
    await snapshot();

    expect(container.getBoundingClientRect().width).toBe(0);
    expect(container.getBoundingClientRect().height).toBe(0);

    container.remove();
  });

  it('treats display: contents on grid item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    // Regular item
    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.backgroundColor = '#9575CD';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // display: contents item
    const contentsWrapper = document.createElement('div');
    contentsWrapper.style.display = 'contents';

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    contentsWrapper.appendChild(item2);

    grid.appendChild(contentsWrapper);

    // Another regular item
    const item3 = document.createElement('div');
    item3.textContent = '3';
    item3.style.backgroundColor = '#673AB7';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item2 should be treated as direct grid item
    const items = [item1, item2, item3];
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 110);
    expect(items[2].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 220);

    grid.remove();
  });
});
