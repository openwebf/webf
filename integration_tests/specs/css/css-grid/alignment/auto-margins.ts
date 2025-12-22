describe('CSS Grid auto margins and alignment interaction', () => {
  it('auto margins override justify-items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 120px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.justifyItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['Start', 'Auto left', 'Auto both'][i];
      item.style.width = '80px';
      if (i === 1) {
        item.style.marginLeft = 'auto';
      } else if (i === 2) {
        item.style.marginLeft = 'auto';
        item.style.marginRight = 'auto';
      }
      item.style.backgroundColor = ['#42A5F5', '#66BB6A', '#FFA726'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '10px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Item 1: aligned start (justify-items)
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    // Item 2: margin-left auto pushes to right
    expect(items[1].getBoundingClientRect().right).toBe(grid.getBoundingClientRect().left + 240);
    // Item 3: centered with auto margins
    const item3Center = (items[2].getBoundingClientRect().left + items[2].getBoundingClientRect().right) / 2;
    const area3Center = grid.getBoundingClientRect().left + 300; // Third column center
    expect(Math.abs(item3Center - area3Center)).toBeLessThan(1);

    grid.remove();
  });

  it('auto margins override align-items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '120px';
    grid.style.gridTemplateRows = 'repeat(3, 100px)';
    grid.style.alignItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.textContent = ['Start', 'Auto top', 'Auto both'][i];
      item.style.height = '60px';
      if (i === 1) {
        item.style.marginTop = 'auto';
      } else if (i === 2) {
        item.style.marginTop = 'auto';
        item.style.marginBottom = 'auto';
      }
      item.style.backgroundColor = ['#2196F3', '#1E88E5', '#1976D2'][i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.fontSize = '10px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Item 1: aligned start (align-items)
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);
    // Item 2: margin-top auto pushes to bottom
    expect(items[1].getBoundingClientRect().bottom).toBe(grid.getBoundingClientRect().top + 200);
    // Item 3: centered with auto margins
    const item3Center = (items[2].getBoundingClientRect().top + items[2].getBoundingClientRect().bottom) / 2;
    const area3Center = grid.getBoundingClientRect().top + 250; // Third row center
    expect(Math.abs(item3Center - area3Center)).toBeLessThan(1);

    grid.remove();
  });

  it('auto margins override justify-self', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = '90px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'justify-self: end';
    item1.style.justifySelf = 'end';
    item1.style.width = '100px';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'margin-left: auto';
    item2.style.justifySelf = 'start'; // Should be overridden
    item2.style.marginLeft = 'auto';
    item2.style.width = '100px';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Item 1: respect justify-self
    expect(items[0].getBoundingClientRect().right).toBe(grid.getBoundingClientRect().left + 150);
    // Item 2: auto margin overrides justify-self
    expect(items[1].getBoundingClientRect().right).toBe(grid.getBoundingClientRect().left + 300);

    grid.remove();
  });

  it('combines auto margins in both axes', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px';
    grid.style.gridTemplateRows = '180px';
    grid.style.justifyItems = 'start';
    grid.style.alignItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'Centered';
    item.style.width = '120px';
    item.style.height = '100px';
    item.style.margin = 'auto';
    item.style.backgroundColor = '#FFB74D';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    const gridRect = grid.getBoundingClientRect();

    // Item should be centered both ways
    const leftMargin = itemRect.left - gridRect.left;
    const rightMargin = gridRect.right - itemRect.right;
    const topMargin = itemRect.top - gridRect.top;
    const bottomMargin = gridRect.bottom - itemRect.bottom;

    expect(Math.abs(leftMargin - rightMargin)).toBeLessThan(1);
    expect(Math.abs(topMargin - bottomMargin)).toBeLessThan(1);

    grid.remove();
  });

  it('auto margins with spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const item = document.createElement('div');
    item.textContent = 'Span 2x2';
    item.style.gridColumn = 'span 2';
    item.style.gridRow = 'span 2';
    item.style.width = '140px';
    item.style.height = '120px';
    item.style.margin = 'auto';
    item.style.backgroundColor = '#66BB6A';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    // Item should be centered in 2x2 area
    expect(itemRect.width).toBe(140);
    expect(itemRect.height).toBe(120);

    grid.remove();
  });
});
