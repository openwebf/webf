describe('CSS Grid absolute positioning with offset properties', () => {
  it('uses top and left offsets', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.width = '310px';
    grid.style.height = '210px';

    const absItem = document.createElement('div');
    absItem.textContent = 'TL';
    absItem.style.position = 'absolute';
    absItem.style.top = '30px';
    absItem.style.left = '40px';
    absItem.style.width = '80px';
    absItem.style.height = '60px';
    absItem.style.backgroundColor = '#42A5F5';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 30);
    expect(absItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 40);

    grid.remove();
  });

  it('uses bottom and right offsets', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';
    grid.style.width = '310px';
    grid.style.height = '210px';

    const absItem = document.createElement('div');
    absItem.textContent = 'BR';
    absItem.style.position = 'absolute';
    absItem.style.bottom = '20px';
    absItem.style.right = '30px';
    absItem.style.width = '80px';
    absItem.style.height = '60px';
    absItem.style.backgroundColor = '#2196F3';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(absItem.getBoundingClientRect().bottom).toBe(grid.getBoundingClientRect().bottom - 20);
    expect(absItem.getBoundingClientRect().right).toBe(grid.getBoundingClientRect().right - 30);

    grid.remove();
  });

  it('uses inset shorthand property', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';
    grid.style.width = '310px';
    grid.style.height = '210px';

    const absItem = document.createElement('div');
    absItem.textContent = 'Inset 20px';
    absItem.style.position = 'absolute';
    absItem.style.inset = '20px';
    absItem.style.backgroundColor = '#BA68C8';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '11px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Should stretch with 20px inset on all sides
    expect(absItem.getBoundingClientRect().width).toBe(270); // 310 - 40
    expect(absItem.getBoundingClientRect().height).toBe(170); // 210 - 40
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 20);
    expect(absItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 20);

    grid.remove();
  });

  it('uses inset with two values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.width = '310px';
    grid.style.height = '210px';

    const absItem = document.createElement('div');
    absItem.textContent = 'Inset 15px 25px';
    absItem.style.position = 'absolute';
    absItem.style.inset = '15px 25px'; // vertical horizontal
    absItem.style.backgroundColor = '#FFB74D';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '10px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // 15px top/bottom, 25px left/right
    expect(absItem.getBoundingClientRect().width).toBe(260); // 310 - 50
    expect(absItem.getBoundingClientRect().height).toBe(180); // 210 - 30
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 15);
    expect(absItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 25);

    grid.remove();
  });

  it('uses negative offsets to extend beyond grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.width = '310px';
    grid.style.height = '210px';

    const absItem = document.createElement('div');
    absItem.textContent = 'Extended';
    absItem.style.position = 'absolute';
    absItem.style.top = '-10px';
    absItem.style.left = '-10px';
    absItem.style.right = '-10px';
    absItem.style.bottom = '-10px';
    absItem.style.backgroundColor = 'rgba(102, 187, 106, 0.8)';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '11px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Extends 10px beyond grid on all sides
    expect(absItem.getBoundingClientRect().width).toBe(330); // 310 + 20
    expect(absItem.getBoundingClientRect().height).toBe(230); // 210 + 20
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top - 10);
    expect(absItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left - 10);

    grid.remove();
  });

  it('uses calc() in offset values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';
    grid.style.width = '310px';
    grid.style.height = '210px';

    const absItem = document.createElement('div');
    absItem.textContent = 'Calc';
    absItem.style.position = 'absolute';
    absItem.style.top = 'calc(50% - 30px)';
    absItem.style.left = 'calc(50% - 40px)';
    absItem.style.width = '80px';
    absItem.style.height = '60px';
    absItem.style.backgroundColor = '#9575CD';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // 50% of 310px = 155px, 50% of 210px = 105px
    expect(absItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 155 - 40);
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 105 - 30);

    grid.remove();
  });

  it('combines different offset units', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.position = 'relative';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';
    grid.style.width = '400px';
    grid.style.height = '300px';

    const absItem = document.createElement('div');
    absItem.textContent = 'Mixed';
    absItem.style.position = 'absolute';
    absItem.style.top = '10%';
    absItem.style.left = '20px';
    absItem.style.right = '15%';
    absItem.style.bottom = '25px';
    absItem.style.backgroundColor = '#4DB6AC';
    absItem.style.display = 'flex';
    absItem.style.alignItems = 'center';
    absItem.style.justifyContent = 'center';
    absItem.style.color = 'white';
    absItem.style.fontSize = '12px';
    grid.appendChild(absItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Top: 10% of 300px = 30px
    expect(absItem.getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 30);
    // Left: 20px
    expect(absItem.getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 20);
    // Right: 15% of 400px = 60px from right edge
    expect(absItem.getBoundingClientRect().right).toBe(grid.getBoundingClientRect().right - 60);
    // Bottom: 25px from bottom edge
    expect(absItem.getBoundingClientRect().bottom).toBe(grid.getBoundingClientRect().bottom - 25);

    grid.remove();
  });
});
