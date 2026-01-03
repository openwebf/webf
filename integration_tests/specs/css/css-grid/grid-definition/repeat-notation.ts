describe('CSS Grid repeat() notation', () => {
  it('repeats fixed number of tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#388E3C'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateColumns).toBe('repeat(3, 100px)');

    const items = Array.from(grid.children) as HTMLElement[];
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBe(100);
    });

    grid.remove();
  });

  // 异常
  fit('repeats with named lines', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '320px';
    grid.style.gridTemplateColumns = 'repeat(3, [line-start] 100px [line-end])';
    grid.style.gridTemplateRows = '50px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e1f5fe';

    const item = document.createElement('div');
    item.textContent = 'Named in Repeat';
    item.style.gridColumn = 'line-start 2 / line-end 2';
    item.style.backgroundColor = '#03A9F4';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot(1);

    const gridRect = grid.getBoundingClientRect();
    const itemRect = item.getBoundingClientRect();

    // Should be in second column
    expect(itemRect.left - gridRect.left).toBeCloseTo(110, 0); // 100px + 10px gap
    expect(itemRect.width).toBe(100);

    grid.remove();
  });

  it('handles multiple repeat() blocks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = 'repeat(2, 80px) repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#FFEB3B', '#FDD835', '#FBC02D', '#F9A825'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(80);
    expect(items[1].getBoundingClientRect().width).toBe(80);
    expect(items[2].getBoundingClientRect().width).toBe(100);
    expect(items[3].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('mixes repeat() with explicit tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '380px';
    grid.style.gridTemplateColumns = '60px repeat(2, 100px) 80px';
    grid.style.gridTemplateRows = '50px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fbe9e7';

    const labels = ['60px', '100px', '100px', '80px'];
    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = labels[i];
      item.style.backgroundColor = ['#FF5722', '#FF7043', '#FF8A65', '#FFAB91'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '12px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(60);
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[2].getBoundingClientRect().width).toBe(100);
    expect(items[3].getBoundingClientRect().width).toBe(80);

    grid.remove();
  });

  it('repeats fractional units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = '1fr';
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBeCloseTo(100, 0);
    });

    grid.remove();
  });

  it('repeats with different fr values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = 'repeat(2, 1fr 2fr)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = i % 2 === 0 ? '1fr' : '2fr';
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#9575CD', '#7E57C2'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Total: 1fr + 2fr + 1fr + 2fr = 6fr
    // 400px / 6 = 66.67px per fr
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(66.67, 0); // 1fr
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(133.33, 0); // 2fr
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(66.67, 0); // 1fr
    expect(items[3].getBoundingClientRect().width).toBeCloseTo(133.33, 0); // 2fr

    grid.remove();
  });

  it('repeats minmax() tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'repeat(3, minmax(80px, 1fr))';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = 'minmax';
      item.style.backgroundColor = ['#4DB6AC', '#26A69A', '#009688'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    items.forEach(item => {
      const width = item.getBoundingClientRect().width;
      expect(width).toBeCloseTo(100, 0); // 300px / 3 = 100px each
    });

    grid.remove();
  });
});
