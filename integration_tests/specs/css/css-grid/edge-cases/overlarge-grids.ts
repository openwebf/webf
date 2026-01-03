describe('CSS Grid overlarge grids', () => {
  it('handles many columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(20, 50px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gap = '5px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.overflowX = 'auto';
    grid.style.maxWidth = '340px';

    for (let i = 0; i < 40; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${(i * 15) % 360}, 70%, 60%)`;
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
    expect(items.length).toBe(40);
    expect(items[0].getBoundingClientRect().width).toBe(50);
    expect(grid.clientWidth).toBeLessThanOrEqual(340);
    expect(grid.scrollWidth).toBeGreaterThan(grid.clientWidth);

    const before = items[0].getBoundingClientRect().left;
    grid.scrollLeft = 200;
    await waitForFrame();
    await snapshot(0.5);
    const after = items[0].getBoundingClientRect().left;
    expect(after).toBeLessThan(before - 150);

    grid.remove();
  });

  it('handles many rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 80px)';
    grid.style.gridTemplateRows = 'repeat(20, 40px)';
    grid.style.gap = '4px';
    grid.style.backgroundColor = '#e3f2fd';
    grid.style.overflowY = 'auto';
    grid.style.maxHeight = '300px';

    for (let i = 0; i < 40; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + (i * 10) % 160}, 70%, 60%)`;
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
    expect(items.length).toBe(40);
    expect(grid.clientHeight).toBeLessThanOrEqual(300);
    expect(grid.scrollHeight).toBeGreaterThan(grid.clientHeight);

    const before = items[0].getBoundingClientRect().top;
    grid.scrollTop = 200;
    await waitForFrame();
    await snapshot(0.5);
    const after = items[0].getBoundingClientRect().top;
    expect(after).toBeLessThan(before - 150);

    grid.remove();
  });

  it('handles very large grid with auto-placement', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, minmax(40px, 1fr))';
    grid.style.gridAutoRows = '35px';
    grid.style.gap = '3px';
    grid.style.backgroundColor = '#f3e5f5';
    grid.style.maxHeight = '250px';
    grid.style.overflowY = 'auto';

    for (let i = 0; i < 100; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + (i * 5) % 80}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '9px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(100);

    grid.remove();
  });

  it('handles grid with many implicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 70px)';
    grid.style.gridTemplateRows = '50px';
    grid.style.gridAutoRows = '45px';
    grid.style.gap = '4px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.maxHeight = '300px';
    grid.style.overflowY = 'auto';

    for (let i = 0; i < 50; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + (i * 7) % 80}, 70%, 65%)`;
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
    expect(items.length).toBe(50);
    // First row explicit (50px), rest implicit (45px)
    expect(items[0].getBoundingClientRect().height).toBe(50);
    expect(items[2].getBoundingClientRect().height).toBe(45);

    grid.remove();
  });

  it('handles large spanning item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(10, 50px)';
    grid.style.gridTemplateRows = 'repeat(10, 40px)';
    grid.style.gap = '3px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.maxWidth = '340px';
    grid.style.maxHeight = '300px';
    grid.style.overflow = 'auto';

    const largeItem = document.createElement('div');
    largeItem.textContent = 'Large Span';
    largeItem.style.gridColumn = '1 / 6';
    largeItem.style.gridRow = '1 / 6';
    largeItem.style.backgroundColor = '#66BB6A';
    largeItem.style.display = 'flex';
    largeItem.style.alignItems = 'center';
    largeItem.style.justifyContent = 'center';
    largeItem.style.color = 'white';
    largeItem.style.fontSize = '11px';
    grid.appendChild(largeItem);

    for (let i = 0; i < 75; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + (i * 5) % 80}, 60%, 55%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '8px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Large item spans 5x5
    expect(largeItem.getBoundingClientRect().width).toBeGreaterThan(200);
    expect(largeItem.getBoundingClientRect().height).toBeGreaterThan(150);

    grid.remove();
  });

  it('handles grid with scrollable content', async () => {
    const container = document.createElement('div');
    container.style.maxWidth = '340px';
    container.style.maxHeight = '280px';
    container.style.overflow = 'auto';
    container.style.backgroundColor = '#ede7f6';
    container.style.padding = '10px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(8, 70px)';
    grid.style.gridTemplateRows = 'repeat(8, 60px)';
    grid.style.gap = '5px';

    for (let i = 0; i < 64; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + (i * 6) % 100}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '10px';
      grid.appendChild(item);
    }

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(64);

    container.remove();
  });
});
