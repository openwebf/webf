xdescribe('CSS Grid safe and unsafe alignment', () => {
  it('handles safe center alignment', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyContent = 'safe center';
    grid.style.alignContent = 'safe center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = 'Safe center';
    item.style.backgroundColor = '#42A5F5';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Safe alignment should prevent overflow
    expect(item.getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('handles unsafe center alignment', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyContent = 'unsafe center';
    grid.style.alignContent = 'unsafe center';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    const item = document.createElement('div');
    item.textContent = 'Unsafe center';
    item.style.backgroundColor = '#2196F3';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '10px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Unsafe allows overflow
    expect(item.getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('handles safe start alignment', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'safe start';
    grid.style.alignItems = 'safe start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.textContent = 'Safe start';
    item.style.backgroundColor = '#BA68C8';
    item.style.padding = '10px';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);

    grid.remove();
  });

  it('handles safe end alignment', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '120px';
    grid.style.gridTemplateRows = '90px';
    grid.style.justifyItems = 'safe end';
    grid.style.alignItems = 'safe end';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'Safe end';
    item.style.backgroundColor = '#FFB74D';
    item.style.padding = '10px';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().right).toBe(grid.getBoundingClientRect().right);

    grid.remove();
  });
});
