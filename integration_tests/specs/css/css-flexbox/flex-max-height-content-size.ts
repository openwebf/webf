describe('flex-max-height-content-size-calculation', () => {
  it('should correctly constrain flex item height with maxHeight calc expression', async () => {
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
          [createText('1222')]
        ),
        (listView = createElement(
          'webf-listview',
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
              [createText('123123123')]
            ),
          ]
        )),
      ]
    );
    
    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle flex items with multiple children in constrained height container', async () => {
    let wrapper;
    let listView;
    
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
        (listView = createElement(
          'webf-listview',
          {
            style: {
              flex: '1',
              backgroundColor: 'lightgreen',
              minHeight: '0',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  padding: '10px',
                  'box-sizing': 'border-box',
                },
              },
              [createText('List item 1')]
            ),
            createElement(
              'div',
              {
                style: {
                  padding: '10px',
                  'box-sizing': 'border-box',
                },
              },
              [createText('List item 2')]
            ),
            createElement(
              'div',
              {
                style: {
                  padding: '10px',
                  'box-sizing': 'border-box',
                },
              },
              [createText('List item 3')]
            ),
          ]
        )),
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

  it('should respect maxHeight constraint when flex item content exceeds available space', async () => {
    let container;
    let listView;
    
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '120px',
          border: '2px solid purple',
          width: '200px',
          'box-sizing': 'border-box',
        },
      },
      [
        (listView = createElement(
          'webf-listview',
          {
            style: {
              flex: '1',
              backgroundColor: 'wheat',
              minHeight: '0',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  padding: '15px',
                  backgroundColor: 'lightcoral',
                  'box-sizing': 'border-box',
                },
              },
              [createText('This is a very long content item that would naturally require much more space than the 120px maxHeight constraint allows.')]
            ),
            createElement(
              'div',
              {
                style: {
                  padding: '15px',
                  backgroundColor: 'lightblue',
                  'box-sizing': 'border-box',
                },
              },
              [createText('Another long item that adds to the total content height.')]
            ),
            createElement(
              'div',
              {
                style: {
                  padding: '15px',
                  backgroundColor: 'lightgreen',
                  'box-sizing': 'border-box',
                },
              },
              [createText('Yet another item that should be constrained by the maxHeight calculation fix.')]
            ),
          ]
        )),
      ]
    );
    
    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle flex items in viewport height calculation with calc()', async () => {
    let viewport;
    let flexContainer;
    let listView;
    
    viewport = createElement(
      'div',
      {
        style: {
          height: '400px',
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
              maxHeight: 'calc(100% - 100px)',
              border: '2px solid blue',
              margin: '50px',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  height: '60px',
                  backgroundColor: 'orange',
                  'box-sizing': 'border-box',
                },
              },
              [createText('Header section')]
            ),
            (listView = createElement(
              'webf-listview',
              {
                style: {
                  flex: '1',
                  backgroundColor: 'lightsteelblue',
                  minHeight: '0',
                  overflow: 'hidden',
                  'box-sizing': 'border-box',
                },
              },
              [
                createElement(
                  'div',
                  {
                    style: {
                      padding: '10px',
                      'box-sizing': 'border-box',
                    },
                  },
                  [createText('WebFListView item 1 - should be properly sized within calc() maxHeight constraint')]
                ),
                createElement(
                  'div',
                  {
                    style: {
                      padding: '10px',
                      'box-sizing': 'border-box',
                    },
                  },
                  [createText('WebFListView item 2')]
                ),
                createElement(
                  'div',
                  {
                    style: {
                      padding: '10px',
                      'box-sizing': 'border-box',
                    },
                  },
                  [createText('WebFListView item 3')]
                ),
              ]
            )),
          ]
        )),
      ]
    );
    
    BODY.appendChild(viewport);
    await snapshot();
  });

  it('should correctly apply min-h-0 with flex items in flex container', async () => {
    let container;
    let listView;
    
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '180px',
          border: '1px solid darkgreen',
          width: '280px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '40px',
              backgroundColor: 'lightgray',
              'box-sizing': 'border-box',
            },
          },
          [createText('Top section')]
        ),
        (listView = createElement(
          'webf-listview',
          {
            style: {
              display: 'flex',
              minHeight: '0', // This should allow shrinking below intrinsic content size
              width: '100%',
              flex: '1',
              flexDirection: 'column',
              alignItems: 'flex-start',
              justifyContent: 'flex-start',
              backgroundColor: 'honeydew',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  padding: '8px',
                  borderBottom: '1px solid #ccc',
                  'box-sizing': 'border-box',
                },
              },
              [createText('WebFListView with min-h-0 should shrink properly')]
            ),
            createElement(
              'div',
              {
                style: {
                  padding: '8px',
                  borderBottom: '1px solid #ccc',
                  'box-sizing': 'border-box',
                },
              },
              [createText('Even with multiple items that would naturally take more space')]
            ),
            createElement(
              'div',
              {
                style: {
                  padding: '8px',
                  'box-sizing': 'border-box',
                },
              },
              [createText('The fix ensures content size is clamped by maxHeight constraint')]
            ),
          ]
        )),
        createElement(
          'div',
          {
            style: {
              height: '25px',
              backgroundColor: 'lightgray',
              'box-sizing': 'border-box',
            },
          },
          [createText('Bottom section')]
        ),
      ]
    );
    
    BODY.appendChild(container);
    await snapshot();
  });

  it('should handle flex items with percentage maxHeight values', async () => {
    let parent;
    let listView;
    
    parent = createElement(
      'div',
      {
        style: {
          height: '250px',
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
              maxHeight: '80%', // 80% of 250px = 200px
              border: '1px solid green',
              'box-sizing': 'border-box',
            },
          },
          [
            (listView = createElement(
              'webf-listview',
              {
                style: {
                  flex: '1',
                  backgroundColor: 'lavender',
                  'box-sizing': 'border-box',
                },
              },
              [
                createElement(
                  'div',
                  {
                    style: {
                      padding: '12px',
                      'box-sizing': 'border-box',
                    },
                  },
                  [createText('WebFListView constrained by 80% maxHeight')]
                ),
                createElement(
                  'div',
                  {
                    style: {
                      padding: '12px',
                      'box-sizing': 'border-box',
                    },
                  },
                  [createText('Should respect percentage-based height calculations')]
                ),
              ]
            )),
          ]
        ),
      ]
    );
    
    BODY.appendChild(parent);
    await snapshot();
  });
});