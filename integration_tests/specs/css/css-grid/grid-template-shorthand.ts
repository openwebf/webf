describe('CSS Grid grid-template shorthand', () => {
  it('applies rows/columns from grid-template shorthand', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplate = '40px 60px / 80px 40px';

    const cellA = document.createElement('div');
    const cellB = document.createElement('div');
    cellA.style.height = '40px';
    cellB.style.height = '40px';
    cellA.style.backgroundColor = 'rgba(100, 181, 246, 0.5)';
    cellB.style.backgroundColor = 'rgba(129, 199, 132, 0.5)';
    grid.appendChild(cellA);
    grid.appendChild(cellB);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateRows).toEqual('40px 60px');
    expect(computed.gridTemplateColumns).toEqual('80px 40px');

    grid.remove();
  });

  it('sets template areas via grid-template shorthand', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplate =
      '"header header side" "footer footer side" / 80px 80px 80px';

    const header = document.createElement('div');
    header.textContent = 'header';
    header.style.gridArea = 'header';
    header.style.height = '40px';
    header.style.backgroundColor = 'rgba(63, 81, 181, 0.4)';
    grid.appendChild(header);

    const footer = document.createElement('div');
    footer.textContent = 'footer';
    footer.style.gridArea = 'footer';
    footer.style.height = '40px';
    footer.style.backgroundColor = 'rgba(76, 175, 80, 0.4)';
    grid.appendChild(footer);

    const side = document.createElement('div');
    side.textContent = 'side';
    side.style.gridArea = 'side';
    side.style.height = '80px';
    side.style.backgroundColor = 'rgba(244, 67, 54, 0.4)';
    grid.appendChild(side);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateAreas).toEqual(
      '"header header side" "footer footer side"',
    );
    expect(computed.gridTemplateColumns).toEqual('80px 80px 80px');

    const gridRect = grid.getBoundingClientRect();
    const headerRect = header.getBoundingClientRect();
    const footerRect = footer.getBoundingClientRect();
    const sideRect = side.getBoundingClientRect();

    expect(Math.round(headerRect.left - gridRect.left)).toBeGreaterThanOrEqual(0);
    expect(Math.round(headerRect.width)).toBeGreaterThanOrEqual(160);
    expect(Math.round(footerRect.top - gridRect.top)).toBeGreaterThanOrEqual(40);
    expect(Math.round(sideRect.left - gridRect.left)).toBeGreaterThanOrEqual(160);
    expect(Math.round(sideRect.height)).toBeGreaterThanOrEqual(80);

    grid.remove();
  });
});

