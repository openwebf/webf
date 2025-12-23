describe('CSS Grid minmax() advanced', () => {
  xit('handles minmax with fit-content max', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(100px, fit-content(200px))';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = 'minmax with fit-content';
    item.style.backgroundColor = '#42A5F5';
    item.style.padding = '10px';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(100);

    grid.remove();
  });

  it('handles nested minmax in repeat', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, minmax(80px, 1fr))';
    grid.style.gridTemplateRows = '70px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#2196F3', '#1E88E5', '#1976D2'][i];
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
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(100);
    });

    grid.remove();
  });

  it('handles minmax with calc() values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(calc(100px - 20px), calc(150px + 50px))';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.textContent = 'minmax with calc';
    item.style.backgroundColor = '#BA68C8';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // min: 80px, max: 200px
    expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(80);
    expect(item.getBoundingClientRect().width).toBeLessThanOrEqual(200);

    grid.remove();
  });

  it('handles minmax with conflicting min/max', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(200px, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'minmax(200px, 100px)';
    item.style.backgroundColor = '#FFB74D';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // When min > max, min wins
    expect(item.getBoundingClientRect().width).toBe(200);

    grid.remove();
  });

  it('handles minmax with spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, minmax(70px, 1fr))';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.textContent = 'Span 2';
    item1.style.gridColumn = 'span 2';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '1';
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
    expect(items[0].getBoundingClientRect().width).toBe(200);
    expect(items[1].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('handles minmax with max-content min', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(max-content, 1fr)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const item = document.createElement('div');
    item.textContent = 'Short text';
    item.style.backgroundColor = '#9575CD';
    item.style.padding = '10px';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should be at least max-content width
    expect(item.getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles minmax with intrinsic sizes and gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, minmax(min-content, max-content))';
    grid.style.gridTemplateRows = '80px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Much longer text here';
    item2.style.backgroundColor = '#26A69A';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });
});
