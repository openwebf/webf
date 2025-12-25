describe('CSS Grid fit-content()', () => {
  it('sizes track with fit-content()', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'fit-content(200px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = 'fit-content(200px)';
    item.style.backgroundColor = '#42A5F5';
    item.style.padding = '10px';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should fit content, clamped to 200px
    expect(item.getBoundingClientRect().width).toBeLessThan(200);

    grid.remove();
  });

  it('uses fit-content with small content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'fit-content(300px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '350px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    const item = document.createElement('div');
    item.textContent = 'Small';
    item.style.backgroundColor = '#2196F3';
    item.style.padding = '10px';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should shrink to content size
    expect(item.getBoundingClientRect().width).toBeLessThan(300);

    grid.remove();
  });

  it('uses fit-content with large content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'fit-content(150px)';
    grid.style.gridTemplateRows = 'auto';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.textContent = 'This is very long content that exceeds the fit-content limit';
    item.style.backgroundColor = '#BA68C8';
    item.style.padding = '10px';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should clamp to max (150px)
    expect(item.getBoundingClientRect().width).toBeLessThanOrEqual(150);

    grid.remove();
  });

  it('uses multiple fit-content tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'fit-content(100px) fit-content(150px) fit-content(120px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const texts = ['Short', 'Medium text', 'Longer'];
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = texts[i];
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(100);
    expect(items[1].getBoundingClientRect().width).toBeLessThanOrEqual(150);
    expect(items[2].getBoundingClientRect().width).toBeLessThanOrEqual(120);

    grid.remove();
  });

  it('combines fit-content with fixed and fr units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px fit-content(150px) 1fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '400px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.textContent = 'Fixed';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Fit';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = '1fr';
    item3.style.backgroundColor = '#43A047';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBeLessThanOrEqual(150);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('uses fit-content in rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px';
    grid.style.gridTemplateRows = 'fit-content(100px) fit-content(80px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const item1 = document.createElement('div');
    item1.textContent = 'Short content';
    item1.style.backgroundColor = '#9575CD';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Another row';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().height).toBeLessThan(100);
    expect(items[1].getBoundingClientRect().height).toBeLessThan(80);

    grid.remove();
  });

  it('handles fit-content with percentage', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'fit-content(50%)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    const item = document.createElement('div');
    item.textContent = 'fit-content(50%)';
    item.style.backgroundColor = '#4DB6AC';
    item.style.padding = '10px';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should clamp to 50% of 300px = 150px
    expect(item.getBoundingClientRect().width).toBeLessThanOrEqual(150);

    grid.remove();
  });
});
