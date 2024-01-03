describe('Transition property', () => {
  it('backgroundColor', async (done) => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
      position: 'absolute',
      padding: '30px',
      transition: 'all 1s linear',
    });
    container1.appendChild(document.createTextNode('DIV'));
    await snapshot();

    const style = window.getComputedStyle(container1);
    expect(style['transition-property']).toEqual('all');
    expect(style['transition-delay']).toEqual('0s');
    expect(style['transition-duration']).toEqual('1s');
    expect(style['transition-timing-function']).toEqual('linear');
    container1.addEventListener('transitionend', async () => {
      await snapshot();
      done();
    });

    requestAnimationFrame(() => {
      setElementStyle(container1, {
        backgroundColor: 'red',
      });
    });
  });
  it('should works with property value is transform: none  ', async () => {
    let container;
    const wrapper = createElement('div', {
      style: {
        position: 'relative',
        margin: '0 auto',
        width: '200px',
        height: '200px',
        border: '1px solid #000'
      }
    }, [
      container = createElement('div', {
        style: {
          position: 'absolute',
          background: 'red',
          width: '50px',
          height: '50px',
          right: '100%',
          transform: 'translatex(100%)',
          transitionDuration: '300ms',
          transitionProperty: 'right,transform,width,height,top'
        }
      })
    ]);
    document.body.appendChild(wrapper);

    await snapshot();
    container.style.right = '0';
    container.style.transform = 'none';
    await sleep(1);
    await snapshot();
    container.style.right = '100%';
    container.style.transform = 'translatex(100%)';
    await sleep(1);
    await snapshot();
  });

  it('should works when transition property are relative to other animation property', async () => {
    let container;
    const wrapper = createElement('div', {
      style: {
        position: 'relative',
        margin: '0 auto',
        width: '200px',
        height: '200px',
        border: '1px solid #000'
      }
    }, [
      container = createElement('div', {
        style: {
          position: 'absolute',
          background: 'red',
          width: '50px',
          height: '50px',
          right: '100%',
          transform: 'translatex(100%)',
          transitionDuration: '300ms',
          transitionProperty: 'right,transform,width,height,top'
        }
      })
    ]);
    document.body.appendChild(wrapper);

    await snapshot();
    container.style.right = '0';
    container.style.transform = 'none';
    container.style.width = '80px';
    await sleep(1);
    await snapshot();
    container.style.right = '100%';
    container.style.width = '60px';
    container.style.transform = 'translatex(100%)';
    await sleep(1);
    await snapshot();
  });
});
