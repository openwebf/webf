describe('CSS Grid extreme values', () => {
  it('handles very small track sizes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(5, 10px)';
    grid.style.gridTemplateRows = 'repeat(2, 10px)';
    grid.style.gap = '2px';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 10; i++) {
      const item = document.createElement('div');
      item.style.backgroundColor = `hsl(${i * 36}, 70%, 60%)`;
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(10);
    expect(items[0].getBoundingClientRect().height).toBe(10);

    grid.remove();
  });

  it('handles very large track sizes', async () => {
    const container = document.createElement('div');
    container.style.maxWidth = '340px';
    container.style.maxHeight = '300px';
    container.style.overflow = 'auto';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 500px)';
    grid.style.gridTemplateRows = 'repeat(2, 400px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 20}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '24px';
      grid.appendChild(item);
    }

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(500);
    expect(items[0].getBoundingClientRect().height).toBe(400);

    container.remove();
  });

  it('handles very small gap values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gap = '0.5px';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 6; i++) {
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

    const items = Array.from(grid.children) as HTMLElement[];
    const gap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(Math.abs(gap - 0.5)).toBeLessThan(1);

    grid.remove();
  });

  it('handles very large gap values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gap = '50px';
    grid.style.backgroundColor = '#fff3e0';

    for (let i = 0; i < 4; i++) {
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
    const colGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    const rowGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(colGap).toBe(50);
    expect(rowGap).toBe(50);

    grid.remove();
  });

  it('handles fractional pixel values', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '333px'; // Creates fractional fr values
    grid.style.gridTemplateColumns = '1fr 1fr 1fr';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 6; i++) {
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

    // 333 - 20 (gaps) = 313 / 3 = 104.33px per column
    const items = Array.from(grid.children) as HTMLElement[];
    const totalWidth = items[0].getBoundingClientRect().width +
                       items[1].getBoundingClientRect().width +
                       items[2].getBoundingClientRect().width + 20;
    expect(Math.abs(totalWidth - 333)).toBeLessThan(2);

    grid.remove();
  });

  it('handles zero-width or zero-height tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '0px 100px 0px 150px';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '5px';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '10px';
      item.style.minWidth = '0';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(0);
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[2].getBoundingClientRect().width).toBe(0);
    expect(items[3].getBoundingClientRect().width).toBe(150);

    grid.remove();
  });
});
