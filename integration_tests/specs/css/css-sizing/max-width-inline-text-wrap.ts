describe('max-width', () => {
  it('should wrap text in inline elements when parent has max-width', async () => {
    let div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'max-width': '200px',
        'background-color': '#f0f0f0',
        'padding': '10px',
      }
    }, [
      createElement('span', {
        style: {
          'box-sizing': 'border-box',
        }
      }, [
        createText('This is a very long text that should wrap within the max-width constraint of the parent div element')
      ])
    ]);

    BODY.appendChild(div);
    await snapshot();
  });

  it('should wrap text in nested inline elements when ancestor has max-width', async () => {
    let div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'max-width': '200px',
        'background-color': '#f0f0f0',
        'padding': '10px',
      }
    }, [
      createElement('span', {
        style: {
          'box-sizing': 'border-box',
        }
      }, [
        createElement('span', {
          style: {
            'box-sizing': 'border-box',
            'color': 'blue',
          }
        }, [
          createText('This is nested text that should also wrap within the max-width constraint')
        ])
      ])
    ]);

    BODY.appendChild(div);
    await snapshot();
  });

  it('should not affect inline elements in flex items with flex: none', async () => {
    let flexContainer = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'display': 'flex',
        'max-width': '200px',
        'background-color': '#e0e0e0',
      }
    }, [
      createElement('div', {
        style: {
          'box-sizing': 'border-box',
          'flex': 'none',
          'background-color': '#f0f0f0',
          'padding': '10px',
        }
      }, [
        createElement('span', {
          style: {
            'box-sizing': 'border-box',
          }
        }, [
          createText('This text in a flex: none item should not be constrained by the flex container max-width')
        ])
      ])
    ]);

    BODY.appendChild(flexContainer);
    await snapshot();
  });

  it('should wrap text in inline elements inside flex items with flex-shrink', async () => {
    let flexContainer = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'display': 'flex',
        'max-width': '200px',
        'background-color': '#e0e0e0',
      }
    }, [
      createElement('div', {
        style: {
          'box-sizing': 'border-box',
          'flex-shrink': '1',
          'background-color': '#f0f0f0',
          'padding': '10px',
        }
      }, [
        createElement('span', {
          style: {
            'box-sizing': 'border-box',
          }
        }, [
          createText('This text in a flex-shrink item should wrap within the flex container max-width')
        ])
      ])
    ]);

    BODY.appendChild(flexContainer);
    await snapshot();
  });

  it('should handle max-width with width auto on parent', async () => {
    let div = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'width': 'auto',
        'max-width': '150px',
        'background-color': '#f0f0f0',
        'padding': '10px',
        'margin': '10px',
      }
    }, [
      createElement('span', {
        style: {
          'box-sizing': 'border-box',
          'font-size': '14px',
        }
      }, [
        createText('Text that needs to wrap at 150px max width constraint')
      ])
    ]);

    BODY.appendChild(div);
    await snapshot();
  });
});
