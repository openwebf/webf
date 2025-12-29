describe('CSS Grid gap transitions', () => {
  it('transitions row-gap property', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.rowGap = '10px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.transition = 'row-gap 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${i * 60}, 70%, 60%)`;
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
    const initialGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(initialGap).toBe(10);

    // Change row gap
    grid.style.rowGap = '25px';
    await waitForFrame();
    await snapshot();

    const newGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(newGap).toBe(25);

    grid.remove();
  });

  it('transitions column-gap property', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.rowGap = '10px';
    grid.style.columnGap = '10px';
    grid.style.backgroundColor = '#e3f2fd';
    grid.style.transition = 'column-gap 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
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
    const initialGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(initialGap).toBe(10);

    // Change column gap
    grid.style.columnGap = '30px';
    await waitForFrame();
    await snapshot();

    const newGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(newGap).toBe(30);

    grid.remove();
  });

  it('transitions gap shorthand property', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';
    grid.style.transition = 'gap 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Change gap
    grid.style.gap = '20px';
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const rowGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    const colGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(rowGap).toBe(20);
    expect(colGap).toBe(20);

    grid.remove();
  });

  it('transitions different row and column gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px 15px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.transition = 'gap 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Change gap
    grid.style.gap = '25px 35px';
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const rowGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    const colGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(rowGap).toBe(25);
    expect(colGap).toBe(35);

    grid.remove();
  });

  it('transitions gap from zero to non-zero', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.transition = 'gap 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
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
    const initialGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(initialGap).toBe(0);

    // Add gap
    grid.style.gap = '15px';
    await waitForFrame();
    await snapshot();

    const newGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(newGap).toBe(15);

    grid.remove();
  });

  it('transitions gap with many items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 60px)';
    grid.style.gridTemplateRows = 'repeat(3, 50px)';
    grid.style.gap = '5px';
    grid.style.backgroundColor = '#ede7f6';
    grid.style.transition = 'gap 0.3s';

    for (let i = 0; i < 12; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 15}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '10px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Change gap
    grid.style.gap = '12px';
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const colGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(colGap).toBe(12);

    grid.remove();
  });
});
