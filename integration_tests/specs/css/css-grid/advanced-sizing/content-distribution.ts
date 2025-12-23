describe('CSS Grid content distribution', () => {
  it('distributes extra space with fr units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 1fr 2fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '400px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['100px', '1fr', '2fr'][i];
      item.style.backgroundColor = ['#42A5F5', '#66BB6A', '#FFA726'][i];
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
    // 400px - 100px = 300px to distribute (1fr + 2fr = 3fr)
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(100); // 1/3 of 300px
    expect(items[2].getBoundingClientRect().width).toBe(200); // 2/3 of 300px

    grid.remove();
  });

  xit('handles space distribution with minmax', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(100px, 1fr) minmax(150px, 2fr)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '450px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Track ${i + 1}`;
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
    // After minimums (100 + 150 = 250), 200px remains
    // Distributed as 1fr:2fr (1/3 vs 2/3)
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(167, 0); // 100 + 67
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(283, 0); // 150 + 133

    grid.remove();
  });

  it('distributes space with auto tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto 1fr auto';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '400px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Auto 1';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '1fr';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Auto 2';
    item3.style.backgroundColor = '#9C27B0';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    item3.style.fontSize = '11px';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Auto tracks take minimum space, fr gets remaining
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles unequal fr distribution', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '0.5fr 1fr 1.5fr 2fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '500px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = ['0.5fr', '1fr', '1.5fr', '2fr'][i];
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800', '#FB8C00'][i];
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
    // Total: 5fr, 500px / 5 = 100px per fr
    expect(items[0].getBoundingClientRect().width).toBe(50);   // 0.5fr
    expect(items[1].getBoundingClientRect().width).toBe(100);  // 1fr
    expect(items[2].getBoundingClientRect().width).toBe(150);  // 1.5fr
    expect(items[3].getBoundingClientRect().width).toBe(200);  // 2fr

    grid.remove();
  });

  it('distributes remaining space after fixed tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '80px 20% 1fr 2fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '480px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = ['80px', '20%', '1fr', '2fr'][i];
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047', '#388E3C'][i];
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
    // 80px + 96px (20%) = 176px, remaining 304px for 3fr
    expect(items[0].getBoundingClientRect().width).toBe(80);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(96, 0);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(101, 0); // ~1/3 of 304
    expect(items[3].getBoundingClientRect().width).toBeCloseTo(203, 0); // ~2/3 of 304

    grid.remove();
  });

  it('handles content distribution with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr 2fr 1fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '400px';
    grid.style.columnGap = '20px';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['1fr', '2fr', '1fr'][i];
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
    // 400px - 40px (gaps) = 360px, distributed as 1:2:1
    expect(items[0].getBoundingClientRect().width).toBe(90);  // 1/4 of 360
    expect(items[1].getBoundingClientRect().width).toBe(180); // 2/4 of 360
    expect(items[2].getBoundingClientRect().width).toBe(90);  // 1/4 of 360

    grid.remove();
  });
});
