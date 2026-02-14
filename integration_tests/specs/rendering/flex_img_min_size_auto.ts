describe('Flex min-size:auto with replaced elements', () => {
  it('does not clamp a flex item to img naturalWidth when CSS width is set', async () => {
    document.body.style.margin = '0';
    document.body.style.padding = '0';

    const container = document.createElement('div');
    container.id = 'container';
    container.style.display = 'flex';
    container.style.width = '150px';
    container.style.background = '#f0f0f0';

    const name = document.createElement('span');
    name.id = 'name';
    name.style.flex = '1 1 0%';
    name.style.minWidth = '0';
    name.style.overflow = 'hidden';
    name.style.whiteSpace = 'nowrap';
    name.textContent = 'CryptoTrader123';

    const badge = document.createElement('span');
    badge.id = 'badge';
    badge.style.marginLeft = '4px';

    const img = document.createElement('img');
    img.id = 'img';
    img.style.width = '16px';
    img.style.height = '16px';
    img.style.display = 'block';
    img.src =
      "data:image/svg+xml;utf8,%3Csvg%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20width%3D'200'%20height%3D'200'%20viewBox%3D'0%200%20200%20200'%3E%3Crect%20x%3D'0'%20y%3D'0'%20width%3D'200'%20height%3D'200'%20fill%3D'%233b82f6'%2F%3E%3C%2Fsvg%3E";

    await new Promise<void>((resolve, reject) => {
      img.onload = () => resolve();
      img.onerror = () => reject(new Error('SVG data URL load error'));
      badge.appendChild(img);
      container.appendChild(name);
      container.appendChild(badge);
      document.body.appendChild(container);
    });

    expect(img.naturalWidth).toBe(200);
    expect(container.offsetWidth).toBe(150);
    expect(badge.offsetWidth).toBe(16);
    expect(name.offsetWidth).toBe(130);
    expect(name.offsetWidth).toBeGreaterThan(0);

    await snapshot();
  });
});

