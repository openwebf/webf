describe('CSS Grid justify-items', () => {
  it('aligns items with start', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'start';
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
    // Items should align to left edge of their grid areas
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 100);

    grid.remove();
  });

  it('aligns items with end', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'end';
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
    // Items should align to right edge of their grid areas
    expect(items[0].getBoundingClientRect().right).toBe(grid.getBoundingClientRect().left + 100);
    expect(items[1].getBoundingClientRect().right).toBe(grid.getBoundingClientRect().left + 200);

    grid.remove();
  });

  it('aligns items with center', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'center';
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
    // Items should be centered in their grid areas
    const item0Center = (items[0].getBoundingClientRect().left + items[0].getBoundingClientRect().right) / 2;
    const area0Center = grid.getBoundingClientRect().left + 50;
    expect(Math.abs(item0Center - area0Center)).toBeLessThan(1);

    grid.remove();
  });

  it('aligns items with stretch (default)', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'stretch';
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
    // Items should stretch to fill their grid areas
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(100);
    });

    grid.remove();
  });

  it('does not stretch items with explicit width', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.width = '60px';
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
    // Items should not stretch due to explicit width
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(60);
    });

    grid.remove();
  });

  it('aligns items with different sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const widths = [40, 60, 80];
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${widths[i]}px`;
      item.style.width = `${widths[i]}px`;
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7'][i];
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
    // Each item should be centered in its grid area
    items.forEach((item, i) => {
      expect(item.getBoundingClientRect().width).toBe(widths[i]);
    });

    grid.remove();
  });

  it('combines with column gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'center';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.width = '70px';
      item.style.backgroundColor = ['#4DB6AC', '#26A69A', '#009688'][i];
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
    // Check gaps are correct
    const gap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().left - 100;
    expect(gap).toBe(10);

    grid.remove();
  });
});
