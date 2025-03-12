describe('border_radius', () => {
  it('all_direction', async () => {
    let container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      backgroundColor: '#252423',
      height: '500px',
    });

    for (let i = 0; i < 5; i++) {
      let dotEl = document.createElement('div');
      setElementStyle(dotEl, {
        display: 'inline-block',
        marginLeft: '5px',
        width: '40px',
        height: '40px',
        borderRadius: '20px',
        backgroundColor: '#FF4B4B',
      });
      container.appendChild(dotEl);
    }

    document.body.appendChild(container);

    await snapshot();
  });

  it('works with overflow and child image of transform', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'border-radius': '20px',
          backgroundColor: 'blue',
          width: '100px',
          border: '5px solid black',
          height: '100px',
          overflow: 'hidden'
        },
      }, [
      createElement('div', {
        style: {
          backgroundColor: 'red',
        }
      }, [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            width: '100px',
            height: '250px',
            borderRadius: '30px',
            transform: 'translate(20px, 20px)'
          }
        })
      ])
    ]
    );

    BODY.appendChild(div);

    await snapshot(0.5);
  });

  it('works with overflow and child image of no transform', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'border-radius': '20px',
          backgroundColor: 'blue',
          width: '100px',
          border: '5px solid black',
          height: '100px',
          overflow: 'hidden'
        },
      }, [
      createElement('div', {
        style: {
          backgroundColor: 'red',
        }
      }, [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            width: '100px',
            height: '250px',
            borderRadius: '30px',
          }
        })
      ])
    ]
    );
    BODY.appendChild(div);

    await snapshot(0.1);
  });

  it('works with overflow hidden', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'border-radius': '10px',
          backgroundColor: 'green',
          width: '100px',
          height: '100px',
          padding: '10px',
          overflow: 'hidden'
        },
      }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '250px',
          backgroundColor: 'yellow'
        }
      })
    ]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('works with overflow hidden and child of opacity', async (done) => {
    let div;
    let item;
    div = createElement(
      'div',
      {
        style: {
          'border-radius': '10px',
          backgroundColor: 'green',
          width: '100px',
          height: '100px',
          padding: '10px',
          overflow: 'hidden'
        },
      }, [
      (item = createElement('div', {
        style: {
          width: '100px',
          height: '250px',
          backgroundColor: 'yellow',
        }
      }))
    ]
    );

    BODY.appendChild(div);

    setTimeout(async () => {
      item.style.opacity = 0.5;
      await snapshot();
      done();
    }, 1000);
  });

  it('works with overflow clip', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          'border-radius': '10px',
          backgroundColor: 'green',
          width: '100px',
          height: '100px',
          padding: '10px',
          overflow: 'clip'
        },
      }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '250px',
          backgroundColor: 'yellow'
        }
      })
    ]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it('works with image', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/100x100-green.png',
        style: {
          'border-radius': '20px',
        },
      },
    );
    BODY.appendChild(image);

    await snapshot(0.1);
  });

  it('works with image width border', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/100x100-green.png',
        style: {
          'border-radius': '30px',
          border: '10px solid red',
          width: '100px',
          height: '100px',
        },
      },
    );
    BODY.appendChild(image);

    await snapshot(0.1);
  });

  it('works with image width border and padding', async () => {
    let image;
    image = createElement(
      'img',
      {
        src: 'assets/100x100-green.png',
        style: {
          'border-radius': '30px',
          border: '10px solid red',
          padding: '10px',
          width: '100px',
          height: '100px',
        },
      },
    );
    BODY.appendChild(image);

    await snapshot(0.1);
  });

  it('should work with percentage of one value', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            borderRadius: '100%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage of one value on element of width and height not equal', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '100px',
          backgroundColor: 'green',
          borderRadius: '100%'
        },
      },
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage of two values', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage border-radius and percentage sizing in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100%',
            height: '100%',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage border-radius and percentage sizing of multiple children in flow layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50%',
            height: '50%',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        }),
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage border-radius and percentage sizing in flex layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100%',
            height: '100%',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage border-radius and percentage sizing of multiple children in flex layout', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '50%',
            height: '50%',
            borderRadius: '100% 50%',
            backgroundColor: 'green',
          }
        }),
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
          }
        }),
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with border and percentage border-radius', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            border: '1px solid black',
            width: '100%',
            height: '100%',
            borderRadius: '100%',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage after element is attached', async (done) => {
    let div;
    let div2;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
          }
        }))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div2.style.borderRadius = '100%';
      await snapshot();
      done();
    });
  });

  it("computed", async (done) => {
    let target;
    target = createElement('div', {
      id: 'target',
      style: {
        'font-size': '40px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(target);

    target.ononscreen = () => {
      test_computed_value('border-radius', '1px');
      test_computed_value('border-radius', '1px 2% 3px 4%');
      test_computed_value(
        'border-radius',
        '5em / 1px 2% 3px 4%',
        '200px / 1px 2% 3px 4%'
      );
      test_computed_value(
        'border-radius',
        '1px 2% 3px 4% / 5em',
        '1px 2% 3px 4% / 200px'
      );

      test_computed_value(
        'border-radius',
        '1px 1px 1px 2% / 1px 2% 1px 2%',
        '1px 1px 1px 2% / 1px 2%'
      );
      test_computed_value(
        'border-radius',
        '1px 1px 1px 1px / 1px 1px 2% 1px',
        '1px / 1px 1px 2%'
      );
      test_computed_value('border-radius', '1px 1px 2% 2%');
      test_computed_value('border-radius', '1px 2% 1px 1px');
      test_computed_value(
        'border-radius',
        '1px 2% 2% 2% / 1px 2% 3px 2%',
        '1px 2% 2% / 1px 2% 3px'
      );

      test_computed_value('border-top-left-radius', 'calc(-0.5em + 20px)', '0px');
      test_computed_value('border-top-right-radius', '20%');
      test_computed_value(
        'border-bottom-right-radius',
        'calc(0.5em + 10px) 40%',
        '30px 40%'
      );
      test_computed_value('border-bottom-left-radius', '50% 60px');

      test_computed_value('border-top-left-radius', '40px 0px', '40px 0px');

      done();
    }
  })
});
