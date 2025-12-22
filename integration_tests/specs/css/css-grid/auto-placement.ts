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

    const gridRect = grid.getBoundingClientRect();
    const item2Rect = (grid.children[1] as HTMLElement).getBoundingClientRect();
    const item3Rect = (grid.children[2] as HTMLElement).getBoundingClientRect();
    expect(Math.round(item3Rect.top - gridRect.top)).toBeGreaterThan(Math.round(item2Rect.top - gridRect.top));
    grid.remove();
  });

  it('fills earlier gaps when auto-flow row dense', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridAutoFlow = 'row dense';
    grid.style.gridTemplateColumns = '60px 60px 60px';
    grid.style.gridAutoRows = '40px';
    grid.style.rowGap = '0';
    grid.style.columnGap = '0';

    const wide1 = document.createElement('div');
    wide1.style.gridColumn = 'span 2';
    wide1.style.height = '40px';
    wide1.style.backgroundColor = 'rgba(33, 150, 243, 0.3)';
    grid.appendChild(wide1);

    const wide2 = document.createElement('div');
    wide2.style.gridColumn = 'span 2';
    wide2.style.height = '40px';
    wide2.style.backgroundColor = 'rgba(0, 200, 83, 0.3)';
    grid.appendChild(wide2);

    const compact = document.createElement('div');
    compact.className = 'column-dense-compact';
    compact.style.height = '40px';
    compact.style.backgroundColor = 'rgba(244, 67, 54, 0.4)';
    grid.appendChild(compact);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const wide2Rect = wide2.getBoundingClientRect();
    const compactRect = compact.getBoundingClientRect();
    expect(Math.round(wide2Rect.top - grid.getBoundingClientRect().top)).toBeGreaterThanOrEqual(40);
    expect(Math.round(compactRect.left - grid.getBoundingClientRect().left)).toBeGreaterThanOrEqual(120);
    expect(Math.round(compactRect.top - grid.getBoundingClientRect().top)).toBe(0);
    grid.remove();
  });

  it('fills earlier gaps when auto-flow column dense', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridAutoFlow = 'column dense';
    grid.style.gridTemplateRows = '40px 40px 40px';
    grid.style.gridAutoColumns = '60px';
    grid.style.rowGap = '0';
    grid.style.columnGap = '0';

    const tall1 = document.createElement('div');
    tall1.style.gridRow = 'span 2';
    tall1.style.width = '60px';
    tall1.style.backgroundColor = 'rgba(255, 193, 7, 0.4)';
    grid.appendChild(tall1);

    const tall2 = document.createElement('div');
    tall2.style.gridRow = 'span 2';
    tall2.style.width = '60px';
    tall2.style.backgroundColor = 'rgba(0, 188, 212, 0.4)';
    grid.appendChild(tall2);

    const shortCell = document.createElement('div');
    shortCell.className = 'column-dense-short';
    shortCell.style.height = '40px';
    shortCell.style.backgroundColor = 'rgba(156, 39, 176, 0.4)';
    grid.appendChild(shortCell);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const tall2Rect = tall2.getBoundingClientRect();
    const shortRect = shortCell.getBoundingClientRect();

    expect(Math.round(tall2Rect.left - gridRect.left)).toBeGreaterThanOrEqual(60);
    expect(Math.round(shortRect.left - gridRect.left)).toBe(0);
    expect(Math.round(shortRect.top - gridRect.top)).toBeGreaterThanOrEqual(80);
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

  it('honors justify-content space-between distributing columns', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;min-width:200px;max-width:200px;grid-template-columns:40px 40px;column-gap:0;row-gap:0;justify-content:space-between;',
    );

    const a = document.createElement('div');
    a.style.height = '20px';
    a.style.backgroundColor = 'rgba(59, 130, 246, 0.5)';
    grid.appendChild(a);

    const b = document.createElement('div');
    b.style.height = '20px';
    b.style.backgroundColor = 'rgba(16, 185, 129, 0.5)';
    grid.appendChild(b);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const rectA = a.getBoundingClientRect();
    const rectB = b.getBoundingClientRect();

    expect(Math.round(rectA.left - gridRect.left)).toBe(0);
    expect(Math.round(rectB.left - gridRect.left)).toBe(160);
    grid.remove();
  });

  it('honors justify-content space-around distributing columns', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;min-width:200px;max-width:200px;grid-template-columns:40px 40px;column-gap:0;row-gap:0;justify-content:space-around;',
    );

    const a = document.createElement('div');
    a.style.height = '20px';
    a.style.backgroundColor = 'rgba(244, 63, 94, 0.5)';
    grid.appendChild(a);

    const b = document.createElement('div');
    b.style.height = '20px';
    b.style.backgroundColor = 'rgba(234, 179, 8, 0.5)';
    grid.appendChild(b);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const rectA = a.getBoundingClientRect();
    const rectB = b.getBoundingClientRect();

    expect(Math.round(rectA.left - gridRect.left)).toBe(30);
    expect(Math.round(rectB.left - gridRect.left)).toBe(130);
    grid.remove();
  });

  it('honors justify-content space-evenly distributing columns', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;min-width:200px;max-width:200px;grid-template-columns:40px 40px;column-gap:0;row-gap:0;justify-content:space-evenly;',
    );

    const a = document.createElement('div');
    a.style.height = '20px';
    a.style.backgroundColor = 'rgba(129, 140, 248, 0.5)';
    grid.appendChild(a);

    const b = document.createElement('div');
    b.style.height = '20px';
    b.style.backgroundColor = 'rgba(147, 51, 234, 0.4)';
    grid.appendChild(b);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const rectA = a.getBoundingClientRect();
    const rectB = b.getBoundingClientRect();

    expect(Math.round(rectA.left - gridRect.left)).toBe(40);
    expect(Math.round(rectB.left - gridRect.left)).toBe(120);
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
    expect(Math.round(rect.width)).toBeGreaterThanOrEqual(149);
    expect(Math.round(rect.width)).toBeLessThanOrEqual(151);
    grid.remove();
  });

  it('centers tracks when auto-fit leaves empty slots', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;width:200px;grid-template-columns:repeat(auto-fit,40px);justify-content:center;column-gap:0;',
    );
    grid.style.backgroundColor = 'lightgray'

    for (let i = 0; i < 2; i++) {
      const cell = document.createElement('div');
      cell.style.height = '20px';
      if  (i == 0) {
        cell.style.backgroundColor = 'rgba(233, 30, 99, 0.4)';
      } else {
        cell.style.backgroundColor = 'rgba(0, 188, 212, 0.5)';
      }
      grid.appendChild(cell);
    }

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const firstRect = (grid.children[0] as HTMLElement).getBoundingClientRect();
    expect(Math.round(firstRect.left - gridRect.left)).toBeGreaterThanOrEqual(60);
    grid.remove();
  });

  it('centers rows when auto-fit leaves empty slots', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;height:200px;grid-template-columns:60px;grid-template-rows:repeat(auto-fit,40px);align-content:center;row-gap:0;',
    );
    grid.style.backgroundColor = 'lightgray'

    for (let i = 0; i < 2; i++) {
      const cell = document.createElement('div');
      cell.style.height = '20px';
      if  (i == 0) {
        cell.style.backgroundColor = 'rgba(103, 58, 183, 0.4)';
      } else {
        cell.style.backgroundColor = 'rgba(0, 188, 212, 0.5)';
      }
      grid.appendChild(cell);
    }

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const firstRect = (grid.children[0] as HTMLElement).getBoundingClientRect();
    expect(Math.round(firstRect.top - gridRect.top)).toBeGreaterThanOrEqual(60);
    grid.remove();
  });

  it('positions items via grid-template-areas', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;width:180px;grid-template-columns:60px 60px 60px;grid-template-rows:40px 40px;grid-template-areas:"hero hero side" "footer footer side";row-gap:0;column-gap:0;',
    );

    const hero = document.createElement('div');
    hero.textContent = 'hero';
    hero.style.height = '40px';
    hero.style.backgroundColor = 'rgba(0, 188, 212, 0.5)';
    hero.style.gridArea = 'hero';
    grid.appendChild(hero);

    const footer = document.createElement('div');
    footer.textContent = 'footer';
    footer.style.height = '40px';
    footer.style.backgroundColor = 'rgba(156, 39, 176, 0.4)';
    footer.style.gridArea = 'footer';
    grid.appendChild(footer);

    const side = document.createElement('div');
    side.textContent = 'side';
    side.style.height = '80px';
    side.style.backgroundColor = 'rgba(255, 193, 7, 0.4)';
    side.style.gridArea = 'side';
    grid.appendChild(side);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const heroRect = hero.getBoundingClientRect();
    const footerRect = footer.getBoundingClientRect();
    const sideRect = side.getBoundingClientRect();
    expect(Math.round(heroRect.left - gridRect.left)).toBeGreaterThanOrEqual(0);
    expect(Math.round(heroRect.width)).toBeGreaterThanOrEqual(120);
    expect(Math.round(footerRect.top - gridRect.top)).toBeGreaterThanOrEqual(40);
    expect(Math.round(sideRect.left - gridRect.left)).toBeGreaterThanOrEqual(120);
    expect(Math.round(sideRect.height)).toBeGreaterThanOrEqual(80);
    grid.remove();
  });

  it('positions items via grid-area shorthand', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid;width:120px;grid-template-columns:60px 60px;grid-template-rows:40px 40px;',
    );

    const filler = document.createElement('div');
    filler.style.height = '40px';
    grid.appendChild(filler);

    const area = document.createElement('div');
    area.id = 'grid-area-cell';
    area.style.height = '40px';
    area.style.backgroundColor = 'rgba(139, 195, 74, 0.4)';
    area.style.gridArea = '2 / 1 / span 1 / span 2';
    grid.appendChild(area);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const areaRect = area.getBoundingClientRect();
    expect(Math.round(areaRect.top - gridRect.top)).toBeGreaterThanOrEqual(40);
    expect(Math.round(areaRect.width)).toBeGreaterThanOrEqual(120);
    grid.remove();
  });
});
