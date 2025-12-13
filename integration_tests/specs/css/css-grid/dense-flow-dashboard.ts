describe('CSS Grid dense auto-flow dashboard', () => {
  it('backfills gaps when auto-flow row dense', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 60px)';
    grid.style.gridAutoRows = '50px';
    grid.style.gap = '8px';
    grid.style.width = '300px';
    grid.style.padding = '12px';
    grid.style.background = '#f3f4f6';
    grid.style.border = '1px solid #d1d5db';
    grid.style.gridAutoFlow = 'row dense';

    const tiles = [
      { id: 'wide', col: '1 / span 3', row: 'auto', color: '#fca5a5' },
      { id: 'tall', col: 'auto', row: 'span 2', color: '#fdba74' },
      { id: 'compact', col: 'auto', row: 'auto', color: '#fed7aa' },
      { id: 'mini', col: 'auto', row: 'auto', color: '#d1fae5' },
    ];

    tiles.forEach((tile) => {
      const cell = document.createElement('div');
      cell.textContent = tile.id;
      cell.style.gridColumn = tile.col;
      cell.style.gridRow = tile.row;
      cell.style.backgroundColor = tile.color;
      cell.style.display = 'flex';
      cell.style.alignItems = 'center';
      cell.style.justifyContent = 'center';
      cell.style.borderRadius = '6px';
      grid.appendChild(cell);
      (grid as any)[tile.id] = cell;
    });

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const wideRect = (grid as any)['wide'].getBoundingClientRect();
    const tallRect = (grid as any)['tall'].getBoundingClientRect();
    const compactRect = (grid as any)['compact'].getBoundingClientRect();

    expect(Math.round(tallRect.left)).toBeGreaterThanOrEqual(Math.round(wideRect.right));
    expect(Math.round(compactRect.top)).toBeGreaterThan(Math.round(wideRect.top));
    grid.remove();
  });
});
