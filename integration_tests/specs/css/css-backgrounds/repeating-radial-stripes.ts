describe('repeating-radial-gradient stripes (px stops)', () => {
  it('circle at center, 6px red + 6px light rings', async () => {
    const div = createElement('div', {
      style: {
        width: '180px',
        height: '80px',
        border: '1px solid #ccc',
        backgroundImage: 'repeating-radial-gradient(circle at center, #e11d48 0 6px, #fee2e2 6px 12px)'
      },
    });
    append(BODY, div);
    await snapshot(div);
  });
});

