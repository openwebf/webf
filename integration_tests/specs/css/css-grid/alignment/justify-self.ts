describe('CSS Grid justify-self', () => {
  it('aligns individual item with start', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2 (start)';
    item2.style.justifySelf = 'start';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = '3';
    item3.style.backgroundColor = '#FFA726';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Item 2 should be at start of its grid area
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 100);

    grid.remove();
  });

  it('aligns individual item with end', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (end)';
        item.style.justifySelf = 'end';
        item.style.fontSize = '11px';
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
    // Item 2 should be at end of its grid area
    expect(items[1].getBoundingClientRect().right).toBe(grid.getBoundingClientRect().left + 200);

    grid.remove();
  });

  it('aligns individual item with center', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (center)';
        item.style.justifySelf = 'center';
        item.style.fontSize = '10px';
      }
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Item 2 should be centered
    const item2Center = (items[1].getBoundingClientRect().left + items[1].getBoundingClientRect().right) / 2;
    const area2Center = grid.getBoundingClientRect().left + 150; // Second column center
    expect(Math.abs(item2Center - area2Center)).toBeLessThan(1);

    grid.remove();
  });

  it('stretches individual item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (stretch)';
        item.style.justifySelf = 'stretch';
        item.style.fontSize = '10px';
      }
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800'][i];
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
    // Item 2 should stretch to fill grid area
    expect(items[1].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('overrides with multiple items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 80px)';
    grid.style.gridTemplateRows = '70px';
    grid.style.justifyItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const alignments = ['start', 'end', 'stretch', 'center'];
    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = alignments[i];
      item.style.justifySelf = alignments[i];
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
    expect(items.length).toBe(4);
    // Stretch item should be widest
    expect(items[2].getBoundingClientRect().width).toBe(80);

    grid.remove();
  });

  it('aligns with baseline', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = 'Text';
      if (i === 1) {
        item.style.justifySelf = 'baseline';
      }
      item.style.fontSize = ['14px', '18px', '22px'][i];
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7'][i];
      item.style.padding = '5px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);

    grid.remove();
  });

  it('handles auto alignment', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e1bee7';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (auto)';
        item.style.justifySelf = 'auto';
        item.style.fontSize = '10px';
      }
      item.style.backgroundColor = ['#CE93D8', '#BA68C8', '#AB47BC'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Auto should inherit from justify-items (center)
    expect(items.length).toBe(3);

    grid.remove();
  });
});
