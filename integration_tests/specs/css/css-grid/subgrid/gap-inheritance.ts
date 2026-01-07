describe('CSS Grid Subgrid gap inheritance', () => {
  it('inherits parent column gap', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 100px 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.columnGap = '20px';
    parent.style.backgroundColor = '#f5f5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#e3f2fd';
    subgrid.style.padding = '10px';

    for (let i = 0; i < 3; i++) {
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
    const gapBetween1And2 = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(gapBetween1And2).toBeCloseTo(20, 1);

    parent.remove();
  });

  it('inherits parent row gap', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto';
    parent.style.gridTemplateRows = '80px 80px 80px';
    parent.style.rowGap = '15px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '10px';

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
    const gapBetween1And2 = items[1].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(gapBetween1And2).toBeCloseTo(15, 1);

    parent.remove();
  });

  it('inherits both column and row gaps', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 100px';
    parent.style.gridTemplateRows = '70px 70px';
    parent.style.gap = '12px 18px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
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
    const colGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(colGap).toBeCloseTo(18, 1);
    const rowGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(rowGap).toBeCloseTo(12, 1);

    parent.remove();
  });

  it('subgrid with own gap does not override inherited gap', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 100px 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.columnGap = '20px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.columnGap = '10px';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '10px';

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
    const gap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(gap).toBeCloseTo(20, 1);

    parent.remove();
  });

  it('inherits parent gap with percentage values', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.width = '300px';
    parent.style.gridTemplateColumns = '1fr 1fr 1fr';
    parent.style.gridTemplateRows = 'auto';
    parent.style.columnGap = '5%';
    parent.style.backgroundColor = '#ede7f6';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#9575cd';
    subgrid.style.padding = '10px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 65%)`;
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
    const gap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(gap).toBeCloseTo(15, 1);

    parent.remove();
  });

  it('zero gap inherited correctly', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.columnGap = '0px';
    parent.style.backgroundColor = '#fce4ec';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
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
    const gap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(Math.abs(gap)).toBeLessThan(1);

    parent.remove();
  });
});
