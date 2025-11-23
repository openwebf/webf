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


  it('supports span placement over multiple implicit rows', async () => {
    const grid = buildGrid((element, cells) => {
      cells[0].style.gridColumn = '1 / span 2';
      cells[0].style.gridRow = '1 / span 2';
      cells[2].style.gridColumn = '1 / span 2';
      element.style.gridAutoFlow = 'row dense';
    });

    const computed = getComputedStyle(grid);
    expect(computed.gridAutoFlow).toEqual('row dense');
    await snapshot();
    grid.remove();
  });

  it('places children across repeat columns', async () => {
    const grid = buildGrid(() => {});

    await snapshot();

    const child1 = grid.children[0] as HTMLElement;
    const child2 = grid.children[1] as HTMLElement;
    const child3 = grid.children[2] as HTMLElement;

    const rect1 = child1.getBoundingClientRect();
    const rect2 = child2.getBoundingClientRect();
    const rect3 = child3.getBoundingClientRect();

    expect(rect2.left).toBeGreaterThan(rect1.left);
    expect(rect3.top).toBeGreaterThan(rect1.top);
    expect(rect3.left).toBeCloseTo(rect1.left, 1);
    grid.remove();
  });
});
