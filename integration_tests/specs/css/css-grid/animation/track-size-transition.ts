describe('CSS Grid track size transitions', () => {
  it('transitions fixed track sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 200px';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.transition = 'grid-template-columns 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${i * 60}, 70%, 60%)`;
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
    const initialWidth = items[0].getBoundingClientRect().width;
    expect(initialWidth).toBe(100);

    // Change track size
    grid.style.gridTemplateColumns = '150px 250px';
    await waitForFrame();
    await snapshot();

    const newWidth = items[0].getBoundingClientRect().width;
    expect(newWidth).toBe(150);

    grid.remove();
  });

  it('handles transition on row track sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px 80px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';
    grid.style.transition = 'grid-template-rows 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
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
    const initialHeight = items[0].getBoundingClientRect().height;
    expect(initialHeight).toBe(60);

    // Change row sizes
    grid.style.gridTemplateRows = '90px 110px';
    await waitForFrame();
    await snapshot();

    const newHeight = items[0].getBoundingClientRect().height;
    expect(newHeight).toBe(90);

    grid.remove();
  });

  it('transitions between different track units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = '100px 200px';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';
    grid.style.transition = 'grid-template-columns 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Change to percentage
    grid.style.gridTemplateColumns = '25% 50%';
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(100); // 25% of 400
    expect(items[1].getBoundingClientRect().width).toBe(200); // 50% of 400

    grid.remove();
  });

  it('transitions auto-rows property', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.transition = 'grid-auto-rows 0.3s';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 15}, 70%, 65%)`;
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
    expect(items[2].getBoundingClientRect().height).toBe(70);

    // Change auto-rows
    grid.style.gridAutoRows = '90px';
    await waitForFrame();
    await snapshot();

    expect(items[2].getBoundingClientRect().height).toBe(90);

    grid.remove();
  });

  it('handles simultaneous column and row transitions', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.transition = 'grid-template-columns 0.3s, grid-template-rows 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Change both dimensions
    grid.style.gridTemplateColumns = 'repeat(2, 130px)';
    grid.style.gridTemplateRows = 'repeat(2, 90px)';
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(130);
    expect(items[0].getBoundingClientRect().height).toBe(90);

    grid.remove();
  });

  it('transitions with fr units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '400px';
    grid.style.gridTemplateColumns = '100px 1fr';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';
    grid.style.transition = 'grid-template-columns 0.3s';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Change fr distribution
    grid.style.gridTemplateColumns = '150px 1fr';
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(150);
    // Second column: 400 - 150 - 10 = 240
    expect(items[1].getBoundingClientRect().width).toBe(240);

    grid.remove();
  });
});
