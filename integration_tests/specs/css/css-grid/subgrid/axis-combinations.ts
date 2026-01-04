describe('CSS Grid Subgrid axis combinations', () => {
  it('subgrid columns only with explicit rows', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 150px 100px';
    parent.style.gridTemplateRows = '80px 80px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f5f5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridTemplateRows = '50px 50px';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridRow = '1';
    subgrid.style.backgroundColor = '#e3f2fd';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
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
    // Subgrid padding consumes space from the outer inherited tracks.
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(150, 1);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(50, 1);

    parent.remove();
  });

  it('subgrid rows only with explicit columns', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '120px 120px';
    parent.style.gridTemplateRows = '70px 90px 70px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = '100px';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridColumn = '1';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `R${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
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
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(90, 1);
    expect(items[2].getBoundingClientRect().height).toBeCloseTo(62, 1);
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(100, 1);

    parent.remove();
  });

  it('subgrid on both axes', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '90px 120px 90px';
    parent.style.gridTemplateRows = '60px 80px 60px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '6px';

    for (let i = 0; i < 9; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 10}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '12px';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(84, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(120, 1);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(54, 1);
    expect(items[3].getBoundingClientRect().height).toBeCloseTo(80, 1);

    parent.remove();
  });

  it('subgrid columns with auto rows', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 130px 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '10px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `Item ${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.padding = '15px 5px';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(90, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(130, 1);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(90, 1);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(items[1].getBoundingClientRect().height, 1);

    parent.remove();
  });

  it('regular grid child with subgrid sibling', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 100px';
    parent.style.gridTemplateRows = '80px 80px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#ede7f6';

    const regularItem = document.createElement('div');
    regularItem.textContent = 'Regular';
    regularItem.style.gridColumn = '1';
    regularItem.style.gridRow = '1';
    regularItem.style.backgroundColor = '#9575cd';
    regularItem.style.display = 'flex';
    regularItem.style.alignItems = 'center';
    regularItem.style.justifyContent = 'center';
    regularItem.style.color = 'white';
    parent.appendChild(regularItem);

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '2 / -1';
    subgrid.style.gridRow = '1';
    subgrid.style.backgroundColor = '#7e57c2';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `S${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 65%)`;
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

    const subgridItems = Array.from(subgrid.children) as HTMLElement[];
    expect(subgridItems[0].getBoundingClientRect().width).toBeCloseTo(112, 1);
    expect(subgridItems[1].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(regularItem.getBoundingClientRect().width).toBeCloseTo(100, 1);

    parent.remove();
  });

  it('subgrid spanning subset of parent tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '80px 100px 120px 100px 80px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '8px';
    parent.style.backgroundColor = '#fce4ec';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '2 / 5';
    subgrid.style.backgroundColor = '#f06292';
    subgrid.style.padding = '10px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${340 + i * 10}, 70%, 65%)`;
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
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(90, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(120, 1);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(90, 1);

    parent.remove();
  });
});
