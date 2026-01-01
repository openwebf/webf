describe('CSS Grid mixed positioned and flow items', () => {
  it('combines regular grid items with absolute items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    // Regular grid items
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

    // Absolute item
    const absItem = document.createElement('div');
    absItem.textContent = 'Abs';
    absItem.style.position = 'absolute';
    absItem.style.top = '30px';
    absItem.style.right = '10px';
    absItem.style.width = '80px';
    absItem.style.height = '60px';
    absItem.style.backgroundColor = '#E91E63';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '11px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Regular items flow normally
    const items = Array.from(grid.children).slice(0, 4) as HTMLElement[];
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 110);

    // Absolute item positioned independently
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 30);

    grid.remove();
  });

  xit('absolute item does not affect grid item flow', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 120px)';
    grid.style.gridTemplateRows = 'repeat(3, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    // Absolute item first in source order
    const absItem = document.createElement('div');
    absItem.textContent = 'Abs First';
    absItem.style.position = 'absolute';
    absItem.style.top = '20px';
    absItem.style.left = '20px';
    absItem.style.width = '100px';
    absItem.style.height = '70px';
    absItem.style.backgroundColor = '#FF9800';
    absItem.style.zIndex = '10';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '10px';
    grid.appendChild(absItem);

    // Regular grid items
    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 25}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Regular items should fill all 6 cells (2x3 grid)
    const regularItems = Array.from(grid.children).slice(1) as HTMLElement[];
    expect(regularItems.length).toBe(6);

    // First regular item should be at grid start
    expect(regularItems[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    expect(regularItems[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);

    grid.remove();
  });

  it('mixes absolute and relatively positioned items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 140px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    // Regular grid item
    const item1 = document.createElement('div');
    item1.textContent = 'Regular';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Relatively positioned grid item
    const item2 = document.createElement('div');
    item2.textContent = 'Relative';
    item2.style.position = 'relative';
    item2.style.top = '10px';
    item2.style.left = '10px';
    item2.style.backgroundColor = '#9C27B0';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    // Absolute item
    const absItem = document.createElement('div');
    absItem.textContent = 'Absolute';
    absItem.style.position = 'absolute';
    absItem.style.bottom = '15px';
    absItem.style.right = '15px';
    absItem.style.width = '90px';
    absItem.style.height = '70px';
    absItem.style.backgroundColor = '#E91E63';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '10px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Relative item offset from its grid position
    const item2GridLeft = grid.getBoundingClientRect().left + 150; // col 2
    expect(item2.getBoundingClientRect().left).toBe(item2GridLeft + 10);

    grid.remove();
  });

  it('overlays absolute item on top of grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(3, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    // Fill grid with items
    for (let i = 0; i < 9; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    // Overlay absolute item
    const overlay = document.createElement('div');
    overlay.textContent = 'Overlay';
    overlay.style.position = 'absolute';
    overlay.style.top = '50%';
    overlay.style.left = '50%';
    overlay.style.transform = 'translate(-50%, -50%)';
    overlay.style.width = '140px';
    overlay.style.height = '100px';
    overlay.style.backgroundColor = 'rgba(233, 30, 99, 0.9)';
    overlay.style.display = 'flex';
    overlay.style.alignItems = 'center';
    overlay.style.justifyContent = 'center';
    overlay.style.color = 'white';
    overlay.style.fontSize = '13px';
    overlay.style.zIndex = '10';
    grid.appendChild(overlay);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Grid items continue to layout normally
    const items = Array.from(grid.children).slice(0, 9) as HTMLElement[];
    expect(items.length).toBe(9);

    grid.remove();
  });

  it('handles dynamic addition of absolute items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 130px)';
    grid.style.gridTemplateRows = 'repeat(2, 90px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    // Initial grid items
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 20}, 60%, 55%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();

    // Add absolute item dynamically
    const absItem = document.createElement('div');
    absItem.textContent = 'Added';
    absItem.style.position = 'absolute';
    absItem.style.top = '25px';
    absItem.style.right = '25px';
    absItem.style.width = '80px';
    absItem.style.height = '60px';
    absItem.style.backgroundColor = '#4CAF50';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '11px';
    grid.appendChild(absItem);

    await waitForFrame();
    await snapshot();

    // Grid items unchanged, absolute item positioned
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 25);

    grid.remove();
  });

  it('positions absolute items within explicitly placed grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    // Explicitly placed grid item
    const item = document.createElement('div');
    item.style.position = 'relative';
    item.style.gridColumn = '2 / 4';
    item.style.gridRow = '1 / 3';
    item.style.backgroundColor = '#9575CD';

    // Absolute child within item
    const absChild = document.createElement('div');
    absChild.textContent = 'Inside';
    absChild.style.position = 'absolute';
    absChild.style.inset = '15px';
    absChild.style.backgroundColor = '#7E57C2';
    absChild.style.display = 'flex';
    absChild.style.alignItems = 'center';
    absChild.style.justifyContent = 'center';
    absChild.style.color = 'white';
    absChild.style.fontSize = '11px';
    item.appendChild(absChild);

    grid.appendChild(item);

    // Regular auto-placed item
    const regularItem = document.createElement('div');
    regularItem.textContent = 'Auto';
    regularItem.style.backgroundColor = '#66BB6A';
    regularItem.style.display = 'flex';
    regularItem.style.alignItems = 'center';
    regularItem.style.justifyContent = 'center';
    regularItem.style.color = 'white';
    grid.appendChild(regularItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item spans 2x2: 100 + 10 + 100 = 210px width, 80 + 10 + 80 = 170px height
    expect(item.getBoundingClientRect().width).toBe(210);
    expect(item.getBoundingClientRect().height).toBe(170);

    // Absolute child inset by 15px
    expect(absChild.getBoundingClientRect().width).toBe(180); // 210 - 30
    expect(absChild.getBoundingClientRect().height).toBe(140); // 170 - 30

    grid.remove();
  });

  xit('handles fixed positioning within grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 130px)';
    grid.style.gridTemplateRows = 'repeat(2, 90px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    // Regular grid items
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${160 + i * 20}, 60%, 50%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    // Sticky positioned item (behaves like relative in grid)
    const stickyItem = document.createElement('div');
    stickyItem.textContent = 'Sticky';
    stickyItem.style.position = 'sticky';
    stickyItem.style.top = '0';
    stickyItem.style.backgroundColor = '#009688';
    stickyItem.style.display = 'flex';
    stickyItem.style.alignItems = 'center';
    stickyItem.style.justifyContent = 'center';
    stickyItem.style.color = 'white';
    stickyItem.style.fontSize = '11px';
    grid.appendChild(stickyItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Sticky item takes up grid cell
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);

    grid.remove();
  });
});
