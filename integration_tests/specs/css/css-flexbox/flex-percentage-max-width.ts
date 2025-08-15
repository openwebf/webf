describe('flex-percentage-max-width', () => {
  it('should respect percentage max-width in flex container', async () => {
    let container;
    let target;

    container = createElement(
      'div',
      {
        style: {
          position: 'relative',
          marginBottom: '60px',
          width: '100%',
          display: 'flex',
          justifyContent: 'space-between',
          border: '1px solid red',
          width: '360px', // Fixed width for testing
          boxSizing: 'border-box',
        },
      },
      [
        (target = createElement(
          'div',
          {
            id: 'target',
            style: {
              maxWidth: '50%',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
              backgroundColor: 'lightblue',
            },
          },
          [createText('左侧文字'.repeat(10))]
        )),
      ]
    );

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle text truncation with percentage max-width', async () => {
    let container;
    let target;
    let rightElement;

    container = createElement(
      'div',
      {
        style: {
          position: 'relative',
          width: '360px',
          display: 'flex',
          justifyContent: 'space-between',
          border: '1px solid green',
          boxSizing: 'border-box',
        },
      },
      [
        (target = createElement(
          'div',
          {
            style: {
              maxWidth: '40%',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
              backgroundColor: 'lightcoral',
              padding: '5px',
            },
          },
          [createText('This is a very long text that should be truncated with ellipsis')]
        )),
        (rightElement = createElement(
          'div',
          {
            style: {
              backgroundColor: 'lightgreen',
              padding: '5px',
            },
          },
          [createText('Right')]
        )),
      ]
    );

    document.body.appendChild(container);

    await snapshot();
  });

  it('should calculate percentage max-width based on flex container width', async () => {
    let outerContainer;
    let flexContainer;
    let target;

    outerContainer = createElement(
      'div',
      {
        style: {
          width: '360px',
          padding: '10px',
          backgroundColor: '#f0f0f0',
        },
      },
      [
        (flexContainer = createElement(
          'div',
          {
            style: {
              width: '90%', // 324px
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              border: '2px solid blue',
              boxSizing: 'border-box',
            },
          },
          [
            (target = createElement(
              'div',
              {
                style: {
                  maxWidth: '60%', // Should be 60% of 324px = 194.4px
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                  backgroundColor: 'yellow',
                  padding: '8px',
                },
              },
              [createText('Lorem ipsum dolor sit amet, consectetur adipiscing elit')]
            )),
            createElement(
              'div',
              {
                style: {
                  backgroundColor: 'pink',
                  padding: '8px',
                },
              },
              [createText('End Item')]
            ),
          ]
        )),
      ]
    );

    document.body.appendChild(outerContainer);

    await snapshot();
  });

  it('should handle multiple flex items with percentage max-width', async () => {
    let container;
    let item1, item2, item3;

    container = createElement(
      'div',
      {
        style: {
          width: '360px',
          display: 'flex',
          justifyContent: 'space-between',
          gap: '10px',
          border: '1px solid purple',
          padding: '10px',
          boxSizing: 'border-box',
        },
      },
      [
        (item1 = createElement(
          'div',
          {
            style: {
              maxWidth: '30%',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
              backgroundColor: 'lightblue',
              padding: '5px',
            },
          },
          [createText('First item with long text')]
        )),
        (item2 = createElement(
          'div',
          {
            style: {
              maxWidth: '40%',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
              backgroundColor: 'lightgreen',
              padding: '5px',
            },
          },
          [createText('Second item with even longer text content')]
        )),
        (item3 = createElement(
          'div',
          {
            style: {
              backgroundColor: 'lightyellow',
            },
          },
          [createText('Third')]
        )),
      ]
    );

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle percentage max-width with flex-grow', async () => {
    let container;
    let growItem, fixedItem;

    container = createElement(
      'div',
      {
        style: {
          width: '360px',
          display: 'flex',
          border: '2px solid orange',
          boxSizing: 'border-box',
        },
      },
      [
        (growItem = createElement(
          'div',
          {
            style: {
              flexGrow: '1',
              maxWidth: '70%',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
              backgroundColor: 'lavender',
              padding: '10px',
            },
          },
          [createText('Growing item with maximum width constraint and very long text')]
        )),
        (fixedItem = createElement(
          'div',
          {
            style: {
              flexShrink: '0',
              backgroundColor: 'peachpuff',
              padding: '10px',
            },
          },
          [createText('Fixed width')]
        )),
      ]
    );

    document.body.appendChild(container);

    await snapshot();
  });

  it('should handle multiple flex items no text with percentage max-width', async () => {
    let container;
    let item1, item2, item3;

    container = createElement(
      'div',
      {
        style: {
          width: '360px',
          display: 'flex',
          justifyContent: 'space-between',
          gap: '5px',
          border: '1px solid purple',
          padding: '10px',
          boxSizing: 'border-box',
        },
      },
      [
        (item1 = createElement(
          'div',
          {
            style: {
              maxWidth: '30%',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
              backgroundColor: 'lightblue',
              padding: '25px',
            },
          }
        )),
        (item2 = createElement(
          'div',
          {
            style: {
              maxWidth: '40%',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
              backgroundColor: 'lightgreen',
              padding: '25px',
            },
          }
        )),
        (item3 = createElement(
          'div',
          {
            style: {
              backgroundColor: 'lightyellow',
              padding: '25px',
            },
          }
        )),
      ]
    );

    document.body.appendChild(container);

    await snapshot();
  });
});
