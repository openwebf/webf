describe('CSS Grid area-based placement', () => {
  it('places items with grid-area using line numbers', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 50px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    // grid-area: row-start / column-start / row-end / column-end
    const item1 = document.createElement('div');
    item1.textContent = '1/1/2/3';
    item1.style.gridArea = '1 / 1 / 2 / 3';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = '2/2/4/5';
    item2.style.gridArea = '2 / 2 / 4 / 5';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: row 1, columns 1-3 (2 columns wide)
    expect(items[0].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[0].getBoundingClientRect().height).toBe(50); // 1 row
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);

    // Item 2: rows 2-4 (2 rows), columns 2-5 (3 columns)
    expect(items[1].getBoundingClientRect().width).toBe(210); // 70px * 3
    expect(items[1].getBoundingClientRect().height).toBe(100); // 50px * 2
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 70);
    expect(items[1].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 50);

    grid.remove();
  });

  it('places items using named grid areas', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 100px 100px';
    grid.style.gridTemplateRows = '60px 60px 60px';
    grid.style.gridTemplateAreas = `
      "header header header"
      "sidebar content content"
      "sidebar footer footer"
    `;
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    const header = document.createElement('div');
    header.textContent = 'Header';
    header.style.gridArea = 'header';
    header.style.backgroundColor = '#2196F3';
    header.style.display = 'flex';
    header.style.alignItems = 'center';
    header.style.justifyContent = 'center';
    header.style.color = 'white';
    grid.appendChild(header);

    const sidebar = document.createElement('div');
    sidebar.textContent = 'Sidebar';
    sidebar.style.gridArea = 'sidebar';
    sidebar.style.backgroundColor = '#42A5F5';
    sidebar.style.display = 'flex';
    sidebar.style.alignItems = 'center';
    sidebar.style.justifyContent = 'center';
    sidebar.style.color = 'white';
    grid.appendChild(sidebar);

    const content = document.createElement('div');
    content.textContent = 'Content';
    content.style.gridArea = 'content';
    content.style.backgroundColor = '#64B5F6';
    content.style.display = 'flex';
    content.style.alignItems = 'center';
    content.style.justifyContent = 'center';
    content.style.color = 'white';
    grid.appendChild(content);

    const footer = document.createElement('div');
    footer.textContent = 'Footer';
    footer.style.gridArea = 'footer';
    footer.style.backgroundColor = '#90CAF9';
    footer.style.display = 'flex';
    footer.style.alignItems = 'center';
    footer.style.justifyContent = 'center';
    grid.appendChild(footer);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Header: row 1, all columns
    expect(items[0].getBoundingClientRect().width).toBe(300); // 100px * 3
    expect(items[0].getBoundingClientRect().height).toBe(60);

    // Sidebar: rows 2-3, column 1
    expect(items[1].getBoundingClientRect().width).toBe(100);
    expect(items[1].getBoundingClientRect().height).toBe(120); // 60px * 2

    // Content: row 2, columns 2-3
    expect(items[2].getBoundingClientRect().width).toBe(200); // 100px * 2
    expect(items[2].getBoundingClientRect().height).toBe(60);

    // Footer: row 3, columns 2-3
    expect(items[3].getBoundingClientRect().width).toBe(200); // 100px * 2
    expect(items[3].getBoundingClientRect().height).toBe(60);

    grid.remove();
  });

  it('handles single-cell named areas', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gridTemplateAreas = `
      "a b c"
      "d e f"
      "g h i"
    `;
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const colors = ['#BA68C8', '#AB47BC', '#9C27B0', '#8E24AA', '#7B1FA2', '#6A1B9A', '#4A148C', '#38006B', '#1A0033'];
    const areas = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'];

    areas.forEach((area, index) => {
      const item = document.createElement('div');
      item.textContent = area.toUpperCase();
      item.style.gridArea = area;
      item.style.backgroundColor = colors[index];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    });

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Each item should be 80x60
    items.forEach((item, index) => {
      expect(item.getBoundingClientRect().width).toBe(80);
      expect(item.getBoundingClientRect().height).toBe(60);
    });

    // Check positions for first and last items
    expect(items[0].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left);
    expect(items[0].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top);

    expect(items[8].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 160);
    expect(items[8].getBoundingClientRect().top).toBe(grid.getBoundingClientRect().top + 120);

    grid.remove();
  });

  it('places items with grid-area shorthand mixing line numbers', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 90px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    // grid-area with single value (all four values)
    const item1 = document.createElement('div');
    item1.textContent = 'Area 1';
    item1.style.gridArea = '1 / 1 / 3 / 3';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // grid-area with span
    const item2 = document.createElement('div');
    item2.textContent = 'Area 2';
    item2.style.gridArea = '1 / 3 / span 2 / span 1';
    item2.style.backgroundColor = '#FFA726';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: rows 1-3 (2 rows), columns 1-3 (2 columns)
    expect(items[0].getBoundingClientRect().width).toBe(180); // 90px * 2
    expect(items[0].getBoundingClientRect().height).toBe(120); // 60px * 2

    // Item 2: rows 1-3 (span 2), column 3
    expect(items[1].getBoundingClientRect().width).toBe(90);
    expect(items[1].getBoundingClientRect().height).toBe(120); // 60px * 2
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 180);

    grid.remove();
  });

  it('handles invalid area names gracefully', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridTemplateAreas = `
      "header header header"
      "content content sidebar"
    `;
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const header = document.createElement('div');
    header.textContent = 'Header';
    header.style.gridArea = 'header';
    header.style.backgroundColor = '#66BB6A';
    header.style.display = 'flex';
    header.style.alignItems = 'center';
    header.style.justifyContent = 'center';
    header.style.color = 'white';
    grid.appendChild(header);

    // Invalid area name - should be auto-placed
    const invalid = document.createElement('div');
    invalid.textContent = 'Invalid';
    invalid.style.gridArea = 'nonexistent';
    invalid.style.backgroundColor = '#4CAF50';
    invalid.style.display = 'flex';
    invalid.style.alignItems = 'center';
    invalid.style.justifyContent = 'center';
    invalid.style.color = 'white';
    grid.appendChild(invalid);

    const content = document.createElement('div');
    content.textContent = 'Content';
    content.style.gridArea = 'content';
    content.style.backgroundColor = '#43A047';
    content.style.display = 'flex';
    content.style.alignItems = 'center';
    content.style.justifyContent = 'center';
    content.style.color = 'white';
    grid.appendChild(content);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Header should be placed correctly
    expect(items[0].getBoundingClientRect().width).toBe(240); // 80px * 3

    // Invalid area item should be auto-placed (1 column)
    expect(items[1].getBoundingClientRect().width).toBeGreaterThan(0);

    // Content should be placed correctly
    expect(items[2].getBoundingClientRect().width).toBe(160); // 80px * 2

    grid.remove();
  });

  it('places items with named area lines', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px 100px 100px';
    grid.style.gridTemplateRows = '60px 60px';
    grid.style.gridTemplateAreas = `
      "header header header"
      "sidebar content content"
    `;
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    // Use area line names: <area-name>-start and <area-name>-end
    const item1 = document.createElement('div');
    item1.textContent = 'Header lines';
    item1.style.gridColumnStart = 'header-start';
    item1.style.gridColumnEnd = 'header-end';
    item1.style.gridRowStart = 'header-start';
    item1.style.gridRowEnd = 'header-end';
    item1.style.backgroundColor = '#9575CD';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Content lines';
    item2.style.gridColumnStart = 'content-start';
    item2.style.gridColumnEnd = 'content-end';
    item2.style.gridRowStart = 'content-start';
    item2.style.gridRowEnd = 'content-end';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: should match header area
    expect(items[0].getBoundingClientRect().width).toBe(300); // 100px * 3
    expect(items[0].getBoundingClientRect().height).toBe(60);

    // Item 2: should match content area
    expect(items[1].getBoundingClientRect().width).toBe(200); // 100px * 2
    expect(items[1].getBoundingClientRect().height).toBe(60);
    expect(items[1].getBoundingClientRect().left).toBe(grid.getBoundingClientRect().left + 100);

    grid.remove();
  });

  it('handles complex named area layouts', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '80px 80px 80px 80px';
    grid.style.gridTemplateRows = '50px 50px 50px';
    grid.style.gridTemplateAreas = `
      "nav nav nav nav"
      "aside main main ad"
      "aside footer footer footer"
    `;
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    const nav = document.createElement('div');
    nav.textContent = 'Nav';
    nav.style.gridArea = 'nav';
    nav.style.backgroundColor = '#4DB6AC';
    nav.style.display = 'flex';
    nav.style.alignItems = 'center';
    nav.style.justifyContent = 'center';
    nav.style.color = 'white';
    grid.appendChild(nav);

    const aside = document.createElement('div');
    aside.textContent = 'Aside';
    aside.style.gridArea = 'aside';
    aside.style.backgroundColor = '#26A69A';
    aside.style.display = 'flex';
    aside.style.alignItems = 'center';
    aside.style.justifyContent = 'center';
    aside.style.color = 'white';
    grid.appendChild(aside);

    const main = document.createElement('div');
    main.textContent = 'Main';
    main.style.gridArea = 'main';
    main.style.backgroundColor = '#009688';
    main.style.display = 'flex';
    main.style.alignItems = 'center';
    main.style.justifyContent = 'center';
    main.style.color = 'white';
    grid.appendChild(main);

    const ad = document.createElement('div');
    ad.textContent = 'Ad';
    ad.style.gridArea = 'ad';
    ad.style.backgroundColor = '#00897B';
    ad.style.display = 'flex';
    ad.style.alignItems = 'center';
    ad.style.justifyContent = 'center';
    ad.style.color = 'white';
    grid.appendChild(ad);

    const footer = document.createElement('div');
    footer.textContent = 'Footer';
    footer.style.gridArea = 'footer';
    footer.style.backgroundColor = '#00796B';
    footer.style.display = 'flex';
    footer.style.alignItems = 'center';
    footer.style.justifyContent = 'center';
    footer.style.color = 'white';
    grid.appendChild(footer);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Nav: row 1, all columns
    expect(items[0].getBoundingClientRect().width).toBe(320); // 80px * 4
    expect(items[0].getBoundingClientRect().height).toBe(50);

    // Aside: rows 2-3, column 1
    expect(items[1].getBoundingClientRect().width).toBe(80);
    expect(items[1].getBoundingClientRect().height).toBe(100); // 50px * 2

    // Main: row 2, columns 2-3
    expect(items[2].getBoundingClientRect().width).toBe(160); // 80px * 2
    expect(items[2].getBoundingClientRect().height).toBe(50);

    // Ad: row 2, column 4
    expect(items[3].getBoundingClientRect().width).toBe(80);
    expect(items[3].getBoundingClientRect().height).toBe(50);

    // Footer: row 3, columns 2-4
    expect(items[4].getBoundingClientRect().width).toBe(240); // 80px * 3
    expect(items[4].getBoundingClientRect().height).toBe(50);

    grid.remove();
  });

  it('handles empty cells in grid-template-areas', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gridTemplateAreas = `
      "header header . ."
      "sidebar content content ."
      "sidebar footer footer ."
    `;
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    const header = document.createElement('div');
    header.textContent = 'Header';
    header.style.gridArea = 'header';
    header.style.backgroundColor = '#F06292';
    header.style.display = 'flex';
    header.style.alignItems = 'center';
    header.style.justifyContent = 'center';
    header.style.color = 'white';
    grid.appendChild(header);

    const sidebar = document.createElement('div');
    sidebar.textContent = 'Sidebar';
    sidebar.style.gridArea = 'sidebar';
    sidebar.style.backgroundColor = '#EC407A';
    sidebar.style.display = 'flex';
    sidebar.style.alignItems = 'center';
    sidebar.style.justifyContent = 'center';
    sidebar.style.color = 'white';
    grid.appendChild(sidebar);

    const content = document.createElement('div');
    content.textContent = 'Content';
    content.style.gridArea = 'content';
    content.style.backgroundColor = '#E91E63';
    content.style.display = 'flex';
    content.style.alignItems = 'center';
    content.style.justifyContent = 'center';
    content.style.color = 'white';
    grid.appendChild(content);

    const footer = document.createElement('div');
    footer.textContent = 'Footer';
    footer.style.gridArea = 'footer';
    footer.style.backgroundColor = '#D81B60';
    footer.style.display = 'flex';
    footer.style.alignItems = 'center';
    footer.style.justifyContent = 'center';
    footer.style.color = 'white';
    grid.appendChild(footer);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Header: row 1, columns 1-2
    expect(items[0].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[0].getBoundingClientRect().height).toBe(60);

    // Sidebar: rows 2-3, column 1
    expect(items[1].getBoundingClientRect().width).toBe(70);
    expect(items[1].getBoundingClientRect().height).toBe(120); // 60px * 2

    // Content: row 2, columns 2-3
    expect(items[2].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[2].getBoundingClientRect().height).toBe(60);

    // Footer: row 3, columns 2-3
    expect(items[3].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[3].getBoundingClientRect().height).toBe(60);

    grid.remove();
  });
});
