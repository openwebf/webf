describe('CSS Grid item margins', () => {
  it('applies fixed pixel margins', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    // Item with uniform margins
    const item1 = document.createElement('div');
    item1.textContent = 'Margin 10px';
    item1.style.margin = '10px';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item with different margins
    const item2 = document.createElement('div');
    item2.textContent = 'Mixed margins';
    item2.style.marginTop = '5px';
    item2.style.marginRight = '15px';
    item2.style.marginBottom = '10px';
    item2.style.marginLeft = '20px';
    item2.style.backgroundColor = '#66BB6A';
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

    // Item 1: 150px - 20px margins = 130px width
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(130, 0);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(80, 0);
    expect(items[0].getBoundingClientRect().left).toBeCloseTo(grid.getBoundingClientRect().left + 10, 0);
    expect(items[0].getBoundingClientRect().top).toBeCloseTo(grid.getBoundingClientRect().top + 10, 0);

    // Item 2: asymmetric margins
    expect(items[1].getBoundingClientRect().left).toBeCloseTo(grid.getBoundingClientRect().left + 150 + 20, 0);
    expect(items[1].getBoundingClientRect().top).toBeCloseTo(grid.getBoundingClientRect().top + 5, 0);

    grid.remove();
  });

  it('applies percentage margins', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px 200px';
    grid.style.gridTemplateRows = '150px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    // Item with percentage margins (relative to width of containing block)
    const item1 = document.createElement('div');
    item1.textContent = '10% margin';
    item1.style.margin = '10%'; // 10% of 200px = 20px
    item1.style.backgroundColor = '#2196F3';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    // Item with 5% margin
    const item2 = document.createElement('div');
    item2.textContent = '5% margin';
    item2.style.margin = '5%'; // 5% of 200px = 10px
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

    // Item 1: 200px - 40px (2 * 20px) = 160px width
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(160, 0);
    // Height: 150px - 40px (2 * 20px) = 110px
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(110, 0);

    // Item 2: 200px - 20px (2 * 10px) = 180px width
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(180, 0);

    grid.remove();
  });

  it('centers items with auto margins horizontally', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 200px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    // Item with horizontal auto margins
    const item1 = document.createElement('div');
    item1.textContent = 'Auto H';
    item1.style.width = '120px';
    item1.style.marginLeft = 'auto';
    item1.style.marginRight = 'auto';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item with left auto margin only (pushed right)
    const item2 = document.createElement('div');
    item2.textContent = 'Auto L';
    item2.style.width = '120px';
    item2.style.marginLeft = 'auto';
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

    // Item 1: centered horizontally
    const item1Left = items[0].getBoundingClientRect().left - grid.getBoundingClientRect().left;
    const item1Right = 200 - (item1Left + 120);
    expect(Math.abs(item1Left - item1Right)).toBeLessThan(1); // Should be centered

    // Item 2: aligned to right edge
    expect(items[1].getBoundingClientRect().right).toBeCloseTo(grid.getBoundingClientRect().left + 400, 0);

    grid.remove();
  });

  it('centers items with auto margins vertically', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '150px';
    grid.style.gridTemplateRows = 'repeat(2, 120px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    // Item with vertical auto margins
    const item1 = document.createElement('div');
    item1.textContent = 'Auto V';
    item1.style.height = '60px';
    item1.style.marginTop = 'auto';
    item1.style.marginBottom = 'auto';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item with top auto margin only (pushed bottom)
    const item2 = document.createElement('div');
    item2.textContent = 'Auto T';
    item2.style.height = '60px';
    item2.style.marginTop = 'auto';
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

    // Item 1: centered vertically in its grid area
    const item1Top = items[0].getBoundingClientRect().top - grid.getBoundingClientRect().top;
    const item1Bottom = 120 - (item1Top + 60);
    expect(Math.abs(item1Top - item1Bottom)).toBeLessThan(1); // Should be centered

    // Item 2: aligned to bottom edge of its area
    expect(items[1].getBoundingClientRect().bottom).toBeCloseTo(grid.getBoundingClientRect().top + 240, 0);

    grid.remove();
  });

  it('centers items with all auto margins', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px';
    grid.style.gridTemplateRows = '150px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    // Item centered both horizontally and vertically
    const item = document.createElement('div');
    item.textContent = 'Centered';
    item.style.width = '120px';
    item.style.height = '80px';
    item.style.margin = 'auto';
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
    const gridRect = grid.getBoundingClientRect();

    // Auto margins resolve against the grid area (the single 200px × 150px cell),
    // not the grid container's stretched border box.
    const leftMargin = itemRect.left - gridRect.left;
    const rightMargin = 200 - (leftMargin + itemRect.width);
    const topMargin = itemRect.top - gridRect.top;
    const bottomMargin = 150 - (topMargin + itemRect.height);

    expect(Math.abs(leftMargin - rightMargin)).toBeLessThan(1);
    expect(Math.abs(topMargin - bottomMargin)).toBeLessThan(1);

    grid.remove();
  });

  it('does not collapse margins in grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px';
    grid.style.gridTemplateRows = 'repeat(3, auto)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    // Adjacent items with margins (should not collapse)
    const item1 = document.createElement('div');
    item1.textContent = 'Item 1';
    item1.style.marginBottom = '20px';
    item1.style.backgroundColor = '#9575CD';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Item 2';
    item2.style.marginTop = '30px';
    item2.style.marginBottom = '15px';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Item 3';
    item3.style.marginTop = '25px';
    item3.style.backgroundColor = '#673AB7';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Margins should NOT collapse - gap should be sum of adjacent margins
    // Gap between item1 and item2: 20px + 30px = 50px
    const gap1 = items[1].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(gap1).toBeCloseTo(50, 0);

    // Gap between item2 and item3: 15px + 25px = 40px
    const gap2 = items[2].getBoundingClientRect().top - items[1].getBoundingClientRect().bottom;
    expect(gap2).toBeCloseTo(40, 0);

    grid.remove();
  });

  it('handles negative margins', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    // Item with negative margins (extends beyond grid area)
    const item1 = document.createElement('div');
    item1.textContent = 'Negative';
    item1.style.margin = '-10px';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Normal item for comparison
    const item2 = document.createElement('div');
    item2.textContent = 'Normal';
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

    // Item 1: 150px + 20px (2 * -10px) = 170px width
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(170, 0);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(120, 0);
    expect(items[0].getBoundingClientRect().left).toBeCloseTo(grid.getBoundingClientRect().left - 10, 0);

    // Item 2: normal sizing
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(150, 0);

    grid.remove();
  });

  it('combines margins with spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    // Spanning item with margins
    const item1 = document.createElement('div');
    item1.textContent = 'Span 2 + margin';
    item1.style.gridColumn = 'span 2';
    item1.style.margin = '10px';
    item1.style.backgroundColor = '#F06292';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Normal item
    const item2 = document.createElement('div');
    item2.textContent = 'Normal';
    item2.style.backgroundColor = '#EC407A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: spans 2 columns (200px) - 20px margins = 180px
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(180, 0);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(60, 0);

    grid.remove();
  });

  it('handles margins with percentage widths', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px 200px';
    grid.style.gridTemplateRows = '120px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    // Item with percentage width and fixed margins
    const item1 = document.createElement('div');
    item1.textContent = '80% + margin';
    item1.style.width = '80%';
    item1.style.margin = '10px';
    item1.style.backgroundColor = '#FFEB3B';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item with fixed width and percentage margins
    const item2 = document.createElement('div');
    item2.textContent = '100px + 5%';
    item2.style.width = '100px';
    item2.style.margin = '5%'; // 5% of 200px = 10px
    item2.style.backgroundColor = '#FDD835';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: 80% of 200px = 160px (margins applied separately)
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(160, 0);

    // Item 2: 100px width (fixed)
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(100, 0);

    grid.remove();
  });
});
