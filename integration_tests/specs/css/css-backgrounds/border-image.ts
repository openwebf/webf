describe('border-image (CSS Backgrounds & Borders)', () => {
  // Engine support may be incomplete; keep initial tests skipped.

  xit('basic border-image with slice and repeat', async () => {
    const div = createElement('div', {
      style: {
        width: '160px',
        height: '100px',
        borderWidth: '20px',
        borderStyle: 'solid',
        borderImageSource: 'url(assets/100x100-green.png)',
        borderImageSlice: '30',
        borderImageRepeat: 'round',
        borderImageWidth: '20',
        backgroundColor: '#fafafa'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  xit('border-image with gradients', async () => {
    const div = createElement('div', {
      style: {
        width: '160px',
        height: '100px',
        borderWidth: '16px',
        borderStyle: 'solid',
        borderImage: 'linear-gradient(45deg, red, blue) 30 / 16px / 0 round',
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});

