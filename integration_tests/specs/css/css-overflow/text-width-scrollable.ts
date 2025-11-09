describe('Scrollable text width with padding and centered text (issue #251)', () => {
  it('no horizontal overflow: scrollWidth equals clientWidth', async () => {
    const box = createElement('div', {
      style: {
        width: '300px',
        padding: '6px 24px 18px 24px',
        border: '1px solid red',
        textAlign: 'center',
        overflow: 'auto',
        backgroundColor: '#fff',
      }
    }, [
      createText('好雨知时节，当春乃发生。随风潜入夜，润物细无声。')
    ]);

    document.body.appendChild(box);

    // Force layout
    await waitForOnScreen(box);

    // Expected: text wraps within content width; no horizontal overflow
    expect(box.scrollWidth).toBe(box.clientWidth);

    await snapshot();
  });
});

