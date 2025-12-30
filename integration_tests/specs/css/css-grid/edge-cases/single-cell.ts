describe('CSS Grid single cell grids', () => {
  it('renders single cell grid with one item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px';
    grid.style.gridTemplateRows = '150px';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = 'Single Cell';
    item.style.backgroundColor = '#42A5F5';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBe(200);
    expect(item.getBoundingClientRect().height).toBe(150);

    grid.remove();
  });

  it('renders single cell grid with auto sizing', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto';
    grid.style.gridTemplateRows = 'auto';
    grid.style.backgroundColor = '#e3f2fd';

    const item = document.createElement('div');
    item.textContent = 'Auto sized content that determines cell size';
    item.style.backgroundColor = '#2196F3';
    item.style.padding = '20px';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('renders single cell grid with fr unit', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.height = '200px';
    grid.style.gridTemplateColumns = '1fr';
    grid.style.gridTemplateRows = '1fr';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.textContent = 'Fills Grid';
    item.style.backgroundColor = '#BA68C8';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBe(300);
    expect(item.getBoundingClientRect().height).toBe(200);

    grid.remove();
  });

  it('renders single cell grid with minmax', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(150px, 300px)';
    grid.style.gridTemplateRows = 'minmax(100px, auto)';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'Minmax Cell';
    item.style.backgroundColor = '#FFB74D';
    item.style.padding = '30px';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(150);
    expect(item.getBoundingClientRect().height).toBeGreaterThanOrEqual(100);

    grid.remove();
  });

  it('aligns item in single cell grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.height = '250px';
    grid.style.gridTemplateColumns = '1fr';
    grid.style.gridTemplateRows = '1fr';
    grid.style.justifyItems = 'center';
    grid.style.alignItems = 'center';
    grid.style.backgroundColor = '#e8f5e9';

    const item = document.createElement('div');
    item.textContent = 'Centered';
    item.style.width = '150px';
    item.style.height = '100px';
    item.style.backgroundColor = '#66BB6A';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item should be centered in grid
    const gridCenterX = grid.getBoundingClientRect().left + 150;
    const gridCenterY = grid.getBoundingClientRect().top + 125;
    const itemCenterX = item.getBoundingClientRect().left + 75;
    const itemCenterY = item.getBoundingClientRect().top + 50;

    expect(Math.abs(gridCenterX - itemCenterX)).toBeLessThan(2);
    expect(Math.abs(gridCenterY - itemCenterY)).toBeLessThan(2);

    grid.remove();
  });

  it('renders single cell empty grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px';
    grid.style.gridTemplateRows = '150px';
    grid.style.backgroundColor = '#ede7f6';

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(0);
    expect(grid.getBoundingClientRect().width).toBe(document.body.getBoundingClientRect().width);

    grid.remove();
  });
});
