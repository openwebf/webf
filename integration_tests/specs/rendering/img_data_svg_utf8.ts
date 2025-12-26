describe('IMG data: SVG', () => {
  it('renders data:image/svg+xml;utf8 with percent-encoded payload', async () => {
    const src =
      "data:image/svg+xml;utf8,%0A%20%20%20%20%3Csvg%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20width%3D'300'%20height%3D'100'%20viewBox%3D'0%200%20300%20100'%3E%0A%20%20%20%20%20%20%3Crect%20x%3D'10'%20y%3D'10'%20width%3D'80'%20height%3D'80'%20fill%3D'%233b82f6'%20rx%3D'8'%2F%3E%0A%20%20%20%20%20%20%3Ccircle%20cx%3D'150'%20cy%3D'50'%20r%3D'40'%20fill%3D'%2310b981'%2F%3E%0A%20%20%20%20%20%20%3Cpolygon%20points%3D'240%2C10%20280%2C90%20200%2C90'%20fill%3D'%23f59e0b'%2F%3E%0A%20%20%20%20%3C%2Fsvg%3E%0A%20%20";

    const img = document.createElement('img');
    img.style.width = '300px';
    img.style.height = '100px';
    img.src = src;

    await new Promise<void>((resolve, reject) => {
      img.onload = () => resolve();
      img.onerror = () => reject(new Error('SVG data URL load error'));
      document.body.appendChild(img);
    });

    expect(img.naturalWidth).toBe(300);
    expect(img.naturalHeight).toBe(100);

    await snapshot();
  });
});

