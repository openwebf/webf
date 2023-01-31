describe('background-331', () => {
  const divStyle = {
    background: 'red',
  };

  it('background initial value for background', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background')).toBe('rgb(255, 0, 0) none repeat scroll 0% 0% / auto padding-box border-box');
  });

  it('background initial value for background-image', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-image')).toBe('none');
  });

  it('background initial value for background-position', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-position')).toBe('0% 0%');
  });

  xit('background initial value for background-size', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-size')).toBe('auto');
  });

  it('background initial value for background-repeat', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-repeat')).toBe('repeat');
  });

  xit('background initial value for background-attachment', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-attachment')).toBe('scroll');
  });

  xit('background initial value for background-origin', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-origin')).toBe('padding-box');
  });

  xit('background initial value for background-clip', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-clip')).toBe('border-box');
  });

  it('background initial value for background-color', async () => {
    let div = createElementWithStyle('div', divStyle);
    append(BODY, div);
    let cs = window.getComputedStyle(div, null);
    expect(cs.getPropertyValue('background-color')).toBe('rgb(255, 0, 0)');
  });

  it('background url should distinguish word capitalize', async (done) => {
    let div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundImage = 'URL(https://gw.alicdn.com/tfs/TB1E5GzToz1gK0jSZLeXXb9kVXa-750-595.png)';
    document.body.appendChild(div);
    await snapshot(1);
    done();
  });

  it("computed", async () => {
    let target;
    target = createElement('div', {
      id: 'target',
      style: {
        'background-image': 'none',
        'font-size': '40px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(target);

    test_computed_value('background-attachment', 'local', 'local');
    test_computed_value('background-attachment', 'scroll', 'scroll');
    test_computed_value('background-attachment', 'fixed', 'fixed');

    test_computed_value(
      'background-clip',
      'border-box'
    );
    test_computed_value(
      'background-clip',
      'content-box'
    );
    test_computed_value(
      'background-clip',
      'padding-box'
    );
    
    // background-color always computes as a single color.
    test_computed_value('background-color', 'rgb(255, 0, 0)');

    test_computed_value(
      'background-origin',
      'border-box'
    );
    test_computed_value(
      'background-origin',
      'content-box'
    );
    test_computed_value(
      'background-origin',
      'padding-box'
    );

    test_computed_value(
      'background-position',
      '50% 6px'
    );
    test_computed_value(
      'background-position',
      '12px 13px'
    );
    test_computed_value('background-position', '12px 13px');
    test_computed_value(
      'background-position',
      '30px -10px'
    );

    test_computed_value('background-position-x', '0.5em', '20px');
    test_computed_value('background-position-x', '-20%', '-20%');

    test_computed_value('background-position-x', 'center', '50%');
    test_computed_value('background-position-x', 'left', '0%');
    test_computed_value('background-position-x', 'right', '100%');
    test_computed_value('background-position-x', 'calc(10px - 0.5em)', '-10px');

    test_computed_value('background-position-y', '0.5em', '20px');
    test_computed_value('background-position-y', '-20%', '-20%');
    test_computed_value('background-position-y', 'center', '50%');
    test_computed_value('background-position-y', 'top', '0%');
    test_computed_value('background-position-y', 'bottom', '100%');
    test_computed_value('background-position-y', 'calc(10px - 0.5em)', '-10px');

    test_computed_value('background-repeat', 'repeat-x');
    test_computed_value('background-repeat', 'repeat');
    test_computed_value('background-repeat', 'repeat-y');
    test_computed_value('background-repeat', 'no-repeat');
    
    test_computed_value('background-size', 'contain');
    test_computed_value('background-size', 'auto 1px');
    test_computed_value('background-size', '2% 3%');
  })
});
