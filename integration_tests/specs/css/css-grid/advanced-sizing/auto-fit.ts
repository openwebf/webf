describe('CSS Grid auto-fit', () => {
  it('collapses empty tracks with auto-fit', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fit, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '350px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#42A5F5', '#66BB6A'][i];
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
    // auto-fit collapses empty tracks, items may stretch
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(100);
    });

    grid.remove();
  });

  it('uses auto-fit with minmax to stretch items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fit, minmax(100px, 1fr))';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '350px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Item ${i + 1}`;
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

    const items = Array.from(grid.children) as HTMLElement[];
    // Items should stretch to fill available space
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(100);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(100);

    grid.remove();
  });

  it('handles auto-fit with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fit, minmax(80px, 1fr))';
    grid.style.gridTemplateRows = '70px';
    grid.style.width = '300px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0'][i];
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
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(80);
    });

    grid.remove();
  });

  it('compares auto-fit vs auto-fill behavior', async () => {
    const grid1 = document.createElement('div');
    grid1.style.display = 'grid';
    grid1.style.gridTemplateColumns = 'repeat(auto-fill, 100px)';
    grid1.style.gridTemplateRows = '70px';
    grid1.style.width = '350px';
    grid1.style.gap = '0';
    grid1.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Fill ${i + 1}`;
      item.style.backgroundColor = ['#FFB74D', '#FFA726'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '11px';
      grid1.appendChild(item);
    }

    document.body.appendChild(grid1);
    await waitForFrame();
    await snapshot();

    const fillItems = Array.from(grid1.children) as HTMLElement[];
    expect(fillItems[0].getBoundingClientRect().width).toBe(100);

    grid1.remove();

    const grid2 = document.createElement('div');
    grid2.style.display = 'grid';
    grid2.style.gridTemplateColumns = 'repeat(auto-fit, minmax(100px, 1fr))';
    grid2.style.gridTemplateRows = '70px';
    grid2.style.width = '350px';
    grid2.style.gap = '0';
    grid2.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Fit ${i + 1}`;
      item.style.backgroundColor = ['#66BB6A', '#4CAF50'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '11px';
      grid2.appendChild(item);
    }

    document.body.appendChild(grid2);
    await waitForFrame();
    await snapshot();

    const fitItems = Array.from(grid2.children) as HTMLElement[];
    // auto-fit items should be wider (stretched)
    expect(fitItems[0].getBoundingClientRect().width).toBeGreaterThan(100);

    grid2.remove();
  });

  xit('handles auto-fit with single item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fit, minmax(100px, 1fr))';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const item = document.createElement('div');
    item.textContent = 'Single item';
    item.style.backgroundColor = '#9575CD';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Single item should stretch to fill available space
    expect(item.getBoundingClientRect().width).toBe(300);

    grid.remove();
  });
});
