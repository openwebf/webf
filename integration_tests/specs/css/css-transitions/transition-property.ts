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

});
