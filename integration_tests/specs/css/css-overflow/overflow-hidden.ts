describe('hidden', () => {
  it('should works with basic', async () => {
    let image;
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "hidden",
      }
    }, [
      (image = createElement('img', {
          src: 'assets/100x100-green.png',
      }))
    ]);

    document.body.appendChild(container);

    await snapshot(0.1);
  });

  it('should works with children of appear event', async () => {
    let image;
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "hidden",
      }
    }, [
      (image = createElement('img', {
          src: 'assets/100x100-green.png',
      }))
    ]);

    image.addEventListener('appear', function onAppear() {});

    document.body.appendChild(container);

    await snapshot(0.1);
  });

  it('should scroll with overflow scroll', async (done) => {
    let p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a text for test scroll logic to uset.`),
        createText(`There should be a text for test scroll logic to uset.`),
        createText(`There should be a text for test scroll logic to uset.`),
        createText(`There should be a text for test scroll logic to uset.`),
        createText(`There should be a text for test scroll logic to uset.`),
        createText(`There should be a text for test scroll logic to uset.`)]

    );
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "scroll",
      }
    }, [
      p
    ]);
    document.body.appendChild(container);
    await snapshot();
    requestAnimationFrame(async () => {
      await simulateSwipe(0, 0, 0, 60, 1);
      await snapshot();
      done();
    });
  });

  it('should can not scroll with overflow hidden', async (done) => {
    let p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a text for test scroll logic to use`)]

    );
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "hidden",
      }
    }, [
      p
    ]);
    document.body.appendChild(container);
    requestAnimationFrame(async () => {
      await simulateSwipe(0, 60, 50, 0, 0.5);
      await snapshot(0.6);
      done();
    });
  });

  it('should scroll with overflow change scroll', async (done) => {
    let p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a text for test scroll logic to use`)]
    );
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "hidden",
      }
    }, [
      p
    ]);
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      container.style.overflow = 'scroll';
      await simulateSwipe(0, 60, 50, 0, 0.5);
      await snapshot(1);
      done();
    });
  });

  it('should can not scroll with overflow change hidden', async (done) => {
    let p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`There should be a text for test scroll logic to use`)]
    );
    let container = createElement('div', {
      style: {
        width: '80px',
        height: '80px',
        borderRadius: '10px',
        overflow: "scroll",
      }
    }, [
      p
    ]);
    document.body.appendChild(container);
    requestAnimationFrame(async () => {
      container.style.overflow = 'hidden';
      await simulateSwipe(0, 60, 50, 0, 0.5);
      await snapshot(0.6);
      done();
    });
  });
});
