describe('CSS Grid auto-rows', () => {
  it('creates implicit rows with grid-auto-rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '50px';
    grid.style.gridAutoRows = '80px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    // Create 6 items (will overflow into implicit rows)
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
    // First row (explicit): 50px
    expect(items[0].getBoundingClientRect().height).toBe(50);
    expect(items[1].getBoundingClientRect().height).toBe(50);
    // Second row (implicit): 80px
    expect(items[2].getBoundingClientRect().height).toBe(80);
    expect(items[3].getBoundingClientRect().height).toBe(80);
    // Third row (implicit): 80px
    expect(items[4].getBoundingClientRect().height).toBe(80);
    expect(items[5].getBoundingClientRect().height).toBe(80);

    grid.remove();
  });

  it('uses auto value for grid-auto-rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '50px';
    grid.style.gridAutoRows = 'auto';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = i < 2 ? 'Short' : 'Taller content here';
      item.style.backgroundColor = ['#2196F3', '#1E88E5', '#1976D2', '#1565C0'][i];
      item.style.padding = '10px';
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
    // Implicit row should size to content
    expect(items[2].getBoundingClientRect().height).toBeGreaterThan(0);

    grid.remove();
  });

  it('uses minmax() in grid-auto-rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '50px';
    grid.style.gridAutoRows = 'minmax(60px, auto)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = i < 2 ? 'Small' : 'Larger content text';
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0', '#8E24AA', '#7B1FA2', '#6A1B9A'][i];
      item.style.padding = '5px';
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
    // Implicit rows should be at least 60px
    expect(items[2].getBoundingClientRect().height).toBeGreaterThanOrEqual(60);
    expect(items[4].getBoundingClientRect().height).toBeGreaterThanOrEqual(60);

    grid.remove();
  });

  it('uses multiple values in grid-auto-rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '50px';
    grid.style.gridAutoRows = '60px 80px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 8; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#FFB74D', '#FFA726', '#FF9800', '#FB8C00', '#F57C00', '#EF6C00', '#E65100', '#D84315'][i];
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
    // First row (explicit): 50px
    expect(items[0].getBoundingClientRect().height).toBe(50);
    // Second row (implicit, first pattern): 60px
    expect(items[2].getBoundingClientRect().height).toBe(60);
    // Third row (implicit, second pattern): 80px
    expect(items[4].getBoundingClientRect().height).toBe(80);
    // Fourth row (implicit, repeats first pattern): 60px
    expect(items[6].getBoundingClientRect().height).toBe(60);

    grid.remove();
  });

  it('uses fr units in grid-auto-rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '50px';
    grid.style.gridAutoRows = '1fr';
    grid.style.height = '250px';
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
    // First row: 50px explicit
    expect(items[0].getBoundingClientRect().height).toBe(50);
    // Remaining space (200px) divided by 2 implicit rows = 100px each
    expect(items[2].getBoundingClientRect().height).toBe(100);
    expect(items[4].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('combines grid-auto-rows with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '50px';
    grid.style.gridAutoRows = '70px';
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
    // Check row gaps are maintained
    const gap1 = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    const gap2 = items[4].getBoundingClientRect().top - items[2].getBoundingClientRect().bottom;
    expect(gap1).toBe(10);
    expect(gap2).toBe(10);

    grid.remove();
  });

  it('uses percentage values in grid-auto-rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '50px';
    grid.style.gridAutoRows = '20%';
    grid.style.height = '300px';
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
    // First row: 50px
    expect(items[0].getBoundingClientRect().height).toBe(50);
    // Second row: 20% of 300px = 60px
    expect(items[2].getBoundingClientRect().height).toBe(60);

    grid.remove();
  });
});
