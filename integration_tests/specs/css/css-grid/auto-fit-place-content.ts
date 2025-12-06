describe('CSS Grid auto-fit dashboards', () => {
  const addTiles = (grid: HTMLDivElement) => {
    ['A', 'B', 'C'].forEach((label, index) => {
      const tile = document.createElement('div');
      tile.textContent = label;
      tile.style.height = '60px';
      tile.style.background = ['#bfdbfe', '#93c5fd', '#60a5fa'][index];
      tile.style.display = 'flex';
      tile.style.alignItems = 'center';
      tile.style.justifyContent = 'center';
      tile.style.borderRadius = '8px';
      grid.appendChild(tile);
    });
  };

  it('centers tiles when auto-fit leaves empty space', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '320px';
    grid.style.minHeight = '200px';
    grid.style.gridTemplateColumns = 'repeat(auto-fit, minmax(80px, 1fr))';
    grid.style.gridAutoRows = '60px';
    grid.style.rowGap = '12px';
    grid.style.columnGap = '12px';
    grid.style.padding = '12px';
    grid.style.backgroundColor = '#f8fafc';
    grid.style.border = '1px solid #cbd5f5';
    grid.style.borderRadius = '12px';
    grid.style.placeContent = 'center center';
    addTiles(grid as HTMLDivElement);
    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();
  });

  it('space-evenly distributes tiles with auto-fill', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '320px';
    grid.style.minHeight = '200px';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, minmax(80px, 1fr))';
    grid.style.gridAutoRows = '60px';
    grid.style.rowGap = '12px';
    grid.style.columnGap = '12px';
    grid.style.padding = '12px';
    grid.style.backgroundColor = '#f8fafc';
    grid.style.border = '1px solid #cbd5f5';
    grid.style.borderRadius = '12px';
    grid.style.placeContent = 'space-evenly flex-start';
    addTiles(grid as HTMLDivElement);
    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();
  });
});
