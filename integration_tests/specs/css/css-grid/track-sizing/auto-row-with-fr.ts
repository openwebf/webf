describe('CSS Grid auto row intrinsic sizing before flex distribution', () => {
  it('auto implicit row fits within container alongside fr rows', async () => {
    // 3 explicit fr rows + 1 implicit auto row inside a fixed-height grid.
    // The auto row content should be subtracted from available space before
    // distributing to fr rows, so everything fits within 220px.
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr 1fr';
    grid.style.gridTemplateRows = '1fr 1fr 1fr';
    grid.style.height = '220px';
    grid.style.width = '200px';
    grid.style.gap = '4px';
    grid.style.backgroundColor = '#f0f4ff';
    grid.style.border = '1px solid #d4d9f5';

    const itemA = document.createElement('div');
    itemA.textContent = 'A';
    itemA.style.backgroundColor = 'rgba(59, 130, 246, 0.4)';
    grid.appendChild(itemA);

    const itemB = document.createElement('div');
    itemB.textContent = 'B';
    itemB.style.backgroundColor = 'rgba(16, 185, 129, 0.4)';
    grid.appendChild(itemB);

    // Items placed in rows 2 and 3
    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = String(i + 3);
      item.style.backgroundColor = ['rgba(234, 179, 8, 0.4)', 'rgba(239, 68, 68, 0.4)', 'rgba(129, 140, 248, 0.4)', 'rgba(236, 72, 153, 0.4)'][i];
      grid.appendChild(item);
    }

    // Item C spans 2 columns, auto-placed into implicit row 4
    const itemC = document.createElement('div');
    itemC.textContent = 'C (col-span-2, auto row)';
    itemC.style.gridColumn = 'span 2';
    itemC.style.backgroundColor = 'rgba(168, 85, 247, 0.4)';
    itemC.style.padding = '8px';
    grid.appendChild(itemC);

    // Label below the grid to detect overflow
    const label = document.createElement('div');
    label.textContent = 'Label below grid';
    label.style.backgroundColor = '#fee2e2';
    label.style.padding = '4px';

    const wrapper = document.createElement('div');
    wrapper.appendChild(grid);
    wrapper.appendChild(label);
    document.body.appendChild(wrapper);

    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const itemCRect = itemC.getBoundingClientRect();
    const labelRect = label.getBoundingClientRect();

    // Grid container height should be 220px
    expect(Math.round(gridRect.height)).toBe(220);

    // Item C bottom should not exceed grid bottom
    expect(itemCRect.bottom).toBeLessThanOrEqual(gridRect.bottom + 1);

    // Label should start at or after grid bottom (no overlap)
    expect(labelRect.top).toBeGreaterThanOrEqual(gridRect.bottom - 1);

    wrapper.remove();
  });

  it('auto row content height is subtracted from fr distribution', async () => {
    // Explicit: 3 x 1fr rows. Implicit: 1 auto row with known content height.
    // Container height: 200px, gap: 0.
    // Expected: auto row takes its intrinsic height, fr rows share the rest.
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr';
    grid.style.gridTemplateRows = '1fr 1fr 1fr';
    grid.style.height = '200px';
    grid.style.width = '150px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ecfccb';

    // 3 items for the 3 explicit fr rows
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `Row ${i + 1}`;
      item.style.backgroundColor = ['#bef264', '#a3e635', '#84cc16'][i];
      grid.appendChild(item);
    }

    // Item in implicit auto row with fixed height
    const autoItem = document.createElement('div');
    autoItem.textContent = 'Auto';
    autoItem.style.height = '50px';
    autoItem.style.backgroundColor = '#fbbf24';
    grid.appendChild(autoItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const autoRect = autoItem.getBoundingClientRect();
    const items = Array.from(grid.children) as HTMLElement[];
    const frItemRect = items[0].getBoundingClientRect();

    // Grid should be 200px
    expect(Math.round(gridRect.height)).toBe(200);

    // Auto row should be 50px
    expect(Math.round(autoRect.height)).toBe(50);

    // Each fr row should be (200 - 50) / 3 = 50px
    expect(Math.round(frItemRect.height)).toBe(50);

    // Auto item bottom should not exceed grid bottom
    expect(autoRect.bottom).toBeLessThanOrEqual(gridRect.bottom + 1);

    grid.remove();
  });

  it('auto row with gap subtracts correctly from fr rows', async () => {
    // Container: 300px, 3 x 1fr + 1 auto row, gap: 10px (3 gaps for 4 rows).
    // Available for tracks: 300 - 30 = 270. Auto row = 60px.
    // Fr rows: (270 - 60) / 3 = 70px each.
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr';
    grid.style.gridTemplateRows = '1fr 1fr 1fr';
    grid.style.height = '300px';
    grid.style.width = '150px';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e0f2fe';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = `Fr ${i + 1}`;
      item.style.backgroundColor = ['#38bdf8', '#0ea5e9', '#0284c7'][i];
      item.style.color = 'white';
      grid.appendChild(item);
    }

    const autoItem = document.createElement('div');
    autoItem.textContent = 'Auto row';
    autoItem.style.height = '60px';
    autoItem.style.backgroundColor = '#f97316';
    autoItem.style.color = 'white';
    grid.appendChild(autoItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const autoRect = autoItem.getBoundingClientRect();
    const items = Array.from(grid.children) as HTMLElement[];
    const frRect = items[0].getBoundingClientRect();

    expect(Math.round(gridRect.height)).toBe(300);
    expect(Math.round(autoRect.height)).toBe(60);
    // (300 - 30 gaps - 60 auto) / 3 = 70
    expect(Math.round(frRect.height)).toBe(70);

    // Everything fits within the grid
    expect(autoRect.bottom).toBeLessThanOrEqual(gridRect.bottom + 1);

    grid.remove();
  });

  it('multiple auto rows with fr rows distribute correctly', async () => {
    // 2 explicit fr rows + 2 implicit auto rows.
    // Container: 200px, gap: 0.
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr';
    grid.style.gridTemplateRows = '1fr 1fr';
    grid.style.height = '200px';
    grid.style.width = '150px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fdf2f8';

    // 2 items for explicit fr rows
    for (let i = 0; i < 2; i++) {
      const item = document.createElement('div');
      item.textContent = `Fr ${i + 1}`;
      item.style.backgroundColor = ['#f472b6', '#ec4899'][i];
      item.style.color = 'white';
      grid.appendChild(item);
    }

    // 2 items for implicit auto rows
    const auto1 = document.createElement('div');
    auto1.textContent = 'Auto 1';
    auto1.style.height = '30px';
    auto1.style.backgroundColor = '#a78bfa';
    grid.appendChild(auto1);

    const auto2 = document.createElement('div');
    auto2.textContent = 'Auto 2';
    auto2.style.height = '40px';
    auto2.style.backgroundColor = '#8b5cf6';
    auto2.style.color = 'white';
    grid.appendChild(auto2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const gridRect = grid.getBoundingClientRect();
    const auto1Rect = auto1.getBoundingClientRect();
    const auto2Rect = auto2.getBoundingClientRect();
    const items = Array.from(grid.children) as HTMLElement[];
    const frRect = items[0].getBoundingClientRect();

    expect(Math.round(gridRect.height)).toBe(200);
    expect(Math.round(auto1Rect.height)).toBe(30);
    expect(Math.round(auto2Rect.height)).toBe(40);
    // Fr rows: (200 - 30 - 40) / 2 = 65
    expect(Math.round(frRect.height)).toBe(65);

    // Everything within grid bounds
    expect(auto2Rect.bottom).toBeLessThanOrEqual(gridRect.bottom + 1);

    grid.remove();
  });
});
