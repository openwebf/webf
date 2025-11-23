describe('CSS Grid auto placement', () => {
  const buildGrid = (configure: (grid: HTMLDivElement, cells: HTMLDivElement[]) => void) => {
    const grid = document.createElement('div');
    grid.style.width = '320px';
    grid.style.minHeight = '160px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.border = '1px solid #ccc';
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 1fr)';
    grid.style.gridAutoRows = '60px';
    grid.style.rowGap = '8px';
    grid.style.columnGap = '12px';
    grid.style.padding = '8px';

    const cells: HTMLDivElement[] = [];
    for (let i = 0; i < 5; i++) {
      const cell = document.createElement('div');
      cell.textContent = `Item ${i + 1}`;
      cell.style.backgroundColor = 'rgba(100, 149, 237, 0.4)';
      cell.style.border = '1px solid rgba(100, 149, 237, 0.8)';
      cell.style.display = 'flex';
      cell.style.alignItems = 'center';
      cell.style.justifyContent = 'center';
      cells.push(cell);
      grid.appendChild(cell);
    }

    configure(grid, cells);

    document.body.appendChild(grid);
    return grid;
  };

  it('lays out implicit rows', async () => {
    const grid = buildGrid(() => {});
    await snapshot();
    grid.remove();
  });

});
