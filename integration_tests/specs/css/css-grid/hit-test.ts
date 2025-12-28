describe('CSS Grid hit testing', () => {
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

  it('treats opacity stacking contexts as higher stacking layer', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';

    const item1 = document.createElement('div');
    item1.id = 'grid-opacity-A';
    item1.textContent = 'A';
    item1.style.gridArea = '1 / 1 / 2 / 3';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.id = 'grid-opacity-B';
    item2.textContent = 'B';
    item2.style.gridArea = '1 / 2 / 3 / 4';
    item2.style.opacity = '0.8';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.id = 'grid-opacity-C';
    item3.textContent = 'C';
    item3.style.gridArea = '2 / 1 / 4 / 3';
    grid.appendChild(item3);

    const item4 = document.createElement('div');
    item4.id = 'grid-opacity-D';
    item4.textContent = 'D';
    item4.style.gridArea = '2 / 3 / 4 / 5';
    grid.appendChild(item4);

    document.body.appendChild(grid);
    await waitForOnScreen(grid);

    function midpointOfOverlap(r1: DOMRect, r2: DOMRect) {
      const left = Math.max(r1.left, r2.left);
      const right = Math.min(r1.right, r2.right);
      const top = Math.max(r1.top, r2.top);
      const bottom = Math.min(r1.bottom, r2.bottom);
      expect(right).toBeGreaterThan(left);
      expect(bottom).toBeGreaterThan(top);
      return {x: left + (right - left) / 2, y: top + (bottom - top) / 2};
    }

    // B overlaps both C and D. Because opacity < 1 creates a stacking context,
    // it participates in the auto/0 stacking layer and should paint above
    // non-stacking, non-positioned grid items.
    const bRect = item2.getBoundingClientRect();
    const cRect = item3.getBoundingClientRect();
    const dRect = item4.getBoundingClientRect();

    const bc = midpointOfOverlap(bRect, cRect);
    expect(document.elementFromPoint(bc.x, bc.y)).toBe(item2);

    const bd = midpointOfOverlap(bRect, dRect);
    expect(document.elementFromPoint(bd.x, bd.y)).toBe(item2);

    grid.remove();
  });
});
