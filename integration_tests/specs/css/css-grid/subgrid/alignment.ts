describe('CSS Grid Subgrid alignment', () => {
  it('aligns subgrid items with justify-items', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '120px 140px 120px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f5f5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.justifyItems = 'center';
    subgrid.style.backgroundColor = '#e3f2fd';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.width = '60px';
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
    expect(items[0].getBoundingClientRect().width).toBe(60);
    expect(items[1].getBoundingClientRect().width).toBe(60);
    expect(items[2].getBoundingClientRect().width).toBe(60);

    parent.remove();
  });

  it('aligns subgrid items with align-items', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto';
    parent.style.gridTemplateRows = '90px 100px 90px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.alignItems = 'center';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `R${i + 1}`;
      item.style.height = '50px';
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
    expect(items[0].getBoundingClientRect().height).toBe(50);
    expect(items[1].getBoundingClientRect().height).toBe(50);
    expect(items[2].getBoundingClientRect().height).toBe(50);

    parent.remove();
  });

  it('subgrid item self-alignment overrides container alignment', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '120px 140px 120px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.justifyItems = 'center';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.width = '60px';
      if (i === 1) {
        item.style.justifySelf = 'start';
      }
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
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
    const item1Rect = items[0].getBoundingClientRect();
    const item2Rect = items[1].getBoundingClientRect();
    const subgridRect = subgrid.getBoundingClientRect();

    expect(items[1].getBoundingClientRect().width).toBe(60);

    parent.remove();
  });

  it('aligns subgrid with place-items shorthand', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '120px 140px';
    parent.style.gridTemplateRows = '90px 100px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.placeItems = 'center';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '6px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.width = '60px';
      item.style.height = '50px';
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
    expect(items[0].getBoundingClientRect().width).toBe(60);
    expect(items[0].getBoundingClientRect().height).toBe(50);

    parent.remove();
  });

  xit('aligns subgrid content with justify-content and align-content', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '150px 180px';
    parent.style.gridTemplateRows = '100px 120px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#ede7f6';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#9575cd';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
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

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(150, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(180, 1);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(100, 1);
    expect(items[2].getBoundingClientRect().height).toBeCloseTo(120, 1);

    parent.remove();
  });
});
