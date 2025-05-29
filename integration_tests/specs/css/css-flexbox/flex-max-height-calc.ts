describe('flex-max-height-calc', () => {
  it('should correctly calculate content size with maxHeight in flex column layout', async () => {
    let container;
    let listView;
    
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          maxHeight: 'calc(80vh - 80px)',
          border: '1px solid #000',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText('Header Content')]
        ),
        (listView = createElement(
          'div',
          {
            style: {
              display: 'flex',
              minHeight: '0',
              width: '100%',
              flex: '1',
              flexDirection: 'column',
              alignItems: 'flex-start',
              justifyContent: 'flex-start',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  'box-sizing': 'border-box',
                },
              },
              [createText('List item content that should be constrained by maxHeight')]
            ),
          ]
        )),
      ]
    );
    
    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle maxHeight calculation with flex-1 child in column direction', async () => {
    let wrapper;
    
    wrapper = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '200px',
          border: '2px solid red',
          width: '250px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '50px',
              backgroundColor: 'lightblue',
              'box-sizing': 'border-box',
            },
          },
          [createText('Fixed height header')]
        ),
        createElement(
          'div',
          {
            style: {
              flex: '1',
              backgroundColor: 'lightgreen',
              minHeight: '0',
              'box-sizing': 'border-box',
            },
          },
          [createText('Flexible content that should be constrained by maxHeight calculation')]
        ),
        createElement(
          'div',
          {
            style: {
              height: '30px',
              backgroundColor: 'lightyellow',
              'box-sizing': 'border-box',
            },
          },
          [createText('Fixed height footer')]
        ),
      ]
    );
    
    BODY.appendChild(wrapper);
    await snapshot();
  });

  xit('should correctly apply maxHeight constraint to content size in flex row layout', async () => {
    let container;
    
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          maxHeight: '100px',
          border: '1px solid #333',
          width: '400px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flex: '1',
              backgroundColor: 'pink',
              'box-sizing': 'border-box',
            },
          },
          [createText('Content that should respect maxHeight in row direction layout')]
        ),
        createElement(
          'div',
          {
            style: {
              flex: '1',
              backgroundColor: 'lightcoral',
              'box-sizing': 'border-box',
            },
          },
          [createText('Second flex item also constrained by maxHeight')]
        ),
      ]
    );
    
    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle calc() expressions in maxHeight for flex items', async () => {
    let viewport;
    let flexContainer;
    
    viewport = createElement(
      'div',
      {
        style: {
          height: '500px',
          width: '100%',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        (flexContainer = createElement(
          'div',
          {
            style: {
              display: 'flex',
              flexDirection: 'column',
              maxHeight: 'calc(100% - 50px)',
              border: '2px solid blue',
              margin: '25px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  height: '80px',
                  backgroundColor: 'orange',
                  'box-sizing': 'border-box',
                },
              },
              [createText('Fixed header')]
            ),
            createElement(
              'div',
              {
                style: {
                  flex: '1',
                  backgroundColor: 'lightsteelblue',
                  minHeight: '0',
                  overflow: 'hidden',
                  'box-sizing': 'border-box',
                },
              },
              [createText('Scrollable content area that should be properly sized with calc() maxHeight')]
            ),
          ]
        )),
      ]
    );
    
    BODY.appendChild(viewport);
    await snapshot();
  });

  it('should handle maxHeight with percentage values in flex layout', async () => {
    let parent;
    
    parent = createElement(
      'div',
      {
        style: {
          height: '300px',
          width: '200px',
          position: 'relative',
          backgroundColor: 'lightgray',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              display: 'flex',
              flexDirection: 'column',
              maxHeight: '75%',
              border: '1px solid green',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  flex: '1',
                  backgroundColor: 'lavender',
                  'box-sizing': 'border-box',
                },
              },
              [createText('Content constrained by 75% maxHeight')]
            ),
          ]
        ),
      ]
    );
    
    BODY.appendChild(parent);
    await snapshot();
  });

  it('should correctly calculate when maxHeight is smaller than natural content size', async () => {
    let container;
    
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '50px',
          border: '2px solid purple',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flex: '1',
              backgroundColor: 'wheat',
              'box-sizing': 'border-box',
            },
          },
          [createText('This content would naturally be much taller than 50px but should be constrained by maxHeight. The fix ensures that content size is properly clamped using min() instead of max().')]
        ),
      ]
    );
    
    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle multiple flex items with maxHeight constraint', async () => {
    let container;
    
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '150px',
          border: '1px solid darkblue',
          width: '250px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flex: '1',
              backgroundColor: 'mistyrose',
              'box-sizing': 'border-box',
            },
          },
          [createText('First flex item')]
        ),
        createElement(
          'div',
          {
            style: {
              flex: '2',
              backgroundColor: 'lightcyan',
              'box-sizing': 'border-box',
            },
          },
          [createText('Second flex item with flex: 2')]
        ),
        createElement(
          'div',
          {
            style: {
              flex: '1',
              backgroundColor: 'peachpuff',
              'box-sizing': 'border-box',
            },
          },
          [createText('Third flex item')]
        ),
      ]
    );
    
    BODY.appendChild(container);
    await snapshot();
  });
});