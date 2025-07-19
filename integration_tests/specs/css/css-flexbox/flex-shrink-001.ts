describe('CSS Flexbox flex-shrink', () => {
  // Test 1: Basic flex-shrink functionality
  it('001-flex-shrink-basic', async () => {
    let container;
    let item1, item2, item3;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('shrink')])),
        (item2 = createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '0',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('no-shrink')])),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 2: Different flex-shrink values
  it('002-flex-shrink-values', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '250px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '2',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('shrink-2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('shrink-1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '3',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('shrink-3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 3: flex-shrink with column direction
  it('003-flex-shrink-column', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '200px',
          height: '150px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100%',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('shrink')]),
        createElement('div', {
          style: {
            width: '100%',
            height: '100px',
            'flex-shrink': '2',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('shrink-more')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 4: flex-shrink with flex-basis
  it('004-flex-shrink-with-basis', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '150px',
            'flex-shrink': '1',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('basis-150')]),
        createElement('div', {
          style: {
            'flex-basis': '100px',
            'flex-shrink': '1',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('basis-100')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 5: All items with flex-shrink 0
  it('005-flex-shrink-all-zero', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
          overflow: 'hidden',
        },
      },
      [
        createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '0',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('no-shrink-1')]),
        createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '0',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('no-shrink-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 6: flex-shrink with min-width
  it('006-flex-shrink-min-width', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '150px',
            'min-width': '80px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('min-80')]),
        createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('shrink')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 7: flex-shrink with different content sizes
  xit('007-flex-shrink-content-sizes', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-shrink': '1',
            height: '100px',
            'background-color': 'red',
            padding: '0 20px',
            'box-sizing': 'border-box',
          },
        }, [createText('Long content that needs space')]),
        createElement('div', {
          style: {
            'flex-shrink': '1',
            height: '100px',
            'background-color': 'blue',
            padding: '0 20px',
            'box-sizing': 'border-box',
          },
        }, [createText('Short')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 8: flex-shrink with flex-wrap
  it('008-flex-shrink-with-wrap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '200px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '150px',
            height: '80px',
            'flex-shrink': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('shrink-1')]),
        createElement('div', {
          style: {
            width: '150px',
            height: '80px',
            'flex-shrink': '2',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('shrink-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 9: flex-shrink with margins
  it('009-flex-shrink-with-margins', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '250px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            margin: '10px',
            'flex-shrink': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('margin')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            margin: '10px',
            'flex-shrink': '2',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('margin-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 10: flex-shrink dynamic changes
  it('010-flex-shrink-dynamic', async () => {
    let container;
    let item1, item2;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('dynamic')])),
        (item2 = createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('static')])),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
    
    // Change flex-shrink
    item1.style['flex-shrink'] = '3';
    await snapshot();
  });

  // Test 11: flex-shrink with percentage widths
  it('011-flex-shrink-percentage', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '60%',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('60%')]),
        createElement('div', {
          style: {
            width: '60%',
            height: '100px',
            'flex-shrink': '2',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('60%-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 12: flex-shrink with auto margins
  xit('012-flex-shrink-auto-margins', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '250px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '1',
            'margin-right': 'auto',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('auto')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('shrink')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 13: flex-shrink with borders and padding
  it('013-flex-shrink-box-sizing', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '250px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '1',
            border: '5px solid darkred',
            padding: '10px',
            'box-sizing': 'border-box',
            'background-color': 'red',
            'text-align': 'center',
          },
        }, [createText('border-box')]),
        createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('normal')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 14: flex-shrink with negative value (should default to 1)
  it('014-flex-shrink-negative', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '-1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('negative')]),
        createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('normal')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 15: flex-shrink with gap
  it('015-flex-shrink-with-gap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          gap: '10px',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('gap-1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '2',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('gap-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 16: flex-shrink with align-items stretch
  it('016-flex-shrink-align-stretch', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'align-items': 'stretch',
          width: '200px',
          height: '120px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '150px',
            'flex-shrink': '1',
            'background-color': 'red',
            'text-align': 'center',
            padding: '10px 0',
          },
        }, [createText('stretch')]),
        createElement('div', {
          style: {
            width: '150px',
            'flex-shrink': '2',
            'background-color': 'blue',
            'text-align': 'center',
            padding: '10px 0',
          },
        }, [createText('stretch-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 17: flex-shrink with nested flex containers
  it('017-flex-shrink-nested', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            display: 'flex',
            width: '200px',
            'flex-shrink': '1',
            'background-color': 'lightcoral',
          },
        }, [
          createElement('div', {
            style: {
              width: '100px',
              'flex-shrink': '1',
              'background-color': 'red',
              'text-align': 'center',
              'line-height': '100px',
            },
          }, [createText('nested-1')]),
          createElement('div', {
            style: {
              width: '100px',
              'flex-shrink': '1',
              'background-color': 'darkred',
              'text-align': 'center',
              'line-height': '100px',
            },
          }, [createText('nested-2')]),
        ]),
        createElement('div', {
          style: {
            width: '200px',
            'flex-shrink': '2',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('sibling')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 18: flex-shrink with replaced elements
  xit('018-flex-shrink-replaced', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            width: '100px',
            height: '100px',
            'flex-shrink': '1',
          },
        }),
        createElement('div', {
          style: {
            width: '150px',
            height: '100px',
            'flex-shrink': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('shrink')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 19: flex-shrink with text overflow
  it('019-flex-shrink-text-overflow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '50px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '150px',
            'flex-shrink': '1',
            'background-color': 'red',
            overflow: 'hidden',
            'text-overflow': 'ellipsis',
            'white-space': 'nowrap',
            padding: '10px',
          },
        }, [createText('This is a very long text that should be truncated')]),
        createElement('div', {
          style: {
            width: '100px',
            'flex-shrink': '0',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '50px',
          },
        }, [createText('fixed')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 20: flex-shrink calculation precision
  it('020-flex-shrink-precision', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '333px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '200px',
            height: '100px',
            'flex-shrink': '1.5',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1.5')]),
        createElement('div', {
          style: {
            width: '200px',
            height: '100px',
            'flex-shrink': '2.5',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('2.5')]),
        createElement('div', {
          style: {
            width: '200px',
            height: '100px',
            'flex-shrink': '0.5',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('0.5')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });
});