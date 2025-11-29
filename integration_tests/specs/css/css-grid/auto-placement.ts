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
    await waitForFrame();
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
    await waitForFrame();
    await snapshot();
    grid.remove();
  });

  it('places children across repeat columns', async () => {
    const grid = buildGrid(() => {});

    await waitForFrame();
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

  it('supports column auto-flow creating new columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridTemplateRows = '40px 40px';
    grid.style.gridAutoColumns = '64px';
    grid.style.columnGap = '6px';
    grid.style.rowGap = '4px';
    grid.style.padding = '8px';
    grid.style.backgroundColor = '#fdfdfd';

    for (let i = 0; i < 4; i++) {
      const cell = document.createElement('div');
      cell.textContent = `Col ${i + 1}`;
      cell.style.height = '40px';
      cell.style.display = 'flex';
      cell.style.alignItems = 'center';
      cell.style.justifyContent = 'center';
      cell.style.border = '1px solid #ddd';
      grid.appendChild(cell);
    }

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const first = grid.children[0] as HTMLElement;
    const third = grid.children[2] as HTMLElement;
    const rectFirst = first.getBoundingClientRect();
    const rectThird = third.getBoundingClientRect();

    expect(rectThird.left).toBeGreaterThan(rectFirst.left);
    expect(rectThird.top).toBeCloseTo(rectFirst.top, 1);
    grid.remove();
  });

  it('uses implicit rows created by explicit placement in column flow', async () => {
    const grid = document.createElement('div');
    grid.id = 'grid-implicit-rows';
    grid.style.display = 'grid';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridTemplateRows = '24px 24px';
    grid.style.gridAutoColumns = '48px';
    grid.style.rowGap = '0px';
    grid.style.columnGap = '0px';

    const extender = document.createElement('div');
    extender.style.gridColumn = '2';
    extender.style.gridRow = '3';
    extender.style.height = '24px';
    grid.appendChild(extender);

    const autoCells: HTMLElement[] = [];
    for (let i = 0; i < 3; i++) {
      const cell = document.createElement('div');
      cell.style.height = '24px';
      cell.textContent = `auto-${i}`;
      grid.appendChild(cell);
      autoCells.push(cell);
    }

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const first = autoCells[0];
    const third = autoCells[2];
    const rectFirst = first.getBoundingClientRect();
    const rectThird = third.getBoundingClientRect();

    expect(rectThird.left).toBeCloseTo(rectFirst.left, 1);
    expect(rectThird.top).toBeGreaterThan(rectFirst.bottom);
    grid.remove();
  });

  it('spans grid using negative line numbers', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '50px 50px 50px';
    grid.style.gridTemplateRows = '30px 30px';

    const cell = document.createElement('div');
    cell.id = 'negative-span';
    cell.style.gridColumn = '1 / -1';
    cell.style.gridRow = '1 / -1';
    cell.textContent = 'span';
    grid.appendChild(cell);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const rect = cell.getBoundingClientRect();
    expect(Math.round(rect.width)).toBeGreaterThanOrEqual(150);
    expect(Math.round(rect.height)).toBeGreaterThanOrEqual(60);
    grid.remove();
  });

  it('honors justify-content center', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;min-width:200px;max-width:200px;grid-template-columns:50px 50px;justify-content:center;',
    );

    const cell = document.createElement('div');
    cell.style.height = '20px';
    cell.style.backgroundColor = 'red'
    grid.appendChild(cell);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const cellRect = cell.getBoundingClientRect();
    expect(Math.round(cellRect.left - gridRect.left)).toBeGreaterThanOrEqual(50);
    grid.remove();
  });

  it('honors align-content flex-end', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;min-height:200px;max-height:200px;grid-template-columns:60px;grid-template-rows:40px 40px;align-content:flex-end;',
    );

    for (let i = 0; i < 2; i++) {
      const cell = document.createElement('div');
      cell.style.height = '40px';
      cell.style.backgroundColor = 'red';
      grid.appendChild(cell);
    }

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const firstRect = (grid.children[0] as HTMLElement).getBoundingClientRect();
    expect(Math.round(firstRect.top - gridRect.top)).toBeGreaterThanOrEqual(119);
    grid.remove();
  });

  it('honors justify-items center for grid cells', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;width:100px;grid-template-columns:100px;justify-items:center;',
    );

    const cell = document.createElement('div');
    cell.style.width = '20px';
    cell.style.height = '10px';
    cell.style.display = 'inline-block';
    cell.style.backgroundColor = 'rgba(255, 0, 0, 0.6)';
    grid.appendChild(cell);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const cellRect = cell.getBoundingClientRect();
    expect(Math.round(cellRect.left - gridRect.left)).toBeGreaterThanOrEqual(40);
    grid.remove();
  });

  it('honors justify-self end overriding container items', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;width:100px;grid-template-columns:100px;justify-items:start;',
    );

    const cell = document.createElement('div');
    cell.style.width = '20px';
    cell.style.height = '10px';
    cell.style.display = 'inline-block';
    cell.style.backgroundColor = 'rgba(0, 128, 255, 0.6)';
    cell.style.justifySelf = 'end';
    grid.appendChild(cell);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const cellRect = cell.getBoundingClientRect();
    expect(Math.round(cellRect.left - gridRect.left)).toBeGreaterThanOrEqual(80);
    grid.remove();
  });

  it('honors align-items center for explicit rows', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;height:120px;grid-template-columns:60px;grid-template-rows:120px;align-items:center;',
    );

    const cell = document.createElement('div');
    cell.style.height = '40px';
    cell.style.display = 'inline-block';
    cell.style.backgroundColor = 'rgba(0, 200, 83, 0.6)';
    grid.appendChild(cell);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const cellRect = cell.getBoundingClientRect();
    expect(Math.round(cellRect.top - gridRect.top)).toBeGreaterThanOrEqual(40);
    grid.remove();
  });

  it('honors align-self flex-end overriding align-items', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;height:120px;grid-template-columns:60px;grid-template-rows:120px;align-items:flex-start;',
    );

    const cell = document.createElement('div');
    cell.style.height = '30px';
    cell.style.display = 'inline-block';
    cell.style.backgroundColor = 'rgba(255, 193, 7, 0.6)';
    cell.style.alignSelf = 'flex-end';
    grid.appendChild(cell);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();
    
    const gridRect = grid.getBoundingClientRect();
    const cellRect = cell.getBoundingClientRect();
    expect(Math.round(cellRect.top - gridRect.top)).toBeGreaterThanOrEqual(90);
    grid.remove();
  });

  it('applies place-content shorthand to both axes', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;min-width:200px;max-width:200px;min-height:200px;max-height:200px;grid-template-columns:50px 50px;grid-template-rows:40px 40px;place-content:flex-end center;',
    );

    const cell = document.createElement('div');
    cell.style.width = '50px';
    cell.style.height = '40px';
    cell.style.backgroundColor = 'rgba(33, 150, 243, 0.6)';
    grid.appendChild(cell);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const cellRect = cell.getBoundingClientRect();
    expect(Math.round(cellRect.left - gridRect.left)).toBeGreaterThanOrEqual(50);
    expect(Math.round(cellRect.top - gridRect.top)).toBeGreaterThanOrEqual(119);
    grid.remove();
  });

  it('applies place-self shorthand to grid items', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;width:100px;grid-template-columns:100px;grid-template-rows:120px;place-items:flex-start flex-start;',
    );

    const cell = document.createElement('div');
    cell.style.width = '20px';
    cell.style.height = '30px';
    cell.style.backgroundColor = 'rgba(156, 39, 176, 0.6)';
    cell.style.placeSelf = 'flex-end center';
    grid.appendChild(cell);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const cellRect = cell.getBoundingClientRect();
    expect(Math.round(cellRect.left - gridRect.left)).toBeGreaterThanOrEqual(40);
    expect(Math.round(cellRect.top - gridRect.top)).toBeGreaterThanOrEqual(90);
    grid.remove();
  });

  it('lays out minmax tracks with named lines', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;width:260px;grid-template-columns:[col-start] minmax(80px, 1fr) [col-mid col-line] repeat(2, [col-line] 1fr) [col-end];column-gap:0;row-gap:0;',
    );

    for (let i = 0; i < 3; i++) {
      const cell = document.createElement('div');
      cell.textContent = `cell-${i}`;
      cell.style.height = '40px';
      cell.style.backgroundColor = i === 0 ? 'rgba(0, 200, 83, 0.3)' : 'rgba(33, 150, 243, 0.3)';
      grid.appendChild(cell);
    }

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const first = grid.children[0] as HTMLElement;
    const second = grid.children[1] as HTMLElement;
    const rectFirst = first.getBoundingClientRect();
    const rectSecond = second.getBoundingClientRect();
    expect(Math.round(rectFirst.width)).toBeGreaterThanOrEqual(80);
    expect(Math.round(rectSecond.left - rectFirst.right)).toBeGreaterThanOrEqual(0);
    grid.remove();
  });

  it('places grid items using named lines', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;width:200px;grid-template-columns:[sidebar] 40px [content] 80px [utility] 80px [end];column-gap:0;row-gap:0;',
    );

    const sidebar = document.createElement('div');
    sidebar.textContent = 'sidebar';
    sidebar.style.height = '30px';
    sidebar.style.backgroundColor = 'rgba(255, 152, 0, 0.4)';
    grid.appendChild(sidebar);

    const named = document.createElement('div');
    named.id = 'named-line-cell';
    named.textContent = 'content';
    named.style.height = '30px';
    named.style.backgroundColor = 'rgba(63, 81, 181, 0.4)';
    named.style.gridColumn = 'content / utility';
    grid.appendChild(named);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const namedRect = named.getBoundingClientRect();
    expect(Math.round(namedRect.left - gridRect.left)).toBeGreaterThanOrEqual(40);
    expect(Math.round(namedRect.width)).toBeGreaterThanOrEqual(80);
    grid.remove();
  });

    it('respects fit-content clamp on track sizing', async () => {
    const grid = document.createElement('div');
    grid.setAttribute('style', 'display:grid;width:200px;grid-template-columns:fit-content(80px);');
    const cell = document.createElement('div');
    cell.textContent = 'wider-than-fit';
    cell.style.width = '150px';
    cell.style.height = '30px';
    cell.style.backgroundColor = 'rgba(244, 67, 54, 0.4)';
    grid.appendChild(cell);
    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const rect = cell.getBoundingClientRect();
    expect(Math.round(rect.width)).toBeLessThanOrEqual(150);
    grid.remove();
  });
});
