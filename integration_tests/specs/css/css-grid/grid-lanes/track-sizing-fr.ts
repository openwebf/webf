describe('CSS Grid fractional (fr) units', () => {
  it('distributes space with single fr', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = '1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const item = document.createElement('div');
    item.textContent = '1fr fills space';
    item.style.backgroundColor = '#66BB6A';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    expect(itemRect.width).toBe(300);

    grid.remove();
  });

  it('distributes space with multiple fr values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = '1fr 2fr 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = i === 1 ? '2fr' : '1fr';
      item.style.backgroundColor = ['#42A5F5', '#2196F3', '#1E88E5'][i];
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
    const widths = items.map(item => item.getBoundingClientRect().width);

    // Total: 4fr (1fr + 2fr + 1fr)
    // 400px / 4 = 100px per fr
    expect(widths[0]).toBeCloseTo(100, 0); // 1fr = 100px
    expect(widths[1]).toBeCloseTo(200, 0); // 2fr = 200px
    expect(widths[2]).toBeCloseTo(100, 0); // 1fr = 100px

    grid.remove();
  });

  it('combines fr with fixed tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = '100px 1fr 80px';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['100px', '1fr', '80px'][i];
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0'][i];
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
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[2].getBoundingClientRect().width).toBe(80);

    // Fr gets remaining space: 400 - 100 - 80 = 220px
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(220, 0);

    grid.remove();
  });

  it('combines fr with percentage tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = '25% 1fr 2fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['25%', '1fr', '2fr'][i];
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800'][i];
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
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(100, 0); // 25% of 400px

    // Remaining: 400 - 100 = 300px
    // Divided as 1fr:2fr = 100:200
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(100, 0);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(200, 0);

    grid.remove();
  });

  it('calculates fr with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = '1fr 2fr 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '20px';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = i === 1 ? '2fr' : '1fr';
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

    // Available space: 400 - 40 (gaps) = 360px
    // Divided as 4fr total: 360 / 4 = 90px per fr
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(90, 0); // 1fr
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(180, 0); // 2fr
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(90, 0); // 1fr

    grid.remove();
  });

  it('distributes remaining space correctly', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '500px';;
    grid.style.gridTemplateColumns = '100px 80px 1fr 2fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = ['100px', '80px', '1fr', '2fr'][i];
      item.style.backgroundColor = ['#4DB6AC', '#26A69A', '#009688', '#00796B'][i];
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
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(80);

    // Remaining: 500 - 100 - 80 - 30 (gaps) = 290px
    // Divided as 1fr:2fr = 96.67:193.33
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(96.67, 0);
    expect(items[3].getBoundingClientRect().width).toBeCloseTo(193.33, 0);

    grid.remove();
  });

  it('handles fr in minmax()', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = 'minmax(100px, 1fr) minmax(80px, 2fr)';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#fce4ec';

    const item1 = document.createElement('div');
    item1.textContent = 'minmax(100px, 1fr)';
    item1.style.backgroundColor = '#F06292';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'minmax(80px, 2fr)';
    item2.style.backgroundColor = '#EC407A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Available: 400 - 10 = 390px
    // Divided as 1fr:2fr = 130:260
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(80);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('handles fractional fr values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = '0.5fr 1.5fr 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['0.5fr', '1.5fr', '1fr'][i];
      item.style.backgroundColor = ['#FFEB3B', '#FDD835', '#FBC02D'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.fontSize = '11px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Total: 3fr (0.5 + 1.5 + 1)
    // 300px / 3 = 100px per fr
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(50, 0); // 0.5fr
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(150, 0); // 1.5fr
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(100, 0); // 1fr

    grid.remove();
  });

  it('handles zero fr', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = '0fr 1fr 2fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8eaf6';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['0fr', '1fr', '2fr'][i];
      item.style.backgroundColor = ['#7C4DFF', '#651FFF', '#6200EA'][i];
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

    // 0fr track should collapse to minimum size
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(0);

    // Remaining space divided as 1fr:2fr
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(items[1].getBoundingClientRect().width);

    grid.remove();
  });

  it('distributes unequal fr values correctly', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = '1fr 3fr 2fr 4fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f1f8e9';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = ['1fr', '3fr', '2fr', '4fr'][i];
      item.style.backgroundColor = ['#9CCC65', '#8BC34A', '#7CB342', '#689F38'][i];
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

    // Total: 10fr
    // 400px / 10 = 40px per fr
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(40, 0); // 1fr
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(120, 0); // 3fr
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(80, 0); // 2fr
    expect(items[3].getBoundingClientRect().width).toBeCloseTo(160, 0); // 4fr

    grid.remove();
  });
});
