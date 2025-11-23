describe('CSS Grid auto columns', () => { 

  it('handles auto columns when grid has no children', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '80px';
    grid.style.gridAutoColumns = '60px';
    grid.style.padding = '12px';
    grid.style.border = '1px dashed #bbb';
    grid.style.borderRadius = '6px';
    grid.style.background = '#fdfdfd';
    grid.style.minHeight = '48px';

    document.body.appendChild(grid);
    await snapshot();

    const rect = grid.getBoundingClientRect();
    expect(rect.width).toBeGreaterThan(40);
    expect(rect.height).toBeGreaterThanOrEqual(24);
    grid.remove();
  });

  it('keeps auto-placed items on one row when columns are auto-generated', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '80px';
    grid.style.gridAutoColumns = '60px';
    grid.style.columnGap = '12px';
    grid.style.padding = '8px';
    grid.style.background = '#fdf2f8';
    grid.style.border = '1px solid #f472b6';
    grid.style.borderRadius = '8px';

    const labels = ['Col1', 'Col2', 'Col3', 'Col4'];
    labels.forEach(label => {
      const cell = document.createElement('div');
      cell.textContent = label;
      cell.style.height = '32px';
      cell.style.display = 'flex';
      cell.style.alignItems = 'center';
      cell.style.justifyContent = 'center';
      cell.style.background = '#f9a8d4';
      cell.style.borderRadius = '4px';
      grid.appendChild(cell);
    });

    document.body.appendChild(grid);
    await snapshot();
  });

  it('allows explicit multi-line placement while others stay inline', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '60px';
    grid.style.gridAutoColumns = '50px';
    grid.style.gridAutoRows = '40px';
    grid.style.columnGap = '6px';
    grid.style.rowGap = '6px';
    grid.style.padding = '8px';
    grid.style.background = '#ecfccb';
    grid.style.borderRadius = '6px';

    const makeCell = (text: string) => {
      const cell = document.createElement('div');
      cell.textContent = text;
      cell.style.display = 'flex';
      cell.style.alignItems = 'center';
      cell.style.justifyContent = 'center';
      cell.style.background = '#bef264';
      cell.style.height = '40px';
      cell.style.fontWeight = '600';
      cell.style.borderRadius = '4px';
      grid.appendChild(cell);
      return cell;
    };

    const a = makeCell('A');
    const b = makeCell('B');
    const c = makeCell('Bottom span');

    a.style.gridColumn = '1';
    b.style.gridColumn = '2';
    c.style.gridColumn = '1 / span 2';
    c.style.gridRow = '2';

    document.body.appendChild(grid);
    await snapshot();
  });

  it('expands width when items reference implicit columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '80px';
    grid.style.gridAutoColumns = '40px';
    grid.style.gridAutoRows = '48px';
    grid.style.columnGap = '0';
    grid.style.rowGap = '12px';
    grid.style.padding = '12px';
    grid.style.backgroundColor = '#eef2ff';
    grid.style.borderRadius = '10px';
    grid.style.boxShadow = 'inset 0 0 0 1px rgba(76, 81, 191, 0.2)';
    grid.style.fontFamily = 'system-ui, -apple-system, BlinkMacSystemFont, sans-serif';

    const labels = ['Base', 'Implicit 2', 'Implicit 3', 'Span 2'];
    const cells = labels.map((label, index) => {
      const cell = document.createElement('div');
      cell.textContent = label;
      cell.style.backgroundColor = ['#c7d2fe', '#a5b4fc', '#818cf8', '#6366f1'][index];
      cell.style.color = '#111827';
      cell.style.borderRadius = '8px';
      cell.style.display = 'flex';
      cell.style.alignItems = 'center';
      cell.style.justifyContent = 'center';
      cell.style.height = '48px';
      cell.style.fontWeight = '600';
      cell.style.letterSpacing = '0.2px';
      grid.appendChild(cell);
      return cell;
    });

    document.body.appendChild(grid);

    cells[1].style.gridColumn = '2';
    cells[2].style.gridColumn = '3';
    cells[3].style.gridColumn = '2 / span 2';
    cells[3].style.height = '104px';

    await snapshot();
  });
});
