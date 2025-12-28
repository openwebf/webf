describe('CSS Grid dynamic style changes', () => {
  it('updates grid-template-columns dynamically', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

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

    const initialWidth = grid.children[0].getBoundingClientRect().width;
    expect(initialWidth).toBe(100);

    // Change column template
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    await waitForFrame();
    await snapshot();

    const newWidth = grid.children[0].getBoundingClientRect().width;
    expect(newWidth).toBe(150);

    grid.remove();
  });

  it('updates grid-template-rows dynamically', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

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

    const initialHeight = grid.children[0].getBoundingClientRect().height;
    expect(initialHeight).toBe(70);

    // Change row template
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    await waitForFrame();
    await snapshot();

    const newHeight = grid.children[0].getBoundingClientRect().height;
    expect(newHeight).toBe(100);

    grid.remove();
  });

  it('updates gap values dynamically', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 20}, 70%, 60%)`;
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

    // Change gap
    grid.style.gap = '20px';
    await waitForFrame();
    await snapshot();

    const newGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(newGap).toBe(20);

    grid.remove();
  });

  it('changes grid-auto-flow dynamically', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gridAutoFlow = 'row';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 20}, 70%, 60%)`;
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
    const initialRow2Pos = items[2].getBoundingClientRect().top;

    // Change to column flow
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = '110px';
    await waitForFrame();
    await snapshot();

    const newRow2Pos = items[2].getBoundingClientRect().top;
    // With column flow, item 2 should be in different position
    expect(newRow2Pos).not.toBe(initialRow2Pos);

    grid.remove();
  });

  it('updates item grid-column dynamically', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.className = `item-${i}`;
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

    const targetItem = grid.querySelector('.item-2') as HTMLElement;
    const initialLeft = targetItem.getBoundingClientRect().left;

    // Change item placement
    // Move item-2 from column 3 to column 1
    targetItem.style.gridColumn = '1';
    targetItem.style.gridRow = '2';

    await waitForFrame();
    await snapshot();

    const newLeft = targetItem.getBoundingClientRect().left;
    expect(newLeft).not.toBe(initialLeft);
    expect(newLeft).toBe(grid.getBoundingClientRect().left); 
    grid.remove();
  });

  it('toggles display property', async () => {
    const container = document.createElement('div');
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
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

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    expect(grid.getBoundingClientRect().width).toBeGreaterThan(0);

    // Hide grid
    grid.style.display = 'none';
    await waitForFrame();
    await snapshot();

    expect(grid.getBoundingClientRect().width).toBe(0);

    // Show grid again
    grid.style.display = 'grid';
    await waitForFrame();
    await snapshot();

    expect(grid.getBoundingClientRect().width).toBeGreaterThan(0);

    container.remove();
  });

  it('changes justify-content dynamically', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.justifyContent = 'start';
    grid.style.width = '400px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${160 + i * 20}, 60%, 50%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const initialLeft = grid.children[0].getBoundingClientRect().left;
    expect(initialLeft).toBe(grid.getBoundingClientRect().left);

    // Change alignment
    grid.style.justifyContent = 'center';
    await waitForFrame();
    await snapshot();

    const newLeft = grid.children[0].getBoundingClientRect().left;
    expect(newLeft).toBeGreaterThan(initialLeft);

    grid.remove();
  });

  it('updates grid-auto-rows dynamically', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fce4ec';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${320 + i * 15}, 70%, 65%)`;
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
    const initialHeight = items[2].getBoundingClientRect().height;
    expect(initialHeight).toBe(70);

    // Change auto rows
    grid.style.gridAutoRows = '90px';
    await waitForFrame();
    await snapshot();

    const newHeight = items[2].getBoundingClientRect().height;
    expect(newHeight).toBe(90);

    grid.remove();
  });
});
