describe('transform translateX/translateY percentage chain (issue #266)', () => {
  it('accepts translateX(-50%) translateY(-50%)', async () => {
    const container = document.createElement('div');
    container.style.width = '200px';
    container.style.height = '200px';
    container.style.position = 'relative';
    container.style.background = '#eee';

    const box = document.createElement('div');
    box.style.width = '60px';
    box.style.height = '60px';
    box.style.background = 'orange';
    box.style.position = 'absolute';
    box.style.left = '50%';
    box.style.top = '50%';
    box.style.transform = 'translateX(-50%) translateY(-50%)';

    container.appendChild(box);
    document.body.appendChild(container);

    await snapshot(container);
  });

  it('accepts translate3d(-25%, 0, 0)', async () => {
    const container = document.createElement('div');
    container.style.width = '200px';
    container.style.height = '100px';
    container.style.position = 'relative';
    container.style.background = '#f5f5f5';

    const box = document.createElement('div');
    box.style.width = '80px';
    box.style.height = '80px';
    box.style.background = 'teal';
    box.style.transform = 'translate3d(-25%, 0, 0)';

    container.appendChild(box);
    document.body.appendChild(container);

    await snapshot(container);
  });
});

