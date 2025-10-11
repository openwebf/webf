describe('Stacking Context', () => {
  it('later sibling without z-index paints above earlier absolute', async () => {
    const wrapper = document.createElement('div');
    wrapper.id = 'wrapper';
    wrapper.style.position = 'relative';
    wrapper.style.width = '200px';
    wrapper.style.height = '200px';

    const reference = document.createElement('div');
    reference.id = 'reference';
    reference.style.position = 'absolute';
    reference.style.background = 'red';
    reference.style.left = '0';
    reference.style.top = '0';
    reference.style.width = '200px';
    reference.style.height = '200px';

    const test = document.createElement('div');
    test.id = 'test';
    test.style.position = 'relative';
    test.style.width = '0';
    test.style.height = '0';
    test.style.border = '100px solid blue';

    wrapper.appendChild(reference);
    wrapper.appendChild(test);
    document.body.appendChild(wrapper);

    await snapshot();
  });

  it('negative z-index paints below normal flow', async () => {
    const wrapper = document.createElement('div');
    wrapper.style.position = 'relative';
    wrapper.style.width = '200px';
    wrapper.style.height = '200px';

    const neg = document.createElement('div');
    neg.style.position = 'absolute';
    neg.style.zIndex = '-1';
    neg.style.background = 'red';
    neg.style.left = '0';
    neg.style.top = '0';
    neg.style.width = '200px';
    neg.style.height = '200px';

    const normal = document.createElement('div');
    normal.style.width = '200px';
    normal.style.height = '200px';
    normal.style.background = 'rgba(0,0,255,1)';

    wrapper.appendChild(neg);
    wrapper.appendChild(normal);
    document.body.appendChild(wrapper);

    await snapshot();
  });

  it('positive z-index paints above later sibling', async () => {
    const wrapper = document.createElement('div');
    wrapper.style.position = 'relative';
    wrapper.style.width = '200px';
    wrapper.style.height = '200px';

    const top = document.createElement('div');
    top.style.position = 'absolute';
    top.style.zIndex = '1';
    top.style.background = 'green';
    top.style.left = '0';
    top.style.top = '0';
    top.style.width = '200px';
    top.style.height = '200px';

    const under = document.createElement('div');
    under.style.width = '200px';
    under.style.height = '200px';
    under.style.background = 'blue';

    wrapper.appendChild(top);
    wrapper.appendChild(under);
    document.body.appendChild(wrapper);

    await snapshot();
  });
});

