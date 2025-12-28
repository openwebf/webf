describe('CSS Grid getComputedStyle comprehensive', () => {
  it('returns all grid container properties', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px 15px';
    grid.style.gridAutoFlow = 'row';
    grid.style.gridAutoRows = '80px';
    grid.style.gridAutoColumns = '90px';
    grid.style.justifyContent = 'center';
    grid.style.alignContent = 'start';
    grid.style.justifyItems = 'stretch';
    grid.style.alignItems = 'stretch';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.display).toBe('grid');
    expect(computed.gridTemplateColumns).toBeTruthy();
    expect(computed.gridTemplateRows).toBeTruthy();
    expect(computed.rowGap).toBe('10px');
    expect(computed.columnGap).toBe('15px');
    expect(computed.gridAutoFlow).toBe('row');
    expect(computed.justifyContent).toBe('center');
    expect(computed.alignContent).toBe('start');

    grid.remove();
  });

  it('returns grid item placement properties', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.backgroundColor = '#e3f2fd';

    const item = document.createElement('div');
    item.textContent = 'Item';
    item.style.gridColumn = '2 / 4';
    item.style.gridRow = '1 / 3';
    item.style.backgroundColor = '#2196F3';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemComputed = getComputedStyle(item);
    expect(itemComputed.gridColumnStart).toBeTruthy();
    expect(itemComputed.gridColumnEnd).toBeTruthy();
    expect(itemComputed.gridRowStart).toBeTruthy();
    expect(itemComputed.gridRowEnd).toBeTruthy();

    grid.remove();
  });

  it('returns grid item alignment properties', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.textContent = 'Item';
    item.style.justifySelf = 'center';
    item.style.alignSelf = 'end';
    item.style.width = '100px';
    item.style.height = '70px';
    item.style.backgroundColor = '#BA68C8';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemComputed = getComputedStyle(item);
    expect(itemComputed.justifySelf).toBe('center');
    expect(itemComputed.alignSelf).toBe('end');

    grid.remove();
  });

  it('returns shorthand gap property', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gap = '20px';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    // Both row-gap and column-gap should be 20px
    expect(computed.rowGap).toBe('20px');
    expect(computed.columnGap).toBe('20px');

    grid.remove();
  });

  it('returns computed values after dynamic changes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 200px';
    grid.style.gridAutoFlow = 'row';
    grid.style.backgroundColor = '#e8f5e9';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();

    let computed = getComputedStyle(grid);
    expect(computed.gridAutoFlow).toBe('row');

    // Change property
    grid.style.gridAutoFlow = 'column';
    await waitForFrame();
    await snapshot();

    computed = getComputedStyle(grid);
    expect(computed.gridAutoFlow).toBe('column');

    grid.remove();
  });

  it('returns inherited vs non-inherited properties', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'repeat(2, 150px)';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#ede7f6';

    const child = document.createElement('div');
    child.style.display = 'grid';
    child.style.gridTemplateColumns = 'repeat(2, 60px)';
    child.style.gap = '5px';
    child.style.backgroundColor = '#9575CD';
    child.style.padding = '10px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 15}, 70%, 65%)`;
      item.style.fontSize = '11px';
      child.appendChild(item);
    }

    parent.appendChild(child);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const parentComputed = getComputedStyle(parent);
    const childComputed = getComputedStyle(child);

    // Grid properties are not inherited
    expect(childComputed.gridTemplateColumns).not.toBe(parentComputed.gridTemplateColumns);
    expect(childComputed.gap).not.toBe(parentComputed.gap);

    parent.remove();
  });
});
