describe('CSS Grid explicit track definition', () => {
  it('defines fixed pixel tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 150px 200px';
    grid.style.gridTemplateRows = '50px 80px';
    grid.style.gap = '0';
    grid.style.padding = '0';
    grid.style.backgroundColor = '#f0f0f0';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = i % 2 === 0 ? '#4CAF50' : '#2196F3';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateColumns).toBe('100px 150px 200px');
    expect(computed.gridTemplateRows).toBe('50px 80px');

    const firstItem = grid.children[0] as HTMLElement;
    const rect = firstItem.getBoundingClientRect();
    expect(rect.width).toBe(100);
    expect(rect.height).toBe(50);

    grid.remove();
  });

  it('defines em/rem unit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '10em 12em';
    grid.style.gridTemplateRows = '5em';
    grid.style.gap = '0';
    grid.style.fontSize = '16px';
    grid.style.backgroundColor = '#fafafa';

    const item1 = document.createElement('div');
    item1.textContent = 'Em Track';
    item1.style.backgroundColor = '#FF5722';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Em Track 2';
    item2.style.backgroundColor = '#9C27B0';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const firstItem = grid.children[0] as HTMLElement;
    const rect = firstItem.getBoundingClientRect();
    expect(rect.width).toBe(160); // 10em * 16px
    expect(rect.height).toBe(80); // 5em * 16px

    grid.remove();
  });

  it('defines percentage tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = '25% 50% 25%';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8eaf6';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${(i === 0 || i === 2) ? '25%' : '50%'}`;
      item.style.backgroundColor = ['#3F51B5', '#5C6BC0', '#7986CB'][i];
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
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(75, 0);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(150, 0);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(75, 0);

    grid.remove();
  });

  it('defines fractional (fr) unit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = '1fr 2fr 1fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i === 1 ? '2fr' : '1fr'}`;
      item.style.backgroundColor = ['#2196F3', '#1976D2', '#1565C0'][i];
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

    // 1fr should be ~75px, 2fr should be ~150px
    expect(widths[0]).toBeCloseTo(75, 0);
    expect(widths[1]).toBeCloseTo(150, 0);
    expect(widths[2]).toBeCloseTo(75, 0);

    grid.remove();
  });

  it('mixes fixed and flexible tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = '100px 1fr 2fr 80px';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const labels = ['100px', '1fr', '2fr', '80px'];
    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = labels[i];
      item.style.backgroundColor = ['#FF9800', '#FB8C00', '#F57C00', '#EF6C00'][i];
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
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[3].getBoundingClientRect().width).toBe(80);

    // Remaining space: 400 - 100 - 80 = 220px
    // Divided as 1fr:2fr = 73.33:146.67
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(73.33, 0);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(146.67, 0);

    grid.remove();
  });

  it('defines tracks with named lines', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = '[start] 100px [middle] 100px [end]';
    grid.style.gridTemplateRows = '[top] 80px [bottom]';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f1f8e9';

    const item1 = document.createElement('div');
    item1.textContent = 'Named Lines';
    item1.style.gridColumn = 'start / middle';
    item1.style.gridRow = 'top / bottom';
    item1.style.backgroundColor = '#8BC34A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Second';
    item2.style.gridColumn = 'middle / end';
    item2.style.backgroundColor = '#689F38';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const item1Rect = item1.getBoundingClientRect();
    expect(item1Rect.left).toBe(gridRect.left);
    expect(item1Rect.width).toBe(100);

    grid.remove();
  });

  it('handles duplicate line names', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '320px';
    grid.style.gridTemplateColumns = '[col] 100px [col] 100px [col] 100px [col]';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fce4ec';

    const item = document.createElement('div');
    item.textContent = 'Duplicate Names';
    item.style.gridColumn = 'col 2 / col 3'; // Second to third 'col' line
    item.style.backgroundColor = '#E91E63';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const itemRect = item.getBoundingClientRect();
    // Should span from second col (110px from left) to third col (220px from left)
    expect(itemRect.left - gridRect.left).toBeCloseTo(110, 0);
    expect(itemRect.width).toBe(100);

    grid.remove();
  });

  it('resolves auto track sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'auto auto';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.backgroundColor = '#9C27B0';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Longer Content Here';
    item2.style.backgroundColor = '#7B1FA2';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const rect1 = items[0].getBoundingClientRect();
    const rect2 = items[1].getBoundingClientRect();

    // Auto tracks should size to content
    expect(rect1.width).toBeGreaterThan(0);
    expect(rect2.width).toBeGreaterThan(rect1.width);

    grid.remove();
  });
});
