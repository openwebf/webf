describe('CSS Grid implicit tracks with named lines', () => {
  it('uses implicit named lines from repeat()', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, [col-start] 100px [col-end])';
    grid.style.gridTemplateRows = '[row-start] 60px [row-end]';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = 'col-start 1 / col-end 1';
    item1.style.gridRow = 'row-start / row-end';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.gridColumn = 'col-start 2 / col-end 2';
    item2.style.gridRow = 'row-start / row-end';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item1.getBoundingClientRect().width).toBe(100);
    expect(item2.getBoundingClientRect().width).toBe(100);
    expect(item2.getBoundingClientRect().left).toBe(item1.getBoundingClientRect().right);

    grid.remove();
  });

  it('places items using line numbers in implicit grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    // Place item in implicit row using line number
    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = '1 / 2';
    item1.style.gridRow = '3 / 4'; // Implicit row
    item1.style.backgroundColor = '#2196F3';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.gridColumn = '2 / 3';
    item2.style.gridRow = '1 / 2'; // Explicit row
    item2.style.backgroundColor = '#1E88E5';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // grid-row: 3 / 4 places the item in the 3rd row track (between lines 3 and 4),
    // so the top offset is the sum of the preceding two tracks: 60 + 70 = 130.
    expect(item1.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 130);

    grid.remove();
  });

  it('uses negative line numbers with implicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    // Place item using negative line number
    const lastItem = document.createElement('div');
    lastItem.textContent = 'Last';
    lastItem.style.gridColumn = '-2 / -1';
    lastItem.style.gridRow = '-1';
    lastItem.style.backgroundColor = '#BA68C8';
    lastItem.style.display = 'flex';
    lastItem.style.alignItems = 'center';
    lastItem.style.justifyContent = 'center';
    lastItem.style.color = 'white';
    lastItem.style.fontSize = '11px';
    grid.appendChild(lastItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Last item should be in last column
    expect(lastItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 100);

    grid.remove();
  });

  it('resolves named lines with auto-placement into implicit grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '[start] 100px [middle] 100px [end]';
    grid.style.gridTemplateRows = '[row-start] 60px [row-end]';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = 'start / middle';
    item1.style.gridRow = 'row-start / row-end';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Auto-placed items will flow into implicit rows
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 2}`;
      item.style.backgroundColor = `hsl(${40 + i * 10}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item1.getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('spans across explicit and implicit tracks with named lines', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, [col] 100px)';
    grid.style.gridTemplateRows = '[row] 60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const spanItem = document.createElement('div');
    spanItem.textContent = 'Span';
    spanItem.style.gridColumn = 'col 1 / col 2';
    spanItem.style.gridRow = '1 / 3'; // Spans explicit and implicit
    spanItem.style.backgroundColor = '#66BB6A';
    spanItem.style.display = 'flex';
    spanItem.style.alignItems = 'center';
    spanItem.style.justifyContent = 'center';
    spanItem.style.color = 'white';
    grid.appendChild(spanItem);

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 50%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Spanning item: 60px explicit + 70px implicit = 130px
    expect(spanItem.getBoundingClientRect().height).toBe(130);

    grid.remove();
  });

  it('handles auto-generated line names in implicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(auto-fill, [row-line] 60px)';
    grid.style.gridAutoRows = '70px';
    grid.style.height = '250px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(6);

    grid.remove();
  });
});
