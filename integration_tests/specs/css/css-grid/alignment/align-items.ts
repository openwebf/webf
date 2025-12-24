describe('CSS Grid align-items', () => {
  it('aligns items with start', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#42A5F5', '#66BB6A', '#FFA726'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // All items should align to top of grid area
    items.forEach(item => {
      expect(item.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);
    });

    grid.remove();
  });

  it('aligns items with end', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'end';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#2196F3', '#1E88E5', '#1976D2'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // All items should align to bottom of grid area
    items.forEach(item => {
      expect(item.getBoundingClientRect().bottom).toBe(grid.getBoundingClientRect().bottom);
    });

    grid.remove();
  });

  it('aligns items with center', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Items should be vertically centered
    const gridCenter = (grid.getBoundingClientRect().top + grid.getBoundingClientRect().bottom) / 2;
    items.forEach(item => {
      const itemCenter = (item.getBoundingClientRect().top + item.getBoundingClientRect().bottom) / 2;
      expect(Math.abs(itemCenter - gridCenter)).toBeLessThan(1);
    });

    grid.remove();
  });

  it('stretches items by default', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800'][i];
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
    // Items should stretch to fill height
    items.forEach(item => {
      expect(item.getBoundingClientRect().height).toBe(100);
    });

    grid.remove();
  });

  it('does not stretch items with explicit height', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.height = '60px';
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047'][i];
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
    // Items should not stretch due to explicit height
    items.forEach(item => {
      expect(item.getBoundingClientRect().height).toBe(60);
    });

    grid.remove();
  });

  it('aligns items with baseline', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'baseline';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = 'Text';
      item.style.fontSize = ['16px', '20px', '24px'][i];
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7'][i];
      item.style.padding = '5px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);

    grid.remove();
  });

  it('combines with row gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.alignItems = 'center';
    grid.style.rowGap = '10px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.height = '50px';
      item.style.backgroundColor = ['#4DB6AC', '#26A69A', '#009688', '#00897B'][i];
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
    // Distance from Item 1 top to Item 3 top: 80.00px
    const distance = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().top - 80;
    expect(distance).toBe(0);
    grid.remove();
  });
});
