describe('display', () => {
  it('001', async () => {
    let divStyle = {
      display: 'inline',
    };
    let element = createElementWithStyle('div', {}, [
      createElementWithStyle('div', divStyle, createText('Filter text')),
      createElementWithStyle('div', divStyle, createText('Filter text')),
    ]);
    append(BODY, element);
    await snapshot();
  });

  it('002', async () => {
    let divStyle = {
      display: 'block',
    };
    let element = createElementWithStyle('div', {}, [
      createElementWithStyle('div', divStyle, createText('Filter text')),
      createElementWithStyle('div', divStyle, createText('Filter text')),
    ]);
    append(BODY, element);
    await snapshot();
  });
  it('005', async () => {
    let divdivStyle = {
      display: 'inline-block',
    };
    let element = createElementWithStyle('div', {}, [
      createText('Filter text'),
      createElementWithStyle('div', divdivStyle, createText('Filter text')),
    ]);
    append(BODY, element);
    await snapshot();
  });
  it('016', async () => {
    let divStyle = {
      color: 'red',
      display: 'none',
    };
    let element = createElementWithStyle('div', divStyle, createText('FAIL'));
    append(BODY, element);
    await snapshot();
  });
  it('applies-to-001', async () => {
    let spanStyle = {
      display: 'inline',
    };
    let element = createElementWithStyle('div', {}, [
      createText('Filter text'),
      createElementWithStyle('span', spanStyle, createText('Filter Text')),
      createText('Filter text'),
    ]);
    append(BODY, element);
    await snapshot();
  });
  it('none-001', async () => {
    let divStyle = {
      backgroundColor: 'red',
      display: 'none',
      position: 'absolute',
    };
    let element = createElementWithStyle('div', divStyle, createText('Filter Text'));
    append(BODY, element);
    await snapshot();
  });
  it('none-002', async () => {
    let divStyle = {
      backgroundColor: 'red',
      display: 'none',
      position: 'fixed',
    };
    let element = createElementWithStyle('div', divStyle, createText('Filter Text'));
    append(BODY, element);
    await snapshot();
  });

  it('should work with value change to empty string', async (done) => {
    let div;
    div = createElement(
    'div',
      {
        style: {
          display: 'flex',
          width: '100px',
          height: '100px',
          background: 'yellow',
        },
      },
      [
        createElement('div', {
          style: {
            width: '200px',
            height: '200px',
            backgroundColor: 'green'
          }
        })
      ]
    );

    document.body.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
        div.style.display = '';
        await snapshot();
        done();
    });
  });

  it('should work with toggle replaced element', async (done) => {
    let img = document.createElement('img');
    img.src = 'assets/cat.png';
    img.onload = async () => {
      await snapshot();
      img.style.display = 'none';
      await snapshot();
      img.style.display = 'block';
      await snapshot();
      done();
    };
    document.body.appendChild(img);
  });

  it('should work with scrollable content', async (done) => {
    let container = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        overflow: 'auto'
      }
    }, [
      createElement('p', {}, [
        createText(' 11111111111111111')
      ]),
      createElement('p', {}, [
        createText(' 222222222222222222222222')
      ]),
      createElement('p', {}, [
        createText(' 333333333333333333333333')
      ]),
      createElement('p', {}, [
        createText(' 444444444444444444444444444444')
      ]),
      createElement('p', {}, [
        createText(' 55555555555555555555555555555555555')
      ]),
      createElement('p', {}, [
        createText(' 6666666666666666666666666')
      ]),
    ]);

    requestAnimationFrame(() => {
      container.style.display = 'none';
      requestAnimationFrame(async () => {
        container.style.display = 'block';
        await snapshot();
        await simulateSwipe(0, 0, 30, 30, 0.1);
        await snapshot();
        done();
      });
    });

    document.body.appendChild(container);
  });

  it('should work with listview', async (done) => {
    let container = createElement('webf-listview', {
      style: {
        width: '100px',
        height: '100px'
      }
    }, [
      createElement('p', {}, [
        createText(' 11111111111111111')
      ]),
      createElement('p', {}, [
        createText(' 222222222222222222222222')
      ]),
      createElement('p', {}, [
        createText(' 333333333333333333333333')
      ]),
      createElement('p', {}, [
        createText(' 444444444444444444444444444444')
      ]),
      createElement('p', {}, [
        createText(' 55555555555555555555555555555555555')
      ]),
      createElement('p', {}, [
        createText(' 6666666666666666666666666')
      ]),
    ]);

    requestAnimationFrame(async () => {
      container.style.display = 'none';
      await snapshot();
      requestAnimationFrame(async () => {
        container.style.display = 'block';
        await snapshot();
        await simulateSwipe(0, 0, 30, 30, 0.1);
        await snapshot();
        done();
      });
    });

    document.body.appendChild(container);
  });

  it('should work when previous sibiling is positioned element', async (done) => {
    let positioned = createElement('div', {
      style: {
        'position': 'absolute',
        'background': 'red'
      }
    }, [
      createText('Click Me')
    ]);
    let showup = createElement('div', {
      style: {
        marginTop: '30px',
        display: 'none'
      }
    }, [
      createText('Show!')
    ]);

    positioned.onclick = async () => {
      showup.style.display = 'block';

      await snapshot();
      done();
    };

    document.body.appendChild(positioned);
    document.body.appendChild(showup);

    await snapshot();

    positioned.click();
  });

  it('should works when reattach display none to dom tree in middle tree', async () => {
    let one, two, three;
    let container = createElement('div', {}, [
      one = createElement('div', {
        style: {
          display: 'block'
        }
      }, [
        createText('One')
      ]),
      createElement('div', {
        style: {
          display: 'none'
        }
      }),
      createElement('div', {
        style: {
          display: 'none'
        }
      }),
      createElement('div', {
        style: {
          display: 'none'
        }
      }),
      two = createElement('div', {
        style: {
          display: 'none'
        },
      }, [
        createText('Two')
      ]),
      three = createElement('div', {
        style: {
          style: 'block'
        }
      }, [
        createText('Three')
      ])
    ]);
    BODY.append(container);

    await snapshot();

    two.style.display = 'block';

    await snapshot();
  });
});
