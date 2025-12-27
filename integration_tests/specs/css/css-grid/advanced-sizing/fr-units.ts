describe('CSS Grid fractional (fr) units', () => {
  it('distributes space with single fr unit', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = '1fr';
    item.style.backgroundColor = '#42A5F5';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBe(300);

    grid.remove();
  });

  it('distributes space equally with multiple fr units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr 1fr 1fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = '1fr';
      item.style.backgroundColor = ['#2196F3', '#1E88E5', '#1976D2'][i];
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
      expect(item.getBoundingClientRect().width).toBe(100);
    });

    grid.remove();
  });

  it('distributes space proportionally with different fr values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr 2fr 3fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '360px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}fr`;
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
    // Total: 1+2+3 = 6fr, 360px / 6 = 60px per fr
    expect(items[0].getBoundingClientRect().width).toBe(60);  // 1fr
    expect(items[1].getBoundingClientRect().width).toBe(120); // 2fr
    expect(items[2].getBoundingClientRect().width).toBe(180); // 3fr

    grid.remove();
  });

  it('combines fr units with fixed sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 1fr 2fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '400px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['100px', '1fr', '2fr'][i];
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '12px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // 400px - 100px = 300px remaining, divided into 3fr
    expect(items[0].getBoundingClientRect().width).toBe(100); // Fixed
    expect(items[1].getBoundingClientRect().width).toBe(100); // 1fr = 100px
    expect(items[2].getBoundingClientRect().width).toBe(200); // 2fr = 200px

    grid.remove();
  });

  it('combines fr units with percentages', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '20% 1fr 2fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['20%', '1fr', '2fr'][i];
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '12px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // 20% of 300px = 60px, remaining 240px divided into 3fr
    expect(items[0].getBoundingClientRect().width).toBe(60);  // 20%
    expect(items[1].getBoundingClientRect().width).toBe(80);  // 1fr
    expect(items[2].getBoundingClientRect().width).toBe(160); // 2fr

    grid.remove();
  });

  it('handles fr units with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr 1fr 1fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '320px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = '1fr';
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7'][i];
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
    // 320px - 20px (gaps) = 300px, divided into 3fr
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(100);
    });

    grid.remove();
  });

  it('distributes fr units in rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '150px';
    grid.style.gridTemplateRows = '1fr 2fr 1fr';
    grid.style.height = '200px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['1fr', '2fr', '1fr'][i];
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
    // Total: 4fr, 200px / 4 = 50px per fr
    expect(items[0].getBoundingClientRect().height).toBe(50);  // 1fr
    expect(items[1].getBoundingClientRect().height).toBe(100); // 2fr
    expect(items[2].getBoundingClientRect().height).toBe(50);  // 1fr

    grid.remove();
  });

  it('uses fr units in grid-auto-rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '50px';
    grid.style.gridAutoRows = '1fr';
    grid.style.height = '250px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047', '#388E3C', '#2E7D32', '#1B5E20'][i];
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
    // First row: 50px explicit
    expect(items[0].getBoundingClientRect().height).toBe(50);
    // Remaining space (200px) divided by 2 implicit rows = 100px each
    expect(items[2].getBoundingClientRect().height).toBe(100);
    expect(items[4].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('handles fractional fr values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '0.5fr 1fr 1.5fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['0.5fr', '1fr', '1.5fr'][i];
      item.style.backgroundColor = ['#F06292', '#EC407A', '#E91E63'][i];
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
    // Total: 3fr, 300px / 3 = 100px per fr
    expect(items[0].getBoundingClientRect().width).toBe(50);  // 0.5fr
    expect(items[1].getBoundingClientRect().width).toBe(100); // 1fr
    expect(items[2].getBoundingClientRect().width).toBe(150); // 1.5fr

    grid.remove();
  });

  it('handles fr units with auto tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto 1fr 2fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '350px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    const item1 = document.createElement('div');
    item1.textContent = 'Auto';
    item1.style.backgroundColor = '#FFEB3B';
    item1.style.padding = '10px';
    item1.style.whiteSpace = 'nowrap';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '1fr';
    item2.style.backgroundColor = '#FDD835';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = '2fr';
    item3.style.backgroundColor = '#FBC02D';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Auto takes minimum space, remaining divided into 3fr
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });
});
