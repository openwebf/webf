describe('CSS Grid minmax() function', () => {
  it('clamps to min with small content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '350px';
    grid.style.gridTemplateColumns = 'minmax(150px, 200px) minmax(100px, 1fr)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.textContent = 'Min 150px';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Flex';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // First track should be at least 150px
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(150);
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(200);

    // Second track gets remaining space
    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);

    grid.remove();
  });

  it('clamps to max with large content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '360px';
    grid.style.gridTemplateColumns = 'minmax(50px, 150px) minmax(50px, 150px) 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = i < 2 ? 'Max 150px' : 'Remaining';
      item.style.backgroundColor = ['#42A5F5', '#2196F3', '#1E88E5'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '11px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // First two tracks should be clamped to max 150px
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(150);
    expect(items[1].getBoundingClientRect().width).toBeLessThanOrEqual(150);

    // Third track gets remaining space
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('uses auto as min', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'minmax(auto, 200px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.textContent = 'Auto minimum size based on content';
    item.style.backgroundColor = '#BA68C8';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    item.style.padding = '5px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    // Should be at least content size, at most 200px
    expect(itemRect.width).toBeGreaterThan(0);
    expect(itemRect.width).toBeLessThanOrEqual(200);

    grid.remove();
  });

  it('uses auto as max', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'minmax(100px, auto)';
    grid.style.gridTemplateRows = '60px';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'Content determines max';
    item.style.backgroundColor = '#FFB74D';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.padding = '10px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    // `auto` max tracks are stretched by default (`justify-content: normal` -> `stretch` for grid).
    expect(itemRect.width).toBeCloseTo(300, 0);

    grid.remove();
  });

  it('handles min-content in minmax', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'minmax(min-content, 150px) 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    const item1 = document.createElement('div');
    item1.textContent = 'MinContent';
    item1.style.backgroundColor = '#9575CD';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.whiteSpace = 'nowrap';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Flex';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // min-content should size to smallest content size
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(150);

    grid.remove();
  });

  it('handles max-content in minmax', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = 'minmax(50px, max-content) 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    const item1 = document.createElement('div');
    item1.textContent = 'This is max content sizing';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    item1.style.whiteSpace = 'nowrap';
    item1.style.padding = '5px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Flex';
    item2.style.backgroundColor = '#26A69A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // max-content should size to full content width
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(50);

    grid.remove();
  });

  it('resolves percentage min/max', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '360px';
    grid.style.gridTemplateColumns = 'minmax(20%, 40%) minmax(30%, 1fr)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fce4ec';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Track ${i + 1}`;
      item.style.backgroundColor = ['#F06292', '#EC407A'][i];
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
    // Space for columns: 360px - 10px gap = 350px.
    // Track 1 uses the definite max (40% of 360px = 144px), and Track 2 gets remaining space.
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(144, 0);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(206, 0);

    grid.remove();
  });

  it('handles fr units in minmax', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = '100px minmax(50px, 1fr) minmax(80px, 2fr)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff9c4';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['100px', '1fr', '2fr'][i];
      item.style.backgroundColor = ['#FFEB3B', '#FDD835', '#FBC02D'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.fontSize = '11px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(100);

    // Remaining space: 400 - 100 - 20 (gaps) = 280px
    // Divided as 1fr:2fr
    const item2Width = items[1].getBoundingClientRect().width;
    const item3Width = items[2].getBoundingClientRect().width;

    const remaining = 400 - 100 - 20;
    expect(item2Width).toBeGreaterThanOrEqual(50);
    expect(item3Width).toBeGreaterThanOrEqual(80);
    expect(Math.abs(item2Width - remaining / 3)).toBeLessThanOrEqual(2);
    expect(Math.abs(item3Width - (remaining * 2) / 3)).toBeLessThanOrEqual(2);

    grid.remove();
  });

  it('handles invalid min > max scenario', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    // When min > max, min is used
    grid.style.gridTemplateColumns = 'minmax(200px, 100px) 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8eaf6';

    const item1 = document.createElement('div');
    item1.textContent = 'Invalid minmax';
    item1.style.backgroundColor = '#5C6BC0';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Flex';
    item2.style.backgroundColor = '#3F51B5';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // When min > max, min value should be used
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(200, 0);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(90, 0);

    grid.remove();
  });

  it('combines multiple minmax tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '360px';
    grid.style.gridTemplateColumns = 'minmax(80px, 120px) minmax(100px, 1fr) minmax(60px, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f1f8e9';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `minmax ${i + 1}`;
      item.style.backgroundColor = ['#9CCC65', '#8BC34A', '#7CB342'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '11px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(80);
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(120);

    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);

    expect(items[2].getBoundingClientRect().width).toBeGreaterThanOrEqual(60);
    expect(items[2].getBoundingClientRect().width).toBeLessThanOrEqual(100);

    grid.remove();
  });
});
