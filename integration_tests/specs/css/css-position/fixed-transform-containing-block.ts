describe('Position fixed containing block (transform)', () => {
  it('anchors fixed descendants to transformed ancestor instead of viewport', async () => {
    document.documentElement.style.margin = '0';
    document.documentElement.style.padding = '0';
    document.documentElement.style.width = '100%';
    document.documentElement.style.height = '100%';
    document.body.style.margin = '0';
    document.body.style.padding = '0';
    document.body.style.width = '100%';
    document.body.style.height = '100%';

    // Push the containing block below the viewport bottom so we can distinguish:
    // - viewport-fixed: bottom == viewportHeight
    // - transform-fixed (per spec): bottom == containing block bottom (> viewportHeight)
    const spacer = createElement('div', {
      style: {
        height: '100px',
        backgroundColor: '#fff',
      },
    });

    const fixed = createElement('div', {
      style: {
        position: 'fixed',
        bottom: '0',
        left: '0',
        width: '100%',
        height: '50px',
        backgroundColor: 'blue',
      },
    });

    const container = createElement(
      'div',
      {
        style: {
          width: '100%',
          height: '90%',
          backgroundColor: 'red',
          position: 'relative',
          transform: 'scale(1)',
        },
      },
      [fixed],
    );

    BODY.appendChild(spacer);
    BODY.appendChild(container);

    await waitForFrame();
    await waitForFrame();

    const containerRect = (container as HTMLElement).getBoundingClientRect();
    const fixedRect = (fixed as HTMLElement).getBoundingClientRect();
    const viewportHeight = window.innerHeight || document.documentElement.clientHeight;

    expect(containerRect.bottom).toBeGreaterThan(viewportHeight + 1);
    expect(fixedRect.bottom).toBeGreaterThan(viewportHeight + 1);
    expect(Math.abs(fixedRect.bottom - containerRect.bottom)).toBeLessThanOrEqual(1);
    expect(Math.abs(fixedRect.top - (containerRect.bottom - 50))).toBeLessThanOrEqual(1);
    await snapshot();
  });
});

