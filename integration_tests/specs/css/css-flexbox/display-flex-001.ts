/*auto generated*/
describe('CSS Display Flex', () => {
  it('001-display-flex-basic', async () => {
    let container = createElement('div', {
      style: {
        width: '300px',
        height: '200px',
        display: 'flex',
        backgroundColor: '#f0f0f0',
        border: '1px solid black',
      },
    }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '50px',
          backgroundColor: 'red',
        },
      }, [createText('Item 1')]),
      createElement('div', {
        style: {
          width: '100px',
          height: '50px',
          backgroundColor: 'green',
        },
      }, [createText('Item 2')]),
      createElement('div', {
        style: {
          width: '100px',
          height: '50px',
          backgroundColor: 'blue',
        },
      }, [createText('Item 3')]),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('002-display-inline-flex-basic', async () => {
    let container = createElement('div', {
      style: {
        backgroundColor: '#f0f0f0',
        border: '1px solid purple',
        padding: '10px',
      },
    }, [
      createText('Before '),
      createElement('div', {
        style: {
          display: 'inline-flex',
          border: '1px solid black',
        },
      }, [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            backgroundColor: 'red',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            backgroundColor: 'green',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            backgroundColor: 'blue',
          },
        }, [createText('3')]),
      ]),
      createText(' After'),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('003-flex-container-width-auto', async () => {
    let container = createElement('div', {
      style: {
        display: 'flex',
        backgroundColor: '#f0f0f0',
        border: '1px solid black',
      },
    }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '50px',
          backgroundColor: 'red',
        },
      }, [createText('Item 1')]),
      createElement('div', {
        style: {
          width: '150px',
          height: '50px',
          backgroundColor: 'green',
        },
      }, [createText('Item 2')]),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('004-inline-flex-container-width-auto', async () => {
    let container = createElement('div', {
      style: {
        backgroundColor: '#f0f0f0',
        padding: '10px',
      },
    }, [
      createElement('span', {}, [createText('Text before ')]),
      createElement('div', {
        style: {
          display: 'inline-flex',
          backgroundColor: 'lightyellow',
          border: '1px solid black',
        },
      }, [
        createElement('div', {
          style: {
            width: '80px',
            height: '40px',
            backgroundColor: 'red',
          },
        }, [createText('Item 1')]),
        createElement('div', {
          style: {
            width: '100px',
            height: '40px',
            backgroundColor: 'green',
          },
        }, [createText('Item 2')]),
      ]),
      createElement('span', {}, [createText(' Text after')]),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('005-flex-with-percentage-children', async () => {
    let container = createElement('div', {
      style: {
        width: '400px',
        display: 'flex',
        backgroundColor: '#f0f0f0',
        border: '1px solid black',
      },
    }, [
      createElement('div', {
        style: {
          width: '25%',
          height: '60px',
          backgroundColor: 'red',
        },
      }, [createText('25%')]),
      createElement('div', {
        style: {
          width: '50%',
          height: '60px',
          backgroundColor: 'green',
        },
      }, [createText('50%')]),
      createElement('div', {
        style: {
          width: '25%',
          height: '60px',
          backgroundColor: 'blue',
        },
      }, [createText('25%')]),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('006-inline-flex-vertical-align', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '20px',
        lineHeight: '30px',
      },
    }, [
      createText('Text '),
      createElement('div', {
        style: {
          display: 'inline-flex',
          verticalAlign: 'middle',
          backgroundColor: 'lightyellow',
          border: '1px solid black',
        },
      }, [
        createElement('div', {
          style: {
            width: '40px',
            height: '40px',
            backgroundColor: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '40px',
            height: '40px',
            backgroundColor: 'green',
          },
        }),
      ]),
      createText(' middle aligned'),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('007-flex-wrap-behavior', async () => {
    let container = createElement('div', {
      style: {
        width: '200px',
        display: 'flex',
        flexWrap: 'wrap',
        backgroundColor: '#f0f0f0',
        border: '1px solid black',
      },
    }, [
      createElement('div', {
        style: {
          width: '80px',
          height: '50px',
          backgroundColor: 'red',
        },
      }, [createText('1')]),
      createElement('div', {
        style: {
          width: '80px',
          height: '50px',
          backgroundColor: 'green',
        },
      }, [createText('2')]),
      createElement('div', {
        style: {
          width: '80px',
          height: '50px',
          backgroundColor: 'blue',
        },
      }, [createText('3')]),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('008-inline-flex-in-text-flow', async () => {
    let container = createElement('div', {
      style: {
        width: '300px',
        fontSize: '16px',
        lineHeight: '24px',
      },
    }, [
      createText('This is some text with an '),
      createElement('div', {
        style: {
          display: 'inline-flex',
          backgroundColor: 'lightyellow',
          border: '1px solid red',
          padding: '2px',
        },
      }, [
        createElement('span', {
          style: {
            backgroundColor: 'lightblue',
            padding: '0 5px',
          },
        }, [createText('inline')]),
        createElement('span', {
          style: {
            backgroundColor: 'lightgreen',
            padding: '0 5px',
          },
        }, [createText('flex')]),
      ]),
      createText(' container in the middle of the text flow.'),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('009-flex-vs-block-comparison', async () => {
    let wrapper = createElement('div', {
      style: {
        backgroundColor: '#f0f0f0',
        padding: '10px',
      },
    }, [
      createElement('div', {
        style: {
          display: 'block',
          backgroundColor: 'lightblue',
          border: '1px solid blue',
          marginBottom: '10px',
        },
      }, [
        createElement('div', {
          style: {
            width: '100px',
            height: '30px',
            backgroundColor: 'navy',
            color: 'white',
          },
        }, [createText('Block child')]),
      ]),
      createElement('div', {
        style: {
          display: 'flex',
          backgroundColor: 'lightcoral',
          border: '1px solid red',
        },
      }, [
        createElement('div', {
          style: {
            width: '100px',
            height: '30px',
            backgroundColor: 'darkred',
            color: 'white',
          },
        }, [createText('Flex child')]),
      ]),
    ]);
    
    document.body.appendChild(wrapper);
    await snapshot();
  });

  it('010-inline-flex-with-gap', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '16px',
      },
    }, [
      createText('Items with gap: '),
      createElement('div', {
        style: {
          display: 'inline-flex',
          gap: '10px',
          backgroundColor: 'lightyellow',
          border: '1px solid orange',
          padding: '5px',
        },
      }, [
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            backgroundColor: 'red',
          },
        }),
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            backgroundColor: 'green',
          },
        }),
        createElement('div', {
          style: {
            width: '30px',
            height: '30px',
            backgroundColor: 'blue',
          },
        }),
      ]),
      createText(' end'),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('011-flex-min-height', async () => {
    let container = createElement('div', {
      style: {
        display: 'flex',
        minHeight: '100px',
        backgroundColor: '#f0f0f0',
        border: '1px solid black',
      },
    }, [
      createElement('div', {
        style: {
          width: '100px',
          backgroundColor: 'red',
        },
      }, [createText('Auto height')]),
      createElement('div', {
        style: {
          width: '100px',
          height: '50px',
          backgroundColor: 'green',
        },
      }, [createText('50px height')]),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('012-inline-flex-baseline-alignment', async () => {
    let container = createElement('div', {
      style: {
        fontSize: '20px',
        lineHeight: '30px',
      },
    }, [
      createText('Text '),
      createElement('div', {
        style: {
          display: 'inline-flex',
          alignItems: 'baseline',
          backgroundColor: 'lightyellow',
          border: '1px solid black',
          height: '60px',
        },
      }, [
        createElement('div', {
          style: {
            fontSize: '30px',
            backgroundColor: 'lightblue',
            padding: '5px',
          },
        }, [createText('Big')]),
        createElement('div', {
          style: {
            fontSize: '16px',
            backgroundColor: 'lightgreen',
            padding: '5px',
          },
        }, [createText('Small')]),
      ]),
      createText(' baseline'),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('013-flex-with-margin-auto', async () => {
    let container = createElement('div', {
      style: {
        width: '300px',
        display: 'flex',
        backgroundColor: '#f0f0f0',
        border: '1px solid black',
      },
    }, [
      createElement('div', {
        style: {
          width: '80px',
          height: '50px',
          backgroundColor: 'red',
        },
      }, [createText('Left')]),
      createElement('div', {
        style: {
          width: '80px',
          height: '50px',
          backgroundColor: 'green',
          marginLeft: 'auto',
        },
      }, [createText('Right')]),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('014-inline-flex-nested', async () => {
    let container = createElement('div', {
      style: {
        padding: '10px',
      },
    }, [
      createText('Outer: '),
      createElement('div', {
        style: {
          display: 'inline-flex',
          gap: '5px',
          backgroundColor: 'lightgray',
          border: '1px solid black',
          padding: '5px',
        },
      }, [
        createElement('div', {
          style: {
            backgroundColor: 'lightblue',
            padding: '5px',
          },
        }, [createText('Item')]),
        createElement('div', {
          style: {
            display: 'inline-flex',
            gap: '3px',
            backgroundColor: 'lightyellow',
            border: '1px solid orange',
            padding: '3px',
          },
        }, [
          createElement('div', {
            style: {
              width: '20px',
              height: '20px',
              backgroundColor: 'red',
            },
          }),
          createElement('div', {
            style: {
              width: '20px',
              height: '20px',
              backgroundColor: 'green',
            },
          }),
        ]),
      ]),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });

  it('015-flex-direction-column', async () => {
    let container = createElement('div', {
      style: {
        display: 'flex',
        flexDirection: 'column',
        width: '200px',
        height: '300px',
        backgroundColor: '#f0f0f0',
        border: '1px solid black',
      },
    }, [
      createElement('div', {
        style: {
          height: '50px',
          backgroundColor: 'red',
        },
      }, [createText('First')]),
      createElement('div', {
        style: {
          height: '50px',
          backgroundColor: 'green',
        },
      }, [createText('Second')]),
      createElement('div', {
        style: {
          height: '50px',
          backgroundColor: 'blue',
        },
      }, [createText('Third')]),
    ]);
    
    document.body.appendChild(container);
    await snapshot();
  });
});