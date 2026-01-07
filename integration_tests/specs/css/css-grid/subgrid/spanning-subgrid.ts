describe('CSS Grid Subgrid spanning tracks', () => {
  it('subgrid spanning all parent columns', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 140px 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f5f5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#e3f2fd';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 4; i++) {
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
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(120, 1);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(140, 1);
    expect(items[3].getBoundingClientRect().width).toBeCloseTo(92, 1);

    parent.remove();
  });

  it('subgrid spanning subset of parent columns', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '80px 100px 120px 100px 80px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '8px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '2 / 5';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '8px';

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

  it('subgrid spanning all parent rows', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto';
    parent.style.gridTemplateRows = '70px 90px 80px 70px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 4; i++) {
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
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(90, 1);
    expect(items[2].getBoundingClientRect().height).toBeCloseTo(80, 1);
    expect(items[3].getBoundingClientRect().height).toBeCloseTo(62, 1);

    parent.remove();
  });

  it('subgrid spanning subset of parent rows', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto';
    parent.style.gridTemplateRows = '60px 80px 100px 80px 60px';
    parent.style.gap = '8px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridRow = '2 / 5';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `R${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
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
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(72, 1);
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(100, 1);
    expect(items[2].getBoundingClientRect().height).toBeCloseTo(72, 1);

    parent.remove();
  });

  it('subgrid spanning both axes with subset', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '80px 100px 120px 100px';
    parent.style.gridTemplateRows = '60px 80px 100px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#ede7f6';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridColumn = '2 / 4';
    subgrid.style.gridRow = '1 / 3';
    subgrid.style.backgroundColor = '#9575cd';
    subgrid.style.padding = '6px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '14px';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(94, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(114, 1);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(54, 1);
    expect(items[2].getBoundingClientRect().height).toBeCloseTo(74, 1);

    parent.remove();
  });

  it('multiple subgrids spanning different ranges', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '80px 100px 120px 100px';
    parent.style.gridTemplateRows = '70px 90px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fce4ec';

    const subgrid1 = document.createElement('div');
    subgrid1.style.display = 'grid';
    subgrid1.style.gridTemplateColumns = 'subgrid';
    subgrid1.style.gridColumn = '1 / 3';
    subgrid1.style.gridRow = '1';
    subgrid1.style.backgroundColor = '#f06292';
    subgrid1.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `A${i + 1}`;
      item.style.backgroundColor = `hsl(${340 + i * 10}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      subgrid1.appendChild(item);
    }

    const subgrid2 = document.createElement('div');
    subgrid2.style.display = 'grid';
    subgrid2.style.gridTemplateColumns = 'subgrid';
    subgrid2.style.gridColumn = '3 / 5';
    subgrid2.style.gridRow = '2';
    subgrid2.style.backgroundColor = '#ec407a';
    subgrid2.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `B${i + 1}`;
      item.style.backgroundColor = `hsl(${330 + i * 10}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      subgrid2.appendChild(item);
    }

    parent.appendChild(subgrid1);
    parent.appendChild(subgrid2);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items1 = Array.from(subgrid1.children) as HTMLElement[];
    const items2 = Array.from(subgrid2.children) as HTMLElement[];

    expect(items1[0].getBoundingClientRect().width).toBeCloseTo(72, 1);
    expect(items1[1].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(items2[0].getBoundingClientRect().width).toBeCloseTo(112, 1);
    expect(items2[1].getBoundingClientRect().width).toBeCloseTo(92, 1);

    parent.remove();
  });
});
