describe('CSS Grid template areas', () => {
  const buildGrid = () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '80px 80px 80px';
    grid.style.gridTemplateRows = '60px 60px';
    grid.style.gridTemplateAreas = '"header header side" "footer footer side"';
    grid.style.columnGap = '8px';
    grid.style.rowGap = '8px';
    grid.style.padding = '8px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.border = '1px solid #ccc';
    grid.style.borderRadius = '8px';

    const header = document.createElement('div');
    header.textContent = 'header';
    header.style.gridArea = 'header';
    header.style.backgroundColor = 'rgba(63, 81, 181, 0.4)';
    header.style.display = 'flex';
    header.style.alignItems = 'center';
    header.style.justifyContent = 'center';
    grid.appendChild(header);

    const footer = document.createElement('div');
    footer.textContent = 'footer';
    footer.style.gridArea = 'footer';
    footer.style.backgroundColor = 'rgba(76, 175, 80, 0.4)';
    footer.style.display = 'flex';
    footer.style.alignItems = 'center';
    footer.style.justifyContent = 'center';
    grid.appendChild(footer);

    const side = document.createElement('div');
    side.textContent = 'side';
    side.style.gridArea = 'side';
    side.style.backgroundColor = 'rgba(244, 67, 54, 0.4)';
    side.style.display = 'flex';
    side.style.alignItems = 'center';
    side.style.justifyContent = 'center';
    grid.appendChild(side);

    return { grid, header, footer, side };
  };

  it('places matching grid-area names correctly', async () => {
    const { grid, header, footer, side } = buildGrid();
    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const headerRect = header.getBoundingClientRect();
    const footerRect = footer.getBoundingClientRect();
    const sideRect = side.getBoundingClientRect();

    const headerOffset = Math.round(headerRect.left - gridRect.left);
    expect(headerOffset).toBeGreaterThanOrEqual(9);
    expect(headerOffset).toBeLessThanOrEqual(10);
    expect(Math.round(headerRect.width)).toBeGreaterThanOrEqual(168);
    expect(Math.round(footerRect.top - gridRect.top)).toBeGreaterThanOrEqual(68);
    expect(Math.round(sideRect.left - gridRect.left)).toBeGreaterThanOrEqual(176);
    grid.remove();
  });

  it('auto places when grid-area references unknown name', async () => {
    const { grid } = buildGrid();
    const orphan = document.createElement('div');
    orphan.textContent = 'orphan';
    orphan.style.gridArea = 'missing-area';
    orphan.style.backgroundColor = 'rgba(255, 152, 0, 0.6)';
    grid.appendChild(orphan);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const orphanRect = orphan.getBoundingClientRect();
    expect(orphanRect.width).toBeGreaterThan(0);
    expect(Math.round(orphanRect.left - gridRect.left)).toBeGreaterThanOrEqual(9);
    grid.remove();
  });
});
