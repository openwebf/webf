describe('CSS Grid template areas advanced', () => {
  it('handles complex multi-row areas', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '320px';
    grid.style.gridTemplateColumns = 'repeat(4, 1fr)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gridTemplateAreas = `
      "header header header sidebar"
      "main main content sidebar"
      "footer footer footer footer"
    `;
    grid.style.gap = '8px';
    grid.style.backgroundColor = '#f5f5f5';
    grid.style.padding = '8px';

    const areas = [
      { name: 'header', text: 'Header', color: '#2196F3' },
      { name: 'main', text: 'Main', color: '#4CAF50' },
      { name: 'content', text: 'Content', color: '#FF9800' },
      { name: 'sidebar', text: 'Sidebar', color: '#9C27B0' },
      { name: 'footer', text: 'Footer', color: '#F44336' }
    ];

    areas.forEach(area => {
      const item = document.createElement('div');
      item.textContent = area.text;
      item.style.gridArea = area.name;
      item.style.backgroundColor = area.color;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.borderRadius = '4px';
      grid.appendChild(item);
    });

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const header = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'Header') as HTMLElement;
    const footer = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'Footer') as HTMLElement;
    const sidebar = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'Sidebar') as HTMLElement;

    const gridRect = grid.getBoundingClientRect();
    const headerRect = header.getBoundingClientRect();
    const footerRect = footer.getBoundingClientRect();
    const sidebarRect = sidebar.getBoundingClientRect();

    // Header should span 3 columns
    expect(headerRect.width).toBeGreaterThan(sidebarRect.width * 2);
    // Footer should span all 4 columns
    expect(footerRect.width).toBeGreaterThan(headerRect.width);
    // Sidebar should span 2 rows
    expect(sidebarRect.height).toBeGreaterThan(headerRect.height);

    grid.remove();
  });

  it('handles empty cells with dot notation', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '240px';
    grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridTemplateAreas = `
      "a . b"
      "c c ."
    `;
    grid.style.gap = '8px';
    grid.style.backgroundColor = '#fafafa';
    grid.style.padding = '8px';

    const items = [
      { area: 'a', color: '#03A9F4' },
      { area: 'b', color: '#4CAF50' },
      { area: 'c', color: '#FF5722' }
    ];

    items.forEach(item => {
      const el = document.createElement('div');
      el.textContent = item.area.toUpperCase();
      el.style.gridArea = item.area;
      el.style.backgroundColor = item.color;
      el.style.display = 'flex';
      el.style.alignItems = 'center';
      el.style.justifyContent = 'center';
      el.style.color = 'white';
      el.style.borderRadius = '4px';
      grid.appendChild(el);
    });

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(3); // Only 3 items, not 6

    const aItem = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'A') as HTMLElement;
    const bItem = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'B') as HTMLElement;
    const cItem = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'C') as HTMLElement;

    expect(aItem.getBoundingClientRect().width).toBeGreaterThan(0);
    expect(bItem.getBoundingClientRect().width).toBeGreaterThan(0);
    expect(cItem.getBoundingClientRect().width).toBeGreaterThan(aItem.getBoundingClientRect().width);

    grid.remove();
  });

  it('combines areas with line placement', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '280px';
    grid.style.gridTemplateColumns = '[start] 1fr [middle] 1fr [end]';
    grid.style.gridTemplateRows = '[top] 60px [center] 60px [bottom]';
    grid.style.gridTemplateAreas = `
      "left right"
      "footer footer"
    `;
    grid.style.gap = '8px';
    grid.style.backgroundColor = '#f3f4f6';
    grid.style.padding = '8px';

    const leftArea = document.createElement('div');
    leftArea.textContent = 'Left Area';
    leftArea.style.gridArea = 'left';
    leftArea.style.backgroundColor = '#8B5CF6';
    leftArea.style.display = 'flex';
    leftArea.style.alignItems = 'center';
    leftArea.style.justifyContent = 'center';
    leftArea.style.color = 'white';
    leftArea.style.borderRadius = '4px';
    grid.appendChild(leftArea);

    const rightArea = document.createElement('div');
    rightArea.textContent = 'Right Area';
    rightArea.style.gridArea = 'right';
    rightArea.style.backgroundColor = '#EC4899';
    rightArea.style.display = 'flex';
    rightArea.style.alignItems = 'center';
    rightArea.style.justifyContent = 'center';
    rightArea.style.color = 'white';
    rightArea.style.borderRadius = '4px';
    grid.appendChild(rightArea);

    const footerArea = document.createElement('div');
    footerArea.textContent = 'Footer';
    footerArea.style.gridArea = 'footer';
    footerArea.style.backgroundColor = '#10B981';
    footerArea.style.display = 'flex';
    footerArea.style.alignItems = 'center';
    footerArea.style.justifyContent = 'center';
    footerArea.style.color = 'white';
    footerArea.style.borderRadius = '4px';
    grid.appendChild(footerArea);

    // Additional item using line placement
    const lineItem = document.createElement('div');
    lineItem.textContent = 'Line Placed';
    lineItem.style.gridColumn = 'start / middle';
    lineItem.style.gridRow = 'top';
    lineItem.style.backgroundColor = '#F59E0B';
    lineItem.style.display = 'flex';
    lineItem.style.alignItems = 'center';
    lineItem.style.justifyContent = 'center';
    lineItem.style.color = 'white';
    lineItem.style.borderRadius = '4px';
    lineItem.style.fontSize = '11px';
    lineItem.style.zIndex = '1';
    grid.appendChild(lineItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(grid.children.length).toBe(4);

    grid.remove();
  });

  it('updates areas dynamically', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '240px';
    grid.style.gridTemplateColumns = 'repeat(2, 1fr)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridTemplateAreas = `
      "a b"
      "c d"
    `;
    grid.style.gap = '8px';
    grid.style.backgroundColor = '#eceff1';
    grid.style.padding = '8px';

    const items = ['a', 'b', 'c', 'd'];
    const colors = ['#EF5350', '#AB47BC', '#42A5F5', '#66BB6A'];

    items.forEach((area, i) => {
      const item = document.createElement('div');
      item.textContent = area.toUpperCase();
      item.style.gridArea = area;
      item.style.backgroundColor = colors[i];
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.borderRadius = '4px';
      grid.appendChild(item);
    });

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Change template areas
    grid.style.gridTemplateAreas = `
      "a a"
      "c d"
    `;

    await waitForFrame();
    await snapshot();

    const aItem = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'A') as HTMLElement;
    const bItem = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'B') as HTMLElement;

    // Item 'a' should now span both columns in first row
    expect(aItem.getBoundingClientRect().width).toBeGreaterThan(bItem.getBoundingClientRect().width);

    grid.remove();
  });

  it('handles invalid area names gracefully', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '240px';
    grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridTemplateAreas = `
      "valid valid valid"
      "left center right"
    `;
    grid.style.gap = '8px';
    grid.style.backgroundColor = '#fafafa';
    grid.style.padding = '8px';

    // Valid area
    const validItem = document.createElement('div');
    validItem.textContent = 'Valid';
    validItem.style.gridArea = 'valid';
    validItem.style.backgroundColor = '#4CAF50';
    validItem.style.display = 'flex';
    validItem.style.alignItems = 'center';
    validItem.style.justifyContent = 'center';
    validItem.style.color = 'white';
    validItem.style.borderRadius = '4px';
    grid.appendChild(validItem);

    // Invalid area - should fall back to auto-placement
    const invalidItem = document.createElement('div');
    invalidItem.textContent = 'Invalid';
    invalidItem.style.gridArea = 'nonexistent';
    invalidItem.style.backgroundColor = '#FF5722';
    invalidItem.style.display = 'flex';
    invalidItem.style.alignItems = 'center';
    invalidItem.style.justifyContent = 'center';
    invalidItem.style.color = 'white';
    invalidItem.style.borderRadius = '4px';
    grid.appendChild(invalidItem);

    // Valid area
    const leftItem = document.createElement('div');
    leftItem.textContent = 'Left';
    leftItem.style.gridArea = 'left';
    leftItem.style.backgroundColor = '#2196F3';
    leftItem.style.display = 'flex';
    leftItem.style.alignItems = 'center';
    leftItem.style.justifyContent = 'center';
    leftItem.style.color = 'white';
    leftItem.style.borderRadius = '4px';
    grid.appendChild(leftItem);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const invalidRect = invalidItem.getBoundingClientRect();
    const validRect = validItem.getBoundingClientRect();
    const leftRect = leftItem.getBoundingClientRect();
    expect(invalidRect.left).toBeGreaterThan(validRect.right + 1);
    expect(invalidRect.top).toBeGreaterThan(leftRect.bottom + 1);

    // All items should be visible
    expect(grid.children.length).toBe(3);
    Array.from(grid.children).forEach(child => {
      const rect = (child as HTMLElement).getBoundingClientRect();
      expect(rect.width).toBeGreaterThan(0);
      expect(rect.height).toBeGreaterThan(0);
    });

    grid.remove();
  });

  it('handles nested area definitions', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '320px';
    grid.style.gridTemplateColumns = 'repeat(4, 1fr)';
    grid.style.gridTemplateRows = 'repeat(4, 50px)';
    grid.style.gridTemplateAreas = `
      "header header header header"
      "nav main main sidebar"
      "nav content content sidebar"
      "footer footer footer footer"
    `;
    grid.style.gap = '6px';
    grid.style.backgroundColor = '#f8fafc';
    grid.style.padding = '6px';

    const areas = [
      { name: 'header', text: 'H', color: '#0EA5E9' },
      { name: 'nav', text: 'N', color: '#8B5CF6' },
      { name: 'main', text: 'M', color: '#10B981' },
      { name: 'content', text: 'C', color: '#F59E0B' },
      { name: 'sidebar', text: 'S', color: '#EF4444' },
      { name: 'footer', text: 'F', color: '#6366F1' }
    ];

    areas.forEach(area => {
      const item = document.createElement('div');
      item.textContent = area.text;
      item.style.gridArea = area.name;
      item.style.backgroundColor = area.color;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.borderRadius = '4px';
      item.style.fontSize = '14px';
      item.style.fontWeight = 'bold';
      grid.appendChild(item);
    });

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const header = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'H') as HTMLElement;
    const nav = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'N') as HTMLElement;
    const main = Array.from(grid.children).find(el => (el as HTMLElement).textContent === 'M') as HTMLElement;

    // Verify header spans all columns
    expect(header.getBoundingClientRect().width).toBeGreaterThan(main.getBoundingClientRect().width);
    // Verify nav spans 2 rows
    expect(nav.getBoundingClientRect().height).toBeGreaterThan(main.getBoundingClientRect().height);

    grid.remove();
  });
});
