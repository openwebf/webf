describe('CSS Grid Subgrid nested subgrids', () => {
  it('nested subgrid inherits from parent subgrid', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f5f5f5';

    const subgrid1 = document.createElement('div');
    subgrid1.style.display = 'grid';
    subgrid1.style.gridTemplateColumns = 'subgrid';
    subgrid1.style.gridColumn = '1 / -1';
    subgrid1.style.backgroundColor = '#e3f2fd';
    subgrid1.style.padding = '8px';

    const subgrid2 = document.createElement('div');
    subgrid2.style.display = 'grid';
    subgrid2.style.gridTemplateColumns = 'subgrid';
    subgrid2.style.gridColumn = '1 / -1';
    subgrid2.style.backgroundColor = '#bbdefb';
    subgrid2.style.padding = '6px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.minHeight = '60px';
      subgrid2.appendChild(item);
    }

    subgrid1.appendChild(subgrid2);
    parent.appendChild(subgrid1);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid2.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(86, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(120, 1);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(86, 1);

    parent.remove();
  });

  it('deeply nested subgrids maintain track inheritance', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '90px 110px 90px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '8px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid1 = document.createElement('div');
    subgrid1.style.display = 'grid';
    subgrid1.style.gridTemplateColumns = 'subgrid';
    subgrid1.style.gridColumn = '1 / -1';
    subgrid1.style.backgroundColor = '#ce93d8';
    subgrid1.style.padding = '8px';

    const subgrid2 = document.createElement('div');
    subgrid2.style.display = 'grid';
    subgrid2.style.gridTemplateColumns = 'subgrid';
    subgrid2.style.gridColumn = '1 / -1';
    subgrid2.style.backgroundColor = '#ba68c8';
    subgrid2.style.padding = '6px';

    const subgrid3 = document.createElement('div');
    subgrid3.style.display = 'grid';
    subgrid3.style.gridTemplateColumns = 'subgrid';
    subgrid3.style.gridColumn = '1 / -1';
    subgrid3.style.backgroundColor = '#ab47bc';
    subgrid3.style.padding = '4px';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.minHeight = '50px';
      subgrid3.appendChild(item);
    }

    subgrid2.appendChild(subgrid3);
    subgrid1.appendChild(subgrid2);
    parent.appendChild(subgrid1);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid3.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(72, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(110, 1);
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(72, 1);

    parent.remove();
  });

  it('nested subgrid with partial span', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '80px 100px 120px 100px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid1 = document.createElement('div');
    subgrid1.style.display = 'grid';
    subgrid1.style.gridTemplateColumns = 'subgrid';
    subgrid1.style.gridColumn = '1 / -1';
    subgrid1.style.backgroundColor = '#ffcc80';
    subgrid1.style.padding = '8px';

    const subgrid2 = document.createElement('div');
    subgrid2.style.display = 'grid';
    subgrid2.style.gridTemplateColumns = 'subgrid';
    subgrid2.style.gridColumn = '2 / 4';
    subgrid2.style.backgroundColor = '#ffb74d';
    subgrid2.style.padding = '6px';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.minHeight = '60px';
      subgrid2.appendChild(item);
    }

    subgrid1.appendChild(subgrid2);
    parent.appendChild(subgrid1);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid2.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(94, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(114, 1);

    parent.remove();
  });

  it('nested subgrids with both axes', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px';
    parent.style.gridTemplateRows = '70px 90px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid1 = document.createElement('div');
    subgrid1.style.display = 'grid';
    subgrid1.style.gridTemplateColumns = 'subgrid';
    subgrid1.style.gridTemplateRows = 'subgrid';
    subgrid1.style.gridColumn = '1 / -1';
    subgrid1.style.gridRow = '1 / -1';
    subgrid1.style.backgroundColor = '#81c784';
    subgrid1.style.padding = '8px';

    const subgrid2 = document.createElement('div');
    subgrid2.style.display = 'grid';
    subgrid2.style.gridTemplateColumns = 'subgrid';
    subgrid2.style.gridTemplateRows = 'subgrid';
    subgrid2.style.gridColumn = '1 / -1';
    subgrid2.style.gridRow = '1 / -1';
    subgrid2.style.backgroundColor = '#66bb6a';
    subgrid2.style.padding = '6px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      subgrid2.appendChild(item);
    }

    subgrid1.appendChild(subgrid2);
    parent.appendChild(subgrid1);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    const items = Array.from(subgrid2.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(86, 1);
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(106, 1);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(56, 1);
    expect(items[2].getBoundingClientRect().height).toBeCloseTo(76, 1);

    parent.remove();
  });
});
