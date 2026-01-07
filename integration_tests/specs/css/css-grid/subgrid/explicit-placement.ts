describe('CSS Grid Subgrid explicit placement', () => {
  it('explicitly places items in subgrid columns', async () => {
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

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = '3';
    item1.style.backgroundColor = 'hsl(200, 70%, 60%)';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.minHeight = '60px';
    subgrid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.gridColumn = '1';
    item2.style.backgroundColor = 'hsl(220, 70%, 60%)';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.minHeight = '60px';
    subgrid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = '3';
    item3.style.gridColumn = '2';
    item3.style.backgroundColor = 'hsl(240, 70%, 60%)';
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

    // Subgrid padding consumes space from the outer inherited tracks.
    expect(item1.getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(item2.getBoundingClientRect().width).toBeCloseTo(92, 1);
    expect(item3.getBoundingClientRect().width).toBeCloseTo(120, 1);

    const item1Left = item1.getBoundingClientRect().left;
    const item2Left = item2.getBoundingClientRect().left;
    const item3Left = item3.getBoundingClientRect().left;
    expect(item2Left).toBeLessThan(item3Left);
    expect(item3Left).toBeLessThan(item1Left);

    const item1Top = item1.getBoundingClientRect().top;
    const item2Top = item2.getBoundingClientRect().top;
    const item3Top = item3.getBoundingClientRect().top;
    expect(item2Top).toBeGreaterThan(item1Top);
    expect(Math.abs(item2Top - item3Top)).toBeLessThanOrEqual(1);

    parent.remove();
  });

  it('explicitly places items spanning multiple subgrid tracks', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '90px 100px 110px 90px';
    parent.style.gridTemplateRows = 'auto';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#f3e5f5';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.backgroundColor = '#ba68c8';
    subgrid.style.padding = '8px';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = '1 / 3';
    item1.style.backgroundColor = 'hsl(280, 70%, 60%)';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.minHeight = '60px';
    subgrid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.gridColumn = '3 / 5';
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

    const item1Width = item1.getBoundingClientRect().width;
    const item2Width = item2.getBoundingClientRect().width;
    // Padding shrinks the first and last inherited tracks.
    expect(item1Width).toBeCloseTo(82 + 10 + 100, 1);
    expect(item2Width).toBeCloseTo(110 + 10 + 82, 1);

    parent.remove();
  });

  it('explicitly places items in subgrid rows', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = 'auto';
    parent.style.gridTemplateRows = '70px 90px 80px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#fff3e0';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#ffb74d';
    subgrid.style.padding = '8px';

    const item1 = document.createElement('div');
    item1.textContent = 'R3';
    item1.style.gridRow = '3';
    item1.style.backgroundColor = 'hsl(40, 70%, 65%)';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    subgrid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'R1';
    item2.style.gridRow = '1';
    item2.style.backgroundColor = 'hsl(55, 70%, 65%)';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    subgrid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'R2';
    item3.style.gridRow = '2';
    item3.style.backgroundColor = 'hsl(70, 70%, 65%)';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    subgrid.appendChild(item3);

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    expect(item1.getBoundingClientRect().height).toBeCloseTo(72, 1);
    expect(item2.getBoundingClientRect().height).toBeCloseTo(62, 1);
    expect(item3.getBoundingClientRect().height).toBeCloseTo(90, 1);

    const item1Top = item1.getBoundingClientRect().top;
    const item2Top = item2.getBoundingClientRect().top;
    const item3Top = item3.getBoundingClientRect().top;
    expect(item2Top).toBeLessThan(item3Top);
    expect(item3Top).toBeLessThan(item1Top);

    parent.remove();
  });

  it('explicitly places items in subgrid with both axes', async () => {
    const parent = document.createElement('div');
    parent.style.display = 'grid';
    parent.style.gridTemplateColumns = '100px 120px 100px';
    parent.style.gridTemplateRows = '70px 90px 70px';
    parent.style.gap = '10px';
    parent.style.backgroundColor = '#e8f5e9';

    const subgrid = document.createElement('div');
    subgrid.style.display = 'grid';
    subgrid.style.gridTemplateColumns = 'subgrid';
    subgrid.style.gridTemplateRows = 'subgrid';
    subgrid.style.gridColumn = '1 / -1';
    subgrid.style.gridRow = '1 / -1';
    subgrid.style.backgroundColor = '#66bb6a';
    subgrid.style.padding = '6px';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.gridColumn = '2';
    item1.style.gridRow = '2';
    item1.style.backgroundColor = 'hsl(120, 60%, 55%)';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    subgrid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.gridColumn = '1 / 3';
    item2.style.gridRow = '1';
    item2.style.backgroundColor = 'hsl(135, 60%, 55%)';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    subgrid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = '3';
    item3.style.gridColumn = '3';
    item3.style.gridRow = '3';
    item3.style.backgroundColor = 'hsl(150, 60%, 55%)';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    subgrid.appendChild(item3);

    parent.appendChild(subgrid);
    document.body.appendChild(parent);
    await waitForFrame();
    await snapshot();

    expect(item1.getBoundingClientRect().width).toBeCloseTo(120, 1);
    expect(item1.getBoundingClientRect().height).toBeCloseTo(90, 1);
    expect(item2.getBoundingClientRect().width).toBeCloseTo(94 + 10 + 120, 1);
    expect(item2.getBoundingClientRect().height).toBeCloseTo(64, 1);
    expect(item3.getBoundingClientRect().width).toBeCloseTo(94, 1);
    expect(item3.getBoundingClientRect().height).toBeCloseTo(64, 1);

    parent.remove();
  });
});
