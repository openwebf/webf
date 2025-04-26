/*auto generated*/
describe('single-sided-dashed-border', () => {
  it('top-only dashed border', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px dashed red',
        borderRight: '5px solid transparent',
        borderBottom: '5px solid transparent',
        borderLeft: '5px solid transparent',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('right-only dashed border', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px solid transparent',
        borderRight: '5px dashed green',
        borderBottom: '5px solid transparent',
        borderLeft: '5px solid transparent',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('bottom-only dashed border', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px solid transparent',
        borderRight: '5px solid transparent',
        borderBottom: '5px dashed blue',
        borderLeft: '5px solid transparent',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('left-only dashed border', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px solid transparent',
        borderRight: '5px solid transparent',
        borderBottom: '5px solid transparent',
        borderLeft: '5px dashed purple',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('top and bottom dashed borders', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px dashed red',
        borderRight: '5px solid transparent',
        borderBottom: '5px dashed blue',
        borderLeft: '5px solid transparent',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('left and right dashed borders', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px solid transparent',
        borderRight: '5px dashed green',
        borderBottom: '5px solid transparent',
        borderLeft: '5px dashed purple',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('adjacent dashed borders (top-right)', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px dashed red',
        borderRight: '5px dashed green',
        borderBottom: '5px solid transparent',
        borderLeft: '5px solid transparent',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('three dashed borders (top, right, bottom)', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px dashed red',
        borderRight: '5px dashed green',
        borderBottom: '5px dashed blue',
        borderLeft: '5px solid transparent',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('single-sided dashed border with border-radius', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px dashed red',
        borderRight: '5px solid transparent',
        borderBottom: '5px solid transparent',
        borderLeft: '5px solid transparent',
        borderRadius: '10px',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('opposite corners dashed borders with border-radius', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '5px dashed red',
        borderRight: '5px solid transparent',
        borderBottom: '5px solid transparent',
        borderLeft: '5px dashed purple',
        borderRadius: '10px',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('dashed borders with different widths', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '2px dashed red',
        borderRight: '5px dashed green',
        borderBottom: '8px dashed blue',
        borderLeft: '12px dashed purple',
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('single-sided dashed border with large border-radius', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '8px dashed red',
        borderRight: '5px solid transparent',
        borderBottom: '5px solid transparent',
        borderLeft: '5px solid transparent',
        borderRadius: '50%', // Make it a circle
        height: '100px',
        width: '100px',
        backgroundColor: 'lightyellow',
        boxSizing: 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('dashed border with transform rotation', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderTop: '8px dashed red',
        borderRight: '5px solid transparent',
        borderBottom: '5px solid transparent',
        borderLeft: '5px solid transparent',
        borderRadius: '15px',
        backgroundColor: 'lightyellow',
        height: '80px',
        width: '80px',
        transform: 'rotate(45deg)',
        margin: '40px',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  // Test for nested elements with dashed borders
  it('nested elements with dashed borders', async () => {
    let container = createElement('div', {
      style: {
        width: '150px',
        height: '150px',
        padding: '10px',
        borderTop: '5px dashed red',
        borderRight: '5px dashed green',
        borderBottom: '5px dashed blue',
        borderLeft: '5px dashed purple',
        backgroundColor: 'lightyellow',
      }
    });

    let innerDiv = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        margin: '10px auto',
        borderTop: '3px dashed blue',
        borderLeft: '3px dashed red',
        backgroundColor: 'lightblue',
      },
    });

    container.appendChild(innerDiv);
    BODY.appendChild(container);

    await snapshot();
  });
});
