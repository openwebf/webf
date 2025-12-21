describe('CSS Grid auto-placement algorithm', () => {
  it('uses sparse packing by default (row flow)', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    // Item spanning 2 columns
    const item1 = document.createElement('div');
    item1.textContent = 'Span 2';
    item1.style.gridColumnEnd = 'span 2';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    // Regular item
    const item2 = document.createElement('div');
    item2.textContent = '1';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    // Another spanning item (won't fit on first row, moves to second)
    const item3 = document.createElement('div');
    item3.textContent = 'Span 3';
    item3.style.gridColumnEnd = 'span 3';
    item3.style.backgroundColor = '#FFA726';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    item3.style.fontSize = '11px';
    grid.appendChild(item3);

    // Regular item (sparse packing - placed after the spanning item)
    const item4 = document.createElement('div');
    item4.textContent = '2';
    item4.style.backgroundColor = '#BA68C8';
    item4.style.display = 'flex';
    item4.style.alignItems = 'center';
    item4.style.justifyContent = 'center';
    item4.style.color = 'white';
    grid.appendChild(item4);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: first row, columns 1-2
    expect(items[0].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);

    // Item 2: first row, column 3
    expect(items[1].getBoundingClientRect().width).toBe(70);
    expect(items[1].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 140);

    // Item 3: second row (sparse packing - doesn't fit in first row)
    expect(items[2].getBoundingClientRect().width).toBe(210); // 70px * 3
    expect(items[2].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 60);

    // Item 4: second row, column 4 (does not backfill the gap on first row)
    expect(items[3].getBoundingClientRect().width).toBe(70);
    expect(items[3].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 60);
    expect(items[3].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 210);

    grid.remove();
  });

  it('uses dense packing when specified', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gridAutoFlow = 'dense';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    // Item spanning 2 columns
    const item1 = document.createElement('div');
    item1.textContent = 'Span 2';
    item1.style.gridColumnEnd = 'span 2';
    item1.style.backgroundColor = '#2196F3';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    // Regular item
    const item2 = document.createElement('div');
    item2.textContent = '1';
    item2.style.backgroundColor = '#42A5F5';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    // Spanning item (with dense, will fill gaps)
    const item3 = document.createElement('div');
    item3.textContent = 'Span 3';
    item3.style.gridColumnEnd = 'span 3';
    item3.style.backgroundColor = '#1E88E5';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    item3.style.fontSize = '11px';
    grid.appendChild(item3);

    // Regular item
    const item4 = document.createElement('div');
    item4.textContent = '2';
    item4.style.backgroundColor = '#1976D2';
    item4.style.display = 'flex';
    item4.style.alignItems = 'center';
    item4.style.justifyContent = 'center';
    item4.style.color = 'white';
    grid.appendChild(item4);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // With dense packing, items should fill all available gaps
    expect(items[0].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[1].getBoundingClientRect().width).toBe(70);
    expect(items[2].getBoundingClientRect().width).toBe(210); // 70px * 3
    expect(items[3].getBoundingClientRect().width).toBe(70);

    grid.remove();
  });

  it('uses column flow when specified', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'repeat(4, 50px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0', '#8E24AA', '#7B1FA2', '#6A1B9A'][i];
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

    // With column flow, items fill columns first
    // Item 1: column 1, row 1
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);

    // Item 2: column 1, row 2
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    expect(items[1].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 50);

    // Item 5: column 2, row 1
    expect(items[4].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 80);
    expect(items[4].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);

    grid.remove();
  });

  it('uses column dense flow', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gridAutoFlow = 'column dense';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    // Item spanning 2 rows
    const item1 = document.createElement('div');
    item1.textContent = 'Span 2';
    item1.style.gridRowEnd = 'span 2';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Regular item
    const item2 = document.createElement('div');
    item2.textContent = '1';
    item2.style.backgroundColor = '#FFA726';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    // Item spanning 2 rows
    const item3 = document.createElement('div');
    item3.textContent = 'Span 2';
    item3.style.gridRowEnd = 'span 2';
    item3.style.backgroundColor = '#FF9800';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    // Regular items to fill gaps
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 2}`;
      item.style.backgroundColor = '#FB8C00';
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

    // With column dense, items fill gaps in columns
    expect(items[0].getBoundingClientRect().height).toBe(120); // 60px * 2
    expect(items[2].getBoundingClientRect().height).toBe(120); // 60px * 2

    grid.remove();
  });

  it('creates implicit tracks with auto-sized columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridAutoColumns = '80px';
    grid.style.gridTemplateRows = '60px';
    // Column flow grows implicit columns for additional items.
    grid.style.gridAutoFlow = 'column';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    // Items that exceed explicit grid
    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047', '#388E3C', '#2E7D32'][i];
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

    // First 2 items use explicit grid (100px)
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(100);

    // Remaining items use auto-sized columns (80px)
    expect(items[2].getBoundingClientRect().width).toBe(80);
    expect(items[3].getBoundingClientRect().width).toBe(80);
    expect(items[4].getBoundingClientRect().width).toBe(80);

    grid.remove();
  });

  it('creates implicit tracks with auto-sized rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 100px';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '50px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    // More items than explicit rows
    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7', '#5E35B1', '#512DA8', '#4527A0'][i];
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

    // First row uses explicit grid (60px)
    expect(items[0].getBoundingClientRect().height).toBe(60);
    expect(items[1].getBoundingClientRect().height).toBe(60);

    // Subsequent rows use auto-sized rows (50px)
    expect(items[2].getBoundingClientRect().height).toBe(50);
    expect(items[3].getBoundingClientRect().height).toBe(50);
    expect(items[4].getBoundingClientRect().height).toBe(50);
    expect(items[5].getBoundingClientRect().height).toBe(50);

    grid.remove();
  });

  it('mixes auto-placement with explicit placement', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    // Explicitly placed item
    const item1 = document.createElement('div');
    item1.textContent = 'Explicit';
    item1.style.gridColumn = '2 / 4';
    item1.style.gridRow = '2';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    // Auto-placed items
    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = '#26A69A';
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

    // Explicitly placed item
    expect(items[0].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 70); // Column 2
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 60); // Row 2

    // Auto-placed items work around the explicit item
    items.slice(1).forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(70);
    });

    grid.remove();
  });

  it('handles sparse row flow with spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 90px)';
    grid.style.gridTemplateRows = 'repeat(4, 60px)';
    grid.style.gridAutoFlow = 'row';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    // Mix of regular and spanning items
    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.backgroundColor = '#F06292';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Span 2x2';
    item2.style.gridColumnEnd = 'span 2';
    item2.style.gridRowEnd = 'span 2';
    item2.style.backgroundColor = '#EC407A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = '2';
    item3.style.backgroundColor = '#E91E63';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    const item4 = document.createElement('div');
    item4.textContent = '3';
    item4.style.backgroundColor = '#D81B60';
    item4.style.display = 'flex';
    item4.style.alignItems = 'center';
    item4.style.justifyContent = 'center';
    item4.style.color = 'white';
    grid.appendChild(item4);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 2 spans 2x2
    expect(items[1].getBoundingClientRect().width).toBe(180); // 90px * 2
    expect(items[1].getBoundingClientRect().height).toBe(120); // 60px * 2

    // Other items are placed around it
    expect(items[0].getBoundingClientRect().width).toBe(90);
    expect(items[2].getBoundingClientRect().width).toBe(90);
    expect(items[3].getBoundingClientRect().width).toBe(90);

    grid.remove();
  });

  it('handles auto-placement with minmax auto-sized tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridAutoColumns = 'minmax(60px, auto)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    // Items beyond explicit grid
    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.textContent = i < 2 ? 'Explicit' : 'Auto';
      item.style.backgroundColor = ['#FFEB3B', '#FDD835', '#FBC02D', '#F9A825', '#F57F17'][i];
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

    // Explicit tracks
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(100);

    // Auto tracks with minmax
    expect(items[2].getBoundingClientRect().width).toBeGreaterThanOrEqual(60);
    expect(items[3].getBoundingClientRect().width).toBeGreaterThanOrEqual(60);
    expect(items[4].getBoundingClientRect().width).toBeGreaterThanOrEqual(60);

    grid.remove();
  });
});
