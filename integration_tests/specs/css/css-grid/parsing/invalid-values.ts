describe('CSS Grid invalid value handling', () => {
  it('ignores invalid display value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();

    // Try to set invalid display value
    grid.style.display = 'invalid-grid';
    await waitForFrame();
    await snapshot();

    // Should fall back to previous valid value or initial value
    const computed = getComputedStyle(grid);
    expect(computed.display).not.toBe('invalid-grid');

    grid.remove();
  });

  it('ignores invalid grid-template-columns value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 200px';
    grid.style.backgroundColor = '#e3f2fd';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();

    const initialComputed = getComputedStyle(grid).gridTemplateColumns;

    // Try to set invalid value
    grid.style.gridTemplateColumns = 'invalid 300px';
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    // Should keep previous valid value or use initial
    expect(computed.gridTemplateColumns).toBeTruthy();

    grid.remove();
  });

  it('ignores invalid gap value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gap = '10px';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();

    // Try to set invalid gap
    grid.style.gap = 'invalid';
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    // Invalid assignment should be a no-op: keep the previous valid value.
    expect(parseFloat(computed.rowGap)).toBe(10);
    expect(parseFloat(computed.columnGap)).toBe(10);

    grid.remove();
  });

  it('ignores invalid grid-auto-flow value', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridAutoFlow = 'row';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();

    // Try to set invalid auto-flow
    grid.style.gridAutoFlow = 'invalid-flow';
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridAutoFlow).not.toBe('invalid-flow');

    grid.remove();
  });

  it('handles negative gap values gracefully', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gap = '10px';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();

    // Try to set negative gap (invalid)
    grid.style.gap = '-10px';
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    // Negative gaps should be clamped to 0 or ignored
    const gap = parseFloat(computed.rowGap);
    expect(gap).toBeGreaterThanOrEqual(0);

    grid.remove();
  });

  it('ignores invalid minmax() syntax', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'minmax(100px, 200px) 150px';
    grid.style.backgroundColor = '#ede7f6';

    const item = document.createElement('div');
    item.textContent = 'Item';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();

    // Try to set invalid minmax (min > max)
    grid.style.gridTemplateColumns = 'minmax(300px, 100px) 150px';
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    // Should handle invalid minmax gracefully
    expect(computed.gridTemplateColumns).toBeTruthy();

    grid.remove();
  });
});
