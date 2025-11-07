describe('conic-gradient position and from', () => {
  it('from 90deg at right center', async () => {
    const div = createElement('div', {
      style: {
        width: '180px',
        height: '80px',
        border: '1px solid #ccc',
        backgroundImage:
          'conic-gradient(from 90deg at right center, #fde047, #f97316, #ef4444, #a855f7, #3b82f6, #22c55e, #fde047)'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});

