describe('CSS Grid sizing resolution algorithm', () => {
  it('resolves intrinsic sizing with content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content max-content auto';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Much Longer Text Content';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Auto';
    item3.style.backgroundColor = '#FFA726';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // min-content should be narrower than max-content
    expect(items[0].getBoundingClientRect().width).toBeLessThan(items[1].getBoundingClientRect().width);

    grid.remove();
  });

  it('resolves fit-content sizing', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'fit-content(150px) 200px';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    const item1 = document.createElement('div');
    item1.textContent = 'Fit content with maximum 150px';
    item1.style.backgroundColor = '#2196F3';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Fixed 200px';
    item2.style.backgroundColor = '#1976D2';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // fit-content should clamp to max
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(150);
    expect(items[1].getBoundingClientRect().width).toBe(200);

    grid.remove();
  });

  it('resolves sizing with spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto auto';
    grid.style.gridTemplateRows = 'auto auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    // Spanning item
    const spanItem = document.createElement('div');
    spanItem.textContent = 'Spanning item that affects sizing';
    spanItem.style.gridColumn = '1 / 3';
    spanItem.style.gridRow = '1';
    spanItem.style.backgroundColor = '#BA68C8';
    spanItem.style.padding = '10px';
    spanItem.style.color = 'white';
    grid.appendChild(spanItem);

    // Regular items
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Spanning item should distribute space across tracks
    expect(spanItem.getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('resolves minimum sizing constraints', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(80px, auto) minmax(100px, auto)';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    const item1 = document.createElement('div');
    item1.textContent = 'Small';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Also small';
    item2.style.backgroundColor = '#FF9800';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Should respect minimum sizes
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(80);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);

    grid.remove();
  });

  it('resolves maximum sizing constraints', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '500px';
    grid.style.gridTemplateColumns = 'minmax(50px, 150px) minmax(50px, 200px) 1fr';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `Item ${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Should respect maximum sizes
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(150);
    expect(items[1].getBoundingClientRect().width).toBeLessThanOrEqual(200);

    grid.remove();
  });

  it('resolves sizing with auto and fr mixed', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = 'auto 1fr 2fr';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    const item1 = document.createElement('div');
    item1.textContent = 'Auto fits content';
    item1.style.backgroundColor = '#9575CD';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '1fr';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = '2fr';
    item3.style.backgroundColor = '#673AB7';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Auto should size to content, fr should distribute remaining space
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    // 2fr should be roughly twice 1fr
    const ratio = items[2].getBoundingClientRect().width / items[1].getBoundingClientRect().width;
    expect(Math.abs(ratio - 2)).toBeLessThan(0.1);

    grid.remove();
  });
});
