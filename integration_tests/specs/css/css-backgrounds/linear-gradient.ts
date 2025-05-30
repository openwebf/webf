describe('Background linear-gradient', () => {
  it('linear-gradient', async () => {
    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      width: '200px',
      height: '100px',
      backgroundImage:
      'linear-gradient(to left, #333, #333 50%, #eee 75%, #333 75%)',
    });

    append(BODY, div1);
    await snapshot(div1);
  });

  it('linear-gradient with many right brackets', async () => {
    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      width: '200px',
      height: '100px',
      backgroundImage: 'linear-gradient(to right, rgba(35, 35, 35, 0.8), rgba(35, 35, 35, 0.1))'
    });

    append(BODY, div1);
    await snapshot(div1);
  });


  it('linear-gradient and remove', async (done) => {
    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      width: '200px',
      height: '100px',
      backgroundImage:
      'linear-gradient(to left, #333, #333 50%, #eee 75%, #333 75%)',
    });

    append(BODY, div1);
    await snapshot(div1);
    requestAnimationFrame(async () => {
      div1.style.backgroundImage = '';
      await snapshot(div1);
      done();
    });
  });

  it('conic-gradient', async () => {
    var div2 = document.createElement('div');
    Object.assign(div2.style, {
      width: '200px',
      height: '200px',
      backgroundImage:
      'conic-gradient(from 0.25turn at 50% 30%,red 20deg, orange 130deg, yellow 90deg, green 180deg, blue 270deg)',
    });

    append(BODY, div2);
    await snapshot(div2);
  });

  xit('radial-gradient', async (done) => {
    var div3 = document.createElement('div');
    Object.assign(div3.style, {
      width: '200px',
      height: '200px',
      backgroundImage: 'radial-gradient(circle at 50% 50%, red 0%, yellow 20%, blue 80%)',
    });

    append(BODY, div3);
    requestAnimationFrame(async () => {
      await snapshot(div3);
      done();
    });
  });

  it('linear-gradient-rotate', async (done) => {
    var div4 = document.createElement('div');
    Object.assign(div4.style, {
      width: '200px',
      height: '100px',
      backgroundImage:
      'linear-gradient(135deg, red, red 10%, blue 75%, yellow 75%)',
    });
    append(BODY, div4);
    requestAnimationFrame(async () => {
      await snapshot(div4);
      done();
    });
  });

  it("linear-gradient to right with color stop of px", async (done) => {

    let flexbox;

    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to right, blue 0px, blue 40px, red 40px, red 120px, orange 120px, orange 200px)',
          display: 'flex',
          'justify-content': 'center',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it("linear-gradient to right with color stop of px and width not set", async (done) => {

    let flexbox;

    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to right, blue 0px, blue 40px, red 40px, red 120px, orange 120px, orange 200px)',
          display: 'flex',
          'justify-content': 'center',
          height: '100px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it("linear-gradient to bottom with color stop of px", async (done) => {

    let flexbox;

    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to bottom, blue 0px, blue 40px, red 40px, red 120px, orange 120px, orange 200px)',
          display: 'flex',
          'justify-content': 'center',
          height: '200px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it("linear-gradient to bottom with color stop of px and height not set", async (done) => {

    let flexbox;
    let container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '300px',
        }
      }
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to bottom, blue 0px, blue 40px, red 40px, red 120px, orange 120px, orange 200px)',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );

    container.appendChild(flexbox);
    BODY.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it("linear-gradient to right with color stop not set", async (done) => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
          'linear-gradient(to right, blue, blue, red, red, orange, orange)',
          display: 'flex',
          'justify-content': 'center',
          height: '100px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it("linear-gradient to bottom with color stop not set", async (done) => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          background:
            'linear-gradient(to bottom, blue, blue, red, red, orange, orange)',
          display: 'flex',
          'justify-content': 'center',
          height: '200px',
          width: '300px',
          'box-sizing': 'border-box',
        },
      },
    );
    BODY.appendChild(flexbox);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it("linear-gradient color update", async (done) => {
    // Test for the gradient color update issue fix
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          background: 'linear-gradient(0.25turn, #DADADA00, #DADADA, #DADADA00)'
        }
      }
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      // Update the gradient colors - this should trigger the fixed cache invalidation
      div.style.background = 'linear-gradient(0.25turn, #6E758300, #4A4B4B, #6E758300)';

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });

  it("linear-gradient direction update", async (done) => {
    // Test gradient direction change with cache invalidation
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          background: 'linear-gradient(to right, red, blue)'
        }
      }
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      // Change gradient direction - should invalidate cache
      div.style.background = 'linear-gradient(to bottom, red, blue)';

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });

  it("linear-gradient stops update", async (done) => {
    // Test gradient color stops change with cache invalidation
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          background: 'linear-gradient(45deg, red 0%, blue 100%)'
        }
      }
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      // Change gradient stops - should invalidate cache
      div.style.background = 'linear-gradient(45deg, red 0%, green 50%, blue 100%)';

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });

  it("linear-gradient size change with same gradient", async (done) => {
    // Test element size change with same gradient (rect change)
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          background: 'linear-gradient(45deg, red, blue)'
        }
      }
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      // Change element size - should invalidate cache due to rect change
      div.style.width = '150px';
      div.style.height = '150px';

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });

  it("linear-gradient multiple rapid updates", async (done) => {
    // Test rapid gradient changes to ensure cache works correctly
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          background: 'linear-gradient(to right, red, blue)'
        }
      }
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      // First update
      div.style.background = 'linear-gradient(to right, green, yellow)';

      requestAnimationFrame(async () => {
        await snapshot();

        requestAnimationFrame(async () => {
          // Second rapid update
          div.style.background = 'linear-gradient(to right, purple, orange)';

          requestAnimationFrame(async () => {
            await snapshot();
            done();
          });
        });
      });
    });
  });

  it("linear-gradient with background color change", async (done) => {
    // Test gradient with background color fallback
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          backgroundColor: 'red',
          background: 'linear-gradient(45deg, rgba(0,0,255,0.5), rgba(0,255,0,0.5))'
        }
      }
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      // Change both background color and gradient
      div.style.backgroundColor = 'yellow';
      div.style.background = 'linear-gradient(45deg, rgba(255,0,0,0.5), rgba(0,0,255,0.5))';

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });

  it("radial-gradient color update", async (done) => {
    // Test radial gradient color updates (same cache logic applies)
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          background: 'radial-gradient(circle, red, blue)'
        }
      }
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      // Update radial gradient colors
      div.style.background = 'radial-gradient(circle, green, yellow)';

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });

  it("conic-gradient color update", async (done) => {
    // Test conic gradient color updates
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          background: 'conic-gradient(from 0deg, red, blue, red)'
        }
      }
    );
    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      // Update conic gradient colors
      div.style.background = 'conic-gradient(from 0deg, green, yellow, green)';

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });
});
