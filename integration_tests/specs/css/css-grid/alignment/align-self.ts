describe('CSS Grid align-self', () => {
  it('aligns individual item with start', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (start)';
        item.style.alignSelf = 'start';
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
    // Item 2 should be at top of grid area
    expect(items[1].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);

    grid.remove();
  });

  it('aligns individual item with end', async () => {
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
        item.textContent += ' (end)';
        item.style.alignSelf = 'end';
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
    // Item 2 should be at bottom of grid area
    expect(items[1].getBoundingClientRect().bottom).toBe(grid.getBoundingClientRect().bottom);

    grid.remove();
  });

  it('aligns individual item with center', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (center)';
        item.style.alignSelf = 'center';
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
    // Item 2 should be vertically centered
    const gridCenter = (grid.getBoundingClientRect().top + grid.getBoundingClientRect().bottom) / 2;
    const item2Center = (items[1].getBoundingClientRect().top + items[1].getBoundingClientRect().bottom) / 2;
    expect(Math.abs(item2Center - gridCenter)).toBeLessThan(1);

    grid.remove();
  });

  it('stretches individual item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (stretch)';
        item.style.alignSelf = 'stretch';
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
    // Item 2 should stretch to fill grid area height
    expect(items[1].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('aligns with baseline', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = 'Text';
      if (i === 1) {
        item.style.alignSelf = 'baseline';
      }
      item.style.fontSize = ['16px', '20px', '24px'][i];
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047'][i];
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

  it('overrides with multiple items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 80px)';
    grid.style.gridTemplateRows = '90px';
    grid.style.alignItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const alignments = ['start', 'end', 'stretch', 'center'];
    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = alignments[i];
      item.style.alignSelf = alignments[i];
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7', '#5E35B1'][i];
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
    // Stretch item should be tallest
    expect(items[2].getBoundingClientRect().height).toBe(90);

    grid.remove();
  });

  it('aligns with first baseline', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = 'Text';
      if (i === 1) {
        item.style.alignSelf = 'first baseline';
      }
      item.style.fontSize = ['14px', '18px', '22px'][i];
      item.style.backgroundColor = ['#4DB6AC', '#26A69A', '#009688'][i];
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
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      if (i === 1) {
        item.textContent += ' (auto)';
        item.style.alignSelf = 'auto';
        item.style.fontSize = '10px';
      }
      item.style.backgroundColor = ['#F06292', '#EC407A', '#E91E63'][i];
      item.style.padding = '10px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Auto should inherit from align-items (center)
    expect(items.length).toBe(3);

    grid.remove();
  });
});
