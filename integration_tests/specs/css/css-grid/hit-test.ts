fdescribe('CSS Grid hit testing', () => {
  it('returns the expected grid item from document.elementFromPoint', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '90px 90px';
    grid.style.gridTemplateRows = '70px 70px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const items: HTMLDivElement[] = [];
    const colors = ['#42A5F5', '#66BB6A', '#FFA726', '#AB47BC'];
    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.id = `grid-hit-${i + 1}`;
      item.style.backgroundColor = colors[i];
      items.push(item);
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForOnScreen(grid);

    const target = items[1];
    const rect = target.getBoundingClientRect();
    const hit = document.elementFromPoint(rect.left + rect.width / 2, rect.top + rect.height / 2);
    expect(hit).toBe(target);

    grid.remove();
  });

  it('accounts for relative offsets when hit testing', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    const base = document.createElement('div');
    base.id = 'grid-hit-base';
    base.style.gridArea = '1 / 1 / 2 / 2';
    base.style.backgroundColor = '#2196F3';
    grid.appendChild(base);

    const shifted = document.createElement('div');
    shifted.id = 'grid-hit-shifted';
    shifted.style.gridArea = '1 / 1 / 2 / 2';
    shifted.style.backgroundColor = '#F06292';
    shifted.style.position = 'relative';
    shifted.style.left = '10px';
    shifted.style.top = '10px';
    shifted.style.zIndex = '1';
    grid.appendChild(shifted);

    document.body.appendChild(grid);
    await waitForOnScreen(grid);

    const baseRect = base.getBoundingClientRect();
    const shiftedRect = shifted.getBoundingClientRect();

    // Point inside the original cell top-left area: should hit base because shifted moved away.
    const hitBase = document.elementFromPoint(baseRect.left + 5, baseRect.top + 5);
    expect(hitBase).toBe(base);

    // Point inside shifted's new box: should hit shifted.
    const hitShifted = document.elementFromPoint(shiftedRect.left + 5, shiftedRect.top + 5);
    expect(hitShifted).toBe(shifted);

    grid.remove();
  });
});

