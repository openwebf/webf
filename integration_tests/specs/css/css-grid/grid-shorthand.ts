describe('CSS Grid shorthand `grid`', () => {
  it('applies template rows/columns from grid shorthand', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid; grid: 40px 60px / 80px 40px;',
    );

    const cellA = document.createElement('div');
    cellA.textContent = 'A';
    cellA.style.backgroundColor = 'rgba(129, 199, 132, 0.5)';
    grid.appendChild(cellA);

    const cellB = document.createElement('div');
    cellB.textContent = 'B';
    cellB.style.backgroundColor = 'rgba(244, 143, 177, 0.5)';
    grid.appendChild(cellB);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateRows).toEqual('40px 60px');
    expect(computed.gridTemplateColumns).toEqual('80px 40px');

    grid.remove();
  });

  it('resets grid using grid: none', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '80px 40px';
    grid.style.gridTemplateRows = '20px 30px';
    grid.style.gridAutoRows = '50px';
    grid.style.gridAutoColumns = '60px';
    grid.style.gridAutoFlow = 'column dense';

    grid.style.grid = 'none';

    document.body.appendChild(grid);

    await waitForFrame();

    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateRows).toEqual('none');
    expect(computed.gridTemplateColumns).toEqual('none');
    expect(computed.gridTemplateAreas).toEqual('none');
    expect(computed.gridAutoFlow).toEqual('row');

    grid.remove();
  });

  it('supports grid: auto-flow <rows> / <columns>', async () => {
    const grid = document.createElement('div');
    grid.setAttribute('style', 'display:grid; grid:auto-flow 80px / 1fr 1fr;');

    const a = document.createElement('div');
    const b = document.createElement('div');
    a.style.height = '40px';
    b.style.height = '40px';
    a.style.backgroundColor = 'rgba(33, 150, 243, 0.4)';
    b.style.backgroundColor = 'rgba(0, 188, 212, 0.4)';
    grid.appendChild(a);
    grid.appendChild(b);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridAutoFlow).toEqual('row');
    expect(computed.gridAutoRows).toEqual('80px');
    expect(computed.gridTemplateColumns).toEqual('1fr 1fr');

    grid.remove();
  });

  it('supports grid: <rows> / auto-flow <columns>', async () => {
    const grid = document.createElement('div');
    grid.setAttribute('style', 'display:grid; grid:80px / auto-flow 50px;');

    const a = document.createElement('div');
    const b = document.createElement('div');
    a.style.width = '50px';
    b.style.width = '50px';
    a.style.backgroundColor = 'rgba(255, 193, 7, 0.4)';
    b.style.backgroundColor = 'rgba(156, 39, 176, 0.4)';
    grid.appendChild(a);
    grid.appendChild(b);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateRows).toEqual('80px');
    expect(computed.gridAutoFlow).toEqual('column');
    expect(computed.gridAutoColumns).toEqual('50px');

    grid.remove();
  });
});
