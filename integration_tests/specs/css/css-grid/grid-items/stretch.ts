describe('CSS Grid stretch alignment', () => {
  it('stretches items to fill grid area by default', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '120px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Stretch';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Stretch';
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
    // Items should fill their grid areas
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[0].getBoundingClientRect().height).toBe(120);
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().height).toBe(120);

    grid.remove();
  });

  it('applies explicit stretch alignment', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'stretch';
    grid.style.justifyItems = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    const item1 = document.createElement('div');
    item1.textContent = 'Stretched';
    item1.style.backgroundColor = '#2196F3';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Stretched';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(150);
    expect(items[0].getBoundingClientRect().height).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(150);
    expect(items[1].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('does not stretch items with explicit size', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = '120px';
    grid.style.alignItems = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Fixed width';
    item1.style.width = '100px';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Fixed height';
    item2.style.height = '80px';
    item2.style.backgroundColor = '#AB47BC';
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
    // Item 1 has fixed width, should not stretch horizontally
    expect(items[0].getBoundingClientRect().width).toBe(100);
    // Item 2 has fixed height, should not stretch vertically
    expect(items[1].getBoundingClientRect().height).toBe(80);

    grid.remove();
  });

  it('overrides stretch with self-alignment', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const item1 = document.createElement('div');
    item1.textContent = 'Start';
    item1.style.alignSelf = 'start';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Center';
    item2.style.alignSelf = 'center';
    item2.style.backgroundColor = '#FFA726';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'End';
    item3.style.alignSelf = 'end';
    item3.style.backgroundColor = '#FF9800';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Items should not fill full height due to self-alignment
    expect(items[0].getBoundingClientRect().height).toBeLessThan(100);
    expect(items[1].getBoundingClientRect().height).toBeLessThan(100);
    expect(items[2].getBoundingClientRect().height).toBeLessThan(100);

    grid.remove();
  });

  it('stretches with margins', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.textContent = 'With margin';
    item1.style.margin = '10px';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'No margin';
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
    // Item 1: 150px - 20px (margins) = 130px
    expect(items[0].getBoundingClientRect().width).toBe(130);
    expect(items[0].getBoundingClientRect().height).toBe(80);
    // Item 2: full size
    expect(items[1].getBoundingClientRect().width).toBe(150);
    expect(items[1].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('stretches spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 90px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const item = document.createElement('div');
    item.textContent = 'Span 2x2';
    item.style.gridColumn = 'span 2';
    item.style.gridRow = 'span 2';
    item.style.backgroundColor = '#9575CD';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    // Should fill the 2x2 area
    expect(itemRect.width).toBe(180); // 90px * 2
    expect(itemRect.height).toBe(160); // 80px * 2

    grid.remove();
  });

  it('handles stretch with min/max constraints', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 200px)';
    grid.style.gridTemplateRows = '150px';
    grid.style.alignItems = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    const item1 = document.createElement('div');
    item1.textContent = 'Max-width';
    item1.style.maxWidth = '150px';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Max-height';
    item2.style.maxHeight = '100px';
    item2.style.backgroundColor = '#26A69A';
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
    // Item 1 clamped to max-width
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(150);
    // Item 2 clamped to max-height
    expect(items[1].getBoundingClientRect().height).toBeLessThanOrEqual(100);

    grid.remove();
  });

  it('stretches with aspect ratio', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 160px)';
    grid.style.gridTemplateRows = '120px';
    grid.style.justifyItems = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    const item = document.createElement('div');
    item.textContent = '16:9';
    item.style.aspectRatio = '16 / 9';
    item.style.backgroundColor = '#F06292';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    // Item maintains aspect ratio
    const ratio = itemRect.width / itemRect.height;
    expect(ratio).toBeCloseTo(16/9, 0.5);

    grid.remove();
  });
});
