describe('CSS Grid overlapping items', () => {
  it('allows items to overlap in same grid area', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(3, 80px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    // Two items in the same area
    const item1 = document.createElement('div');
    item1.textContent = 'Behind';
    item1.style.gridArea = '2 / 2 / 3 / 3';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Front';
    item2.style.gridArea = '2 / 2 / 3 / 3';
    item2.style.backgroundColor = '#FFA726';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.padding = '10px';
    item2.style.margin = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Both items occupy the same space
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 100);
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 80);
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 100 + 10); // With margin
    expect(items[1].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 80 + 10); // With margin

    grid.remove();
  });

  it('respects z-index for overlapping items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    // Item with z-index 1
    const item1 = document.createElement('div');
    item1.textContent = 'z:1';
    item1.style.gridArea = '1 / 1 / 3 / 3';
    item1.style.backgroundColor = '#2196F3';
    item1.style.zIndex = '1';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item with z-index 3 (should be on top)
    const item2 = document.createElement('div');
    item2.textContent = 'z:3';
    item2.style.gridArea = '2 / 2 / 4 / 4';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.zIndex = '3';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    // Item with z-index 2
    const item3 = document.createElement('div');
    item3.textContent = 'z:2';
    item3.style.gridArea = '1 / 2 / 2 / 4';
    item3.style.backgroundColor = '#FFA726';
    item3.style.zIndex = '2';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Verify z-index values
    expect(getComputedStyle(items[0]).zIndex).toBe('1');
    expect(getComputedStyle(items[1]).zIndex).toBe('3');
    expect(getComputedStyle(items[2]).zIndex).toBe('2');

    grid.remove();
  });

  it('uses document order for painting without z-index', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 90px)';
    grid.style.gridTemplateRows = 'repeat(3, 70px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    // Three overlapping items (last one should be on top)
    const item1 = document.createElement('div');
    item1.textContent = 'First';
    item1.style.gridArea = '1 / 1 / 3 / 3';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Second';
    item2.style.gridArea = '2 / 2 / 4 / 4';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Third';
    item3.style.gridArea = '1 / 2 / 2 / 4';
    item3.style.backgroundColor = '#9C27B0';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Items are painted in document order (third item on top)
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);

    grid.remove();
  });

  xit('handles negative z-index', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 90px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    // Item with negative z-index (should be behind)
    const item1 = document.createElement('div');
    item1.textContent = 'z:-1';
    item1.style.gridArea = '1 / 1 / 3 / 3';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.zIndex = '-1';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item with z-index 0
    const item2 = document.createElement('div');
    item2.textContent = 'z:0';
    item2.style.gridArea = '1 / 2 / 2 / 4';
    item2.style.backgroundColor = '#FFA726';
    item2.style.zIndex = '0';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    // Item without z-index (auto, same as 0)
    const item3 = document.createElement('div');
    item3.textContent = 'z:auto';
    item3.style.gridArea = '2 / 2 / 3 / 4';
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

    // Verify z-index values
    expect(getComputedStyle(items[0]).zIndex).toBe('-1');
    expect(getComputedStyle(items[1]).zIndex).toBe('0');
    expect(getComputedStyle(items[2]).zIndex).toBe('auto');

    grid.remove();
  });

  it('handles overlapping with spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(4, 50px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    // Large spanning item
    const item1 = document.createElement('div');
    item1.textContent = 'Large span';
    item1.style.gridArea = '1 / 1 / 4 / 4';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Small item on top
    const item2 = document.createElement('div');
    item2.textContent = 'Small';
    item2.style.gridArea = '2 / 2 / 3 / 3';
    item2.style.backgroundColor = '#FFA726';
    item2.style.zIndex = '1';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    // Another spanning item
    const item3 = document.createElement('div');
    item3.textContent = 'Medium';
    item3.style.gridArea = '2 / 3 / 4 / 5';
    item3.style.backgroundColor = '#42A5F5';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: large (3x3)
    expect(items[0].getBoundingClientRect().width).toBe(210); // 70px * 3
    expect(items[0].getBoundingClientRect().height).toBe(150); // 50px * 3

    // Item 2: small (1x1) with z-index
    expect(items[1].getBoundingClientRect().width).toBe(70);
    expect(items[1].getBoundingClientRect().height).toBe(50);

    // Item 3: medium (2x2)
    expect(items[2].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[2].getBoundingClientRect().height).toBe(100); // 50px * 2

    grid.remove();
  });

  it('handles complex z-index stacking', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(5, 60px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const zIndexes = [5, 10, 1, 7, 3];
    const colors = ['#9575CD', '#7E57C2', '#673AB7', '#5E35B1', '#512DA8'];
    const areas = [
      '1 / 1 / 3 / 3',
      '1 / 2 / 2 / 4',
      '2 / 3 / 4 / 5',
      '1 / 4 / 3 / 6',
      '2 / 1 / 4 / 3'
    ];

    areas.forEach((area, index) => {
      const item = document.createElement('div');
      item.textContent = `z:${zIndexes[index]}`;
      item.style.gridArea = area;
      item.style.backgroundColor = colors[index];
      item.style.zIndex = zIndexes[index].toString();
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '11px';
      grid.appendChild(item);
    });

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Verify all z-index values are applied
    items.forEach((item, index) => {
      expect(getComputedStyle(item).zIndex).toBe(zIndexes[index].toString());
    });

    grid.remove();
  });

  xit('overlaps with partial grid areas', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    // Items that partially overlap
    const item1 = document.createElement('div');
    item1.textContent = 'A';
    item1.style.gridArea = '1 / 1 / 2 / 3';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'B';
    item2.style.gridArea = '1 / 2 / 3 / 4';
    item2.style.backgroundColor = '#26A69A';
    item2.style.opacity = '0.8';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'C';
    item3.style.gridArea = '2 / 1 / 4 / 3';
    item3.style.backgroundColor = '#009688';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    const item4 = document.createElement('div');
    item4.textContent = 'D';
    item4.style.gridArea = '2 / 3 / 4 / 5';
    item4.style.backgroundColor = '#00897B';
    item4.style.display = 'flex';
    item4.style.alignItems = 'center';
    item4.style.justifyContent = 'center';
    item4.style.color = 'white';
    grid.appendChild(item4);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // All items have correct dimensions
    expect(items[0].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[1].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[2].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[3].getBoundingClientRect().width).toBe(140); // 70px * 2

    grid.remove();
  });

  it('handles overlapping with positioned grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 90px)';
    grid.style.gridTemplateRows = 'repeat(3, 70px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';
    grid.style.position = 'relative';

    // Regular grid item
    const item1 = document.createElement('div');
    item1.textContent = 'Grid item';
    item1.style.gridArea = '2 / 2 / 3 / 3';
    item1.style.backgroundColor = '#F06292';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    // Positioned grid item (still participates in grid)
    const item2 = document.createElement('div');
    item2.textContent = 'Relative';
    item2.style.gridArea = '2 / 2 / 3 / 3';
    item2.style.backgroundColor = '#EC407A';
    item2.style.position = 'relative';
    item2.style.top = '10px';
    item2.style.left = '10px';
    item2.style.zIndex = '1';
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

    // Both items start in the same grid area
    // Item 2 is offset by position
    expect(items[1].getBoundingClientRect().left).toBe(items[0].getBoundingClientRect().left + 10);
    expect(items[1].getBoundingClientRect().top).toBe(items[0].getBoundingClientRect().top + 10);

    grid.remove();
  });
});
