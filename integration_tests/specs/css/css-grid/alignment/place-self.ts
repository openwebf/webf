describe('CSS Grid place-self shorthand', () => {
  it('sets both align-self and justify-self with one value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (center)';
        item.style.placeSelf = 'center';
        item.style.fontSize = '11px';
      }
      item.style.backgroundColor = ['#42A5F5', '#66BB6A', '#FFA726'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Item 2 should be centered both ways
    expect(getComputedStyle(items[1]).alignSelf).toBe('center');
    expect(getComputedStyle(items[1]).justifySelf).toBe('center');

    grid.remove();
  });

  it('sets align-self and justify-self with two values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (start/end)';
        item.style.placeSelf = 'start end';
        item.style.fontSize = '10px';
      }
      item.style.backgroundColor = ['#2196F3', '#1E88E5', '#1976D2'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(getComputedStyle(items[1]).alignSelf).toBe('start');
    expect(getComputedStyle(items[1]).justifySelf).toBe('end');

    grid.remove();
  });

  it('uses stretch for both axes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.placeItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (stretch)';
        item.style.placeSelf = 'stretch';
        item.style.fontSize = '10px';
      }
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0'][i];
      item.style.padding = '10px';
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
    // Item 2 should stretch
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('uses auto for both axes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.placeItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (auto)';
        item.style.placeSelf = 'auto';
        item.style.fontSize = '11px';
      }
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Auto should inherit from place-items (center)
    expect(getComputedStyle(items[1]).alignSelf).toBe('auto');
    expect(getComputedStyle(items[1]).justifySelf).toBe('auto');

    grid.remove();
  });

  it('overrides place-items alignment', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 80px)';
    grid.style.gridTemplateRows = '90px';
    grid.style.placeItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const placements = ['center', 'end', 'stretch', 'start'];
    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = placements[i];
      item.style.placeSelf = placements[i];
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047', '#388E3C'][i];
      item.style.padding = '8px';
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
    // Stretch item should fill the grid area
    expect(items[2].getBoundingClientRect().width).toBe(80);
    expect(items[2].getBoundingClientRect().height).toBe(90);

    grid.remove();
  });
});
