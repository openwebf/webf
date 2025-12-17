describe('CSS Grid gaps', () => {
  it('applies row-gap', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 100px';
    grid.style.gridTemplateRows = '60px 60px';
    grid.style.rowGap = '20px';
    grid.style.columnGap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047', '#388E3C'][i];
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
    const item1Rect = items[0].getBoundingClientRect();
    const item3Rect = items[2].getBoundingClientRect();

    // Row gap should be 20px between rows
    expect(item3Rect.top - item1Rect.bottom).toBeCloseTo(20, 0);

    grid.remove();
  });

  it('applies column-gap', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 100px';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '20px';
    grid.style.rowGap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#42A5F5', '#2196F3'][i];
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
    const item1Rect = items[0].getBoundingClientRect();
    const item2Rect = items[1].getBoundingClientRect();

    // Column gap should be 20px between columns
    expect(item2Rect.left - item1Rect.right).toBeCloseTo(20, 0);

    grid.remove();
  });

  it('uses gap shorthand', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 100px';
    grid.style.gridTemplateRows = '60px 60px';
    grid.style.gap = '15px 25px'; // row-gap column-gap
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0', '#8E24AA'][i];
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
    const item1Rect = items[0].getBoundingClientRect();
    const item2Rect = items[1].getBoundingClientRect();
    const item3Rect = items[2].getBoundingClientRect();

    // Column gap should be 25px
    expect(item2Rect.left - item1Rect.right).toBeCloseTo(25, 0);

    // Row gap should be 15px
    expect(item3Rect.top - item1Rect.bottom).toBeCloseTo(15, 0);

    grid.remove();
  });

  it('uses gap shorthand with single value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 100px';
    grid.style.gridTemplateRows = '60px 60px';
    grid.style.gap = '20px'; // Both row and column gap
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
    const item1Rect = items[0].getBoundingClientRect();
    const item2Rect = items[1].getBoundingClientRect();
    const item3Rect = items[2].getBoundingClientRect();

    // Both gaps should be 20px
    expect(item2Rect.left - item1Rect.right).toBeCloseTo(20, 0);
    expect(item3Rect.top - item1Rect.bottom).toBeCloseTo(20, 0);

    grid.remove();
  });

  it('handles percentage gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.height = '300px';
    grid.style.gridTemplateColumns = '1fr 1fr';
    grid.style.gridTemplateRows = '1fr 1fr';
    grid.style.rowGap = '5%'; // 5% of 300px = 15px
    grid.style.columnGap = '5%'; // 5% of 400px = 20px
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7', '#5E35B1'][i];
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
    const item1Rect = items[0].getBoundingClientRect();
    const item2Rect = items[1].getBoundingClientRect();
    const item3Rect = items[2].getBoundingClientRect();

    // Column gap: 5% of 400px = 20px
    expect(item2Rect.left - item1Rect.right).toBeCloseTo(20, 0);

    // Row gap: 5% of 300px = 15px
    expect(item3Rect.top - item1Rect.bottom).toBeCloseTo(15, 0);

    grid.remove();
  });

  it('uses calc() in gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 100px';
    grid.style.gridTemplateRows = '60px 60px';
    grid.style.rowGap = 'calc(10px + 5px)'; // = 15px
    grid.style.columnGap = 'calc(20px - 5px)'; // = 15px
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
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
    const item1Rect = items[0].getBoundingClientRect();
    const item2Rect = items[1].getBoundingClientRect();
    const item3Rect = items[2].getBoundingClientRect();

    // Both gaps should resolve to 15px
    expect(item2Rect.left - item1Rect.right).toBeCloseTo(15, 0);
    expect(item3Rect.top - item1Rect.bottom).toBeCloseTo(15, 0);

    grid.remove();
  });

  it('combines gaps with repeat()', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fce4ec';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#F48FB1', '#F06292', '#EC407A', '#E91E63', '#D81B60', '#C2185B'][i];
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

    // Check gaps between first row items
    const item1Rect = items[0].getBoundingClientRect();
    const item2Rect = items[1].getBoundingClientRect();
    const item4Rect = items[3].getBoundingClientRect();

    expect(item2Rect.left - item1Rect.right).toBeCloseTo(10, 0);
    expect(item4Rect.top - item1Rect.bottom).toBeCloseTo(10, 0);

    grid.remove();
  });

  it('excludes gaps from fr calculation', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = '1fr 1fr 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '20px';
    grid.style.backgroundColor = '#fff9c4';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = '1fr';
      item.style.backgroundColor = ['#FFEB3B', '#FDD835', '#FBC02D'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Available for fr: 400 - 40 (gaps) = 360px
    // Each fr: 360 / 3 = 120px
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBeCloseTo(120, 0);
    });

    grid.remove();
  });

  it('handles zero gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 100px';
    grid.style.gridTemplateRows = '60px 60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8eaf6';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#7C4DFF', '#651FFF', '#6200EA', '#5E35B1'][i];
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
    const item1Rect = items[0].getBoundingClientRect();
    const item2Rect = items[1].getBoundingClientRect();
    const item3Rect = items[2].getBoundingClientRect();

    // No gaps, items should be adjacent
    expect(item2Rect.left - item1Rect.right).toBeCloseTo(0, 0);
    expect(item3Rect.top - item1Rect.bottom).toBeCloseTo(0, 0);

    grid.remove();
  });

  it('handles large gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '80px 80px';
    grid.style.gridTemplateRows = '50px 50px';
    grid.style.gap = '40px';
    grid.style.backgroundColor = '#f1f8e9';
    grid.style.padding = '10px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#9CCC65', '#8BC34A', '#7CB342', '#689F38'][i];
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
    const item1Rect = items[0].getBoundingClientRect();
    const item2Rect = items[1].getBoundingClientRect();
    const item3Rect = items[2].getBoundingClientRect();

    // Large gaps
    expect(item2Rect.left - item1Rect.right).toBeCloseTo(40, 0);
    expect(item3Rect.top - item1Rect.bottom).toBeCloseTo(40, 0);

    grid.remove();
  });
});
