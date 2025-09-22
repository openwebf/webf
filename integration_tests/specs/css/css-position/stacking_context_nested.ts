describe('Stacking Context - Nested', () => {
  it('child negative z-index remains above outside z-index 0 when parent z-index is positive', async () => {
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
    base.style.zIndex = '0';
    base.style.background = 'blue';

    const parent = document.createElement('div');
    parent.style.position = 'absolute';
    parent.style.left = '0';
    parent.style.top = '0';
    parent.style.width = '200px';
    parent.style.height = '200px';
    parent.style.zIndex = '1';

    const child = document.createElement('div');
    child.style.position = 'absolute';
    child.style.left = '0';
    child.style.top = '0';
    child.style.width = '200px';
    child.style.height = '200px';
    child.style.zIndex = '-1';
    child.style.background = 'red';
    parent.appendChild(child);

    wrapper.appendChild(base);
    wrapper.appendChild(parent);
    document.body.appendChild(wrapper);

    // Despite child having -1, its parent z-index:1 stacking context paints above base.
    // Expect red on top.
    await snapshot();
  });
});

