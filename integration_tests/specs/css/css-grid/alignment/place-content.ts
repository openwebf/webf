describe('CSS Grid place-content shorthand', () => {
  it('sets both align-content and justify-content with one value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.width = '250px';
    grid.style.height = '200px';
    grid.style.placeContent = 'center';
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

    // Grid should be centered both vertically and horizontally
    expect(getComputedStyle(grid).alignContent).toBe('center');
    expect(getComputedStyle(grid).justifyContent).toBe('center');

    grid.remove();
  });

  it('sets align-content and justify-content with two values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.width = '250px';
    grid.style.height = '200px';
    grid.style.placeContent = 'start end';
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

    expect(getComputedStyle(grid).alignContent).toBe('start');
    expect(getComputedStyle(grid).justifyContent).toBe('end');

    grid.remove();
  });

  it('uses space-between for both axes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 70px)';
    grid.style.gridTemplateRows = 'repeat(2, 50px)';
    grid.style.width = '220px';
    grid.style.height = '170px';
    grid.style.placeContent = 'space-between';
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

    expect(getComputedStyle(grid).alignContent).toBe('space-between');
    expect(getComputedStyle(grid).justifyContent).toBe('space-between');

    grid.remove();
  });
});
