describe('CSS Grid implicit track creation', () => {
  it('creates implicit rows when items exceed explicit rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 8; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${i * 45}, 70%, 60%)`;
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
    // Row 1 (explicit)
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);
    // Row 2 (implicit)
    expect(items[2].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 60);
    // Row 3 (implicit)
    expect(items[4].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 130);

    grid.remove();
  });

  it('creates implicit columns with column auto-flow', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = '110px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 8; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
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
    // Column 1 (explicit)
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    // Column 2 (implicit)
    expect(items[2].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 100);
    // Column 3 (implicit)
    expect(items[4].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 210);

    grid.remove();
  });

  it('creates implicit tracks when item placed beyond explicit grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridAutoRows = '50px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    // Place item explicitly in row 5
    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridRow = '5';
    item1.style.gridColumn = '1';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Add regular item
    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.backgroundColor = '#9C27B0';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item in row 5 should create implicit rows 3, 4, 5
    // Row 5 starts after rows 1-4: 60 + 60 + 50 + 50 = 220.
    expect(item1.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 220);

    grid.remove();
  });

  it('creates negative implicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridAutoRows = '50px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    // Place item at negative row (before explicit grid)
    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridRow = '-5';
    item1.style.gridColumn = '1';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.backgroundColor = '#FF9800';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(2);

    grid.remove();
  });

  it('creates implicit tracks with spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    // Spanning item that extends into implicit rows
    const item1 = document.createElement('div');
    item1.textContent = 'Span';
    item1.style.gridRow = '1 / span 3';
    item1.style.gridColumn = '1';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 50%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Spanning item should span 60 + 70 + 70 = 200px
    expect(item1.getBoundingClientRect().height).toBe(200);

    grid.remove();
  });

  it('creates implicit tracks in both dimensions', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoColumns = '90px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    // Place item beyond explicit grid in both dimensions
    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridRow = '3';
    item1.style.gridColumn = '3';
    item1.style.backgroundColor = '#9575CD';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item should be at position created by implicit tracks
    // grid-column: 3/grid-row: 3 position the item in the 3rd track (between lines 3 and 4),
    // so its offset is the sum of the preceding two tracks.
    expect(item1.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 190); // 100 + 90
    expect(item1.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 130); // 60 + 70

    grid.remove();
  });

  it('handles empty implicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    // Item in row 1
    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridRow = '1';
    item1.style.gridColumn = '1';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item in row 4 (rows 2 and 3 are empty implicit)
    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.gridRow = '4';
    item2.style.gridColumn = '2';
    item2.style.backgroundColor = '#009688';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item 2 should be placed after row1(60) + gap(10) + row2(70) + gap(10) + row3(70) + gap(10) = 230.
    expect(item2.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 230);

    grid.remove();
  });
});
