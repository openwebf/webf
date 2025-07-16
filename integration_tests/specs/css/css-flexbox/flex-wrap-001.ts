/*auto generated*/
describe('flex-wrap-001', () => {
  // Test 1: Initial value (should default to 'nowrap')
  it('001-initial-value', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          // No flex-wrap specified, should default to 'nowrap'
          width: '200px',
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

  // Test 2: flex-wrap: nowrap
  it('002-nowrap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'nowrap',
          width: '200px',
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

  // Test 3: flex-wrap: wrap
  it('003-wrap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '180px',
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

  // Test 4: flex-wrap: wrap-reverse
  it('004-wrap-reverse', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap-reverse',
          width: '200px',
          height: '180px',
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

  // Test 5: flex-wrap with column direction
  it('005-column-wrap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '180px',
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

  // Test 6: flex-wrap: wrap-reverse with column direction
  it('006-column-wrap-reverse', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          'flex-wrap': 'wrap-reverse',
          width: '200px',
          height: '180px',
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

  // Test 7: Dynamic flex-wrap change
  it('007-dynamic-change', async () => {
    let container;
    container = createElement(
      'div',
      {
        id: 'dynamic-wrap',
        style: {
          display: 'flex',
          'flex-wrap': 'nowrap',
          width: '200px',
          height: '180px',
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
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('C')]),
      ]
    );
    BODY.appendChild(container);
    
    // Initial state: nowrap
    await snapshot();
    
    // Change to wrap
    container.style.flexWrap = 'wrap';
    await snapshot();
    
    // Change to wrap-reverse
    container.style.flexWrap = 'wrap-reverse';
    await snapshot();
  });

  // Test 8: flex-wrap with many items (multiple lines)
  it('008-multiple-lines', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '250px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '60px',
            height: '60px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '60px',
            height: '60px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '60px',
            height: '60px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('3')]),
        createElement('div', {
          style: {
            width: '60px',
            height: '60px',
            'background-color': 'yellow',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('4')]),
        createElement('div', {
          style: {
            width: '60px',
            height: '60px',
            'background-color': 'purple',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('5')]),
        createElement('div', {
          style: {
            width: '60px',
            height: '60px',
            'background-color': 'orange',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('6')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 9: flex-wrap with margins
  it('009-wrap-with-margins', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '240px',
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
            margin: '10px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            margin: '10px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            margin: '10px',
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

  // Test 10: flex-wrap with flex-grow
  it('010-wrap-with-flex-grow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '300px',
          height: '180px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-grow': '1',
            'min-width': '100px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('grow')]),
        createElement('div', {
          style: {
            width: '150px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('fixed')]),
        createElement('div', {
          style: {
            'flex-grow': '1',
            'min-width': '100px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('grow')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 11: flex-wrap with align-content
  it('011-wrap-align-content', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          'align-content': 'space-between',
          width: '200px',
          height: '250px',
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
            height: '60px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '60px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('3')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '60px',
            'background-color': 'yellow',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('4')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 12: flex-wrap with different sized items
  it('012-wrap-different-sizes', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '250px',
          height: '200px',
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
            width: '60px',
            height: '60px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '120px',
            height: '40px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '40px',
          },
        }, [createText('3')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '100px',
            'background-color': 'yellow',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('4')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 13: flex-wrap: nowrap with min-width
  it('013-nowrap-min-width', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'nowrap',
          width: '200px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'min-width': '80px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            'min-width': '80px',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            'min-width': '80px',
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

  // Test 14: flex-wrap with flex-shrink
  it('014-nowrap-with-flex-shrink', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'nowrap',
          width: '200px',
          height: '100px',
          'background-color': '#eee',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '80px',
            'flex-shrink': '1',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('shrink')]),
        createElement('div', {
          style: {
            width: '80px',
            'flex-shrink': '2',
            height: '80px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('shrink-2')]),
        createElement('div', {
          style: {
            width: '80px',
            'flex-shrink': '0',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('no-shrink')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 15: flex-wrap with nested flex containers
  it('015-nested-wrap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '300px',
          height: '200px',
          'background-color': '#ddd',
          border: '2px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            display: 'flex',
            'flex-wrap': 'wrap',
            width: '140px',
            height: '140px',
            'background-color': 'lightblue',
            margin: '5px',
          },
        }, [
          createElement('div', {
            style: {
              width: '60px',
              height: '60px',
              margin: '5px',
              'background-color': 'red',
              'text-align': 'center',
              'line-height': '60px',
            },
          }, [createText('1A')]),
          createElement('div', {
            style: {
              width: '60px',
              height: '60px',
              margin: '5px',
              'background-color': 'darkred',
              'text-align': 'center',
              'line-height': '60px',
            },
          }, [createText('1B')]),
        ]),
        createElement('div', {
          style: {
            display: 'flex',
            'flex-wrap': 'wrap-reverse',
            width: '140px',
            height: '140px',
            'background-color': 'lightgreen',
            margin: '5px',
          },
        }, [
          createElement('div', {
            style: {
              width: '60px',
              height: '60px',
              margin: '5px',
              'background-color': 'green',
              'text-align': 'center',
              'line-height': '60px',
            },
          }, [createText('2A')]),
          createElement('div', {
            style: {
              width: '60px',
              height: '60px',
              margin: '5px',
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

  // Test 16: flex-wrap with gap property
  it('016-wrap-with-gap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          gap: '10px',
          width: '200px',
          height: '180px',
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

  // Test 17: flex-wrap with absolute positioned child
  it('017-wrap-absolute-child', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          position: 'relative',
          width: '200px',
          height: '180px',
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
            width: '40px',
            height: '40px',
            'background-color': 'yellow',
            'text-align': 'center',
            'line-height': '40px',
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

  // Test 18: flex-wrap with max-height constraint
  it('018-wrap-max-height', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '200px',
          'max-height': '150px',
          overflow: 'hidden',
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
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'yellow',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('4')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 19: flex-wrap with justify-content
  it('019-wrap-justify-content', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          'justify-content': 'space-between',
          width: '300px',
          height: '180px',
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
        createElement('div', {
          style: {
            width: '80px',
            height: '80px',
            'background-color': 'yellow',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('4')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 20: flex-wrap with align-items
  it('020-wrap-align-items', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          'align-items': 'center',
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
            height: '60px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '60px',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '80px',
            height: '40px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '40px',
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