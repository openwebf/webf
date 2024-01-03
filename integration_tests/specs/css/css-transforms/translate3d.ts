describe('Transform translate3d', () => {
  it('001', async () => {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'translate3d(100px, 100px, 100px)',
      })
    );

    await snapshot();
  });

  it('should work with percentage with x', async () => {
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
            transform: 'translate3d(50%, 0, 0)',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage with y', async () => {
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
            transform: 'translate3d(0, 50%, 0)',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage with x and y', async () => {
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
            transform: 'translate3d(50%, 50%, 0)',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage and size are not defined when dynamic created', async (done) => {
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
            transform: 'translate3d(50%, 50%, 0)',
            backgroundColor: 'green',
          }
        }, [
          createText('TEXT TEXT')
        ])
      ]
    );
    requestAnimationFrame(async () => {
      document.body.appendChild(div);
      await snapshot();
      done();
    });
  });

  it('should works when transform 3d animations', async (done) => {
    const stylesheet = `@keyframes jump-scaleY {
        0% {
          transform:
              perspective(1000px)
              rotateX(24deg)
              rotateY(-45deg)
              rotateZ(4deg);
        }

        80%,
        100% {
          transform:
              perspective(1000px)
              rotateX(-24deg)
              rotateY(45deg)
              rotateZ(-4deg);
        }
      }`;
    const styleEle = document.createElement('style');
    styleEle.textContent = stylesheet;
    document.head.appendChild(styleEle);

    let div;

    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '100px',
          position: 'absolute',
          left: 0,
          right: 0,
          margin: 'auto',
          background: 'linear-gradient(60deg, red, yellow, red, yellow, red)',
          boxShadow: '24px 16px 64px 0 rgba(0, 0, 0, 0.08)',
          borderRadius: '2px',
          animation: '0.5s ease 0s 1 reverse both running jump-scaleY'
        }
      }
    );
    document.body.appendChild(div);

    div.addEventListener('animationend', async () => {
      await snapshot();
      done();
    });
    await snapshot();
  });
});
