/*auto generated*/
describe('flex-basis', () => {
  it('001', async () => {
    let p;
    let test;
    let ref;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          id: 'test',
          style: {
            'background-color': 'green',
            height: '100px',
            'flex-basis': '60px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            'background-color': 'green',
            height: '100px',
            width: '40px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('002', async () => {
    let p;
    let test;
    let ref;
    let container;
    let cover;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          id: 'test',
          style: {
            height: '100px',
            'flex-basis': '60px',
            width: '80px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            height: '100px',
            'background-color': 'green',
            width: '40px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        'background-color': 'green',
        height: '100px',
        'margin-top': '-100px',
        width: '60px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('003', async () => {
    let p;
    let test;
    let ref;
    let container;
    let cover;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          id: 'test',
          style: {
            height: '100px',
            'flex-basis': '-50px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            height: '100px',
            'background-color': 'green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        'background-color': 'green',
        height: '100px',
        'margin-left': '50px',
        'margin-top': '-100px',
        width: '50px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('004', async () => {
    let p;
    let test;
    let ref;
    let container;
    let cover;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          id: 'test',
          style: {
            'background-color': 'green',
            height: '100px',
            'flex-basis': '-50px',
            width: '30px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            'background-color': 'green',
            height: '100px',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    cover = createElement('div', {
      id: 'cover',
      style: {
        'background-color': 'green',
        height: '100px',
        'margin-left': '80px',
        'margin-top': '-100px',
        width: '20px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(p);
    BODY.appendChild(container);
    BODY.appendChild(cover);

    await snapshot();
  });
  it('005', async () => {
    let p;
    let test;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'green',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          id: 'test',
          style: {
            'background-color': 'red',
            'flex-basis': '0',
            height: '100px',
            width: '100px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('007', async () => {
    let p;
    let test;
    let ref;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          'background-color': 'red',
          display: 'flex',
          height: '100px',
          width: '100px',
          'box-sizing': 'border-box',
        },
      },
      [
        (test = createElement('div', {
          id: 'test',
          style: {
            'background-color': 'green',
            height: '100px',
            'flex-basis': 'auto',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (ref = createElement('div', {
          id: 'ref',
          style: {
            'background-color': 'green',
            height: '100px',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(container);

    await snapshot();
  });
  it('item-margins-001', async () => {
    let p;
    let referenceOverlappedRed;
    let inlineBlock;
    let inlineBlock_1;
    let div;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    referenceOverlappedRed = createElement('div', {
      id: 'reference-overlapped-red',
      style: {
        position: 'absolute',
        'background-color': 'red',
        width: '100px',
        height: '100px',
        'z-index': '-1',
        'box-sizing': 'border-box',
      },
    });
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          background: 'green',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              'box-sizing': 'border-box',
              'margin-right': '21px',
              flex: '0 0 auto',
              'line-height': '0px',
            },
          },
          [
            (inlineBlock = createElement('div', {
              class: 'inline-block',
              style: {
                display: 'inline-block',
                width: '40px',
                height: '50px',
                'box-sizing': 'border-box',
              },
            })),
            (inlineBlock_1 = createElement('div', {
              class: 'inline-block',
              style: {
                display: 'inline-block',
                width: '40px',
                height: '50px',
                'box-sizing': 'border-box',
              },
            })),
          ]
        ),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(div);

    await snapshot();
  });


  it("works with flex-basis larger than content main size in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flexBasis: '100px',
              width: '200px',
              padding: '10px 0',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis smaller than content main size in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flexBasis: '0',
              width: '200px',
              padding: '10px 0',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis not exists and width smaller than content main size in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              width: '30px',
              padding: '10px 0',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis larger than content main size in flex column direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flexBasis: '100px',
              height: '200px',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis smaller than content size in flex column direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              flexBasis: '0',
              height: '200px',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis not exists and height smaller than content main size in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          border: '1px solid purple',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '30px',
              backgroundColor: 'green'
            },
          },
          [
            createElement('div', {
              style: {
                width: '50px',
                height: '50px',
                backgroundColor: 'yellow'
              }
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis smaller than width in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          margin: '10px 0',
          width: '200px',
          height: '50px',
          backgroundColor: 'yellow'
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              width: '150px',
              flexBasis: '100px',
              backgroundColor: 'green'
            },
          }
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  
  it("works with flex-basis larger than width in flex row direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          margin: '10px 0',
          width: '200px',
          height: '50px',
          backgroundColor: 'yellow'
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              width: '50px',
              flexBasis: '100px',
              backgroundColor: 'green'
            },
          }
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it("works with flex-basis smaller than height in flex column direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          margin: '10px 0',
          width: '50px',
          height: '200px',
          backgroundColor: 'yellow'
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '150px',
              flexBasis: '100px',
              backgroundColor: 'green'
            },
          }
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  
  it("works with flex-basis larger than height in flex column direction", async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          margin: '10px 0',
          width: '50px',
          height: '200px',
          backgroundColor: 'yellow'
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              height: '50px',
              flexBasis: '100px',
              backgroundColor: 'green'
            },
          }
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('should properly layout text in flex items with flex: 1 1 0%', async () => {
    // Create the outer container
    const div1 = document.createElement('div');
    div1.id = 'div_1';
    div1.style.display = 'flex';

    // Create the main flex container
    const div2 = document.createElement('div');
    div2.id = 'div_2';
    div2.style.backgroundColor = 'grey';
    div2.style.color = 'cyan';
    div2.style.position = 'relative';
    div2.style.display = 'flex';
    div2.style.height = '2.5rem';
    div2.style.padding = '0.25rem';
    div2.style.textAlign = 'center';
    div2.style.boxSizing = 'border-box';

    // Create the first flex item with text
    const divBuy = document.createElement('div');
    divBuy.id = 'div_buy';
    divBuy.style.minWidth = '0';
    divBuy.style.padding = '32px';
    divBuy.style.display = 'flex';
    divBuy.style.flex = '1 1 0%';
    divBuy.style.flexShrink = '0';
    divBuy.style.justifyContent = 'center';
    divBuy.style.alignItems = 'center';
    divBuy.style.border = '1px solid red';
    divBuy.style.zIndex = '20';
    divBuy.style.fontSize = '16px';
    divBuy.textContent = 'Buy111222333';

    // Create the second flex item with text  
    const divSell = document.createElement('div');
    divSell.id = 'div_sell';
    divSell.style.minWidth = '0';
    divSell.style.padding = '32px';
    divSell.style.display = 'flex';
    divSell.style.flex = '1 1 0%';
    divSell.style.flexShrink = '0';
    divSell.style.justifyContent = 'center';
    divSell.style.alignItems = 'center';
    divSell.style.border = '1px solid red';
    divSell.style.zIndex = '20';
    divSell.style.fontSize = '16px';
    divSell.textContent = 'Sell';

    // Assemble the structure
    div2.appendChild(divBuy);
    div2.appendChild(divSell);
    div1.appendChild(div2);
    document.body.appendChild(div1);

    await snapshot();
  });
});
