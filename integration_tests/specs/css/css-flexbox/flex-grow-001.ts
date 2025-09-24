/*auto generated*/
describe('flex-grow-001', () => {
  // Test 1: Basic flex-grow behavior
  it('001-basic-flex-grow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('grow-1')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '2',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('grow-2')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('no-grow')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 2: flex-grow with zero value
  it('002-flex-grow-zero', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '0',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('grow-0')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '0',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('grow-0')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '0',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('grow-0')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 3: flex-grow with decimal values
  it('003-flex-grow-decimal', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '0.5',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('0.5')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '1.5',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1.5')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '2',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 4: flex-grow with column direction
  it('004-flex-grow-column', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '300px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '50px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            'flex-grow': '2',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '50px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '50px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '50px',
          },
        }, [createText('0')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 5: flex-grow with min-width constraint
  it('005-flex-grow-min-width', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '100px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('min-100')]),
        createElement('div', {
          style: {
            'min-width': '50px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('min-50')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('fixed')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 6: flex-grow with max-width constraint
  it('006-flex-grow-max-width', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '350px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            'max-width': '100px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('max-100')]),
        createElement('div', {
          style: {
            width: '50px',
            'max-width': '150px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('max-150')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('no-max')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 7: flex-grow with all items having same grow factor
  it('007-equal-flex-grow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '20px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '20px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '20px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 8: flex-grow with margins
  it('008-flex-grow-with-margins', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            margin: '0 10px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            margin: '0 10px',
            'flex-grow': '2',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            margin: '0 10px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('0')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 9: flex-grow with flex-basis
  it('009-flex-grow-with-basis', async () => {
    let container;
    let item1, item2, item3;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
        },
      },
      [
        item1 = createElement('div', {
          id: 'item1',
          style: {
            'flex-basis': '50px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('basis-50')]),
        item2 = createElement('div', {
          id: 'item2',
          style: {
            'flex-basis': '100px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('basis-100')]),
        item3 = createElement('div', {
          id: 'item3',
          style: {
            'flex-basis': '50px',
            // 'flex-grow': '0',
            // 'flex-shrink': '0',
            // width: '50px',
            // 'min-width': '50px',
            // 'max-width': '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('no-grow')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 10: flex-grow with dynamic changes
  it('010-flex-grow-dynamic', async () => {
    let container;
    let growItem;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        growItem = createElement('div', {
          id: 'grow-item',
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '0',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('dynamic')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('grow-1')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('fixed')]),
      ]
    );
    BODY.appendChild(container);

    // Initial state
    await snapshot();

    // Change flex-grow
    growItem.style.flexGrow = '2';
    await snapshot();
  });

  // Test 11: flex-grow with wrap
  it('011-flex-grow-with-wrap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '200px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'flex-grow': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 12: flex-grow with different sized items
  it('012-flex-grow-different-sizes', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '30px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('30px')]),
        createElement('div', {
          style: {
            width: '60px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('60px')]),
        createElement('div', {
          style: {
            width: '90px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('90px')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 13: flex-grow with negative value (should be treated as 0)
  it('013-flex-grow-negative', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '-1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('neg')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('0')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 14: flex-grow with very large values
  it('014-flex-grow-large-values', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '20px',
            height: '100px',
            'flex-grow': '100',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100')]),
        createElement('div', {
          style: {
            width: '20px',
            height: '100px',
            'flex-grow': '200',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('200')]),
        createElement('div', {
          style: {
            width: '20px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 15: flex-grow with gap
  it('015-flex-grow-with-gap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          gap: '10px',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '2',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('0')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 16: flex-grow with nested flex containers
  it('016-nested-flex-grow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#ddd',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            display: 'flex',
            'flex-grow': '1',
            'background-color': 'lightblue',
            margin: '5px',
          },
        }, [
          createElement('div', {
            style: {
              width: '30px',
              'flex-grow': '1',
              'background-color': 'red',
              margin: '5px',
              'text-align': 'center',
              'line-height': '80px',
            },
          }, [createText('1')]),
          createElement('div', {
            style: {
              width: '30px',
              'flex-grow': '2',
              'background-color': 'darkred',
              margin: '5px',
              'text-align': 'center',
              'line-height': '80px',
            },
          }, [createText('2')]),
        ]),
        createElement('div', {
          style: {
            width: '100px',
            'background-color': 'green',
            margin: '5px',
            'text-align': 'center',
            'line-height': '90px',
          },
        }, [createText('fixed')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 17: flex-grow with auto margins
  it('017-flex-grow-auto-margins', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'margin-right': 'auto',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('auto')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('0')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 18: flex-grow with percentage width
  it('018-flex-grow-percentage-width', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '20%',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('20%')]),
        createElement('div', {
          style: {
            width: '30%',
            height: '100px',
            'flex-grow': '1',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('30%')]),
        createElement('div', {
          style: {
            width: '10%',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('10%')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 19: flex-grow with content overflow
  it('019-flex-grow-content-overflow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '250px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '1',
            overflow: 'hidden',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('VeryLongTextThatOverflows')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'flex-grow': '2',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('grow-2')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('fixed')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 20: flex-grow with align-items
  it('020-flex-grow-align-items', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'align-items': 'center',
          width: '300px',
          height: '150px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            'flex-grow': '1',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '50px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '80px',
            'flex-grow': '2',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('0')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });
});
