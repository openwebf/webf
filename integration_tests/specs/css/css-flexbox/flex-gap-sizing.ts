/*auto generated*/
describe('css-flexbox gap sizing', () => {
  // The bug: when flex items with minWidth overflow a container with gap,
  // the scrollable content area does not include the gap space.
  // Scrolling to the end clips the last item by exactly the total gap length.

  it('row-flex-1-minwidth-with-gap-scroll-to-end', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if scrolling to the right end shows "Item 3" fully with its right border visible.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          gap: '10px',
          width: '200px',
          height: '80px',
          'background-color': '#f0f0f0',
          'overflow-x': 'auto',
          border: '3px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '100px',
            'background-color': '#ffcccc',
            height: '60px',
            border: '3px solid red',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 1')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '100px',
            'background-color': '#ccffcc',
            height: '60px',
            border: '3px solid green',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 2')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '100px',
            'background-color': '#ccccff',
            height: '60px',
            border: '3px solid blue',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 3')]),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    // Scroll to the very end
    flexbox.scrollLeft = flexbox.scrollWidth;

    await snapshot();
  });

  it('row-flex-1-minwidth-with-gap-4-items-scroll-to-end', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if scrolling to the right end shows "Item 4" fully with its right border visible.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          gap: '10px',
          width: '200px',
          height: '80px',
          'background-color': '#f0f0f0',
          'overflow-x': 'auto',
          border: '3px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '80px',
            'background-color': '#ffcccc',
            height: '60px',
            border: '3px solid red',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 1')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '80px',
            'background-color': '#ccffcc',
            height: '60px',
            border: '3px solid green',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 2')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '80px',
            'background-color': '#ccccff',
            height: '60px',
            border: '3px solid blue',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 3')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '80px',
            'background-color': '#ffffcc',
            height: '60px',
            border: '3px solid orange',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 4')]),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    // Scroll to the very end
    flexbox.scrollLeft = flexbox.scrollWidth;

    await snapshot();
  });

  it('row-flex-1-minwidth-with-large-gap-scroll-to-end', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if scrolling to the right end shows "Item 3" fully (large 30px gap).`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'row',
          gap: '30px',
          width: '200px',
          height: '80px',
          'background-color': '#f0f0f0',
          'overflow-x': 'auto',
          border: '3px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '100px',
            'background-color': '#ffcccc',
            height: '60px',
            border: '3px solid red',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 1')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '100px',
            'background-color': '#ccffcc',
            height: '60px',
            border: '3px solid green',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 2')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-width': '100px',
            'background-color': '#ccccff',
            height: '60px',
            border: '3px solid blue',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 3')]),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    // Scroll to the very end
    flexbox.scrollLeft = flexbox.scrollWidth;

    await snapshot();
  });

  it('column-flex-1-minheight-with-gap-scroll-to-end', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if scrolling to the bottom shows "Item 3" fully with its bottom border visible.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          gap: '10px',
          width: '150px',
          height: '200px',
          'background-color': '#f0f0f0',
          'overflow-y': 'auto',
          border: '3px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '100px',
            'background-color': '#ffcccc',
            border: '3px solid red',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 1')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '100px',
            'background-color': '#ccffcc',
            border: '3px solid green',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 2')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '100px',
            'background-color': '#ccccff',
            border: '3px solid blue',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 3')]),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    // Scroll to the very end
    flexbox.scrollTop = flexbox.scrollHeight;

    await snapshot();
  });

  it('column-flex-1-minheight-with-gap-4-items-scroll-to-end', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if scrolling to the bottom shows "Item 4" fully with its bottom border visible.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          gap: '10px',
          width: '150px',
          height: '200px',
          'background-color': '#f0f0f0',
          'overflow-y': 'auto',
          border: '3px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '80px',
            'background-color': '#ffcccc',
            border: '3px solid red',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 1')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '80px',
            'background-color': '#ccffcc',
            border: '3px solid green',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 2')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '80px',
            'background-color': '#ccccff',
            border: '3px solid blue',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 3')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '80px',
            'background-color': '#ffffcc',
            border: '3px solid orange',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 4')]),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    // Scroll to the very end
    flexbox.scrollTop = flexbox.scrollHeight;

    await snapshot();
  });

  it('column-flex-1-minheight-with-large-gap-scroll-to-end', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if scrolling to the bottom shows "Item 3" fully (large 30px gap).`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          gap: '30px',
          width: '150px',
          height: '200px',
          'background-color': '#f0f0f0',
          'overflow-y': 'auto',
          border: '3px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '100px',
            'background-color': '#ffcccc',
            border: '3px solid red',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 1')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '100px',
            'background-color': '#ccffcc',
            border: '3px solid green',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 2')]),
        createElement('div', {
          style: {
            flex: '1',
            'min-height': '100px',
            'background-color': '#ccccff',
            border: '3px solid blue',
            'box-sizing': 'border-box',
          },
        }, [createText('Item 3')]),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    // Scroll to the very end
    flexbox.scrollTop = flexbox.scrollHeight;

    await snapshot();
  });
});
