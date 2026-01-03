describe('CSS Grid container behavior', () => {
  it('creates block-level box as grid container', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 120px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
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

    // Grid should be block-level (take full width)
    expect(grid.getBoundingClientRect().width).toBeGreaterThan(240);

    grid.remove();
  });

  it('respects width and height on grid container', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.height = '300px';
    grid.style.gridTemplateColumns = '1fr 1fr';
    grid.style.gridTemplateRows = '1fr 1fr';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
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

    expect(grid.getBoundingClientRect().width).toBe(400);
    expect(grid.getBoundingClientRect().height).toBe(300);

    // fr units should distribute remaining space
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(195); // (400 - 10) / 2

    grid.remove();
  });

  it('applies padding to grid container', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.padding = '20px';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
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
    // First item should be offset by padding
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 20);
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 20);

    grid.remove();
  });

  it('applies border to grid container', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.border = '5px solid #666';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
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
    // First item should be offset by border
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 5);
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 5);

    grid.remove();
  });

  it('combines border, padding, and content box', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.border = '3px solid #333';
    grid.style.padding = '15px';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
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
    // First item offset by border + padding
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 18); // 3 + 15
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 18);

    grid.remove();
  });

  it('handles box-sizing: border-box on grid container', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.boxSizing = 'border-box';
    grid.style.width = '300px';
    grid.style.height = '250px';
    grid.style.gridTemplateColumns = '1fr 1fr';
    grid.style.gridTemplateRows = '1fr 1fr';
    grid.style.gap = '10px';
    grid.style.border = '5px solid #666';
    grid.style.padding = '10px';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Total size should be 300x250 including border and padding
    expect(grid.getBoundingClientRect().width).toBe(300);
    expect(grid.getBoundingClientRect().height).toBe(250);

    // Content area: 300 - 10 (border) - 20 (padding) = 270
    const items = Array.from(grid.children) as HTMLElement[];
    const itemWidth = items[0].getBoundingClientRect().width;
    expect(itemWidth).toBe(130); // (270 - 10) / 2
    
    grid.remove();
  });
});
