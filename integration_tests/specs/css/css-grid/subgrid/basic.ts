describe('CSS Grid subgrid', () => {
  it('inherits parent column tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '[start] 100px [mid] 1fr [end] 80px';
    grid.style.gridTemplateRows = '40px 40px';
    grid.style.columnGap = '12px';
    grid.style.width = '400px';
    grid.style.backgroundColor = '#e3f2fd';

    const reference = document.createElement('div');
    reference.textContent = 'Reference';
    reference.style.gridColumn = '2';
    reference.style.gridRow = '1';
    reference.style.backgroundColor = '#42A5F5';
    reference.style.color = 'white';
    reference.style.display = 'flex';
    reference.style.alignItems = 'center';
    reference.style.justifyContent = 'center';
    grid.appendChild(reference);

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridRow = '2';
    subgrid.style.backgroundColor = '#bbdefb';

    const inner = document.createElement('div');
    inner.textContent = 'Inner';
    inner.style.gridColumn = 'mid / end';
    inner.style.backgroundColor = '#1E88E5';
    inner.style.color = 'white';
    inner.style.display = 'flex';
    inner.style.alignItems = 'center';
    inner.style.justifyContent = 'center';
    subgrid.appendChild(inner);

    grid.appendChild(subgrid);
    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const refRect = reference.getBoundingClientRect();
    const innerRect = inner.getBoundingClientRect();
    expect(Math.abs(innerRect.left - refRect.left)).toBeLessThanOrEqual(1);
    expect(Math.abs(innerRect.width - refRect.width)).toBeLessThanOrEqual(1);

    grid.remove();
  });

  it('inherits parent row tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '160px 160px';
    grid.style.gridTemplateRows = '[a] 30px [b] 50px [c] 40px';
    grid.style.rowGap = '10px';
    grid.style.columnGap = '12px';
    grid.style.backgroundColor = '#fce4ec';

    const reference = document.createElement('div');
    reference.textContent = 'Reference';
    reference.style.gridColumn = '1';
    reference.style.gridRow = 'b';
    reference.style.backgroundColor = '#EC407A';
    reference.style.color = 'white';
    reference.style.display = 'flex';
    reference.style.alignItems = 'center';
    reference.style.justifyContent = 'center';
    grid.appendChild(reference);

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridColumn = '2';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#f8bbd0';

    const inner = document.createElement('div');
    inner.textContent = 'Inner';
    inner.style.gridRow = 'b';
    inner.style.backgroundColor = '#D81B60';
    inner.style.color = 'white';
    inner.style.display = 'flex';
    inner.style.alignItems = 'center';
    inner.style.justifyContent = 'center';
    subgrid.appendChild(inner);

    grid.appendChild(subgrid);
    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const refRect = reference.getBoundingClientRect();
    const innerRect = inner.getBoundingClientRect();
    expect(Math.abs(innerRect.top - refRect.top)).toBeLessThanOrEqual(1);
    expect(Math.abs(innerRect.height - refRect.height)).toBeLessThanOrEqual(1);

    grid.remove();
  });
});

