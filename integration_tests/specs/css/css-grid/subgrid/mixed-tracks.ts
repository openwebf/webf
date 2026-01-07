describe('CSS Grid Subgrid mixed track types', () => {
  it('subgrid with mixed fixed and fr tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.width = '400px';
    parent.style.gridTemplateColumns = '100px 1fr 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f5f5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#e3f2fd';
    subgrid.style.padding = '8px';

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
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(100);

    parent.remove();
  });

  it('subgrid with mixed minmax and auto tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'minmax(80px, 120px) auto minmax(100px, 150px)';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '8px';

    const texts = ['Short', 'Medium Text', 'Longer Content'];
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = texts[i];
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
    expect(items[0].getBoundingClientRect().width).toBeGreaterThanOrEqual(80);
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(120);
    expect(items[2].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);

    parent.remove();
  });

  it('subgrid with mixed intrinsic and fractional tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.width = '400px';
    parent.style.gridTemplateColumns = 'min-content 2fr max-content 1fr';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '8px';

    const texts = ['A', 'Flexible', 'Max', 'Flex'];
    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = texts[i];
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
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
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[3].getBoundingClientRect().width * 1.8);

    parent.remove();
  });

  it('subgrid with repeat and mixed track types', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.width = '450px';
    parent.style.gridTemplateColumns = 'repeat(2, 100px 1fr)';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '8px';

    for (let i = 0; i < 4; i++) {
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
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(100, 1);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(100);
    expect(items[3].getBoundingClientRect().width).toBeGreaterThan(100);

    parent.remove();
  });

  it('subgrid with fit-content and fr tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.width = '400px';
    parent.style.gridTemplateColumns = 'fit-content(120px) 2fr fit-content(100px)';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#ede7f6';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#9575cd';
    subgrid.style.padding = '8px';

    const texts = ['Fit', 'Flexible Content', 'Fit2'];
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = texts[i];
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
    expect(items[0].getBoundingClientRect().width).toBeLessThanOrEqual(120);
    expect(items[2].getBoundingClientRect().width).toBeLessThanOrEqual(100);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(items[0].getBoundingClientRect().width);

    parent.remove();
  });

  it('subgrid with complex mixed track pattern', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.width = '500px';
    parent.style.gridTemplateColumns = '80px minmax(100px, 1fr) auto fit-content(150px) 2fr';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '8px';
    parent.style.backgroundColor = '#fce4ec';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#f06292';
    subgrid.style.padding = '8px';

    const texts = ['1', '2', '3', '4', '5'];
    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.textContent = texts[i];
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
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(72, 1);
    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(100);
    expect(items[3].getBoundingClientRect().width).toBeLessThanOrEqual(150);

    parent.remove();
  });
});
