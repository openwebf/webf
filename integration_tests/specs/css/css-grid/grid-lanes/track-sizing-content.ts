describe('CSS Grid content-based sizing', () => {
  it('sizes tracks to min-content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content min-content';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.padding = '10px';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    item1.style.whiteSpace = 'nowrap';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Longer Text Content';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    item2.style.whiteSpace = 'nowrap';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const width1 = items[0].getBoundingClientRect().width;
    const width2 = items[1].getBoundingClientRect().width;

    // min-content should size to minimum content width
    expect(width1).toBeGreaterThan(0);
    expect(width2).toBeGreaterThan(width1);

    grid.remove();
  });

  it('sizes tracks to max-content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'max-content max-content';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e3f2fd';
    grid.style.padding = '10px';

    const item1 = document.createElement('div');
    item1.textContent = 'Content A';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    item1.style.whiteSpace = 'nowrap';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Much Longer Content B';
    item2.style.backgroundColor = '#2196F3';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    item2.style.whiteSpace = 'nowrap';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const width1 = items[0].getBoundingClientRect().width;
    const width2 = items[1].getBoundingClientRect().width;

    // max-content should size to maximum content width
    expect(width1).toBeGreaterThan(0);
    expect(width2).toBeGreaterThan(width1);

    grid.remove();
  });

  it('uses fit-content() function', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';;
    grid.style.gridTemplateColumns = 'fit-content(150px) 1fr';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'This is a very long text that exceeds the fit-content limit';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Flex';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const width1 = items[0].getBoundingClientRect().width;

    // fit-content should clamp to max(min-content, min(max-content, argument))
    expect(width1).toBeGreaterThan(0);
    expect(width1).toBeLessThanOrEqual(150);

    grid.remove();
  });

  it('sizes with spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto';
    grid.style.gridTemplateRows = 'auto auto';
    grid.style.columnGap = '10px';
    grid.style.rowGap = '10px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.padding = '10px';

    const item1 = document.createElement('div');
    item1.textContent = 'A';
    item1.style.gridColumn = '1';
    item1.style.gridRow = '1';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'B';
    item2.style.gridColumn = '2';
    item2.style.gridRow = '1';
    item2.style.backgroundColor = '#FFA726';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const spanItem = document.createElement('div');
    spanItem.textContent = 'This item spans both columns';
    spanItem.style.gridColumn = '1 / 3';
    spanItem.style.gridRow = '2';
    spanItem.style.backgroundColor = '#FF9800';
    spanItem.style.padding = '10px';
    spanItem.style.color = 'white';
    spanItem.style.whiteSpace = 'nowrap';
    grid.appendChild(spanItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Spanning item should influence track sizing
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles nested grid content sizing', async () => {
    const outerGrid = document.createElement('div');
    outerGrid.style.display = 'grid';
    outerGrid.style.gridTemplateColumns = 'auto 1fr';
    outerGrid.style.gridTemplateRows = 'auto';
    outerGrid.style.columnGap = '10px';
    outerGrid.style.backgroundColor = '#ede7f6';
    outerGrid.style.padding = '10px';

    const innerGrid = document.createElement('div');
    innerGrid.style.display = 'grid';
    innerGrid.style.gridTemplateColumns = 'auto auto';
    innerGrid.style.gridTemplateRows = 'auto';
    innerGrid.style.columnGap = '5px';
    innerGrid.style.backgroundColor = '#9575CD';
    innerGrid.style.padding = '5px';

    const innerItem1 = document.createElement('div');
    innerItem1.textContent = 'Inner A';
    innerItem1.style.backgroundColor = '#7E57C2';
    innerItem1.style.padding = '5px';
    innerItem1.style.color = 'white';
    innerGrid.appendChild(innerItem1);

    const innerItem2 = document.createElement('div');
    innerItem2.textContent = 'Inner B';
    innerItem2.style.backgroundColor = '#673AB7';
    innerItem2.style.padding = '5px';
    innerItem2.style.color = 'white';
    innerGrid.appendChild(innerItem2);

    outerGrid.appendChild(innerGrid);

    const outerItem = document.createElement('div');
    outerItem.textContent = 'Outer Item';
    outerItem.style.backgroundColor = '#5E35B1';
    outerItem.style.display = 'flex';
    outerItem.style.alignItems = 'center';
    outerItem.style.justifyContent = 'center';
    outerItem.style.color = 'white';
    outerGrid.appendChild(outerItem);

    document.body.appendChild(outerGrid);
    await waitForFrame();
    await snapshot();

    // Outer grid's auto track should size to nested grid's content
    const innerGridRect = innerGrid.getBoundingClientRect();
    expect(innerGridRect.width).toBeGreaterThan(0);
    expect(innerGridRect.height).toBeGreaterThan(0);

    outerGrid.remove();
  });

  it('resolves intrinsic sizes correctly', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content max-content auto';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e0f2f1';
    grid.style.padding = '10px';

    const minItem = document.createElement('div');
    minItem.textContent = 'Min Content Size';
    minItem.style.backgroundColor = '#4DB6AC';
    minItem.style.padding = '10px';
    minItem.style.color = 'white';
    grid.appendChild(minItem);

    const maxItem = document.createElement('div');
    maxItem.textContent = 'Max Content Size';
    maxItem.style.backgroundColor = '#26A69A';
    maxItem.style.padding = '10px';
    maxItem.style.color = 'white';
    maxItem.style.whiteSpace = 'nowrap';
    grid.appendChild(maxItem);

    const autoItem = document.createElement('div');
    autoItem.textContent = 'Auto Size';
    autoItem.style.backgroundColor = '#009688';
    autoItem.style.padding = '10px';
    autoItem.style.color = 'white';
    grid.appendChild(autoItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // All tracks should size to their content
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles mixed content and fixed sizing', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px min-content 1fr max-content 80px';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#fce4ec';
    grid.style.padding = '10px';

    const labels = ['100px', 'min-content', '1fr', 'max-content', '80px'];
    const colors = ['#F48FB1', '#F06292', '#EC407A', '#E91E63', '#D81B60'];

    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.textContent = labels[i];
      item.style.backgroundColor = colors[i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '10px';
      if (i === 1 || i === 3) {
        item.style.whiteSpace = 'nowrap';
      }
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Fixed tracks
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[4].getBoundingClientRect().width).toBe(80);

    // Content-based tracks
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[3].getBoundingClientRect().width).toBeGreaterThan(0);

    // Fr track gets remaining
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles empty content in content-sized tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content max-content auto';
    grid.style.gridTemplateRows = '60px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#fff9c4';
    grid.style.padding = '10px';

    // Empty items
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.style.backgroundColor = ['#FFEB3B', '#FDD835', '#FBC02D'][i];
      item.style.minWidth = '20px'; // Give some visual size
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Even with empty content, tracks should have some size
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(0);
    });

    grid.remove();
  });
});
