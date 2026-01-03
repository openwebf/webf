describe('CSS Grid inside flexbox', () => {
  it('renders grid as flex item', async () => {
    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.gap = '15px';
    flex.style.backgroundColor = '#f5f5f5';
    flex.style.padding = '15px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#42A5F5';
    grid.style.padding = '10px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = '#BBDEFB';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      grid.appendChild(item);
    }

    flex.appendChild(grid);

    const textDiv = document.createElement('div');
    textDiv.textContent = 'Flex sibling';
    textDiv.style.backgroundColor = '#66BB6A';
    textDiv.style.padding = '20px';
    textDiv.style.color = 'white';
    flex.appendChild(textDiv);

    document.body.appendChild(flex);
    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const siblingRect = textDiv.getBoundingClientRect();

    // As a flex item, the grid's automatic minimum size should be its content-based
    // minimum (min-size:auto), so fixed tracks should not be flex-shrunk.
    expect(gridRect.width).toBeCloseTo(230, 0); // (100 + 10 + 100) + padding(20)
    expect(siblingRect.width).toBeLessThan(100);

    flex.remove();
  });

  it('handles flex-grow on grid item', async () => {
    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.width = '600px';
    flex.style.gap = '10px';
    flex.style.backgroundColor = '#e3f2fd';
    flex.style.padding = '15px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 1fr)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gap = '8px';
    grid.style.flexGrow = '1';
    grid.style.backgroundColor = '#2196F3';
    grid.style.padding = '10px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = '#90CAF9';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    flex.appendChild(grid);

    const sidebar = document.createElement('div');
    sidebar.textContent = 'Sidebar';
    sidebar.style.width = '150px';
    sidebar.style.backgroundColor = '#1976D2';
    sidebar.style.padding = '20px';
    sidebar.style.color = 'white';
    flex.appendChild(sidebar);

    document.body.appendChild(flex);
    await waitForFrame();
    await snapshot();

    // Grid should grow to fill available space
    expect(grid.getBoundingClientRect().width).toBeGreaterThan(300);

    flex.remove();
  });

  it('handles flex-direction column with grid', async () => {
    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.flexDirection = 'column';
    flex.style.height = '400px';
    flex.style.gap = '12px';
    flex.style.backgroundColor = '#f3e5f5';
    flex.style.padding = '15px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '8px';
    grid.style.backgroundColor = '#BA68C8';
    grid.style.padding = '12px';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = '#E1BEE7';
      item.style.padding = '15px';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      grid.appendChild(item);
    }

    flex.appendChild(grid);

    const footer = document.createElement('div');
    footer.textContent = 'Footer';
    footer.style.backgroundColor = '#9C27B0';
    footer.style.padding = '20px';
    footer.style.color = 'white';
    flex.appendChild(footer);

    document.body.appendChild(flex);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(6);

    flex.remove();
  });

  it('aligns grid within flex container', async () => {
    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.justifyContent = 'center';
    flex.style.alignItems = 'center';
    flex.style.height = '300px';
    flex.style.backgroundColor = '#fff3e0';
    flex.style.padding = '20px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#FFB74D';
    grid.style.padding = '12px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = '#FFE0B2';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      grid.appendChild(item);
    }

    flex.appendChild(grid);
    document.body.appendChild(flex);
    await waitForFrame();
    await snapshot();

    // Grid should be centered in flex container
    const flexCenter = flex.getBoundingClientRect().left + flex.getBoundingClientRect().width / 2;
    const gridCenter = grid.getBoundingClientRect().left + grid.getBoundingClientRect().width / 2;
    expect(Math.abs(flexCenter - gridCenter)).toBeLessThan(5);

    flex.remove();
  });

  it('handles multiple grids in flex row', async () => {
    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.gap = '15px';
    flex.style.backgroundColor = '#e8f5e9';
    flex.style.padding = '15px';

    for (let g = 0; g < 3; g++) {
      const grid = document.createElement('div');
      grid.style.display = 'grid';
      grid.style.gridTemplateColumns = 'repeat(2, 70px)';
      grid.style.gridTemplateRows = 'repeat(2, 60px)';
      grid.style.gap = '6px';
      grid.style.backgroundColor = `hsl(${120 + g * 15}, 60%, 55%)`;
      grid.style.padding = '10px';

      for (let i = 0; i < 4; i++) {
        const item = document.createElement('div');
        item.textContent = `${g + 1}.${i + 1}`;
        item.style.backgroundColor = `hsl(${120 + g * 15}, 40%, 85%)`;
        item.style.display = 'flex';
        item.style.alignItems = 'center';
        item.style.justifyContent = 'center';
        item.style.color = '#333';
        item.style.fontSize = '10px';
        grid.appendChild(item);
      }

      flex.appendChild(grid);
    }

    document.body.appendChild(flex);
    await waitForFrame();
    await snapshot();

    const grids = Array.from(flex.children) as HTMLElement[];
    expect(grids.length).toBe(3);

    flex.remove();
  });

  it('handles flex-shrink on grid', async () => {
    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.width = '300px';
    flex.style.gap = '10px';
    flex.style.backgroundColor = '#ede7f6';
    flex.style.padding = '12px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '6px';
    grid.style.flexShrink = '1';
    grid.style.backgroundColor = '#9575CD';
    grid.style.padding = '10px';
    grid.style.minWidth = '0'; // Allow shrinking below content size

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = '#D1C4E9';
      item.style.padding = '12px';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = '#333';
      grid.appendChild(item);
    }

    flex.appendChild(grid);

    const sidebar = document.createElement('div');
    sidebar.textContent = 'Fixed';
    sidebar.style.width = '100px';
    sidebar.style.flexShrink = '0';
    sidebar.style.backgroundColor = '#673AB7';
    sidebar.style.padding = '20px';
    sidebar.style.color = 'white';
    flex.appendChild(sidebar);

    document.body.appendChild(flex);
    await waitForFrame();
    await snapshot();

    // Grid should fit within flex container constraints
    expect(grid.getBoundingClientRect().right).toBeLessThanOrEqual(flex.getBoundingClientRect().right);

    flex.remove();
  });
});
