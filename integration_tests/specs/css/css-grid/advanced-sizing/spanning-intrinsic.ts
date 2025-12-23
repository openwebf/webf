describe('CSS Grid spanning with intrinsic sizes', () => {
  it('handles spanning items with min-content tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content min-content min-content';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Span 2 columns';
    item1.style.gridColumn = 'span 2';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Single';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.padding = '10px';
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

  it('handles spanning items with max-content tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'max-content max-content';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    const item1 = document.createElement('div');
    item1.textContent = 'Regular column';
    item1.style.backgroundColor = '#2196F3';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Short';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Spanning item across both columns';
    item3.style.gridColumn = 'span 2';
    item3.style.backgroundColor = '#1976D2';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    item3.style.fontSize = '11px';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('handles spanning with mixed intrinsic and fixed tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px min-content max-content';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Fixed';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Spanning min and max';
    item2.style.gridColumn = '2 / 4';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles spanning with auto tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto auto';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    const item1 = document.createElement('div');
    item1.textContent = 'Item 1';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Item 2';
    item2.style.backgroundColor = '#FFA726';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Item 3';
    item3.style.backgroundColor = '#FF9800';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    const item4 = document.createElement('div');
    item4.textContent = 'Spanning item that influences track sizing';
    item4.style.gridColumn = 'span 3';
    item4.style.backgroundColor = '#FB8C00';
    item4.style.padding = '10px';
    item4.style.color = 'white';
    item4.style.fontSize = '11px';
    grid.appendChild(item4);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[3].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('handles spanning with minmax and intrinsic sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, minmax(min-content, max-content))';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Medium text';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Longer text here';
    item3.style.backgroundColor = '#43A047';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    item3.style.fontSize = '11px';
    grid.appendChild(item3);

    const item4 = document.createElement('div');
    item4.textContent = 'Spanning item';
    item4.style.gridColumn = 'span 2';
    item4.style.backgroundColor = '#388E3C';
    item4.style.padding = '10px';
    item4.style.color = 'white';
    grid.appendChild(item4);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[3].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('handles nested grid with spanning and intrinsic sizing', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content max-content';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    const item1 = document.createElement('div');
    item1.textContent = 'Min';
    item1.style.backgroundColor = '#9575CD';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.style.gridColumn = '1 / 3';
    item2.style.display = 'grid';
    item2.style.gridTemplateColumns = '1fr 1fr';
    item2.style.gap = '5px';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.padding = '10px';

    const nested1 = document.createElement('div');
    nested1.textContent = 'Nested 1';
    nested1.style.backgroundColor = '#673AB7';
    nested1.style.padding = '5px';
    nested1.style.color = 'white';
    nested1.style.fontSize = '10px';
    item2.appendChild(nested1);

    const nested2 = document.createElement('div');
    nested2.textContent = 'Nested 2';
    nested2.style.backgroundColor = '#5E35B1';
    nested2.style.padding = '5px';
    nested2.style.color = 'white';
    nested2.style.fontSize = '10px';
    item2.appendChild(nested2);

    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item1.getBoundingClientRect().width).toBeGreaterThan(0);
    expect(item2.getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });
});
