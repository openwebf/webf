describe('CSS Grid minmax() basic', () => {
  it('uses minmax with fixed min and max', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(100px, 200px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = 'minmax(100px, 200px)';
    item.style.backgroundColor = '#42A5F5';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should clamp to max (200px) since grid is 300px
    expect(item.getBoundingClientRect().width).toBe(200);

    grid.remove();
  });

  it('uses minmax with min and 1fr', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(100px, 1fr) minmax(100px, 1fr)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = 'minmax(100px, 1fr)';
      item.style.backgroundColor = ['#2196F3', '#1E88E5'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '10px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Should distribute equally at 150px each
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(150);
    });

    grid.remove();
  });

  it('respects minimum size', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(150px, 1fr) 50px';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '180px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'minmax(150px, 1fr)';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '50px';
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
    // Should enforce minimum even if grid is smaller
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(150);
    expect(items[1].getBoundingClientRect().width).toBe(50);

    grid.remove();
  });

  it('uses minmax with percentage values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(20%, 50%)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'minmax(20%, 50%)';
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

    // Should use max (50% of 300px = 150px)
    expect(item.getBoundingClientRect().width).toBe(150);

    grid.remove();
  });

  it('uses minmax with auto as min', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(auto, 200px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const item = document.createElement('div');
    item.textContent = 'minmax(auto, 200px)';
    item.style.backgroundColor = '#66BB6A';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Auto as min means min-content, max is 200px
    expect(item.getBoundingClientRect().width).toBeLessThanOrEqual(200);

    grid.remove();
  });

  it('uses minmax with auto as max', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(100px, auto)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const item = document.createElement('div');
    item.textContent = 'minmax(100px, auto)';
    item.style.backgroundColor = '#9575CD';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Auto as max means max-content, at least 100px
    expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(100);

    grid.remove();
  });

  it('combines multiple minmax tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(50px, 1fr) minmax(100px, 2fr) minmax(80px, 1fr)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '400px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `Track ${i + 1}`;
      item.style.backgroundColor = ['#4DB6AC', '#26A69A', '#009688'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '11px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Total fr: 1+2+1 = 4fr, but mins: 50+100+80 = 230px
    // Remaining: 400-230 = 170px, distributed as 1fr:2fr:1fr
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(50);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThanOrEqual(80);

    grid.remove();
  });

  it('uses minmax with min-content and max-content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(min-content, max-content)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    const item = document.createElement('div');
    item.textContent = 'minmax(min-content, max-content)';
    item.style.backgroundColor = '#F06292';
    item.style.padding = '10px';
    item.style.color = 'white';
    item.style.fontSize = '10px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('uses minmax in row sizing', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '150px';
    grid.style.gridTemplateRows = 'minmax(50px, 100px) minmax(60px, 1fr)';
    grid.style.height = '200px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Row ${i + 1}`;
      item.style.backgroundColor = ['#FFEB3B', '#FDD835'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Row 1: clamped to max (100px)
    expect(items[0].getBoundingClientRect().height).toBe(100);
    // Row 2: takes remaining space (100px), which is > 60px min
    expect(items[1].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });
});
