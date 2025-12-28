describe('CSS Grid extended computed values', () => {
  it('computes grid-template-columns with mixed units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '500px';
    grid.style.gridTemplateColumns = '100px 20% 1fr 2fr';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = 'Item';
    item.style.backgroundColor = '#42A5F5';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    // Should compute percentages and fr units to pixel values
    expect(computed.gridTemplateColumns).toBeTruthy();

    grid.remove();
  });

  it('computes grid-template-rows with auto', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'auto 100px auto';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `Item ${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 30}, 70%, 60%)`;
      item.style.padding = '10px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateRows).toBeTruthy();

    grid.remove();
  });

  it('computes grid-auto-flow value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridAutoFlow = 'row dense';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridAutoFlow).toBe('row dense');

    grid.remove();
  });

  it('computes gap property values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gap = '15px 20px';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.rowGap).toBe('15px');
    expect(computed.columnGap).toBe('20px');

    grid.remove();
  });

  it('computes justify-content value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.justifyContent = 'space-between';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.width = '300px';
    grid.style.backgroundColor = '#e8f5e9';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.justifyContent).toBe('space-between');

    grid.remove();
  });

  it('computes align-items value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.alignItems = 'end';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = '100px';
    grid.style.backgroundColor = '#ede7f6';

    const item = document.createElement('div');
    item.textContent = 'Item';
    item.style.height = '50px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.alignItems).toBe('end');

    grid.remove();
  });
});
