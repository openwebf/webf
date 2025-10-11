describe('Stacking Context - Opacity and Transform', () => {
  it('child cannot escape opacity stacking context against outside positive z-index', async () => {
    const wrapper = document.createElement('div');
    wrapper.style.position = 'relative';
    wrapper.style.width = '200px';
    wrapper.style.height = '200px';

    const ctx = document.createElement('div');
    ctx.style.opacity = '0.9';
    ctx.style.width = '200px';
    ctx.style.height = '200px';
    ctx.style.position = 'relative';

    const inner = document.createElement('div');
    inner.style.position = 'absolute';
    inner.style.left = '0';
    inner.style.top = '0';
    inner.style.width = '200px';
    inner.style.height = '200px';
    inner.style.zIndex = '999';
    inner.style.background = 'green';
    ctx.appendChild(inner);

    const outside = document.createElement('div');
    outside.style.position = 'absolute';
    outside.style.left = '0';
    outside.style.top = '0';
    outside.style.width = '200px';
    outside.style.height = '200px';
    outside.style.zIndex = '1';
    outside.style.background = 'blue';

    wrapper.appendChild(ctx);
    wrapper.appendChild(outside);
    document.body.appendChild(wrapper);

    // Expect the blue to be on top (outside positive z-index wins over inner of opacity ctx)
    await snapshot();
  });

  it('transform establishes stacking context similar to opacity', async () => {
    const wrapper = document.createElement('div');
    wrapper.style.position = 'relative';
    wrapper.style.width = '200px';
    wrapper.style.height = '200px';

    const ctx = document.createElement('div');
    ctx.style.transform = 'translate(0px, 0px)';
    ctx.style.width = '200px';
    ctx.style.height = '200px';
    ctx.style.position = 'relative';

    const inner = document.createElement('div');
    inner.style.position = 'absolute';
    inner.style.left = '0';
    inner.style.top = '0';
    inner.style.width = '200px';
    inner.style.height = '200px';
    inner.style.zIndex = '999';
    inner.style.background = 'green';
    ctx.appendChild(inner);

    const outside = document.createElement('div');
    outside.style.position = 'absolute';
    outside.style.left = '0';
    outside.style.top = '0';
    outside.style.width = '200px';
    outside.style.height = '200px';
    outside.style.zIndex = '1';
    outside.style.background = 'blue';

    wrapper.appendChild(ctx);
    wrapper.appendChild(outside);
    document.body.appendChild(wrapper);

    await snapshot();
  });
});

