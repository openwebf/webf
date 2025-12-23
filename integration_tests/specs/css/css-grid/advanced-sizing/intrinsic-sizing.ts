describe('CSS Grid intrinsic sizing', () => {
  it('uses min-content for track sizing', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content min-content';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Longer text';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Both should shrink to min-content
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('uses max-content for track sizing', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'max-content max-content';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.backgroundColor = '#2196F3';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Much longer text here';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Both should expand to max-content (no wrapping)
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('combines min-content and max-content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content max-content';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Text wraps';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'No wrap here';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('uses intrinsic sizing with auto tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto min-content max-content';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '5px';
    grid.style.backgroundColor = '#fff3e0';

    const texts = ['Auto', 'Min', 'Max content'];
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
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles intrinsic sizing with images', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content max-content';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.style.width = '50px';
    item1.style.height = '50px';
    item1.style.backgroundColor = '#66BB6A';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.style.width = '100px';
    item2.style.height = '60px';
    item2.style.backgroundColor = '#4CAF50';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(50);
    expect(items[1].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('uses intrinsic sizing in rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px';
    grid.style.gridTemplateRows = 'min-content max-content';
    grid.style.gap = '5px';
    grid.style.backgroundColor = '#ede7f6';

    const item1 = document.createElement('div');
    item1.textContent = 'Min content height';
    item1.style.backgroundColor = '#9575CD';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Max content height with more text';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().height).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().height).toBeGreaterThan(0);

    grid.remove();
  });
});
