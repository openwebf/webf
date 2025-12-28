describe('CSS Grid implicit tracks with gaps', () => {
  it('applies row gaps to implicit rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.rowGap = '15px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 6; i++) {
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
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Gap between row 1 and row 2
    const gap1 = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(gap1).toBe(15);
    // Gap between row 2 and row 3
    const gap2 = items[4].getBoundingClientRect().top - items[2].getBoundingClientRect().bottom;
    expect(gap2).toBe(15);

    grid.remove();
  });

  it('applies column gaps to implicit columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = '110px';
    grid.style.rowGap = '10px';
    grid.style.columnGap = '15px';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 30}, 70%, 60%)`;
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
    // Gap between column 1 and column 2
    const gap1 = items[2].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(gap1).toBe(15);
    // Gap between column 2 and column 3
    const gap2 = items[4].getBoundingClientRect().left - items[2].getBoundingClientRect().right;
    expect(gap2).toBe(15);

    grid.remove();
  });

  it('applies gaps with mixed explicit and implicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px 65px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '12px';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 8; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 20}, 70%, 60%)`;
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
    // Gap between explicit rows
    const explicitGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(explicitGap).toBe(12);
    // Gap between explicit row 2 and implicit row 3
    const mixedGap = items[4].getBoundingClientRect().top - items[2].getBoundingClientRect().bottom;
    expect(mixedGap).toBe(12);
    // Gap between implicit rows
    const implicitGap = items[6].getBoundingClientRect().top - items[4].getBoundingClientRect().bottom;
    expect(implicitGap).toBe(12);

    grid.remove();
  });

  it('uses gap shorthand with implicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '20px 10px'; // row-gap column-gap
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
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
    // Row gap
    const rowGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(rowGap).toBe(20);
    // Column gap
    const colGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(colGap).toBe(10);

    grid.remove();
  });

  it('calculates fr units with gaps in implicit grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = '1fr';
    grid.style.width = '450px';
    grid.style.columnGap = '10px';
    grid.style.rowGap = '5px';
    grid.style.backgroundColor = '#e8f5e9';

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
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // First column: 100px
    expect(items[0].getBoundingClientRect().width).toBe(100);
    // Remaining: 450 - 100 - 10 - 10 = 330px for 2 columns = 165px each
    expect(items[2].getBoundingClientRect().width).toBe(165);
    expect(items[4].getBoundingClientRect().width).toBe(165);

    grid.remove();
  });

  it('handles percentage gaps with implicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.rowGap = '5%';
    grid.style.columnGap = '5%';
    grid.style.width = '300px';
    grid.style.height = '400px';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 65%)`;
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
    // Column gap: 5% of 300px = 15px
    const colGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(colGap).toBe(15);
    // Row gap: 5% of 400px = 20px
    const rowGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(rowGap).toBe(20);

    grid.remove();
  });

  it('applies gaps with spanning items in implicit grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    // Spanning item across implicit rows
    const item1 = document.createElement('div');
    item1.textContent = 'Span';
    item1.style.gridColumn = '1 / span 2';
    item1.style.gridRow = '2 / span 2';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${160 + i * 15}, 60%, 50%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Spanning item: 2 rows (70px each) + 1 gap (10px) = 150px
    expect(item1.getBoundingClientRect().height).toBe(150);
    // Spanning item: 2 columns (100px each) + 1 gap (10px) = 210px
    expect(item1.getBoundingClientRect().width).toBe(210);

    grid.remove();
  });
});
