describe('CSS Grid line-based placement', () => {
  it('places items with positive line numbers', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 80px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    // Item spanning columns 2-4, row 1-2
    const item1 = document.createElement('div');
    item1.textContent = '2/4, 1/2';
    item1.style.gridColumnStart = '2';
    item1.style.gridColumnEnd = '4';
    item1.style.gridRowStart = '1';
    item1.style.gridRowEnd = '2';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    // Item at column 1, row 2
    const item2 = document.createElement('div');
    item2.textContent = '1, 2';
    item2.style.gridColumnStart = '1';
    item2.style.gridRowStart = '2';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: columns 2-4 (2 columns wide), row 1
    expect(items[0].getBoundingClientRect().width).toBe(160); // 80px * 2
    expect(items[0].getBoundingClientRect().height).toBe(60);
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 80); // Starts at column 2

    // Item 2: column 1, row 2
    expect(items[1].getBoundingClientRect().width).toBe(80);
    expect(items[1].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 60); // Row 2

    grid.remove();
  });

  it('places items with negative line numbers', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    // Item spanning from start to -1 (last line), row 1
    const item1 = document.createElement('div');
    item1.textContent = '1 / -1';
    item1.style.gridColumnStart = '1';
    item1.style.gridColumnEnd = '-1';
    item1.style.gridRowStart = '1';
    item1.style.backgroundColor = '#2196F3';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item at last column (-2 to -1), last row
    const item2 = document.createElement('div');
    item2.textContent = '-2/-1, -1';
    item2.style.gridColumnStart = '-2';
    item2.style.gridColumnEnd = '-1';
    item2.style.gridRowStart = '-1';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: spans all 3 columns
    expect(items[0].getBoundingClientRect().width).toBe(300);

    // Item 2: last column only
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 200); // Last column

    grid.remove();
  });

  it('uses span keyword for column span', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(5, 60px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    // Item spanning 3 columns from column 2
    const item1 = document.createElement('div');
    item1.textContent = 'span 3';
    item1.style.gridColumnStart = '2';
    item1.style.gridColumnEnd = 'span 3';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item spanning 2 columns from auto position
    const item2 = document.createElement('div');
    item2.textContent = 'span 2';
    item2.style.gridColumnEnd = 'span 2';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: 3 columns wide starting at column 2
    expect(items[0].getBoundingClientRect().width).toBe(180); // 60px * 3
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 60); // Column 2

    // Item 2: 2 columns wide at column 1
    expect(items[1].getBoundingClientRect().width).toBe(120); // 60px * 2

    grid.remove();
  });

  it('uses span keyword for row span', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(4, 50px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    // Item spanning 2 rows from row 2
    const item1 = document.createElement('div');
    item1.textContent = 'Row span 2';
    item1.style.gridColumn = '1';
    item1.style.gridRowStart = '2';
    item1.style.gridRowEnd = 'span 2';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item spanning 3 rows from row 1
    const item2 = document.createElement('div');
    item2.textContent = 'Row span 3';
    item2.style.gridColumn = '2';
    item2.style.gridRowStart = '1';
    item2.style.gridRowEnd = 'span 3';
    item2.style.backgroundColor = '#FFA726';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: 2 rows tall starting at row 2
    expect(items[0].getBoundingClientRect().height).toBe(100); // 50px * 2
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 50); // Row 2

    // Item 2: 3 rows tall starting at row 1
    expect(items[1].getBoundingClientRect().height).toBe(150); // 50px * 3

    grid.remove();
  });

  it('places items with named lines', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '[start] 80px [col2] 80px [col3] 80px [end]';
    grid.style.gridTemplateRows = '[top] 60px [middle] 60px [bottom]';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    // Item from named line 'start' to 'col3'
    const item1 = document.createElement('div');
    item1.textContent = 'start/col3';
    item1.style.gridColumnStart = 'start';
    item1.style.gridColumnEnd = 'col3';
    item1.style.gridRowStart = 'top';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item from 'col2' to 'end'
    const item2 = document.createElement('div');
    item2.textContent = 'col2/end';
    item2.style.gridColumnStart = 'col2';
    item2.style.gridColumnEnd = 'end';
    item2.style.gridRowStart = 'middle';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: spans from start to col3 (2 columns)
    expect(items[0].getBoundingClientRect().width).toBe(160); // 80px * 2
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top); // Row 'top'

    // Item 2: spans from col2 to end (2 columns)
    expect(items[1].getBoundingClientRect().width).toBe(160); // 80px * 2
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 80); // Column 'col2'
    expect(items[1].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 60); // Row 'middle'

    grid.remove();
  });

  it('uses span with named lines', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '[col] 70px [col] 70px [col] 70px [col] 70px [col]';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    // Item spanning to 'col 3' (third occurrence of 'col')
    const item1 = document.createElement('div');
    item1.textContent = 'span col 3';
    item1.style.gridColumnStart = '1';
    item1.style.gridColumnEnd = 'col 3';
    item1.style.backgroundColor = '#9575CD';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item spanning 2 'col' lines
    const item2 = document.createElement('div');
    item2.textContent = 'span 2 col';
    item2.style.gridColumnStart = 'col 3';
    item2.style.gridColumnEnd = 'span 2 col';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: spans to third 'col' line
    expect(items[0].getBoundingClientRect().width).toBe(140); // 70px * 2

    // Item 2: spans 2 'col' lines from col 3
    expect(items[1].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 140); // After first 2 columns

    grid.remove();
  });

  it('handles auto placement with explicit end line', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    // Item with auto start, explicit end (span 2)
    const item1 = document.createElement('div');
    item1.textContent = 'Auto/span 2';
    item1.style.gridColumnEnd = 'span 2';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Regular item
    const item2 = document.createElement('div');
    item2.textContent = 'Auto';
    item2.style.backgroundColor = '#26A69A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    // Another spanning item
    const item3 = document.createElement('div');
    item3.textContent = 'Auto/span 3';
    item3.style.gridColumnEnd = 'span 3';
    item3.style.backgroundColor = '#009688';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    item3.style.fontSize = '10px';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: 2 columns wide
    expect(items[0].getBoundingClientRect().width).toBe(140); // 70px * 2

    // Item 2: 1 column wide
    expect(items[1].getBoundingClientRect().width).toBe(70);

    // Item 3: 3 columns wide (wraps to next row if needed)
    expect(items[2].getBoundingClientRect().width).toBe(210); // 70px * 3

    grid.remove();
  });

  it('handles mixed line numbers and auto', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 50px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    // Item with explicit column, auto row
    const item1 = document.createElement('div');
    item1.textContent = 'Col 2';
    item1.style.gridColumn = '2';
    item1.style.backgroundColor = '#FFEB3B';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    grid.appendChild(item1);

    // Item with auto column, explicit row
    const item2 = document.createElement('div');
    item2.textContent = 'Row 2';
    item2.style.gridRow = '2';
    item2.style.backgroundColor = '#FDD835';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    grid.appendChild(item2);

    // Auto placement item
    const item3 = document.createElement('div');
    item3.textContent = 'Auto';
    item3.style.backgroundColor = '#FBC02D';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: column 2, auto row (row 1)
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 70); // Column 2
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top); // Row 1

    // Item 2: auto column (column 1), row 2
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left); // Column 1
    expect(items[1].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 50); // Row 2

    // Item 3: auto placed
    expect(items[2].getBoundingClientRect().width).toBe(70);

    grid.remove();
  });

  it('handles line numbers beyond grid bounds', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    // Item with end line beyond explicit grid
    const item1 = document.createElement('div');
    item1.textContent = '1/6 (beyond)';
    item1.style.gridColumnStart = '1';
    item1.style.gridColumnEnd = '6'; // Only 4 lines exist explicitly
    item1.style.backgroundColor = '#F06292';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item should create implicit tracks
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(240); // At least 3 columns

    grid.remove();
  });

  it('handles zero and invalid line numbers', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8eaf6';

    // Item with line number 0 (should be treated as auto)
    const item1 = document.createElement('div');
    item1.textContent = 'Line 0';
    item1.style.gridColumnStart = '0';
    item1.style.backgroundColor = '#5C6BC0';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Normal item for comparison
    const item2 = document.createElement('div');
    item2.textContent = 'Auto';
    item2.style.backgroundColor = '#3F51B5';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Both items should be auto-placed
    expect(items[0].getBoundingClientRect().width).toBe(80);
    expect(items[1].getBoundingClientRect().width).toBe(80);

    grid.remove();
  });
});
