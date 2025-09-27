/*auto generated*/
describe('flex-direction-001', () => {
  // Test 1: Initial value (should default to 'row')
  it('001-initial-value', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          // No flex-direction specified, should default to 'row'
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 2: flex-direction: row
  it('002-row', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 3: flex-direction: row-reverse
  it('003-row-reverse', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row-reverse',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 4: flex-direction: column
  it('004-column', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '120px',
          height: '260px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 5: flex-direction: column-reverse
  it('005-column-reverse', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column-reverse',
          width: '120px',
          height: '260px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 6: Dynamic flex-direction change
  it('006-dynamic-change', async () => {
    let container;
    container = createElement(
      'div',
      {
        id: 'dynamic-flex',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '300px',
          height: '300px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('A')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('B')]),
      ]
    );
    BODY.appendChild(container);
    
    // Initial state: row
    await snapshot();
    
    // Change to column
    container.style.flexDirection = 'column';
    await snapshot();
    
    // Change to row-reverse
    container.style.flexDirection = 'row-reverse';
    await snapshot();
    
    // Change to column-reverse
    container.style.flexDirection = 'column-reverse';
    await snapshot();
  });

  // Test 7: flex-direction with flex-wrap
  it('007-with-wrap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          'flex-wrap': 'wrap',
          width: '220px',
          height: '180px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 8: flex-direction column with flex-wrap
  it('008-column-wrap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'flex-wrap': 'wrap',
          width: '220px',
          height: '180px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 9: flex-direction with RTL direction
  it('009-rtl-direction', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          direction: 'rtl',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 10: flex-direction with auto margins
  it('010-auto-margins', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '350px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'margin-left': 'auto',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 11: flex-direction column with auto margins
  it('011-column-auto-margins', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '120px',
          height: '400px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'margin-top': 'auto',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 12: flex-direction with flex-grow
  it('012-with-flex-grow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '350px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-grow': '1',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('grow-1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('fixed')]),
        createElement('div', {
          style: {
            'flex-grow': '2',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('grow-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 13: flex-direction column with flex-grow
  it('013-column-with-flex-grow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '120px',
          height: '400px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-grow': '1',
            width: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('grow-1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('fixed')]),
        createElement('div', {
          style: {
            'flex-grow': '2',
            width: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('grow-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 14: Nested flex containers with different directions
  it('014-nested-flex', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '350px',
          height: '200px',
          'background-color': '#ddd',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            display: 'flex',
            'flex-direction': 'column',
            width: '150px',
            'background-color': 'lightblue',
            margin: '10px',
          },
        }, [
          createElement('div', {
            style: {
              width: '100px',
              height: '60px',
              margin: '10px',
              'background-color': 'red',
              'text-align': 'center',
              'line-height': '60px',
            },
          }, [createText('1A')]),
          createElement('div', {
            style: {
              width: '100px',
              height: '60px',
              margin: '10px',
              'background-color': 'darkred',
              'text-align': 'center',
              'line-height': '60px',
            },
          }, [createText('1B')]),
        ]),
        createElement('div', {
          style: {
            display: 'flex',
            'flex-direction': 'column-reverse',
            width: '150px',
            'background-color': 'lightgreen',
            margin: '10px',
          },
        }, [
          createElement('div', {
            style: {
              width: '100px',
              height: '60px',
              margin: '10px',
              'background-color': 'green',
              'text-align': 'center',
              'line-height': '60px',
            },
          }, [createText('2A')]),
          createElement('div', {
            style: {
              width: '100px',
              height: '60px',
              margin: '10px',
              'background-color': 'darkgreen',
              'text-align': 'center',
              'line-height': '60px',
            },
          }, [createText('2B')]),
        ]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 15: flex-direction with absolute positioned child
  it('015-absolute-child', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          position: 'relative',
          width: '300px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            position: 'absolute',
            top: '10px',
            right: '10px',
            width: '50px',
            height: '50px',
            'background-color': 'yellow',
            'text-align': 'center',
            'line-height': '50px',
          },
        }, [createText('abs')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 16: flex-direction with min/max width constraints
  it('016-min-max-constraints', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '350px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex': '1',
            'min-width': '100px',
            'max-width': '150px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('min-max')]),
        createElement('div', {
          style: {
            'flex': '1',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('flex-1')]),
        createElement('div', {
          style: {
            'flex': '1',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('flex-1')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 17: flex-direction with overflow
  // TODO overflow 缺少滚动条
  it('017-overflow-behavior', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '200px',
          height: '100px',
          overflow: 'auto',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('Item-1')]),
        createElement('div', {
          style: {
            'min-width': '100px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('Item-2')]),
        createElement('div', {
          style: {
            'min-width': '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('Item-3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 18: flex-direction with align-items
  it('018-align-items-interaction', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
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
            width: '80px',
            height: '60px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '100px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '40px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '40px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 19: flex-direction column with align-items
  it('019-column-align-items', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'align-items': 'center',
          width: '200px',
          height: '300px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '60px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '120px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '40px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 20: flex-direction with justify-content
  it('020-justify-content-interaction', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          'justify-content': 'space-between',
          width: '350px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('3')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });
});