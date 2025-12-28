describe('CSS Grid track breadth calculation', () => {
  it('calculates track breadth with fixed sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 150px 200px';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['100px', '150px', '200px'][i];
      item.style.backgroundColor = ['#42A5F5', '#66BB6A', '#FFA726'][i];
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
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(150);
    expect(items[2].getBoundingClientRect().width).toBe(200);

    grid.remove();
  });

  it('calculates breadth with content-based sizing', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto';
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
    item2.textContent = 'Much longer content here';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    grid.remove();
  });

  it('calculates breadth with percentage constraints', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '25% 50% 25%';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '400px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['25%', '50%', '25%'][i];
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0'][i];
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
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(200);
    expect(items[2].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('handles breadth with mixed units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 30% auto 1fr';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '500px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const item1 = document.createElement('div');
    item1.textContent = '100px';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '30%';
    item2.style.backgroundColor = '#FFA726';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Auto';
    item3.style.backgroundColor = '#FF9800';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    item3.style.fontSize = '11px';
    grid.appendChild(item3);

    const item4 = document.createElement('div');
    item4.textContent = '1fr';
    item4.style.backgroundColor = '#FB8C00';
    item4.style.display = 'flex';
    item4.style.alignItems = 'center';
    item4.style.justifyContent = 'center';
    item4.style.color = 'white';
    item4.style.fontSize = '11px';
    grid.appendChild(item4);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // 100px + 150px (30%) = 250px used, remaining shared between auto and 1fr
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(150);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[3].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles breadth with minmax constraints', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(100px, 200px) minmax(150px, 1fr)';
    grid.style.gridTemplateRows = '80px';
    grid.style.width = '400px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Track ${i + 1}`;
      item.style.backgroundColor = ['#66BB6A', '#4CAF50'][i];
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
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(200);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(150);

    grid.remove();
  });
});
