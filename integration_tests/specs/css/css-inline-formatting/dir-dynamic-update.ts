describe('RTL dir dynamic update', () => {
  afterEach(() => {
    document.documentElement.removeAttribute('dir');
    BODY.innerHTML = '';
  });

  it('should remap marginInlineStart when documentElement.dir changes', async () => {
    const container = createElement('div', {
      style: {
        width: '200px',
        border: '1px solid black',
        padding: '0px',
        backgroundColor: '#fff',
      },
    });

    const box = createElement('div', {
      style: {
        display: 'inline-block',
        width: '20px',
        height: '20px',
        backgroundColor: '#f00',
        marginInlineStart: '10px',
      },
    });

    container.appendChild(box);
    BODY.appendChild(container);
    await nextFrames(1);

    const borderLeft = Math.round(parseFloat(getComputedStyle(container).borderLeftWidth || "0"));
    const borderRight = Math.round(parseFloat(getComputedStyle(container).borderRightWidth || "0"));

    let c = container.getBoundingClientRect();
    let b = box.getBoundingClientRect();
    expect(Math.round(b.left - c.left)).toBe(10 + borderLeft);

    document.documentElement.dir = 'rtl';

    await nextFrames(1);

    expect(document.documentElement.dir).toBe('rtl');

    c = container.getBoundingClientRect();
    b = box.getBoundingClientRect();
    expect(Math.round(c.right - b.right)).toBe(10 + borderRight);

    await snapshot();
  });
});
