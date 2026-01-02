describe('CSS Grid circular dependencies', () => {
  xit('handles percentage height in auto-sized row', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px';
    grid.style.gridTemplateRows = 'auto';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.innerHTML =
      '<span id="word1">Item</span> <span id="word2">with</span> <span id="word3">percentage</span> <span id="word4">height</span>';
    item.style.height = '50%'; // Circular: auto row needs item height, item needs row height
    item.style.backgroundColor = '#42A5F5';
    item.style.padding = '20px';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    expect(itemRect.width).toBe(200);
    expect(itemRect.height).toBe(42);

    const word1 = item.querySelector('#word1') as HTMLElement;
    const word2 = item.querySelector('#word2') as HTMLElement;
    const word3 = item.querySelector('#word3') as HTMLElement;
    const word4 = item.querySelector('#word4') as HTMLElement;

    const top1 = word1.getBoundingClientRect().top;
    const top2 = word2.getBoundingClientRect().top;
    const top3 = word3.getBoundingClientRect().top;
    const top4 = word4.getBoundingClientRect().top;

    // Expect wrap between "percentage" and "height".
    expect(Math.abs(top2 - top1)).toBeLessThan(1);
    expect(Math.abs(top3 - top1)).toBeLessThan(1);
    expect(top4).toBeGreaterThan(top1 + 1);

    grid.remove();
  });

  it('handles min-content with percentage-sized children', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'min-content';
    grid.style.gridTemplateRows = 'auto';
    grid.style.backgroundColor = '#e3f2fd';

    const item = document.createElement('div');
    const child = document.createElement('div');
    child.textContent = 'Child';
    child.style.width = '50%'; // Circular dependency
    child.style.backgroundColor = '#2196F3';
    child.style.padding = '10px';
    child.style.color = 'white';
    item.appendChild(child);

    item.style.backgroundColor = '#BBDEFB';
    item.style.padding = '10px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles auto-sized tracks with percentage gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '5%'; // Gap depends on grid size, which depends on content
    grid.style.width = '300px';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.padding = '20px';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const gap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(gap).toBe(15); // 5% of 300px
    const expectedRowGap = grid.getBoundingClientRect().height * 0.05;
    const rowGap1 = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    const rowGap2 = items[3].getBoundingClientRect().top - items[1].getBoundingClientRect().bottom;
    expect(rowGap1).toBeGreaterThan(0);
    expect(rowGap2).toBeGreaterThan(0);
    expect(rowGap1).toBeCloseTo(expectedRowGap, 0);
    expect(rowGap2).toBeCloseTo(expectedRowGap, 0);

    grid.remove();
  });

  it('resolves nested percentage dependencies', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto';
    grid.style.gridTemplateRows = 'auto';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.style.backgroundColor = '#FFB74D';
    item.style.padding = '10px';

    const child = document.createElement('div');
    child.style.width = '80%';
    child.style.backgroundColor = '#FF9800';
    child.style.padding = '10px';

    const grandchild = document.createElement('div');
    grandchild.textContent = 'Nested content';
    grandchild.style.width = '90%';
    grandchild.style.backgroundColor = '#F57C00';
    grandchild.style.padding = '10px';
    grandchild.style.color = 'white';

    child.appendChild(grandchild);
    item.appendChild(child);
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(grandchild.getBoundingClientRect().width).toBeGreaterThan(0);
    const gridHeight = grid.getBoundingClientRect().height;
    const itemHeight = item.getBoundingClientRect().height;
    expect(gridHeight).toBeGreaterThan(80);
    expect(gridHeight).toBeLessThan(90);
    expect(itemHeight).toBeGreaterThan(80);
    expect(itemHeight).toBeLessThan(90);

    grid.remove();
  });

  it('handles fit-content with percentage margins', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'fit-content(300px)';
    grid.style.gridTemplateRows = 'auto';
    grid.style.width = '400px';
    grid.style.backgroundColor = '#e8f5e9';

    const item = document.createElement('div');
    item.textContent = 'Content with percentage margin';
    item.style.marginLeft = '10%'; // Depends on containing block
    item.style.marginRight = '10%';
    item.style.backgroundColor = '#66BB6A';
    item.style.padding = '10px';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });
});
