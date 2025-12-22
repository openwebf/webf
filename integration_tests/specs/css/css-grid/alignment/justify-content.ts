describe('CSS Grid justify-content', () => {
  it('aligns content with start', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '350px';
    grid.style.justifyContent = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#42A5F5', '#66BB6A', '#FFA726'][i];
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
    // Items should start at left edge
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);

    grid.remove();
  });

  it('aligns content with end', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '350px';
    grid.style.justifyContent = 'end';
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
    // Last item should end at right edge
    expect(items[2].getBoundingClientRect().right).toBe(grid.getBoundingClientRect().right);

    grid.remove();
  });

  it('aligns content with center', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 70px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '300px';
    grid.style.justifyContent = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
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
    const gridRect = grid.getBoundingClientRect();
    const firstItemLeft = items[0].getBoundingClientRect().left - gridRect.left;
    const lastItemRight = gridRect.right - items[2].getBoundingClientRect().right;

    // Should be centered with equal space on both sides
    expect(Math.abs(firstItemLeft - lastItemRight)).toBeLessThan(1);

    grid.remove();
  });

  it('aligns content with space-between', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 70px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '300px';
    grid.style.justifyContent = 'space-between';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800'][i];
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
    const gridRect = grid.getBoundingClientRect();

    // First item at start, last at end
    expect(items[0].getBoundingClientRect().left).toBe(gridRect.left);
    expect(items[2].getBoundingClientRect().right).toBe(gridRect.right);

    // Equal spacing between items
    const gap1 = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    const gap2 = items[2].getBoundingClientRect().left - items[1].getBoundingClientRect().right;
    expect(Math.abs(gap1 - gap2)).toBeLessThan(1);

    grid.remove();
  });

  it('aligns content with space-around', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 60px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '300px';
    grid.style.justifyContent = 'space-around';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047'][i];
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
    const gridRect = grid.getBoundingClientRect();

    // Space on sides should be half of space between items
    const leftSpace = items[0].getBoundingClientRect().left - gridRect.left;
    const rightSpace = gridRect.right - items[2].getBoundingClientRect().right;
    const middleSpace = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;

    expect(Math.abs(leftSpace - rightSpace)).toBeLessThan(1);
    expect(Math.abs(middleSpace - leftSpace * 2)).toBeLessThan(2);

    grid.remove();
  });

  it('aligns content with space-evenly', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 60px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '300px';
    grid.style.justifyContent = 'space-evenly';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7'][i];
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
    const gridRect = grid.getBoundingClientRect();

    // All gaps should be equal
    const leftSpace = items[0].getBoundingClientRect().left - gridRect.left;
    const rightSpace = gridRect.right - items[2].getBoundingClientRect().right;
    const gap1 = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    const gap2 = items[2].getBoundingClientRect().left - items[1].getBoundingClientRect().right;

    expect(Math.abs(leftSpace - rightSpace)).toBeLessThan(1);
    expect(Math.abs(leftSpace - gap1)).toBeLessThan(1);
    expect(Math.abs(gap1 - gap2)).toBeLessThan(1);

    grid.remove();
  });

  it('aligns content with stretch', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '300px';
    grid.style.justifyContent = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#4DB6AC', '#26A69A', '#009688'][i];
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
    // Items should stretch to fill available space
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(100);
    });

    grid.remove();
  });

  it('handles justify-content with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 70px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '300px';
    grid.style.justifyContent = 'center';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#fce4ec';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#F06292', '#EC407A', '#E91E63'][i];
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
    // Check gaps are maintained
    const gap1 = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    const gap2 = items[2].getBoundingClientRect().left - items[1].getBoundingClientRect().right;
    expect(gap1).toBe(10);
    expect(gap2).toBe(10);

    grid.remove();
  });

  it('handles justify-content with auto-sized tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto auto';
    grid.style.gridTemplateRows = '60px';
    grid.style.width = '300px';
    grid.style.justifyContent = 'space-between';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['Short', 'Medium text', 'Long text here'][i];
      item.style.backgroundColor = ['#FFEB3B', '#FDD835', '#FBC02D'][i];
      item.style.padding = '5px';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.fontSize = '11px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const gridRect = grid.getBoundingClientRect();

    // First at start, last at end
    expect(items[0].getBoundingClientRect().left).toBe(gridRect.left);
    expect(items[2].getBoundingClientRect().right).toBe(gridRect.right);

    grid.remove();
  });
});
