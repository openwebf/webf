describe('CSS Grid Subgrid named lines', () => {
  it('subgrid inherits parent named lines', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '[start] 100px [middle] 150px [end]';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f5f5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = 'start / end';
    subgrid.style.backgroundColor = '#e3f2fd';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.minHeight = '60px';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(142, 1);

    parent.remove();
  });

  it('subgrid items placed using inherited named lines', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '[col-a] 100px [col-b] 120px [col-c] 100px [col-d]';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = 'col-a / col-d';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '8px';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = 'col-a / col-b';
    item1.style.backgroundColor = 'hsl(280, 70%, 60%)';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.minHeight = '60px';
    subgrid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.gridColumn = 'col-b / col-d';
    item2.style.backgroundColor = 'hsl(295, 70%, 60%)';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.minHeight = '60px';
    subgrid.appendChild(item2);

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    expect(item1.getBoundingClientRect().width).toBeCloseTo(92, 1);
    const item2Width = item2.getBoundingClientRect().width;
    expect(item2Width).toBeCloseTo(120 + 10 + 92, 1);

    parent.remove();
  });

  it('subgrid with named row lines', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto';
    parent.style.gridTemplateRows = '[row-start] 70px [row-mid] 90px [row-end]';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridRow = 'row-start / row-end';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `R${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(62, 1);
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(82, 1);

    parent.remove();
  });

  it('subgrid with multiple named lines same name', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '[col] 100px [col] 120px [col] 100px [col]';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = 'col 1 / col 4';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.minHeight = '60px';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(120, 1);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(92, 1);

    parent.remove();
  });

  it('subgrid with mixed numbered and named lines', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '[start] 90px 110px [middle] 130px [end]';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#ede7f6';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = 'start / end';
    subgrid.style.backgroundColor = '#9575cd';
    subgrid.style.padding = '8px';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = '1 / 2';
    item1.style.backgroundColor = 'hsl(260, 70%, 65%)';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.minHeight = '60px';
    subgrid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.gridColumn = '2 / middle';
    item2.style.backgroundColor = 'hsl(280, 70%, 65%)';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.minHeight = '60px';
    subgrid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = '3';
    item3.style.gridColumn = 'middle / end';
    item3.style.backgroundColor = 'hsl(300, 70%, 65%)';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    item3.style.minHeight = '60px';
    subgrid.appendChild(item3);

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    expect(item1.getBoundingClientRect().width).toBeCloseTo(82, 1);
    expect(item2.getBoundingClientRect().width).toBeCloseTo(110, 1);
    expect(item3.getBoundingClientRect().width).toBeCloseTo(122, 1);

    parent.remove();
  });
});
