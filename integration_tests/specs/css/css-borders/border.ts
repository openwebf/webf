/*auto generated*/
describe('border', () => {
  it('001', async () => {
    let div;
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        border: '25px',
        'border-style': 'solid',
        'border-color': '#000',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
  it('003', async () => {
    let div;
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        'border-color': 'blue',
        'border-style': 'solid',
        'border-width': '5px',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
  fit('005', async () => {
    let reference;
    let test;
    let wrapper;
    wrapper = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'wrapper',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (reference = createElement('div', {
          id: 'reference',
          style: {
            position: 'absolute',
            background: 'red',
            height: '200px',
            left: '0',
            top: '0',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (test = createElement('div', {
          id: 'test',
          style: {
            position: 'relative',
            border: '100px solid blue',
            height: '0',
            width: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(wrapper);

    await snapshot();
  });
  it('006', async () => {
    let reference;
    let test;
    let wrapper;
    wrapper = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'wrapper',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (reference = createElement('div', {
          id: 'reference',
          style: {
            position: 'absolute',
            background: 'red',
            height: '200px',
            left: '0',
            top: '0',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (test = createElement('div', {
          id: 'test',
          style: {
            position: 'relative',
            border: '100px solid #000',
            height: '0',
            width: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(wrapper);

    await snapshot();
  });
  it('008', async () => {
    let reference;
    let test;
    let wrapper;
    wrapper = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        id: 'wrapper',
        style: {
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (reference = createElement('div', {
          id: 'reference',
          style: {
            position: 'absolute',
            background: 'red',
            height: '200px',
            left: '0',
            top: '0',
            width: '200px',
            'box-sizing': 'border-box',
          },
        })),
        (test = createElement('div', {
          id: 'test',
          style: {
            position: 'relative',
            border: '100px solid blue',
            height: '0',
            width: '0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(wrapper);

    await snapshot();
  });
  it('010', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there is a box below with a dashed blue border.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        border: '5px solid blue',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });

  it('border will not appear if border width is 0.0', async () => {
    let p;
    let div;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are no solid border.`
        ),
      ]
    );
    div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderWidth: 0,
        borderStyle: 'solid',
        borderColor: '#000',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(div);

    await snapshot();
  });

  it('borderSide should handle hitTest', async () => {
    let clickCount = 0;
    let container = createElement('div', {
      style: {
        width: '20px',
        height: '20px',
        border: '5px solid #000'
      }
    }, [
    ]);

    BODY.appendChild(container);
    container.onclick = () => clickCount++;
    await simulateClick(1.0, 1.0);
    expect(clickCount).toBe(1);
  });

  it('marginSide should not handle hitTest', async () => {
    let clickCount = 0;
    let container = createElement('div', {
      style: {
        width: '20px',
        height: '20px',
        margin: '10px',
        border: '2px solid #000'
      }
    });

    BODY.appendChild(container);
    container.onclick = () => clickCount++;

    await simulateClick(1.0, 1.0);
    await simulateClick(11.0, 11.0);
    expect(clickCount).toBe(1);
  });

  it('should work with border-width change', async (done) => {
    let div;
    let foo;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'red',
          position: 'relative',
          border: '2px solid black'
        },
      },
      [
        createElement('div', {
          style: {
            height: '100px',
            width: '100px',
            backgroundColor: 'yellow',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await snapshot();

    requestAnimationFrame(async () => {
       div.style.borderWidth = '10px';
      await snapshot();
      done();
    });
  });

  it('border-style-computed', async () => {
    let target
    target = createElement('div', {
      id: 'target',
      style: {
        'box-sizing': 'border-box',
      },
    })
    BODY.appendChild(target)

    test_computed_value('border-style', 'none')
    // test_computed_value('border-style', 'inset outset')
    // test_computed_value('border-style', 'hidden dotted dashed')
    // test_computed_value('border-style', 'solid double groove ridge')

    test_computed_value('border-top-style', 'solid')
    // test_computed_value('border-right-style', 'double')
    // test_computed_value('border-bottom-style', 'groove')
    // test_computed_value('border-left-style', 'ridge')
  })

  it('border-width-computed', async () => {
    let box
    let target
    box = createElement('div', {
      id: 'box',
      style: {
        'border-style': 'solid',
        'border-top-width': 'thin',
        'border-right-width': 'medium',
        'border-bottom-width': 'thick',
        'box-sizing': 'border-box',
      },
    })
    target = createElement('div', {
      id: 'target',
      style: {
        'border-style': 'solid',
        'font-size': '40px',
        'box-sizing': 'border-box',
      },
    })
    BODY.appendChild(box)
    BODY.appendChild(target)

    const computedStyle = getComputedStyle(box);
    const thinWidth = computedStyle['border-top-width'];
    const mediumWidth = computedStyle['border-right-width'];
    const thickWidth = computedStyle['border-bottom-width'];

    test_computed_value('border-width', '1px')
    // test_computed_value('border-width', '1px 2px')
    // test_computed_value('border-width', '1px 2px 3px')
    // test_computed_value('border-width', '1px 2px 3px 4px')

    // test_computed_value('border-width', '0.5em', '20px')
    // test_computed_value(
    //   'border-width',
    //   '2px thin medium thick',
    //   '2px ' + thinWidth + ' ' + mediumWidth + ' ' + thickWidth,
    // )

    // test_computed_value('border-top-width', '0px')
    // test_computed_value('border-right-width', '10px')
    // test_computed_value('border-bottom-width', 'calc(-0.5em + 20px)', '0px')
    // test_computed_value('border-left-width', 'calc(0.5em + 10px)', '30px')

    // const thin = Number(thinWidth.replace('px', ''))
    // const medium = Number(mediumWidth.replace('px', ''))
    // const thick = Number(thickWidth.replace('px', ''))
      
    // console.log(thin, medium, thick);
    // expect(0).toBeLessThanOrEqual(thin);
    // expect(thin).toBeLessThanOrEqual(medium);
    // expect(medium).toBeLessThanOrEqual(thick);
  })
});
