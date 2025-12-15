describe('CSS Grid auto-repeat (auto-fill/auto-fit)', () => {
  it('fills columns with auto-fill', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '320px';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
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

    // auto-fill creates as many tracks as fit: (100px + 10px) * 3 = 330px, but only 320px available
    // So should create 2 tracks: 100px + 10px + 100px = 210px used
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('fits columns with auto-fit', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '320px';
    grid.style.gridTemplateColumns = 'repeat(auto-fit, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e1f5fe';

    const item1 = document.createElement('div');
    item1.textContent = '1';
    item1.style.backgroundColor = '#03A9F4';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2';
    item2.style.backgroundColor = '#0288D1';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // auto-fit collapses empty tracks, so with 2 items we get 2 tracks
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('auto-fills rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.height = '250px';
    grid.style.width = '100px';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(auto-fill, 60px)';
    grid.style.gap = '10px';
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

    // With 250px height and 60px rows + 10px gap: fits 3 rows (60+10+60+10+60 = 200px)
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().height).toBe(60);
    expect(items[1].getBoundingClientRect().height).toBe(60);
    expect(items[2].getBoundingClientRect().height).toBe(60);
    expect(items[3].getBoundingClientRect().height).toBe(40);

    grid.remove();
  });

  it('auto-fits rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.height = '200px';
    grid.style.width = '100px';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(auto-fit, 60px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fce4ec';

    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#EC407A', '#D81B60'][i];
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
    expect(items[0].getBoundingClientRect().height).toBe(60);
    expect(items[1].getBoundingClientRect().height).toBe(60);

    grid.remove();
  });

  it('auto-repeat with minmax()', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '350px';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, minmax(100px, 1fr))';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = 'minmax';
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0'][i];
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

    // 350px width: fits 3 tracks of 100px each with 10px gaps
    const items = Array.from(grid.children) as HTMLElement[];
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBeGreaterThanOrEqual(100);
    });

    grid.remove();
  });

  it('auto-repeat with fixed tracks before', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '350px';
    grid.style.gridTemplateColumns = '60px repeat(auto-fill, 80px) 50px';
    grid.style.gridTemplateRows = '50px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    const labels = ['60px', '80px', '80px', '50px'];
    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = labels[i];
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7', '#5E35B1'][i];
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
    expect(items[1].getBoundingClientRect().width).toBe(80);
    expect(items[2].getBoundingClientRect().width).toBe(80);
    expect(items[3].getBoundingClientRect().width).toBe(50);
    grid.remove();
  });

  it('auto-repeat with fixed tracks after', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, 80px) 100px';
    grid.style.gridTemplateRows = '50px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f7fa';

    const item1 = document.createElement('div');
    item1.textContent = 'Auto';
    item1.style.backgroundColor = '#26C6DA';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '100px';
    item2.style.backgroundColor = '#00ACC1';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[items.length - 1].getBoundingClientRect().width).toBe(80);

    grid.remove();
  });

  it('auto-repeat with percentage sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, 25%)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8eaf6';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = '25%';
      item.style.backgroundColor = ['#7C4DFF', '#651FFF', '#6200EA', '#5E35B1'][i];
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
    items.forEach(item => {
      expect(item.getBoundingClientRect().width).toBeCloseTo(75, 0); // 25% of 300px
    });

    grid.remove();
  });

  it('works with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '330px';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, 100px)';
    grid.style.gridTemplateRows = '60px 60px';
    grid.style.columnGap = '10px';
    grid.style.rowGap = '10px';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800', '#FB8C00', '#F57C00', '#EF6C00'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // With 330px and 10px gap: fits 3 tracks (100 + 10 + 100 + 10 + 100 = 320px)
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[2].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('updates auto-fill on container resize', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '220px';
    grid.style.gridTemplateColumns = 'repeat(auto-fill, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
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

    // Initially fits 2 tracks (100 + 10 + 100 = 210px)
    let firstItemRect = (grid.children[0] as HTMLElement).getBoundingClientRect();
    expect(firstItemRect.width).toBe(100);

    // Resize to fit 3 tracks
    grid.style.width = '330px';
    await waitForFrame();
    await snapshot();

    // Now should fit 3 tracks (100 + 10 + 100 + 10 + 100 = 320px)
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[2].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });
});
