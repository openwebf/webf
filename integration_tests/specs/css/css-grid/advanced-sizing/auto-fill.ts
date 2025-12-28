describe('CSS Grid auto-fill', () => {
  it('creates tracks with auto-fill and fixed size', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '350px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#42A5F5', '#66BB6A', '#FFA726', '#BA68C8', '#9575CD'][i];
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
    // Should fit 3 columns (350/100 = 3), wrapping to rows
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[2].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('creates empty tracks with auto-fill', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, 80px)';
    grid.style.gridTemplateRows = '70px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#2196F3', '#1E88E5'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should create tracks even if not all filled
    const items = Array.from(grid.children) as HTMLElement[];
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(80);
    });

    grid.remove();
  });

  it('uses auto-fill with minmax', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, minmax(100px, 1fr))';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '350px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0', '#8E24AA', '#7B1FA2'][i];
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
    // Should fit 3 columns at minimum (350/100 = 3)
    items.slice(0, 3).forEach(item => {
      expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(100);
    });

    grid.remove();
  });

  it('handles auto-fill with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, 90px)';
    grid.style.gridTemplateRows = '70px';
    grid.style.width = '300px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800', '#FB8C00'][i];
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
    // With gaps: 90 + 10 + 90 + 10 + 90 = 290px, fits 3 columns
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(90);
    });

    grid.remove();
  });

  it('handles auto-fill with small items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, minmax(60px, 1fr))';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '250px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
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
    // Should fit 4 columns (250/60 = 4), but only 3 items
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(60);
    });

    grid.remove();
  });
});
