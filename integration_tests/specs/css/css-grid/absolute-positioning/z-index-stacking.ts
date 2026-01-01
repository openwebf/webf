describe('CSS Grid absolute positioning with z-index', () => {
  it('stacks absolute items by z-index', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.width = '310px';
    grid.style.height = '210px';

    // Lower z-index (behind)
    const abs1 = document.createElement('div');
    abs1.textContent = 'Z:1';
    abs1.style.position = 'absolute';
    abs1.style.top = '40px';
    abs1.style.left = '40px';
    abs1.style.width = '100px';
    abs1.style.height = '80px';
    abs1.style.backgroundColor = '#42A5F5';
    abs1.style.zIndex = '1';
    abs1.style.display = 'flex';
    abs1.style.alignItems = 'center';
    abs1.style.justifyContent = 'center';
    abs1.style.color = 'white';
    abs1.style.fontSize = '12px';
    grid.appendChild(abs1);

    // Higher z-index (in front)
    const abs2 = document.createElement('div');
    abs2.textContent = 'Z:10';
    abs2.style.position = 'absolute';
    abs2.style.top = '60px';
    abs2.style.left = '60px';
    abs2.style.width = '100px';
    abs2.style.height = '80px';
    abs2.style.backgroundColor = '#E91E63';
    abs2.style.zIndex = '10';
    abs2.style.display = 'flex';
    abs2.style.alignItems = 'center';
    abs2.style.justifyContent = 'center';
    abs2.style.color = 'white';
    abs2.style.fontSize = '12px';
    grid.appendChild(abs2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Both positioned correctly
    expect(abs1.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 40);
    expect(abs2.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 60);

    grid.remove();
  });

  it('uses negative z-index to stack behind grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 120px)';
    grid.style.gridTemplateRows = 'repeat(2, 90px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    // Regular grid item
    const item = document.createElement('div');
    item.textContent = 'Grid Item';
    item.style.backgroundColor = '#2196F3';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    // Absolute with negative z-index (should be behind grid item)
    const absItem = document.createElement('div');
    absItem.textContent = 'Z:-1';
    absItem.style.position = 'absolute';
    absItem.style.top = '20px';
    absItem.style.left = '20px';
    absItem.style.width = '140px';
    absItem.style.height = '110px';
    absItem.style.backgroundColor = '#FFB74D';
    absItem.style.zIndex = '-1';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '12px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 20);

    grid.remove();
  });

  it('creates stacking context with grid item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 140px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    // Grid item with stacking context
    const item = document.createElement('div');
    item.style.position = 'relative';
    item.style.zIndex = '1';
    item.style.backgroundColor = '#BA68C8';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';

    // Absolute child within item's stacking context
    const absChild = document.createElement('div');
    absChild.textContent = 'Child Z:100';
    absChild.style.position = 'absolute';
    absChild.style.top = '10px';
    absChild.style.left = '10px';
    absChild.style.width = '80px';
    absChild.style.height = '60px';
    absChild.style.backgroundColor = '#9C27B0';
    absChild.style.zIndex = '100';
    absChild.style.display = 'flex';
    absChild.style.alignItems = 'center';
    absChild.style.justifyContent = 'center';
    absChild.style.color = 'white';
    absChild.style.fontSize = '10px';
    item.appendChild(absChild);

    grid.appendChild(item);

    // Grid-level absolute with lower z-index
    const gridAbs = document.createElement('div');
    gridAbs.textContent = 'Grid Z:2';
    gridAbs.style.position = 'absolute';
    gridAbs.style.top = '30px';
    gridAbs.style.left = '30px';
    gridAbs.style.width = '100px';
    gridAbs.style.height = '70px';
    gridAbs.style.backgroundColor = '#4CAF50';
    gridAbs.style.zIndex = '2';
    gridAbs.style.display = 'flex';
    gridAbs.style.alignItems = 'center';
    gridAbs.style.justifyContent = 'center';
    gridAbs.style.color = 'white';
    gridAbs.style.fontSize = '10px';
    grid.appendChild(gridAbs);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Grid-level absolute with z:2 should be above item with z:1
    expect(gridAbs.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 30);

    grid.remove();
  });

  it('orders items with same z-index by source order', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 130px)';
    grid.style.gridTemplateRows = 'repeat(2, 90px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.width = '270px';
    grid.style.height = '190px';

    // All with same z-index, should stack by source order
    const abs1 = document.createElement('div');
    abs1.textContent = '1st';
    abs1.style.position = 'absolute';
    abs1.style.top = '20px';
    abs1.style.left = '20px';
    abs1.style.width = '90px';
    abs1.style.height = '70px';
    abs1.style.backgroundColor = '#FFB74D';
    abs1.style.zIndex = '5';
    abs1.style.display = 'flex';
    abs1.style.alignItems = 'center';
    abs1.style.justifyContent = 'center';
    abs1.style.color = 'white';
    grid.appendChild(abs1);

    const abs2 = document.createElement('div');
    abs2.textContent = '2nd';
    abs2.style.position = 'absolute';
    abs2.style.top = '40px';
    abs2.style.left = '40px';
    abs2.style.width = '90px';
    abs2.style.height = '70px';
    abs2.style.backgroundColor = '#FF9800';
    abs2.style.zIndex = '5';
    abs2.style.display = 'flex';
    abs2.style.alignItems = 'center';
    abs2.style.justifyContent = 'center';
    abs2.style.color = 'white';
    grid.appendChild(abs2);

    const abs3 = document.createElement('div');
    abs3.textContent = '3rd';
    abs3.style.position = 'absolute';
    abs3.style.top = '60px';
    abs3.style.left = '60px';
    abs3.style.width = '90px';
    abs3.style.height = '70px';
    abs3.style.backgroundColor = '#F57C00';
    abs3.style.zIndex = '5';
    abs3.style.display = 'flex';
    abs3.style.alignItems = 'center';
    abs3.style.justifyContent = 'center';
    abs3.style.color = 'white';
    grid.appendChild(abs3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // All positioned correctly
    expect(abs1.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 20);
    expect(abs2.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 40);
    expect(abs3.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 60);

    grid.remove();
  });

  it('stacks absolute items with auto z-index', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 130px)';
    grid.style.gridTemplateRows = 'repeat(2, 90px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.width = '270px';
    grid.style.height = '190px';

    // Auto z-index (default)
    const abs1 = document.createElement('div');
    abs1.textContent = 'Auto';
    abs1.style.position = 'absolute';
    abs1.style.top = '30px';
    abs1.style.left = '30px';
    abs1.style.width = '100px';
    abs1.style.height = '80px';
    abs1.style.backgroundColor = '#66BB6A';
    abs1.style.display = 'flex';
    abs1.style.alignItems = 'center';
    abs1.style.justifyContent = 'center';
    abs1.style.color = 'white';
    grid.appendChild(abs1);

    // Explicit z-index
    const abs2 = document.createElement('div');
    abs2.textContent = 'Z:1';
    abs2.style.position = 'absolute';
    abs2.style.top = '50px';
    abs2.style.left = '50px';
    abs2.style.width = '100px';
    abs2.style.height = '80px';
    abs2.style.backgroundColor = '#4CAF50';
    abs2.style.zIndex = '1';
    abs2.style.display = 'flex';
    abs2.style.alignItems = 'center';
    abs2.style.justifyContent = 'center';
    abs2.style.color = 'white';
    grid.appendChild(abs2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item with explicit z-index should be above auto
    expect(abs1.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 30);
    expect(abs2.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 50);

    grid.remove();
  });

  it('handles z-index with opacity creating stacking context', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 140px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    // Grid item with opacity (creates stacking context)
    const item = document.createElement('div');
    item.style.position = 'relative';
    item.style.backgroundColor = '#9575CD';
    item.style.opacity = '0.9';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';

    // Absolute child
    const absChild = document.createElement('div');
    absChild.textContent = 'Child';
    absChild.style.position = 'absolute';
    absChild.style.top = '10px';
    absChild.style.left = '10px';
    absChild.style.width = '70px';
    absChild.style.height = '50px';
    absChild.style.backgroundColor = '#7E57C2';
    absChild.style.zIndex = '1000';
    absChild.style.display = 'flex';
    absChild.style.alignItems = 'center';
    absChild.style.justifyContent = 'center';
    absChild.style.color = 'white';
    absChild.style.fontSize = '10px';
    item.appendChild(absChild);

    grid.appendChild(item);

    // Grid-level absolute
    const gridAbs = document.createElement('div');
    gridAbs.textContent = 'Grid Abs';
    gridAbs.style.position = 'absolute';
    gridAbs.style.top = '25px';
    gridAbs.style.left = '25px';
    gridAbs.style.width = '90px';
    gridAbs.style.height = '65px';
    gridAbs.style.backgroundColor = '#4CAF50';
    gridAbs.style.zIndex = '1';
    gridAbs.style.display = 'flex';
    gridAbs.style.alignItems = 'center';
    gridAbs.style.justifyContent = 'center';
    gridAbs.style.color = 'white';
    gridAbs.style.fontSize = '10px';
    grid.appendChild(gridAbs);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(gridAbs.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 25);

    grid.remove();
  });

  it('stacks multiple layers with different z-index values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';
    grid.style.width = '310px';
    grid.style.height = '210px';

    const zIndexes = [-1, 0, 1, 5, 10];
    zIndexes.forEach((z, i) => {
      const abs = document.createElement('div');
      abs.textContent = `Z:${z}`;
      abs.style.position = 'absolute';
      abs.style.top = `${20 + i * 20}px`;
      abs.style.left = `${20 + i * 20}px`;
      abs.style.width = '80px';
      abs.style.height = '60px';
      abs.style.backgroundColor = `hsl(${160 + i * 20}, 60%, 50%)`;
      abs.style.zIndex = String(z);
      abs.style.display = 'flex';
      abs.style.alignItems = 'center';
      abs.style.justifyContent = 'center';
      abs.style.color = 'white';
      abs.style.fontSize = '11px';
      grid.appendChild(abs);
    });

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Verify positioning
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(5);

    grid.remove();
  });
});
