describe('CSS Grid min/max-content sizing', () => {
  it('sizes items with min-content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
    grid.style.gridTemplateRows = '100px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'MinContent';
    item1.style.width = 'min-content';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'LongerMinContent';
    item2.style.width = 'min-content';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Items should size to minimum content width
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('sizes items with max-content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 1fr)';
    grid.style.gridTemplateRows = '100px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.width = 'max-content';
    item1.style.backgroundColor = '#2196F3';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'This is much longer content';
    item2.style.width = 'max-content';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Items should size to maximum content width
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('sizes items with fit-content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 200px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Short fit-content';
    item1.style.width = 'fit-content';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Much longer fit-content text that may affect sizing';
    item2.style.width = 'fit-content';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // fit-content should size between min and max-content
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles min-content with wrapping text', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr 1fr';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    const item1 = document.createElement('div');
    item1.textContent = 'This text will wrap to minimum width';
    item1.style.width = 'min-content';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Shorter';
    item2.style.width = 'min-content';
    item2.style.backgroundColor = '#FFA726';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // min-content should wrap to narrowest width
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles max-content without wrapping', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto';
    grid.style.gridTemplateRows = 'repeat(2, auto)';
    grid.style.gap = '5px';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.textContent = 'This text should not wrap with max-content';
    item1.style.width = 'max-content';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Short';
    item2.style.width = 'max-content';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // max-content should not wrap
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(items[1].getBoundingClientRect().width);

    grid.remove();
  });

  it('combines intrinsic sizing with constraints', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 200px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const item1 = document.createElement('div');
    item1.textContent = 'Max-content with max-width';
    item1.style.width = 'max-content';
    item1.style.maxWidth = '150px';
    item1.style.backgroundColor = '#9575CD';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Min';
    item2.style.width = 'min-content';
    item2.style.minWidth = '80px';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Item 1 clamped to max-width
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(150);
    // Item 2 at least min-width
    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(80);

    grid.remove();
  });

  it('handles fit-content with max constraint', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr';
    grid.style.gridTemplateRows = 'auto';
    grid.style.width = '250px';
    grid.style.backgroundColor = '#e0f2f1';

    const item = document.createElement('div');
    item.textContent = 'This is long fit-content text that should be constrained';
    item.style.width = 'fit-content';
    item.style.maxWidth = '200px';
    item.style.backgroundColor = '#4DB6AC';
    item.style.padding = '5px';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    expect(itemRect.width).toBeLessThanOrEqual(200);

    grid.remove();
  });

  it('handles intrinsic sizing with percentage fallback', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    const item1 = document.createElement('div');
    item1.textContent = 'Min-content';
    item1.style.width = 'min-content';
    item1.style.backgroundColor = '#F06292';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Max-content';
    item2.style.width = 'max-content';
    item2.style.backgroundColor = '#EC407A';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });
});
