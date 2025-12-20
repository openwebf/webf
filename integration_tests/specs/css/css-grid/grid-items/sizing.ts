describe('CSS Grid item sizing', () => {
  it('sizes items with percentage width and height', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px 200px';
    grid.style.gridTemplateRows = '150px 150px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    // Item with 50% width and height
    const item1 = document.createElement('div');
    item1.textContent = '50% x 50%';
    item1.style.width = '50%';
    item1.style.height = '50%';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    // Item with 80% width and 100% height
    const item2 = document.createElement('div');
    item2.textContent = '80% x 100%';
    item2.style.width = '80%';
    item2.style.height = '100%';
    item2.style.backgroundColor = '#66BB6A';
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

    // Item 1: 50% of grid area (100px x 75px)
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(100, 0);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(75, 0);

    // Item 2: 80% width, 100% height of grid area
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(160, 0);
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(150, 0);

    grid.remove();
  });

  it('respects min-width and min-height constraints', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '150px 150px';
    grid.style.gridTemplateRows = '100px 100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    // Item with width smaller than min-width
    const item1 = document.createElement('div');
    item1.textContent = 'Min 100px';
    item1.style.width = '50px';
    item1.style.minWidth = '100px';
    item1.style.backgroundColor = '#2196F3';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item with height smaller than min-height
    const item2 = document.createElement('div');
    item2.textContent = 'Min 80px';
    item2.style.height = '30px';
    item2.style.minHeight = '80px';
    item2.style.backgroundColor = '#1E88E5';
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

    // Item 1: should be at least 100px wide
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);

    // Item 2: should be at least 80px tall
    expect(items[1].getBoundingClientRect().height).toBeGreaterThanOrEqual(80);

    grid.remove();
  });

  it('respects max-width and max-height constraints', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px 200px';
    grid.style.gridTemplateRows = '150px 150px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    // Item with 100% width but max-width
    const item1 = document.createElement('div');
    item1.textContent = 'Max 120px';
    item1.style.width = '100%';
    item1.style.maxWidth = '120px';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item with 100% height but max-height
    const item2 = document.createElement('div');
    item2.textContent = 'Max 100px';
    item2.style.height = '100%';
    item2.style.maxHeight = '100px';
    item2.style.backgroundColor = '#AB47BC';
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

    // Item 1: should not exceed 120px wide
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(120);

    // Item 2: should not exceed 100px tall
    expect(items[1].getBoundingClientRect().height).toBeLessThanOrEqual(100);

    grid.remove();
  });

  it('handles min and max constraints together', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '120px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    // Item with both min and max width
    const item1 = document.createElement('div');
    item1.textContent = 'Min/Max';
    item1.style.width = '150px';
    item1.style.minWidth = '60px';
    item1.style.maxWidth = '90px';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item with percentage and constraints
    const item2 = document.createElement('div');
    item2.textContent = 'Percent';
    item2.style.width = '120%';
    item2.style.minWidth = '50px';
    item2.style.maxWidth = '80px';
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

    // Item 1: clamped to max-width (90px)
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(90, 0);

    // Item 2: clamped to max-width (80px)
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(80, 0);

    grid.remove();
  });

  it('sizes items with fixed pixel dimensions', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 120px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    // Item with fixed width and height
    const item1 = document.createElement('div');
    item1.textContent = '80x60';
    item1.style.width = '80px';
    item1.style.height = '60px';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item larger than grid area
    const item2 = document.createElement('div');
    item2.textContent = '150x120';
    item2.style.width = '150px';
    item2.style.height = '120px';
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

    // Item 1: exact size
    expect(items[0].getBoundingClientRect().width).toBe(80);
    expect(items[0].getBoundingClientRect().height).toBe(60);

    // Item 2: maintains specified size even if larger than area
    expect(items[1].getBoundingClientRect().width).toBe(150);
    expect(items[1].getBoundingClientRect().height).toBe(120);

    grid.remove();
  });

  it('handles auto sizing with content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
    grid.style.gridTemplateRows = '100px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    // Item with auto width (fits content)
    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.width = 'auto';
    item1.style.backgroundColor = '#9575CD';
    item1.style.padding = '10px';
    item1.style.display = 'inline-flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item with auto height (fits content)
    const item2 = document.createElement('div');
    item2.textContent = 'Auto height content';
    item2.style.height = 'auto';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.padding = '5px';
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

    // Auto-sized items fit their content
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().height).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles percentage sizing in spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 90px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    // Item spanning 2 columns with 50% width
    const item1 = document.createElement('div');
    item1.textContent = 'Span 2, 50%';
    item1.style.gridColumn = 'span 2';
    item1.style.width = '50%';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item spanning 2 rows with 60% height
    const item2 = document.createElement('div');
    item2.textContent = 'Span 2, 60%';
    item2.style.gridRow = 'span 2';
    item2.style.height = '60%';
    item2.style.backgroundColor = '#26A69A';
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

    // Item 1: 50% of 2 columns (90px)
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(90, 0);

    // Item 2: 60% of 2 rows (96px)
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(96, 0);

    grid.remove();
  });

  xit('handles box-sizing with width and padding', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    // Item with content-box (default)
    const item1 = document.createElement('div');
    item1.textContent = 'Content-box';
    item1.style.width = '100px';
    item1.style.padding = '10px';
    item1.style.boxSizing = 'content-box';
    item1.style.backgroundColor = '#F06292';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item with border-box
    const item2 = document.createElement('div');
    item2.textContent = 'Border-box';
    item2.style.width = '100px';
    item2.style.padding = '10px';
    item2.style.boxSizing = 'border-box';
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

    // Item 1: 100px width + 20px padding = 120px total
    expect(items[0].getBoundingClientRect().width).toBe(120);

    // Item 2: 100px total width (includes padding)
    expect(items[1].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('handles intrinsic sizing keywords', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
    grid.style.gridTemplateRows = '100px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    // Item with min-content width
    const item1 = document.createElement('div');
    item1.textContent = 'Min content sizing';
    item1.style.width = 'min-content';
    item1.style.backgroundColor = '#FFEB3B';
    item1.style.padding = '5px';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item with max-content width
    const item2 = document.createElement('div');
    item2.textContent = 'Max content sizing here';
    item2.style.width = 'max-content';
    item2.style.backgroundColor = '#FDD835';
    item2.style.padding = '5px';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    // Item with fit-content width
    const item3 = document.createElement('div');
    item3.textContent = 'Fit';
    item3.style.width = 'fit-content';
    item3.style.backgroundColor = '#FBC02D';
    item3.style.padding = '5px';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // All items should have intrinsic sizes based on content
    const rect1 = items[0].getBoundingClientRect();
    const rect2 = items[1].getBoundingClientRect();
    const rect3 = items[2].getBoundingClientRect();

    // Track size is 100px (300px / 3); intrinsic keywords should prevent stretch.
    expect(rect1.width).toBeLessThan(100);
    expect(rect2.width).toBeGreaterThan(100);
    expect(rect3.width).toBeLessThan(100);
    // Ensure the max-content item does not overlap the next cell when sizing flex (fr) tracks.
    expect(rect3.left - rect2.right).toBeGreaterThanOrEqual(0);
    expect(rect3.left - rect2.right).toBeCloseTo(0, 0);

    grid.remove();
  });
});
