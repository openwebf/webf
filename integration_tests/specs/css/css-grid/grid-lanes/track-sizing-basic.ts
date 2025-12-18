describe('CSS Grid track sizing fundamentals', () => {
  it('sizes fixed pixel tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 150px 200px';
    grid.style.gridTemplateRows = '60px 80px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `Item ${i + 1}`;
      item.style.backgroundColor = i % 2 === 0 ? '#42A5F5' : '#66BB6A';
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
    // First row
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().width).toBe(150);
    expect(items[2].getBoundingClientRect().width).toBe(200);
    expect(items[0].getBoundingClientRect().height).toBe(60);

    // Second row
    expect(items[3].getBoundingClientRect().height).toBe(80);

    grid.remove();
  });

  it('sizes percentage tracks in definite container', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '360px';
    grid.style.height = '200px';
    grid.style.gridTemplateColumns = '25% 50% 25%';
    grid.style.gridTemplateRows = '40% 60%';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#2196F3', '#1E88E5', '#1976D2', '#1565C0', '#0D47A1', '#0277BD'][i];
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
    // Column percentages
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(90, 0); // 25% of 360px
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(180, 0); // 50% of 360px
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(90, 0); // 25% of 360px

    // Row percentages
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(80, 0); // 40% of 200px
    expect(items[3].getBoundingClientRect().height).toBeCloseTo(120, 0); // 60% of 200px

    grid.remove();
  });

  it('sizes percentage tracks in indefinite container', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    // No height set - indefinite
    grid.style.gridTemplateColumns = '30% 40% 30%';
    grid.style.gridTemplateRows = '50% 50%'; // Percentages in indefinite container
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#BA68C8', '#AB47BC', '#9C27B0'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      // Give items some content height
      item.style.minHeight = '60px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Width percentages should work (definite container width)
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(90, 0); // 30% of 300px
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(120, 0); // 40% of 300px
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(90, 0); // 30% of 300px

    // Height percentages in indefinite container should resolve
    expect(items[0].getBoundingClientRect().height).toBeGreaterThan(0);

    grid.remove();
  });

  it('sizes auto tracks to content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'auto auto auto';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.padding = '10px';

    const item1 = document.createElement('div');
    item1.textContent = 'Short';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.padding = '10px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Medium Length Text';
    item2.style.backgroundColor = '#FFA726';
    item2.style.padding = '10px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Very Long Content Here';
    item3.style.backgroundColor = '#FF9800';
    item3.style.padding = '10px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    const widths = items.map(item => item.getBoundingClientRect().width);

    // Auto tracks should size to content
    expect(widths[0]).toBeGreaterThan(0);
    expect(widths[1]).toBeGreaterThan(widths[0]);
    expect(widths[2]).toBeGreaterThan(widths[1]);

    grid.remove();
  });

  it('resolves track sizes in correct order', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '350px';
    // Fixed tracks are resolved first, then auto, then fr
    grid.style.gridTemplateColumns = '100px auto 1fr 80px';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.textContent = '100px';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Auto Content';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    item2.style.padding = '5px';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = '1fr';
    item3.style.backgroundColor = '#43A047';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    item3.style.fontSize = '11px';
    grid.appendChild(item3);

    const item4 = document.createElement('div');
    item4.textContent = '80px';
    item4.style.backgroundColor = '#388E3C';
    item4.style.display = 'flex';
    item4.style.alignItems = 'center';
    item4.style.justifyContent = 'center';
    item4.style.color = 'white';
    item4.style.fontSize = '11px';
    grid.appendChild(item4);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Fixed tracks
    expect(items[0].getBoundingClientRect().width).toBe(100);
    expect(items[3].getBoundingClientRect().width).toBe(80);

    // Auto track should fit content
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);

    // Fr track gets remaining space
    const autoWidth = items[1].getBoundingClientRect().width;
    const frWidth = items[2].getBoundingClientRect().width;
    // Total: 100 + autoWidth + frWidth + 80 + 30 (gaps) = 350
    expect(100 + autoWidth + frWidth + 80 + 30).toBeCloseTo(350, 0);

    grid.remove();
  });

  it('handles zero-sized tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '0px 100px 0px 100px';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = ['#F48FB1', '#F06292', '#EC407A', '#E91E63'][i];
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
    expect(items[0].getBoundingClientRect().width).toBe(0);
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[2].getBoundingClientRect().width).toBe(0);
    expect(items[3].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });

  it('handles very large fixed tracks', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '300px';
    grid.style.gridTemplateColumns = '500px 100px'; // First track larger than container
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e1f5fe';
    grid.style.overflow = 'hidden';

    const item1 = document.createElement('div');
    item1.textContent = '500px Track';
    item1.style.backgroundColor = '#03A9F4';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '100px';
    item2.style.backgroundColor = '#0288D1';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Tracks maintain their specified size even if larger than container
    expect(items[0].getBoundingClientRect().width).toBe(500);
    expect(items[1].getBoundingClientRect().width).toBe(100);

    grid.remove();
  });
});
