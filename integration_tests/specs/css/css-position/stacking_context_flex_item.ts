describe('Stacking Context - Flex item z-index', () => {
  it('non-positioned flex item with z-index:1 paints above earlier normal-flow sibling', async () => {
    const wrapper = document.createElement('div');
    wrapper.style.position = 'relative';
    wrapper.style.width = '200px';
    wrapper.style.height = '200px';

    // Flex item first in DOM, but should still overlay due to positive z-index
    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.width = '200px';
    flex.style.height = '200px';

    const item = document.createElement('div');
    item.style.zIndex = '1';
    item.style.background = 'blue';
    item.style.width = '200px';
    item.style.height = '200px';
    flex.appendChild(item);

    const normal = document.createElement('div');
    normal.style.width = '200px';
    normal.style.height = '200px';
    normal.style.background = 'red';

    wrapper.appendChild(flex);
    wrapper.appendChild(normal);
    document.body.appendChild(wrapper);

    // Expect blue on top (flex item z-index applies even when not positioned)
    await snapshot();
  });

  it('flex item with z-index:0 should paint in the auto/0 positioned layer', async () => {
    const wrapper = document.createElement('div');
    wrapper.style.position = 'relative';
    wrapper.style.width = '200px';
    wrapper.style.height = '200px';

    const base = document.createElement('div');
    base.style.position = 'absolute';
    base.style.left = '0';
    base.style.top = '0';
    base.style.width = '200px';
    base.style.height = '200px';
    base.style.background = 'red';

    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.width = '200px';
    flex.style.height = '200px';

    const item = document.createElement('div');
    item.style.zIndex = '0';
    item.style.background = 'blue';
    item.style.width = '200px';
    item.style.height = '200px';
    flex.appendChild(item);

    wrapper.appendChild(base);
    wrapper.appendChild(flex);
    document.body.appendChild(wrapper);

    // Positioned auto/0 (and z-index:0 contexts) paint after normal flow but before positives.
    // With no positives, blue should overlay red.
    await snapshot();
  });
});

