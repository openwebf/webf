describe('Box border', () => {
  it('should work with basic samples', async () => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      border: '2px solid #f40',
    });

    document.body.appendChild(div);
    div.style.border = '4px solid blue';
    await snapshot();
  });

  it('test pass if there is a hollow black square', async () => {
    let div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      border: '25px',
      borderStyle: 'solid',
      borderColor: 'black',
    });
    append(BODY, div);
    await snapshot(div);
  });

  // @TODO: Support border-style: dashed.
  xit('dashed border', async () => {
    const div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      border: '2px dashed red',
    });
    append(BODY, div);
    await snapshot(div);
  });

  // @TODO: Support border-style: dashed.
  xit('dashed with backgroundColor', async () => {
    const div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      border: '10px dashed red',
      backgroundColor: 'green',
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('border-bottom-left-radius', async () => {
    let div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      'border-bottom-left-radius': '100px',
      backgroundColor: 'red',
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('border-bottom-right-radius', async () => {
    let div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      'border-bottom-right-radius': '100px',
      backgroundColor: 'red',
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('border-top-left-radius', async () => {
    let div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      'border-top-left-radius': '100px',
      backgroundColor: 'red',
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('border-top-right-radius', async () => {
    let div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      'border-top-right-radius': '100px',
      backgroundColor: 'red',
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('border radius with absolute', async () => {
    let red = createElementWithStyle('div', {
      position: 'absolute',
      width: '100px',
      height: '100px',
      top: '50px',
      left: '50px',
      backgroundColor: 'red',
    });
    let green = createElementWithStyle('div', {
      position: 'absolute',
      top: '50px',
      left: '50px',
      width: '100px',
      height: '100px',
      borderRadius: '50px',
      backgroundColor: 'green',
    });
    let container = createElementWithStyle('div', {
      width: '200px',
      height: '200px',
      position: 'absolute',
    });
    append(container, red);
    append(container, green);
    append(BODY, container);
    await snapshot();
  });

  xit('border-style-computed', async () => {
    let target
    target = createElement('div', {
      id: 'target',
      style: {
        'box-sizing': 'border-box',
      },
    })
    BODY.appendChild(target)

    test_computed_value('border-style', 'none')
    test_computed_value('border-style', 'inset outset')
    test_computed_value('border-style', 'hidden dotted dashed')
    test_computed_value('border-style', 'solid double groove ridge')

    test_computed_value('border-top-style', 'solid')
    test_computed_value('border-right-style', 'double')
    test_computed_value('border-bottom-style', 'groove')
    test_computed_value('border-left-style', 'ridge')
  })

  it('border-width-computed', async () => {
    let box
    let target
    box = createElement('div', {
      id: 'box',
      style: {
        'border-style': 'dotted',
        'border-top-width': 'thin',
        'border-right-width': 'medium',
        'border-bottom-width': 'thick',
        'box-sizing': 'border-box',
      },
    })
    target = createElement('div', {
      id: 'target',
      style: {
        'border-style': 'dotted',
        'font-size': '40px',
        'box-sizing': 'border-box',
      },
    })
    BODY.appendChild(box)
    BODY.appendChild(target)

    const thinWidth = getComputedStyle(box).borderTopWidth
    const mediumWidth = getComputedStyle(box).borderRightWidth
    const thickWidth = getComputedStyle(box).borderBottomWidth

    test_computed_value('border-width', '1px')
    test_computed_value('border-width', '1px 2px')
    test_computed_value('border-width', '1px 2px 3px')
    test_computed_value('border-width', '1px 2px 3px 4px')

    test_computed_value('border-width', '0.5em', '20px')
    test_computed_value(
      'border-width',
      '2px thin medium thick',
      '2px ' + thinWidth + ' ' + mediumWidth + ' ' + thickWidth,
    )

    test_computed_value('border-top-width', '0px')
    test_computed_value('border-right-width', '10px')
    test_computed_value('border-bottom-width', 'calc(-0.5em + 10px)', '0px')
    test_computed_value('border-left-width', 'calc(0.5em + 10px)', '30px')

    test(() => {
      const thin = Number(thinWidth.replace('px', ''))
      const medium = Number(mediumWidth.replace('px', ''))
      const thick = Number(thickWidth.replace('px', ''))
      assert_less_than_equal(0, thin)
      assert_less_than_equal(thin, medium)
      assert_less_than_equal(medium, thick)
    }, 'thin ≤ medium ≤ thick')
  })

  xit('border-shadow-computed', async () => {
    let target
    target = createElement('div', {
      id: 'target',
      style: {
        color: 'blue',
        'font-size': '20px',
        'box-sizing': 'border-box',
      },
    })
    BODY.appendChild(target)

    ;('use strict')
    const currentColor = 'rgb(0, 0, 255)'
    test_computed_value('box-shadow', 'none')
    test_computed_value(
      'box-shadow',
      '1px 2px',
      currentColor + ' 1px 2px 0px 0px',
    )
    test_computed_value(
      'box-shadow',
      'currentcolor -1em -2em 3em -4em',
      currentColor + ' -20px -40px 60px -80px',
    )
    test_computed_value('box-shadow', 'rgb(0, 255, 0) 1px 2px 3px 4px inset')
  })

  xit('border-radius-computed', async () => {
    let target
    target = createElement('div', {
      id: 'target',
      style: {
        'font-size': '40px',
        'box-sizing': 'border-box',
      },
    })
    BODY.appendChild(target)

    test_computed_value('border-radius', '1px')
    test_computed_value('border-radius', '1px 2% 3px 4%')
    test_computed_value(
      'border-radius',
      '5em / 1px 2% 3px 4%',
      '200px / 1px 2% 3px 4%',
    )
    test_computed_value(
      'border-radius',
      '1px 2% 3px 4% / 5em',
      '1px 2% 3px 4% / 200px',
    )

    test_computed_value(
      'border-radius',
      '1px 1px 1px 2% / 1px 2% 1px 2%',
      '1px 1px 1px 2% / 1px 2%',
    )
    test_computed_value(
      'border-radius',
      '1px 1px 1px 1px / 1px 1px 2% 1px',
      '1px / 1px 1px 2%',
    )
    test_computed_value('border-radius', '1px 1px 2% 2%')
    test_computed_value('border-radius', '1px 2% 1px 1px')
    test_computed_value(
      'border-radius',
      '1px 2% 2% 2% / 1px 2% 3px 2%',
      '1px 2% 2% / 1px 2% 3px',
    )

    test_computed_value('border-top-left-radius', 'calc(-0.5em + 10px)', '0px')
    test_computed_value('border-top-right-radius', '20%')
    test_computed_value(
      'border-bottom-right-radius',
      'calc(0.5em + 10px) 40%',
      '30px 40%',
    )
    test_computed_value('border-bottom-left-radius', '50% 60px')

    test_computed_value('border-top-left-radius', '40px 0px', '40px 0px')
  })

});
