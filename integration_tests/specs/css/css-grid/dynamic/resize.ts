describe('CSS Grid container resize behavior', () => {
  it('reflows grid when container width changes', async () => {
    const container = document.createElement('div');
    container.style.width = '400px';
    container.style.height = '300px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr 1fr';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.width = '100%';

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

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    const initialWidth = grid.children[0].getBoundingClientRect().width;
    expect(initialWidth).toBe(195); // (400 - 10) / 2

    // Resize container
    container.style.width = '600px';
    await waitForFrame();
    await snapshot();

    const newWidth = grid.children[0].getBoundingClientRect().width;
    expect(newWidth).toBe(295); // (600 - 10) / 2

    container.remove();
  });

  it('reflows grid when container height changes', async () => {
    const container = document.createElement('div');
    container.style.width = '300px';
    container.style.height = '200px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '1fr 1fr';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';
    grid.style.height = '100%';

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

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    const initialHeight = grid.children[0].getBoundingClientRect().height;
    expect(initialHeight).toBe(95); // (200 - 10) / 2

    // Resize container
    container.style.height = '400px';
    await waitForFrame();
    await snapshot();

    const newHeight = grid.children[0].getBoundingClientRect().height;
    expect(newHeight).toBe(195); // (400 - 10) / 2

    container.remove();
  });

  it('recalculates percentage track sizing on resize', async () => {
    const container = document.createElement('div');
    container.style.width = '400px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '50% 25% 25%';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';
    grid.style.width = '100%';

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

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(200); // 50% of 400
    expect(items[1].getBoundingClientRect().width).toBe(100); // 25% of 400

    // Resize container
    container.style.width = '600px';
    await waitForFrame();
    await snapshot();

    expect(items[0].getBoundingClientRect().width).toBe(300); // 50% of 600
    expect(items[1].getBoundingClientRect().width).toBe(150); // 25% of 600

    container.remove();
  });

  it('recalculates fr units on container resize', async () => {
    const container = document.createElement('div');
    container.style.width = '400px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 1fr 2fr';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.width = '100%';

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

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // 400 - 100 - 20 (gaps) = 280 remaining for 3fr = 93.33 per fr
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(Math.round(items[1].getBoundingClientRect().width)).toBe(93); // 1fr
    expect(Math.round(items[2].getBoundingClientRect().width)).toBe(187); // 2fr

    // Resize container
    container.style.width = '700px';
    await waitForFrame();
    await snapshot();

    // 700 - 100 - 20 (gaps) = 580 remaining for 3fr = 193.33 per fr
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(Math.round(items[1].getBoundingClientRect().width)).toBe(193); // 1fr
    expect(Math.round(items[2].getBoundingClientRect().width)).toBe(387); // 2fr

    container.remove();
  });

  it('recalculates auto-fit columns on resize', async () => {
    const container = document.createElement('div');
    container.style.width = '350px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(auto-fit, minmax(100px, 1fr))';
    grid.style.gridAutoRows = '70px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';
    grid.style.width = '100%';

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

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const initialRow1Count = items.filter(item =>
      item.getBoundingClientRect().top === grid.getBoundingClientRect().top
    ).length;
    // 350px width: can fit 3 columns at 100px min with 20px gaps
    expect(initialRow1Count).toBe(3);

    // Resize container to fit 4 columns
    container.style.width = '460px';
    await waitForFrame();
    await snapshot();

    const newRow1Count = items.filter(item =>
      item.getBoundingClientRect().top === grid.getBoundingClientRect().top
    ).length;
    // 460px width: can fit 4 columns at 100px min with 30px gaps
    expect(newRow1Count).toBe(4);

    container.remove();
  });

  it('recalculates percentage gaps on resize', async () => {
    const container = document.createElement('div');
    container.style.width = '400px';
    container.style.height = '300px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.columnGap = '5%';
    grid.style.rowGap = '5%';
    grid.style.backgroundColor = '#ede7f6';
    grid.style.width = '100%';
    grid.style.height = '100%';

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

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Column gap: 5% of 400px = 20px
    const initialColGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(initialColGap).toBe(20);
    // Row gap: 5% of 300px = 15px
    const initialRowGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(initialRowGap).toBe(15);

    // Resize container
    container.style.width = '600px';
    container.style.height = '400px';
    await waitForFrame();
    await snapshot();

    // Column gap: 5% of 600px = 30px
    const newColGap = items[1].getBoundingClientRect().left - items[0].getBoundingClientRect().right;
    expect(newColGap).toBe(30);
    // Row gap: 5% of 400px = 20px
    const newRowGap = items[2].getBoundingClientRect().top - items[0].getBoundingClientRect().bottom;
    expect(newRowGap).toBe(20);

    container.remove();
  });

  it('handles minmax() with resize', async () => {
    const container = document.createElement('div');
    container.style.width = '300px';

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, minmax(80px, 1fr))';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2f1';
    grid.style.width = '100%';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${160 + i * 15}, 60%, 50%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    container.appendChild(grid);
    document.body.appendChild(container);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // 300 - 20 (gaps) = 280 / 3 = 93.33px (above min of 80px)
    expect(Math.round(items[0].getBoundingClientRect().width)).toBe(93);

    // Resize to narrow container
    container.style.width = '200px';
    await waitForFrame();
    await snapshot();

    // 200 - 20 (gaps) = 180 / 3 = 60px, but min is 80px so columns should be 80px
    expect(items[0].getBoundingClientRect().width).toBe(80);

    container.remove();
  });
});
