describe('Transform rotate(0deg) support (issue #647)', () => {
  it('computed transform should be none and not crash', async () => {
    const div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
      transform: 'rotate(0deg)'
    });
    document.body.appendChild(div);

    const style = window.getComputedStyle(div);
    expect(style['transform']).toEqual('none');

    await snapshot();
  });
});

