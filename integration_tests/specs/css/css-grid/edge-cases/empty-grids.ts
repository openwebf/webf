describe('CSS Grid empty grids', () => {
  it('renders empty grid with explicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.minHeight = '160px';

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(0);
    // Grid should maintain size even without items
    expect(grid.getBoundingClientRect().height).toBeGreaterThanOrEqual(160);

    grid.remove();
  });

  it('renders empty grid with auto tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto auto';
    grid.style.gridTemplateRows = 'auto auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';
    grid.style.minHeight = '100px';

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(0);
    expect(grid.getBoundingClientRect().height).toBeGreaterThanOrEqual(100);

    grid.remove();
  });

  it('renders empty grid with fr units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.height = '200px';
    grid.style.gridTemplateColumns = '1fr 2fr 1fr';
    grid.style.gridTemplateRows = '1fr 1fr';
    grid.style.gap = '8px';
    grid.style.backgroundColor = '#f3e5f5';

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(0);
    expect(grid.getBoundingClientRect().width).toBe(300);
    expect(grid.getBoundingClientRect().height).toBe(200);

    grid.remove();
  });

  it('adds items to previously empty grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 120px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    document.body.appendChild(grid);
    await waitForFrame();

    expect(grid.children.length).toBe(0);

    // Add items
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

    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(4);

    grid.remove();
  });

  it('renders empty grid with named lines', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '[start] 100px [middle] 100px [end]';
    grid.style.gridTemplateRows = '[top] 70px [bottom]';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.minHeight = '80px';

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(0);

    grid.remove();
  });

  it('handles empty grid with minmax tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = 'minmax(100px, 1fr) minmax(150px, 2fr)';
    grid.style.gridTemplateRows = 'minmax(80px, auto)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(0);
    expect(grid.getBoundingClientRect().width).toBe(400);

    grid.remove();
  });
});
