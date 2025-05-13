/*auto generated*/
describe('border-style', () => {
  it('basic dashed style', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        border: '5px dashed black',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('dash size proportional to border width', async () => {
    let container = createElement('div', {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: '10px',
      }
    });

    // Create three boxes with different border widths
    let div1 = createElement('div', {
      style: {
        border: '2px dashed red',
        height: '50px',
        width: '100px',
      },
    });

    let div2 = createElement('div', {
      style: {
        border: '5px dashed red',
        height: '50px',
        width: '100px',
      },
    });

    let div3 = createElement('div', {
      style: {
        border: '10px dashed red',
        height: '50px',
        width: '100px',
      },
    });

    container.appendChild(div1);
    container.appendChild(div2);
    container.appendChild(div3);
    BODY.appendChild(container);

    await snapshot();
  });

  it('dashed with different colors on each side', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderStyle: 'dashed',
        borderWidth: '5px',
        borderTopColor: 'red',
        borderRightColor: 'green',
        borderBottomColor: 'blue',
        borderLeftColor: 'purple',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('dashed border with large border-radius', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        border: '8px dashed blue',
        borderRadius: '50%', // Make it a circle
        backgroundColor: 'yellow',
        height: '100px',
        width: '100px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });

  it('dashed border with corner overflow visible', async () => {
    let container = createElement('div', {
      style: {
        position: 'relative',
        width: '150px',
        height: '150px',
        border: '1px solid black',
        padding: '10px',
      }
    });

    let div = createElement('div', {
      style: {
        position: 'absolute',
        top: '10px',
        left: '10px',
        width: '130px',
        height: '130px',
        border: '15px dashed red',
        borderRadius: '20px',
        backgroundColor: 'rgba(255, 255, 0, 0.5)', // Semi-transparent yellow
      },
    });

    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();
  });

  it('dashed border with transform', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        border: '8px dashed green',
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

  it('dashed borders for all four sides with different widths', async () => {
    let div = createElement('div', {
      xmlns: 'http://www.w3.org/1999/xhtml',
      style: {
        borderStyle: 'dashed',
        borderTopWidth: '2px',
        borderRightWidth: '5px',
        borderBottomWidth: '10px',
        borderLeftWidth: '15px',
        borderColor: 'blue',
        height: '100px',
        width: '100px',
        backgroundColor: 'yellow',
      },
    });
    BODY.appendChild(div);

    await snapshot();
  });
});
