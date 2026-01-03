describe('CSS Grid nested grids', () => {
  it('renders grid inside grid', async () => {
    const outerGrid = document.createElement('div');
    outerGrid.style.display = 'grid';
    outerGrid.style.gridTemplateColumns = 'repeat(2, 200px)';
    outerGrid.style.gridTemplateRows = 'repeat(2, 150px)';
    outerGrid.style.gap = '15px';
    outerGrid.style.backgroundColor = '#f5f5f5';

    const innerGrid = document.createElement('div');
    innerGrid.style.display = 'grid';
    innerGrid.style.gridTemplateColumns = 'repeat(2, 80px)';
    innerGrid.style.gridTemplateRows = 'repeat(2, 60px)';
    innerGrid.style.gap = '8px';
    innerGrid.style.backgroundColor = '#42A5F5';
    innerGrid.style.padding = '10px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = '#BBDEFB';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      innerGrid.appendChild(item);
    }

    outerGrid.appendChild(innerGrid);

    // Regular outer grid items
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `Outer ${i + 1}`;
      item.style.backgroundColor = '#66BB6A';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      outerGrid.appendChild(item);
    }

    document.body.appendChild(outerGrid);
    await waitForFrame();
    await snapshot();

    expect(innerGrid.getBoundingClientRect().width).toBe(200);

    outerGrid.remove();
  });

  it('handles deeply nested grids', async () => {
    const level1 = document.createElement('div');
    level1.style.display = 'grid';
    level1.style.gridTemplateColumns = '300px';
    level1.style.gridTemplateRows = 'auto';
    level1.style.gap = '10px';
    level1.style.backgroundColor = '#e3f2fd';
    level1.style.padding = '10px';

    const level2 = document.createElement('div');
    level2.style.display = 'grid';
    level2.style.gridTemplateColumns = 'repeat(2, 130px)';
    level2.style.gridTemplateRows = 'auto';
    level2.style.gap = '8px';
    level2.style.backgroundColor = '#2196F3';
    level2.style.padding = '10px';

    const level3 = document.createElement('div');
    level3.style.display = 'grid';
    level3.style.gridTemplateColumns = 'repeat(2, 55px)';
    level3.style.gridTemplateRows = 'auto';
    level3.style.gap = '5px';
    level3.style.backgroundColor = '#1976D2';
    level3.style.padding = '8px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = '#BBDEFB';
      item.style.padding = '10px';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      item.style.fontSize = '10px';
      level3.appendChild(item);
    }

    level2.appendChild(level3);
    level1.appendChild(level2);
    document.body.appendChild(level1);
    await waitForFrame();
    await snapshot();

    expect(level3.children.length).toBe(4);

    level1.remove();
  });

  it('nests grid with spanning items', async () => {
    const outerGrid = document.createElement('div');
    outerGrid.style.display = 'grid';
    outerGrid.style.gridTemplateColumns = 'repeat(3, 120px)';
    outerGrid.style.gridTemplateRows = 'repeat(2, 100px)';
    outerGrid.style.gap = '10px';
    outerGrid.style.backgroundColor = '#f3e5f5';

    const innerGrid = document.createElement('div');
    innerGrid.style.display = 'grid';
    innerGrid.style.gridColumn = '1 / 3'; // Spans 2 columns in outer
    innerGrid.style.gridRow = '1 / 3'; // Spans 2 rows in outer
    innerGrid.style.gridTemplateColumns = 'repeat(2, 1fr)';
    innerGrid.style.gridTemplateRows = 'repeat(2, 1fr)';
    innerGrid.style.gap = '8px';
    innerGrid.style.backgroundColor = '#BA68C8';
    innerGrid.style.padding = '10px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `Inner ${i + 1}`;
      item.style.backgroundColor = '#E1BEE7';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      item.style.fontSize = '11px';
      innerGrid.appendChild(item);
    }

    outerGrid.appendChild(innerGrid);

    // Other outer items
    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Outer ${i + 1}`;
      item.style.backgroundColor = '#9C27B0';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      outerGrid.appendChild(item);
    }

    document.body.appendChild(outerGrid);
    await waitForFrame();
    await snapshot();

    // Inner grid spans 2x2 outer cells: 120 + 10 + 120 = 250
    expect(innerGrid.getBoundingClientRect().width).toBe(250);

    outerGrid.remove();
  });

  it('mixes nested grids with different layouts', async () => {
    const container = document.createElement('div');
    container.style.display = 'grid';
    container.style.gridTemplateColumns = '250px 250px';
    container.style.gridTemplateRows = 'auto';
    container.style.gap = '15px';
    container.style.backgroundColor = '#fff3e0';

    // Grid 1: row layout
    const grid1 = document.createElement('div');
    grid1.style.display = 'grid';
    grid1.style.gridTemplateColumns = '1fr';
    grid1.style.gridTemplateRows = 'repeat(3, 60px)';
    grid1.style.gap = '5px';
    grid1.style.backgroundColor = '#FFB74D';
    grid1.style.padding = '10px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `A${i + 1}`;
      item.style.backgroundColor = '#FFE0B2';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      grid1.appendChild(item);
    }

    // Grid 2: column layout
    const grid2 = document.createElement('div');
    grid2.style.display = 'grid';
    grid2.style.gridTemplateColumns = 'repeat(3, 70px)';
    grid2.style.gridTemplateRows = '1fr';
    grid2.style.gap = '5px';
    grid2.style.backgroundColor = '#FF9800';
    grid2.style.padding = '10px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `B${i + 1}`;
      item.style.backgroundColor = '#FFCC80';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      grid2.appendChild(item);
    }

    container.appendChild(grid1);
    container.appendChild(grid2);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    expect(grid1.children.length).toBe(3);
    expect(grid2.children.length).toBe(3);

    container.remove();
  });

  it('handles nested grids with auto-placement', async () => {
    const outerGrid = document.createElement('div');
    outerGrid.style.display = 'grid';
    outerGrid.style.gridTemplateColumns = 'repeat(2, 180px)';
    outerGrid.style.gridAutoRows = 'minmax(120px, auto)';
    outerGrid.style.gap = '12px';
    outerGrid.style.backgroundColor = '#e8f5e9';

    for (let g = 0; g < 2; g++) {
      const innerGrid = document.createElement('div');
      innerGrid.style.display = 'grid';
      innerGrid.style.gridTemplateColumns = 'repeat(2, 1fr)';
      innerGrid.style.gridAutoRows = '50px';
      innerGrid.style.gap = '6px';
      innerGrid.style.backgroundColor = '#66BB6A';
      innerGrid.style.padding = '10px';

      for (let i = 0; i < 4; i++) {
        const item = document.createElement('div');
        item.textContent = `${g + 1}.${i + 1}`;
        item.style.backgroundColor = '#C8E6C9';
        item.style.display = 'flex';
        item.style.alignItems = 'center';
        item.style.justifyContent = 'center';
        item.style.color = '#333';
        item.style.fontSize = '11px';
        innerGrid.appendChild(item);
      }

      outerGrid.appendChild(innerGrid);
    }

    document.body.appendChild(outerGrid);
    await waitForFrame();
    await snapshot();

    const innerGrids = Array.from(outerGrid.children) as HTMLElement[];
    expect(innerGrids.length).toBe(2);

    outerGrid.remove();
  });

  it('preserves grid context across nesting levels', async () => {
    const outerGrid = document.createElement('div');
    outerGrid.style.display = 'grid';
    outerGrid.style.gridTemplateColumns = '300px';
    outerGrid.style.justifyContent = 'center';
    outerGrid.style.backgroundColor = '#ede7f6';
    outerGrid.style.padding = '20px';

    const innerGrid = document.createElement('div');
    innerGrid.style.display = 'grid';
    innerGrid.style.gridTemplateColumns = 'repeat(3, 90px)';
    innerGrid.style.gridTemplateRows = 'auto';
    innerGrid.style.gap = '5px';
    innerGrid.style.justifyContent = 'space-between';
    innerGrid.style.backgroundColor = '#9575CD';
    innerGrid.style.padding = '12px';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = '#D1C4E9';
      item.style.padding = '15px';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      innerGrid.appendChild(item);
    }

    outerGrid.appendChild(innerGrid);
    document.body.appendChild(outerGrid);
    await waitForFrame();
    await snapshot();

    expect(innerGrid.children.length).toBe(6);

    outerGrid.remove();
  });
});
