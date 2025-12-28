describe('CSS Grid dynamic add/remove items', () => {
  it('adds new items to grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    // Initial items
    for (let i = 0; i < 3; i++) {
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

    // Add more items dynamically
    for (let i = 3; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${i * 60}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(6);

    grid.remove();
  });

  it('removes items from grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    // Create initial items
    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.className = `item-${i}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();

    // Remove items
    const itemToRemove1 = grid.querySelector('.item-1');
    const itemToRemove2 = grid.querySelector('.item-4');
    itemToRemove1?.remove();
    itemToRemove2?.remove();

    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);

    grid.remove();
  });

  it('reflows grid when items are added', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    // Start with 2 items
    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 30}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();

    const firstRect1 = grid.children[0].getBoundingClientRect();

    // Add 2 more items
    for (let i = 2; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 30}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    await waitForFrame();
    await snapshot();

    const firstRect2 = grid.children[0].getBoundingClientRect();
    // First item should remain in same position
    expect(firstRect1.top).toBe(firstRect2.top);
    expect(firstRect1.left).toBe(firstRect2.left);

    grid.remove();
  });

  it('inserts item at specific position', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    // Create items
    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();

    // Insert new item at position 2
    const newItem = document.createElement('div');
    newItem.textContent = 'NEW';
    newItem.style.backgroundColor = '#FF5722';
    newItem.style.display = 'flex';
    newItem.style.alignItems = 'center';
    newItem.style.justifyContent = 'center';
    newItem.style.color = 'white';
    newItem.style.fontSize = '11px';
    grid.insertBefore(newItem, grid.children[2]);

    await waitForFrame();
    await snapshot();

    expect(grid.children[2].textContent).toBe('NEW');
    expect(grid.children.length).toBe(6);

    grid.remove();
  });

  it('removes all items from grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.minHeight = '150px';

    for (let i = 0; i < 6; i++) {
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

    // Remove all items
    while (grid.firstChild) {
      grid.removeChild(grid.firstChild);
    }

    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(0);
    // Grid should still maintain its size
    expect(grid.getBoundingClientRect().height).toBeGreaterThanOrEqual(150);

    grid.remove();
  });

  it('replaces items in grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.className = `item-${i}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();

    // Replace item at position 3
    const oldItem = grid.children[3];
    const newItem = document.createElement('div');
    newItem.textContent = 'REPLACED';
    newItem.style.backgroundColor = '#E91E63';
    newItem.style.display = 'flex';
    newItem.style.alignItems = 'center';
    newItem.style.justifyContent = 'center';
    newItem.style.color = 'white';
    newItem.style.fontSize = '10px';
    grid.replaceChild(newItem, oldItem);

    await waitForFrame();
    await snapshot();

    expect(grid.children[3].textContent).toBe('REPLACED');
    expect(grid.children.length).toBe(6);

    grid.remove();
  });

  it('dynamically adds items with explicit placement', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

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

    document.body.appendChild(grid);
    await waitForFrame();

    // Add item with explicit placement
    const explicitItem = document.createElement('div');
    explicitItem.textContent = 'Explicit';
    explicitItem.style.gridColumn = '2';
    explicitItem.style.gridRow = '2';
    explicitItem.style.backgroundColor = '#00BCD4';
    explicitItem.style.display = 'flex';
    explicitItem.style.alignItems = 'center';
    explicitItem.style.justifyContent = 'center';
    explicitItem.style.color = 'white';
    explicitItem.style.fontSize = '11px';
    grid.appendChild(explicitItem);

    await waitForFrame();
    await snapshot();

    // Check explicit item is in correct position
    expect(explicitItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 110); // 100 + 10 gap
    expect(explicitItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 80); // 70 + 10 gap

    grid.remove();
  });
});
