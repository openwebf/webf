describe('repeating-linear-gradient stripes (px stops)', () => {
  it('90deg, 8px dark + 8px light stripes', async () => {
    const div = createElement('div', {
      style: {
        width: '180px',
        height: '80px',
        border: '1px solid #ccc',
        backgroundImage: 'repeating-linear-gradient(90deg, #111827 0 8px, #e5e7eb 8px 16px)'
      },
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('0deg, 8px dark + 8px light stripes', async () => {
    const div = createElement('div', {
      style: {
        width: '180px',
        height: '80px',
        border: '1px solid #ccc',
        backgroundImage: 'repeating-linear-gradient(0deg, #111827 0 8px, #e5e7eb 8px 16px)'
      },
    });
    append(BODY, div);
    await snapshot(div);
  });
});

