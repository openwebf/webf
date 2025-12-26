describe('IMG GIF', () => {
  it('loads and renders a local gif', async () => {
    const img = document.createElement('img');
    img.src = 'assets/ruler-640-20.gif';
    img.style.width = '320px';
    img.style.height = '10px';
    img.style.border = '1px solid #ccc';

    await new Promise<void>((resolve, reject) => {
      img.onload = () => resolve();
      img.onerror = () => reject(new Error('GIF load error'));
      document.body.appendChild(img);
    });

    expect(img.naturalWidth).toBeGreaterThan(0);
    expect(img.naturalHeight).toBeGreaterThan(0);

    await snapshot();
  });
});

