describe('CSS Grid Subgrid intrinsic sizing', () => {
  it('subgrid with min-content parent tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'min-content min-content min-content';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f5f5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#e3f2fd';
    subgrid.style.padding = '8px';

    const texts = ['S', 'Medium Content', 'X'];
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

  it('subgrid with max-content parent tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'max-content max-content';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = i === 0 ? 'Short' : 'Much Longer Text Content';
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.padding = '10px';
      item.style.minHeight = '60px';
      item.style.whiteSpace = 'nowrap';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    parent.remove();
  });

  it('subgrid with fit-content parent tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.width = '400px';
    parent.style.gridTemplateColumns = 'fit-content(150px) fit-content(200px)';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Content ${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.padding = '10px';
      item.style.minHeight = '60px';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(150);
    expect(items[1].getBoundingClientRect().width).toBeLessThanOrEqual(200);

    parent.remove();
  });

  it('subgrid with mixed intrinsic and fixed tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px min-content max-content';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '8px';

    const texts = ['Fixed', 'Min', 'Max Content'];
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = texts[i];
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.padding = '10px';
      item.style.minHeight = '60px';
      item.style.whiteSpace = 'nowrap';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(items[1].getBoundingClientRect().width);

    parent.remove();
  });

  it('subgrid intrinsic sizing with wrapping text', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.width = '300px';
    parent.style.gridTemplateColumns = 'minmax(min-content, 150px) 1fr';
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
      item.textContent = i === 0 ? 'This is long text that may wrap' : 'Item 2';
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.padding = '10px';
      item.style.minHeight = '60px';
      subgrid.appendChild(item);
    }

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(150);
    expect(items[0].getBoundingClientRect().width).toBeGreaterThan(0);

    parent.remove();
  });

  it('subgrid with intrinsic row sizing', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto';
    parent.style.gridTemplateRows = 'min-content max-content auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fce4ec';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#f06292';
    subgrid.style.padding = '8px';

    const heights = ['40px', '80px', '60px'];
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `Row ${i + 1}`;
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
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(40, 0);
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(80, 0);
    expect(items[2].getBoundingClientRect().height).toBeCloseTo(60, 0);
    expect(items[1].getBoundingClientRect().height).toBeGreaterThan(items[0].getBoundingClientRect().height);
    expect(items[1].getBoundingClientRect().height).toBeGreaterThan(items[2].getBoundingClientRect().height);

    parent.remove();
  });
});
