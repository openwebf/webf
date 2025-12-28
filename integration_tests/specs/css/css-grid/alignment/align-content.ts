describe('CSS Grid align-content', () => {
  it('aligns content with start', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.height = '200px';
    grid.style.alignContent = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#42A5F5', '#66BB6A', '#FFA726', '#BA68C8'][i];
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
    // Items should start at top edge
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);

    grid.remove();
  });

  it('aligns content with end', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.height = '200px';
    grid.style.alignContent = 'end';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#2196F3', '#1E88E5', '#1976D2', '#1565C0'][i];
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
    // Last row should end at bottom edge
    expect(items[2].getBoundingClientRect().bottom).toBe(grid.getBoundingClientRect().bottom);

    grid.remove();
  });

  it('aligns content with center', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 50px)';
    grid.style.height = '180px';
    grid.style.alignContent = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0', '#8E24AA'][i];
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
    const topSpace = items[0].getBoundingClientRect().top - gridRect.top;
    const bottomSpace = gridRect.bottom - items[2].getBoundingClientRect().bottom;

    // Should be centered with equal space on top and bottom
    expect(Math.abs(topSpace - bottomSpace)).toBeLessThan(1);

    grid.remove();
  });

  it('aligns content with space-between', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(3, 50px)';
    grid.style.height = '220px';
    grid.style.alignContent = 'space-between';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800', '#FB8C00', '#F57C00', '#EF6C00'][i];
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

    // First row at top, last row at bottom
    expect(items[0].getBoundingClientRect().top).toBe(gridRect.top);
    expect(items[4].getBoundingClientRect().bottom).toBe(gridRect.bottom);

    // Equal spacing between rows
    const gap1 = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    const gap2 = items[4].getBoundingClientRect().top - items[2].getBoundingClientRect().bottom;
    expect(Math.abs(gap1 - gap2)).toBeLessThan(1);

    grid.remove();
  });

  it('aligns content with space-around', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 50px)';
    grid.style.height = '180px';
    grid.style.alignContent = 'space-around';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047', '#388E3C'][i];
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

    // Space on top/bottom should be half of space between rows
    const topSpace = items[0].getBoundingClientRect().top - gridRect.top;
    const bottomSpace = gridRect.bottom - items[2].getBoundingClientRect().bottom;
    const middleSpace = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;

    expect(Math.abs(topSpace - bottomSpace)).toBeLessThan(1);
    expect(Math.abs(middleSpace - topSpace * 2)).toBeLessThan(2);

    grid.remove();
  });

  it('aligns content with space-evenly', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 50px)';
    grid.style.height = '180px';
    grid.style.alignContent = 'space-evenly';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7', '#5E35B1'][i];
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
    const topSpace = items[0].getBoundingClientRect().top - gridRect.top;
    const bottomSpace = gridRect.bottom - items[2].getBoundingClientRect().bottom;
    const middleSpace = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;

    expect(Math.abs(topSpace - bottomSpace)).toBeLessThan(1);
    expect(Math.abs(topSpace - middleSpace)).toBeLessThan(1);

    grid.remove();
  });

  it('aligns content with stretch', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 1fr)';
    grid.style.height = '200px';
    grid.style.alignContent = 'stretch';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#4DB6AC', '#26A69A', '#009688', '#00897B'][i];
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
    // Rows should stretch to fill available space
    expect(items[0].getBoundingClientRect().height).toBe(100);
    expect(items[2].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('handles align-content with row gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 50px)';
    grid.style.height = '180px';
    grid.style.alignContent = 'center';
    grid.style.rowGap = '10px';
    grid.style.backgroundColor = '#fce4ec';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#F06292', '#EC407A', '#E91E63', '#D81B60'][i];
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
    // Check gap is maintained
    const gap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(gap).toBe(10);

    grid.remove();
  });

  it('handles align-content with auto-sized tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'auto auto';
    grid.style.height = '200px';
    grid.style.alignContent = 'space-between';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = ['Short', 'Text', 'Longer text', 'More'][i];
      item.style.backgroundColor = ['#FFEB3B', '#FDD835', '#FBC02D', '#F9A825'][i];
      item.style.padding = '10px';
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

    // First row at top, last row at bottom
    expect(items[0].getBoundingClientRect().top).toBe(gridRect.top);
    expect(items[2].getBoundingClientRect().bottom).toBe(gridRect.bottom);

    grid.remove();
  });

  it('handles align-content with single row', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.height = '180px';
    grid.style.alignContent = 'center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#b2dfdb';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#26A69A', '#009688'][i];
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
    const gridCenter = (gridRect.top + gridRect.bottom) / 2;
    const rowCenter = (items[0].getBoundingClientRect().top + items[0].getBoundingClientRect().bottom) / 2;

    // Single row should be centered
    expect(Math.abs(gridCenter - rowCenter)).toBeLessThan(1);

    grid.remove();
  });

  it('handles space-between with two rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 50px)';
    grid.style.height = '200px';
    grid.style.alignContent = 'space-between';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#c5cae9';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#7986CB', '#5C6BC0', '#3F51B5', '#3949AB'][i];
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

    // With two rows, first at top, last at bottom
    expect(items[0].getBoundingClientRect().top).toBe(gridRect.top);
    expect(items[2].getBoundingClientRect().bottom).toBe(gridRect.bottom);

    grid.remove();
  });

  it('handles align-content with mixed row sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '40px 60px 50px';
    grid.style.height = '250px';
    grid.style.alignContent = 'space-evenly';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#d1c4e9';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7', '#5E35B1', '#512DA8', '#4527A0'][i];
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
    expect(items[0].getBoundingClientRect().height).toBe(40);
    expect(items[2].getBoundingClientRect().height).toBe(60);
    expect(items[4].getBoundingClientRect().height).toBe(50);

    grid.remove();
  });
});
