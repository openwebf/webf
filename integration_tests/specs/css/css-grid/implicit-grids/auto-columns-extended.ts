describe('CSS Grid auto-columns extended', () => {
  it('creates implicit columns with grid-auto-columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = '120px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#42A5F5', '#66BB6A', '#FFA726', '#BA68C8', '#26A69A', '#EC407A'][i];
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
    // First column (explicit): 100px
    expect(items[0].getBoundingClientRect().width).toBe(100);
    // Second column (implicit): 120px
    expect(items[2].getBoundingClientRect().width).toBe(120);
    // Third column (implicit): 120px
    expect(items[4].getBoundingClientRect().width).toBe(120);

    grid.remove();
  });

  it('uses auto value for grid-auto-columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = 'auto';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    const texts = ['A', 'B', 'Wider', 'Text', 'C', 'D'];
    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = texts[i];
      item.style.backgroundColor = ['#2196F3', '#1E88E5', '#1976D2', '#1565C0', '#1976D2', '#1E88E5'][i];
      item.style.padding = '10px';
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
    // Implicit columns should size to content
    expect(items[2].getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('uses minmax() in grid-auto-columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = 'minmax(80px, auto)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = i < 2 ? 'S' : 'Longer';
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0', '#8E24AA', '#7B1FA2', '#6A1B9A'][i];
      item.style.padding = '10px';
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
    // Implicit columns should be at least 80px
    expect(items[2].getBoundingClientRect().width).toBeGreaterThanOrEqual(80);
    expect(items[4].getBoundingClientRect().width).toBeGreaterThanOrEqual(80);

    grid.remove();
  });

  it('uses multiple values in grid-auto-columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = '90px 110px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 10; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800', '#FB8C00', '#F57C00', '#EF6C00', '#E65100', '#D84315', '#BF360C', '#A1887F'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '11px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // First column (explicit): 100px
    expect(items[0].getBoundingClientRect().width).toBe(100);
    // Second column (implicit, first pattern): 90px
    expect(items[2].getBoundingClientRect().width).toBe(90);
    // Third column (implicit, second pattern): 110px
    expect(items[4].getBoundingClientRect().width).toBe(110);
    // Fourth column (implicit, repeats first pattern): 90px
    expect(items[6].getBoundingClientRect().width).toBe(90);

    grid.remove();
  });

  it('uses fr units in grid-auto-columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = '1fr';
    grid.style.width = '400px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#66BB6A', '#4CAF50', '#43A047', '#388E3C', '#2E7D32', '#1B5E20'][i];
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
    // First column: 100px explicit
    expect(items[0].getBoundingClientRect().width).toBe(100);
    // Remaining space (300px) divided by 2 implicit columns = 150px each
    expect(items[2].getBoundingClientRect().width).toBe(150);
    expect(items[4].getBoundingClientRect().width).toBe(150);

    grid.remove();
  });

  it('combines grid-auto-columns with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = '110px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#9575CD', '#7E57C2', '#673AB7', '#5E35B1', '#512DA8', '#4527A0'][i];
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
    // Check column gaps are maintained
    const gap1 = items[2].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    const gap2 = items[4].getBoundingClientRect().left - items[2].getBoundingClientRect().right;
    expect(gap1).toBe(10);
    expect(gap2).toBe(10);

    grid.remove();
  });

  it('uses percentage values in grid-auto-columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gridAutoFlow = 'column';
    grid.style.gridAutoColumns = '25%';
    grid.style.width = '400px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#4DB6AC', '#26A69A', '#009688', '#00897B'][i];
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
    // First column: 100px
    expect(items[0].getBoundingClientRect().width).toBe(100);
    // Second column: 25% of 400px = 100px
    expect(items[2].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });
});
