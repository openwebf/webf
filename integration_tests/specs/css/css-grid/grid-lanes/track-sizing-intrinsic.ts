describe('CSS Grid intrinsic track sizing', () => {
  it('calculates base size for auto tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto';
    grid.style.gridTemplateRows = 'auto';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.padding = '10px';

    const item1 = document.createElement('div');
    item1.textContent = 'Base Size A';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.padding = '15px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Base Size B - Longer';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.padding = '15px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Auto tracks should establish base size from content
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('calculates growth limit', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = 'auto 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    const autoItem = document.createElement('div');
    autoItem.textContent = 'Auto Track';
    autoItem.style.backgroundColor = '#42A5F5';
    autoItem.style.display = 'flex';
    autoItem.style.alignItems = 'center';
    autoItem.style.justifyContent = 'center';
    autoItem.style.color = 'white';
    autoItem.style.padding = '10px';
    grid.appendChild(autoItem);

    const frItem = document.createElement('div');
    frItem.textContent = 'Flex Track';
    frItem.style.backgroundColor = '#2196F3';
    frItem.style.display = 'flex';
    frItem.style.alignItems = 'center';
    frItem.style.justifyContent = 'center';
    frItem.style.color = 'white';
    grid.appendChild(frItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const autoWidth = items[0].getBoundingClientRect().width;
    const frWidth = items[1].getBoundingClientRect().width;

    // Auto track sizes to content, fr gets remaining
    expect(autoWidth).toBeGreaterThan(0);
    expect(frWidth).toBeGreaterThan(0);
    expect(autoWidth + frWidth + 10).toBeCloseTo(400, 1);

    grid.remove();
  });

  it('handles spanning items contribution', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto auto';
    grid.style.gridTemplateRows = 'auto auto';
    grid.style.columnGap = '10px';
    grid.style.rowGap = '10px';
    grid.style.backgroundColor = '#f3e5f5';
    grid.style.padding = '10px';

    // Single column items
    const item1 = document.createElement('div');
    item1.textContent = 'A';
    item1.style.gridColumn = '1';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'B';
    item2.style.gridColumn = '2';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'C';
    item3.style.gridColumn = '3';
    item3.style.backgroundColor = '#9C27B0';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    // Spanning item that should influence track sizing
    const spanItem = document.createElement('div');
    spanItem.textContent = 'This spans all three columns';
    spanItem.style.gridColumn = '1 / 4';
    spanItem.style.gridRow = '2';
    spanItem.style.backgroundColor = '#8E24AA';
    spanItem.style.padding = '10px';
    spanItem.style.color = 'white';
    spanItem.style.whiteSpace = 'nowrap';
    grid.appendChild(spanItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // First three items should have some width
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    // Spanning item should fit within the three columns
    const spanWidth = items[3].getBoundingClientRect().width;
    expect(spanWidth).toBeGreaterThan(0);

    grid.remove();
  });

  it('distributes extra space', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = 'auto auto 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Medium';
    item2.style.backgroundColor = '#FFA726';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Flex';
    item3.style.backgroundColor = '#FF9800';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Auto tracks size to content
    const auto1Width = items[0].getBoundingClientRect().width;
    const auto2Width = items[1].getBoundingClientRect().width;
    const frWidth = items[2].getBoundingClientRect().width;

    expect(auto1Width).toBeGreaterThan(0);
    expect(auto2Width).toBeGreaterThan(0);

    // Fr track gets remaining space
    expect(frWidth).toBeGreaterThan(0);
    expect(auto1Width + auto2Width + frWidth + 20).toBeCloseTo(400, 1);

    grid.remove();
  });

  it('resolves circular dependencies', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto 1fr';
    grid.style.gridTemplateRows = 'auto';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#ede7f6';
    grid.style.padding = '10px';

    // Item with percentage width in auto track (potential circular dependency)
    const autoItem = document.createElement('div');
    autoItem.style.gridColumn = '1';
    autoItem.style.width = '50%'; // Percentage in auto track
    autoItem.style.minWidth = '80px';
    autoItem.style.backgroundColor = '#9575CD';
    autoItem.style.height = '60px';
    autoItem.style.display = 'flex';
    autoItem.style.alignItems = 'center';
    autoItem.style.justifyContent = 'center';
    autoItem.textContent = 'Auto';
    autoItem.style.color = 'white';
    grid.appendChild(autoItem);

    const frItem = document.createElement('div');
    frItem.style.gridColumn = '2';
    frItem.style.backgroundColor = '#7E57C2';
    frItem.style.display = 'flex';
    frItem.style.alignItems = 'center';
    frItem.style.justifyContent = 'center';
    frItem.textContent = 'Flex';
    frItem.style.color = 'white';
    grid.appendChild(frItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Should resolve without infinite loop
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(80);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles intrinsic sizing with minmax', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = 'minmax(auto, 150px) minmax(auto, 1fr)';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    const item1 = document.createElement('div');
    item1.textContent = 'Intrinsic Size Content';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Flex';
    item2.style.backgroundColor = '#26A69A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // First track: auto minimum, 150px maximum
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(150);

    // Second track: auto minimum, grows with fr
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles intrinsic sizing with fixed minimum', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'auto minmax(100px, auto)';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#fce4ec';

    const item1 = document.createElement('div');
    item1.textContent = 'A';
    item1.style.backgroundColor = '#F06292';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Small';
    item2.style.backgroundColor = '#EC407A';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // First track: auto sizing
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);

    // Second track: at least 100px even if content is smaller
    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);

    grid.remove();
  });

  it('handles multiple intrinsic tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto auto auto';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '8px';
    grid.style.backgroundColor = '#fff9c4';
    grid.style.padding = '10px';

    const texts = ['Short', 'Medium Text', 'Longer Content Here', 'X'];
    const colors = ['#FFEB3B', '#FDD835', '#FBC02D', '#F9A825'];

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = texts[i];
      item.style.backgroundColor = colors[i];
      item.style.padding = '10px';
      item.style.color = 'black';
      item.style.fontSize = '12px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const widths = items.map(item => item.getBoundingClientRect().width);

    // All tracks should size to their content
    widths.forEach(width => {
      expect(width).toBeGreaterThan(0);
    });

    // Widths should vary based on content
    expect(widths[2]).toBeGreaterThan(widths[0]);

    grid.remove();
  });
});
