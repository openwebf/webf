describe('CSS Grid area as containing block', () => {
  it('positions absolute child relative to positioned grid item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    // Positioned grid item
    const item = document.createElement('div');
    item.style.position = 'relative';
    item.style.gridColumn = '2';
    item.style.gridRow = '1';
    item.style.backgroundColor = '#42A5F5';
    item.textContent = 'Item';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';

    // Absolute child
    const absChild = document.createElement('div');
    absChild.textContent = 'Abs';
    absChild.style.position = 'absolute';
    absChild.style.top = '10px';
    absChild.style.right = '10px';
    absChild.style.width = '30px';
    absChild.style.height = '25px';
    absChild.style.backgroundColor = '#E91E63';
    absChild.style.display = 'flex';
    absChild.style.alignItems = 'center';
    absChild.style.justifyContent = 'center';
    absChild.style.color = 'white';
    absChild.style.fontSize = '9px';
    item.appendChild(absChild);

    grid.appendChild(item);
    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Absolute child positioned relative to grid item, not grid container
    expect(absChild.getBoundingClientRect().top).toBe(item.getBoundingClientRect().top + 10);
    expect(absChild.getBoundingClientRect().right).toBe(item.getBoundingClientRect().right - 10);

    grid.remove();
  });

  it('absolute child stretches within positioned grid item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    const item = document.createElement('div');
    item.style.position = 'relative';
    item.style.gridColumn = '1 / span 2';
    item.style.gridRow = '1';
    item.style.backgroundColor = '#2196F3';

    const absChild = document.createElement('div');
    absChild.textContent = 'Stretched';
    absChild.style.position = 'absolute';
    absChild.style.inset = '15px';
    absChild.style.backgroundColor = '#1976D2';
    absChild.style.display = 'flex';
    absChild.style.alignItems = 'center';
    absChild.style.justifyContent = 'center';
    absChild.style.color = 'white';
    absChild.style.fontSize = '11px';
    item.appendChild(absChild);

    grid.appendChild(item);
    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item spans 2 columns: 150 + 10 + 150 = 310px
    expect(item.getBoundingClientRect().width).toBe(310);
    // Absolute child: 310 - 15 - 15 = 280px
    expect(absChild.getBoundingClientRect().width).toBe(280);
    // Height: 100 - 15 - 15 = 70px
    expect(absChild.getBoundingClientRect().height).toBe(70);

    grid.remove();
  });

  it('multiple absolute children in positioned grid item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 120px)';
    grid.style.gridTemplateRows = 'repeat(2, 90px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.style.position = 'relative';
    item.style.gridColumn = '1';
    item.style.gridRow = '1';
    item.style.backgroundColor = '#BA68C8';

    // Top-left absolute child
    const abs1 = document.createElement('div');
    abs1.textContent = 'TL';
    abs1.style.position = 'absolute';
    abs1.style.top = '5px';
    abs1.style.left = '5px';
    abs1.style.width = '40px';
    abs1.style.height = '30px';
    abs1.style.backgroundColor = '#9C27B0';
    abs1.style.display = 'flex';
    abs1.style.alignItems = 'center';
    abs1.style.justifyContent = 'center';
    abs1.style.color = 'white';
    abs1.style.fontSize = '10px';
    item.appendChild(abs1);

    // Bottom-right absolute child
    const abs2 = document.createElement('div');
    abs2.textContent = 'BR';
    abs2.style.position = 'absolute';
    abs2.style.bottom = '5px';
    abs2.style.right = '5px';
    abs2.style.width = '40px';
    abs2.style.height = '30px';
    abs2.style.backgroundColor = '#7B1FA2';
    abs2.style.display = 'flex';
    abs2.style.alignItems = 'center';
    abs2.style.justifyContent = 'center';
    abs2.style.color = 'white';
    abs2.style.fontSize = '10px';
    item.appendChild(abs2);

    grid.appendChild(item);
    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(abs1.getBoundingClientRect().top).toBe(item.getBoundingClientRect().top + 5);
    expect(abs1.getBoundingClientRect().left).toBe(item.getBoundingClientRect().left + 5);
    expect(abs2.getBoundingClientRect().bottom).toBe(item.getBoundingClientRect().bottom - 5);
    expect(abs2.getBoundingClientRect().right).toBe(item.getBoundingClientRect().right - 5);

    grid.remove();
  });

  xit('absolute child in spanning grid item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.style.position = 'relative';
    item.style.gridColumn = '1 / 3';
    item.style.gridRow = '1 / 3';
    item.style.backgroundColor = '#FFB74D';

    const absChild = document.createElement('div');
    absChild.textContent = 'Center';
    absChild.style.position = 'absolute';
    absChild.style.top = '50%';
    absChild.style.left = '50%';
    absChild.style.transform = 'translate(-50%, -50%)';
    absChild.style.width = '80px';
    absChild.style.height = '60px';
    absChild.style.backgroundColor = '#FF9800';
    absChild.style.display = 'flex';
    absChild.style.alignItems = 'center';
    absChild.style.justifyContent = 'center';
    absChild.style.color = 'white';
    absChild.style.fontSize = '11px';
    item.appendChild(absChild);

    grid.appendChild(item);
    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item spans 2x2: 100 + 10 + 100 = 210px width, 70 + 10 + 70 = 150px height
    expect(item.getBoundingClientRect().width).toBe(210);
    console.log('-----------------------------0')
    expect(item.getBoundingClientRect().height).toBe(150);
    console.log('-----------------------------1')
    // Absolute child centered in item
    const itemCenterX = item.getBoundingClientRect().left + 105;
    const itemCenterY = item.getBoundingClientRect().top + 75;
    const childCenterX = absChild.getBoundingClientRect().left + 40;
    const childCenterY = absChild.getBoundingClientRect().top + 30;
    console.log("itemCenterX:", itemCenterX, "itemCenterY:", itemCenterY);
    console.log("childCenterX:", childCenterX, "childCenterY:", childCenterY);

    expect(Math.round(childCenterX)).toBe(Math.round(itemCenterX));
    console.log('-----------------------------2')

    expect(Math.round(childCenterY)).toBe(Math.round(itemCenterY));
    console.log('-----------------------------3')

    grid.remove();
  });

  it('nested grid with absolute positioning', async () => {
    const outerGrid = document.createElement('div');
    outerGrid.style.display = 'grid';
    outerGrid.style.gridTemplateColumns = 'repeat(2, 150px)';
    outerGrid.style.gridTemplateRows = 'repeat(2, 100px)';
    outerGrid.style.gap = '10px';
    outerGrid.style.backgroundColor = '#e8f5e9';

    const innerGrid = document.createElement('div');
    innerGrid.style.display = 'grid';
    innerGrid.style.position = 'relative';
    innerGrid.style.gridTemplateColumns = 'repeat(2, 60px)';
    innerGrid.style.gridTemplateRows = 'repeat(2, 40px)';
    innerGrid.style.gap = '5px';
    innerGrid.style.backgroundColor = '#66BB6A';
    innerGrid.style.padding = '10px';

    const absChild = document.createElement('div');
    absChild.textContent = 'Abs';
    absChild.style.position = 'absolute';
    absChild.style.top = '10px';
    absChild.style.left = '10px';
    absChild.style.width = '50px';
    absChild.style.height = '40px';
    absChild.style.backgroundColor = '#4CAF50';
    absChild.style.display = 'flex';
    absChild.style.alignItems = 'center';
    absChild.style.justifyContent = 'center';
    absChild.style.color = 'white';
    absChild.style.fontSize = '10px';
    innerGrid.appendChild(absChild);

    outerGrid.appendChild(innerGrid);
    document.body.appendChild(outerGrid);
    await waitForFrame();
    await snapshot();

    // Absolute positioned relative to inner grid
    expect(absChild.getBoundingClientRect().top).toBe(innerGrid.getBoundingClientRect().top + 10);
    expect(absChild.getBoundingClientRect().left).toBe(innerGrid.getBoundingClientRect().left + 10);

    outerGrid.remove();
  });

  it('absolute child with percentage sizing in grid item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 200px)';
    grid.style.gridTemplateRows = 'repeat(2, 120px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    const item = document.createElement('div');
    item.style.position = 'relative';
    item.style.gridColumn = '1';
    item.style.gridRow = '1';
    item.style.backgroundColor = '#9575CD';

    const absChild = document.createElement('div');
    absChild.textContent = '75%';
    absChild.style.position = 'absolute';
    absChild.style.top = '10%';
    absChild.style.left = '10%';
    absChild.style.width = '80%';
    absChild.style.height = '80%';
    absChild.style.backgroundColor = '#7E57C2';
    absChild.style.display = 'flex';
    absChild.style.alignItems = 'center';
    absChild.style.justifyContent = 'center';
    absChild.style.color = 'white';
    absChild.style.fontSize = '12px';
    item.appendChild(absChild);

    grid.appendChild(item);
    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item is 200x120
    expect(item.getBoundingClientRect().width).toBe(200);
    expect(item.getBoundingClientRect().height).toBe(120);

    // Absolute child: 80% of 200 = 160px, 80% of 120 = 96px
    expect(absChild.getBoundingClientRect().width).toBe(160);
    expect(absChild.getBoundingClientRect().height).toBe(96);

    // Positioned at 10%: 20px left, 12px top
    expect(absChild.getBoundingClientRect().left).toBe(item.getBoundingClientRect().left + 20);
    expect(absChild.getBoundingClientRect().top).toBe(item.getBoundingClientRect().top + 12);

    grid.remove();
  });

  it('absolute child in aligned grid item', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 120px)';
    grid.style.gap = '10px';
    grid.style.justifyItems = 'center';
    grid.style.alignItems = 'center';
    grid.style.backgroundColor = '#e0f2f1';

    const item = document.createElement('div');
    item.style.position = 'relative';
    item.style.width = '100px';
    item.style.height = '80px';
    item.style.backgroundColor = '#4DB6AC';

    const absChild = document.createElement('div');
    absChild.textContent = 'Abs';
    absChild.style.position = 'absolute';
    absChild.style.top = '5px';
    absChild.style.right = '5px';
    absChild.style.width = '40px';
    absChild.style.height = '30px';
    absChild.style.backgroundColor = '#009688';
    absChild.style.display = 'flex';
    absChild.style.alignItems = 'center';
    absChild.style.justifyContent = 'center';
    absChild.style.color = 'white';
    absChild.style.fontSize = '10px';
    item.appendChild(absChild);

    grid.appendChild(item);
    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item is centered in its grid area, absolute child positioned relative to item
    expect(absChild.getBoundingClientRect().top).toBe(item.getBoundingClientRect().top + 5);
    expect(absChild.getBoundingClientRect().right).toBe(item.getBoundingClientRect().right - 5);

    grid.remove();
  });
});
