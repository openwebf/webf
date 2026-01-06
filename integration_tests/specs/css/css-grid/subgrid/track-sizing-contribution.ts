describe('CSS Grid Subgrid track sizing contribution', () => {
  it('subgrid content contributes to parent auto track sizing', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto auto auto';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f5f5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#e3f2fd';
    subgrid.style.padding = '8px';

    const texts = ['Short', 'Much Longer Text Content', 'Medium'];
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = texts[i];
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.padding = '10px';
      item.style.minHeight = '50px';
      item.style.whiteSpace = 'nowrap';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[2].getBoundingClientRect().width);

    parent.remove();
  });

  it('subgrid with min-content contributes to parent sizing', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'min-content auto min-content';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `Content ${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.padding = '10px';
      item.style.minHeight = '50px';
      item.style.whiteSpace = 'nowrap';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    parent.remove();
  });

  it('subgrid with large content affects parent track sizing', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'inline-grid';
    parent.style.gridTemplateColumns = 'auto auto';
    parent.style.gridTemplateRows = 'auto auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const regularItem = document.createElement('div');
    regularItem.textContent = 'Small';
    regularItem.style.gridColumn = '1';
    regularItem.style.gridRow = '1';
    regularItem.style.backgroundColor = '#ffb74d';
    regularItem.style.padding = '10px';
    parent.appendChild(regularItem);

    document.body.appendChild(parent);
    await waitForFrame();
    const baselineColumnWidth = regularItem.getBoundingClientRect().width;

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridRow = '2';
    subgrid.style.backgroundColor = '#ff9800';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Very Long Content Text ${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.padding = '10px';
      item.style.minHeight = '50px';
      item.style.whiteSpace = 'nowrap';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    await waitForFrame();
    await snapshot();

    const subgridItems = Array.from(subgrid.children) as HTMLElement[];
    expect(regularItem.getBoundingClientRect().width).toBeGreaterThan(baselineColumnWidth);
    expect(subgridItems[0].getBoundingClientRect().width).toBeGreaterThan(baselineColumnWidth);

    parent.remove();
  });

  it('multiple subgrids contribute to parent track sizing', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto auto';
    parent.style.gridTemplateRows = 'auto auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid1 = document.createElement('div');
    subgrid1.style.display = 'grid';
    subgrid1.style.gridTemplateColumns = 'subgrid';
    subgrid1.style.gridColumn = '1 / -1';
    subgrid1.style.gridRow = '1';
    subgrid1.style.backgroundColor = '#66bb6a';
    subgrid1.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Short ${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      item.style.padding = '10px';
      item.style.whiteSpace = 'nowrap';
      subgrid1.appendChild(item);
    }

    const subgrid2 = document.createElement('div');
    subgrid2.style.display = 'grid';
    subgrid2.style.gridTemplateColumns = 'subgrid';
    subgrid2.style.gridColumn = '1 / -1';
    subgrid2.style.gridRow = '2';
    subgrid2.style.backgroundColor = '#4caf50';
    subgrid2.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = i === 1 ? 'Much Longer Content Text' : 'Short';
      item.style.backgroundColor = `hsl(${120 + i * 15}, 50%, 45%)`;
      item.style.padding = '10px';
      item.style.whiteSpace = 'nowrap';
      subgrid2.appendChild(item);
    }

    parent.appendChild(subgrid1);
    parent.appendChild(subgrid2);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const subgrid1Items = Array.from(subgrid1.children) as HTMLElement[];
    const subgrid2Items = Array.from(subgrid2.children) as HTMLElement[];
    expect(subgrid1Items[1].getBoundingClientRect().width).toBeCloseTo(subgrid2Items[1].getBoundingClientRect().width, 1);

    parent.remove();
  });

  it('subgrid content affects parent fr track sizing', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.width = '400px';
    parent.style.gridTemplateColumns = '1fr 2fr';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#ede7f6';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#9575cd';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Item ${i + 1}`;
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
    const ratio = items[1].getBoundingClientRect().width / items[0].getBoundingClientRect().width;
    expect(ratio).toBeGreaterThan(1.8);
    expect(ratio).toBeLessThan(2.2);

    parent.remove();
  });

  it('subgrid row content affects parent row sizing', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto';
    parent.style.gridTemplateRows = 'auto auto auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fce4ec';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#f06292';
    subgrid.style.padding = '8px';

    const heights = ['40px', '80px', '50px'];
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `R${i + 1}`;
      item.style.backgroundColor = `hsl(${340 + i * 10}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.minHeight = heights[i];
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[1].getBoundingClientRect().height).toBeGreaterThan(items[0].getBoundingClientRect().height);
    expect(items[1].getBoundingClientRect().height).toBeGreaterThan(items[2].getBoundingClientRect().height);

    parent.remove();
  });
});
