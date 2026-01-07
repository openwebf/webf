describe('CSS Grid Subgrid absolutely positioned elements', () => {
  it('absolutely positioned item in subgrid with parent as containing block', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f5f5f5';
    parent.style.position = 'relative';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#e3f2fd';
    subgrid.style.padding = '8px';
    subgrid.style.minHeight = '150px';

    const regularItem = document.createElement('div');
    regularItem.textContent = 'Regular';
    regularItem.style.backgroundColor = 'hsl(200, 70%, 60%)';
    regularItem.style.display = 'flex';
    regularItem.style.alignItems = 'center';
    regularItem.style.justifyContent = 'center';
    regularItem.style.color = 'white';
    regularItem.style.minHeight = '60px';
    subgrid.appendChild(regularItem);

    const absItem = document.createElement('div');
    absItem.textContent = 'Abs';
    absItem.style.position = 'absolute';
    absItem.style.top = '20px';
    absItem.style.left = '20px';
    absItem.style.width = '80px';
    absItem.style.height = '50px';
    absItem.style.backgroundColor = 'hsl(220, 70%, 60%)';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    subgrid.appendChild(absItem);

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    expect(absItem.getBoundingClientRect().width).toBe(80);
    expect(absItem.getBoundingClientRect().height).toBe(50);

    parent.remove();
  });

  xit('absolutely positioned item with grid-column placement in subgrid', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '90px 110px 90px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.position = 'relative';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '8px';
    subgrid.style.minHeight = '150px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.minHeight = '60px';
      subgrid.appendChild(item);
    }

    const absItem = document.createElement('div');
    absItem.textContent = 'Abs';
    absItem.style.position = 'absolute';
    absItem.style.gridColumn = '2';
    absItem.style.top = '80px';
    absItem.style.backgroundColor = 'hsl(320, 70%, 60%)';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.height = '40px';
    subgrid.appendChild(absItem);

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    expect(absItem.getBoundingClientRect().width).toBeGreaterThan(0);

    parent.remove();
  });

  it('subgrid as containing block for absolutely positioned descendants', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 100px';
    parent.style.gridTemplateRows = '80px 100px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.position = 'relative';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 10}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      subgrid.appendChild(item);
    }

    const absItem = document.createElement('div');
    absItem.textContent = 'Overlay';
    absItem.style.position = 'absolute';
    absItem.style.top = '10px';
    absItem.style.right = '10px';
    absItem.style.width = '70px';
    absItem.style.height = '50px';
    absItem.style.backgroundColor = 'hsl(0, 70%, 60%)';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.zIndex = '10';
    subgrid.appendChild(absItem);

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    expect(absItem.getBoundingClientRect().width).toBe(70);
    expect(absItem.getBoundingClientRect().height).toBe(50);

    parent.remove();
  });

  it('absolutely positioned subgrid itself', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';
    parent.style.position = 'relative';
    parent.style.minHeight = '250px';

    const regularItem = document.createElement('div');
    regularItem.textContent = 'Regular';
    regularItem.style.gridColumn = '1';
    regularItem.style.backgroundColor = 'hsl(120, 60%, 55%)';
    regularItem.style.display = 'flex';
    regularItem.style.alignItems = 'center';
    regularItem.style.justifyContent = 'center';
    regularItem.style.color = 'white';
    regularItem.style.minHeight = '60px';
    parent.appendChild(regularItem);

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.position = 'absolute';
    subgrid.style.top = '100px';
    subgrid.style.left = '10px';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${135 + i * 15}, 60%, 55%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.minHeight = '50px';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const subgridRect = subgrid.getBoundingClientRect();
    const parentRect = parent.getBoundingClientRect();
    expect(subgridRect.top).toBeGreaterThan(parentRect.top + 90);

    parent.remove();
  });
});
