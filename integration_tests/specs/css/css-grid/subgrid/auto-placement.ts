describe('CSS Grid Subgrid auto placement', () => {
  it('auto-places items in subgrid columns', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 100px';
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
    // Subgrid track sizes inherit from the parent grid, but the subgrid's own
    // padding consumes space from the outermost inherited tracks.
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(120, 1);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(92, 1);

    const item1Left = items[0].getBoundingClientRect().left;
    const item2Left = items[1].getBoundingClientRect().left;
    const item3Left = items[2].getBoundingClientRect().left;
    expect(item1Left).toBeLessThan(item2Left);
    expect(item2Left).toBeLessThan(item3Left);

    parent.remove();
  });

  it('auto-places items in subgrid rows', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto';
    parent.style.gridTemplateRows = '70px 90px 80px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
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
    // Subgrid padding is applied by shrinking the outer inherited tracks.
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(62, 1);
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(90, 1);
    expect(items[2].getBoundingClientRect().height).toBeCloseTo(72, 1);

    const item1Top = items[0].getBoundingClientRect().top;
    const item2Top = items[1].getBoundingClientRect().top;
    const item3Top = items[2].getBoundingClientRect().top;
    expect(item1Top).toBeLessThan(item2Top);
    expect(item2Top).toBeLessThan(item3Top);

    parent.remove();
  });

  it('auto-places items with grid-auto-flow dense in subgrid', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 100px';
    parent.style.gridTemplateRows = 'auto auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridAutoFlow = 'dense';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '8px';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = 'span 2';
    item1.style.backgroundColor = 'hsl(40, 70%, 65%)';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.minHeight = '60px';
    subgrid.appendChild(item1);

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 2}`;
      item.style.backgroundColor = `hsl(${55 + i * 15}, 70%, 65%)`;
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
    expect(items.length).toBe(4);

    parent.remove();
  });

  it('auto-places mixed explicit and auto items in subgrid', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '90px 110px 100px 90px';
    parent.style.gridTemplateRows = 'auto auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '8px';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = '3';
    item1.style.backgroundColor = 'hsl(120, 60%, 55%)';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.minHeight = '60px';
    subgrid.appendChild(item1);

    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 2}`;
      item.style.backgroundColor = `hsl(${135 + i * 15}, 60%, 55%)`;
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
    expect(items.length).toBe(6);
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(100, 1);

    parent.remove();
  });
});
