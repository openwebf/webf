describe('Transform rotate', function () {
  it('001', async () => {
    const div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      transform: 'rotate(5deg)',
    });
    document.body.appendChild(div);
    const style = window.getComputedStyle(div);
    expect(style['transform']).toEqual(
      'matrix(0.996195, 0.087156, -0.087156, 0.996195, 0, 0)',
    );
    await snapshot();
  })
})
