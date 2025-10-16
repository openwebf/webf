describe('background-image multiple linear-gradients (issue #272)', () => {
  it('paints top and bottom gradient masks with layered background-image', async () => {
    const container = createElement('div', {
      className: 'container',
      style: {
        margin: '16px 0 16px',
        textAlign: 'center',
        position: 'relative',
        width: '260px',
        backgroundColor: '#fafafa',
        border: '1px solid #ddd'
      }
    }, []);

    // Populate some content to make the container tall
    for (let i = 0; i < 10; i++) {
      const row = createElement('div', { }, [createText(String(i + 1))]);
      row.style.padding = '4px';
      row.style.color = '#323233';
      container.appendChild(row);
    }

    // Overlay mask using two linear-gradient layers
    const mask = createElement('div', {
      className: 'mask',
      style: {
        position: 'absolute',
        top: '0',
        left: '0',
        zIndex: 10 as any,
        width: '100%',
        height: '100%',
        backgroundImage:
          'linear-gradient(180deg, rgba(255, 255, 255, .9), rgba(255, 255, 255, .4)), ' +
          'linear-gradient(0deg, rgba(255, 255, 255, .9), rgba(255, 255, 255, .4))',
        backgroundRepeat: 'no-repeat',
        backgroundPosition: 'top, bottom',
        backgroundSize: '100% 110px',
        transform: 'translateZ(0)'
      }
    });

    container.appendChild(mask);
    append(BODY, container);

    await snapshot(container);
  });
});

