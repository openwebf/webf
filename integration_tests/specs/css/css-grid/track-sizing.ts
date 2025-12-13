describe('CSS Grid track sizing', () => {
  it('sizes fractional columns proportionally', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = '1fr 2fr';
    grid.style.columnGap = '0';
    grid.style.rowGap = '0';
    grid.style.height = '80px';
    grid.style.background = '#f0f4ff';
    grid.style.border = '1px solid #d4d9f5';

    const colA = document.createElement('div');
    colA.style.background = 'rgba(99, 102, 241, 0.6)';
    colA.style.height = '80px';
    grid.appendChild(colA);

    const colB = document.createElement('div');
    colB.style.background = 'rgba(79, 70, 229, 0.7)';
    colB.style.height = '80px';
    grid.appendChild(colB);

    document.body.appendChild(grid);
    await waitForFrame();

    const widthA = colA.getBoundingClientRect().width;
    const widthB = colB.getBoundingClientRect().width;

    expect(Math.round(widthA + widthB)).toBeGreaterThanOrEqual(298);
    // Column B should be roughly double column A (allow tiny rounding error).
    expect(Math.round(widthB / widthA)).toBeGreaterThanOrEqual(2);
    grid.remove();
  });

  it('clamps minmax tracks to provided bounds', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '220px';
    grid.style.gridTemplateColumns = 'minmax(80px, 140px) minmax(40px, 1fr)';
    grid.style.columnGap = '0';
    grid.style.rowGap = '0';
    grid.style.background = '#fef3c7';
    grid.style.padding = '0';

    const minCell = document.createElement('div');
    minCell.textContent = 'minmax';
    minCell.style.background = '#fcd34d';
    grid.appendChild(minCell);

    const flexCell = document.createElement('div');
    flexCell.textContent = 'flex';
    flexCell.style.background = '#fbbf24';
    grid.appendChild(flexCell);

    document.body.appendChild(grid);
    await waitForFrame();

    const minWidth = minCell.getBoundingClientRect().width;
    const flexWidth = flexCell.getBoundingClientRect().width;

    expect(minWidth).toBeGreaterThanOrEqual(80);
    expect(minWidth).toBeLessThanOrEqual(140);
    expect(Math.round(minWidth + flexWidth)).toBeGreaterThanOrEqual(218);
    grid.remove();
  });

  it('assigns grid-auto-rows for implicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '120px';
    grid.style.gridTemplateRows = '40px';
    grid.style.gridAutoRows = '80px';
    grid.style.rowGap = '0';
    grid.style.width = '140px';
    grid.style.background = '#ecfccb';

    const explicit = document.createElement('div');
    explicit.textContent = 'explicit';
    explicit.style.background = '#bef264';
    explicit.style.height = '40px';
    grid.appendChild(explicit);

    for (let i = 0; i < 2; i++) {
      const autoRow = document.createElement('div');
      autoRow.textContent = `auto ${i}`;
      autoRow.style.background = i % 2 === 0 ? '#a3e635' : '#84cc16';
      grid.appendChild(autoRow);
    }

    document.body.appendChild(grid);
    await waitForFrame();

    const explicitHeight = explicit.getBoundingClientRect().height;
    const implicitHeight = (grid.children[1] as HTMLElement).getBoundingClientRect().height;
    expect(Math.round(explicitHeight)).toBe(40);
    expect(Math.round(implicitHeight)).toBe(80);
    grid.remove();
  });
});
