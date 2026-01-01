describe('CSS Grid absolute positioning basics', () => {
  it('positions absolute item relative to grid container', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.width = '320px';
    grid.style.height = '150px';

    // Regular grid item
    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Absolute positioned item
    const absItem = document.createElement('div');
    absItem.textContent = 'Abs';
    absItem.style.position = 'absolute';
    absItem.style.top = '20px';
    absItem.style.left = '30px';
    absItem.style.width = '80px';
    absItem.style.height = '60px';
    absItem.style.backgroundColor = '#E91E63';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '12px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Absolute item positioned relative to grid container
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 20);
    expect(absItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 30);

    grid.remove();
  });

  it('absolute item does not participate in grid layout', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 30}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    // Absolute item - should not take up grid cell
    const absItem = document.createElement('div');
    absItem.textContent = 'Abs';
    absItem.style.position = 'absolute';
    absItem.style.top = '10px';
    absItem.style.right = '10px';
    absItem.style.width = '60px';
    absItem.style.height = '50px';
    absItem.style.backgroundColor = '#FF9800';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '11px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // First three items should layout normally (2 cols)
    const items = Array.from(grid.children).slice(0, 3) as HTMLElement[];
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 110);
    expect(items[2].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 80);

    grid.remove();
  });

  it('absolute item with all offsets stretches within grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';
    grid.style.width = '210px';
    grid.style.height = '150px';

    const absItem = document.createElement('div');
    absItem.textContent = 'Stretched';
    absItem.style.position = 'absolute';
    absItem.style.top = '10px';
    absItem.style.left = '10px';
    absItem.style.right = '10px';
    absItem.style.bottom = '10px';
    absItem.style.backgroundColor = '#BA68C8';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '11px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should stretch to fill grid minus offsets
    expect(absItem.getBoundingClientRect().width).toBe(190); // 210 - 10 - 10
    expect(absItem.getBoundingClientRect().height).toBe(130); // 150 - 10 - 10

    grid.remove();
  });

  it('centers absolute item with auto margins', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.width = '300px';
    grid.style.height = '200px';

    const absItem = document.createElement('div');
    absItem.textContent = 'Centered';
    absItem.style.position = 'absolute';
    absItem.style.top = '0';
    absItem.style.left = '0';
    absItem.style.right = '0';
    absItem.style.bottom = '0';
    absItem.style.width = '120px';
    absItem.style.height = '80px';
    absItem.style.margin = 'auto';
    absItem.style.backgroundColor = '#FFB74D';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '10px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should be centered in grid
    const gridRect = grid.getBoundingClientRect();
    const itemRect = absItem.getBoundingClientRect();
    const centerX = gridRect.left + gridRect.width / 2;
    const centerY = gridRect.top + gridRect.height / 2;

    expect(Math.round(itemRect.left + itemRect.width / 2)).toBe(Math.round(centerX));
    expect(Math.round(itemRect.top + itemRect.height / 2)).toBe(Math.round(centerY));

    grid.remove();
  });

  it('stacks multiple absolute items by source order', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.width = '210px';
    grid.style.height = '150px';

    // First absolute item
    const abs1 = document.createElement('div');
    abs1.textContent = '1';
    abs1.style.position = 'absolute';
    abs1.style.top = '20px';
    abs1.style.left = '20px';
    abs1.style.width = '80px';
    abs1.style.height = '60px';
    abs1.style.backgroundColor = '#66BB6A';
    abs1.style.display = 'flex';
    abs1.style.alignItems = 'center';
    abs1.style.justifyContent = 'center';
    abs1.style.color = 'white';
    grid.appendChild(abs1);

    // Second absolute item (overlapping)
    const abs2 = document.createElement('div');
    abs2.textContent = '2';
    abs2.style.position = 'absolute';
    abs2.style.top = '40px';
    abs2.style.left = '40px';
    abs2.style.width = '80px';
    abs2.style.height = '60px';
    abs2.style.backgroundColor = '#4CAF50';
    abs2.style.display = 'flex';
    abs2.style.alignItems = 'center';
    abs2.style.justifyContent = 'center';
    abs2.style.color = 'white';
    grid.appendChild(abs2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Both should be positioned correctly
    expect(abs1.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 20);
    expect(abs2.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 40);

    grid.remove();
  });

  it('absolute item with percentage offsets', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';
    grid.style.width = '300px';
    grid.style.height = '200px';

    const absItem = document.createElement('div');
    absItem.textContent = '50%';
    absItem.style.position = 'absolute';
    absItem.style.top = '25%';
    absItem.style.left = '25%';
    absItem.style.width = '50%';
    absItem.style.height = '50%';
    absItem.style.backgroundColor = '#9575CD';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '12px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // 25% of 300px = 75px, 25% of 200px = 50px
    expect(absItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 75);
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 50);
    // 50% of 300px = 150px, 50% of 200px = 100px
    expect(absItem.getBoundingClientRect().width).toBe(150);
    expect(absItem.getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  xit('absolute item ignores grid properties', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';
    grid.style.width = '320px';

    const absItem = document.createElement('div');
    absItem.textContent = 'Ignored';
    absItem.style.position = 'absolute';
    absItem.style.top = '15px';
    absItem.style.left = '15px';
    absItem.style.width = '100px';
    absItem.style.height = '70px';
    absItem.style.gridColumn = '2'; // Should be ignored
    absItem.style.gridRow = '2'; // Should be ignored
    absItem.style.backgroundColor = '#4DB6AC';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '10px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should use absolute positioning, not grid placement
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 15);
    expect(absItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 15);

    grid.remove();
  });
});
