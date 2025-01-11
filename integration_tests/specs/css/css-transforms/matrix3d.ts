describe('Transform matrix3d', function () {
  it('001', async () => {
    const div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      marginTop: '10px',
      backgroundColor: 'red',
      transform: 'matrix3d(0,1,1,1,10,10,1,0,0,1,1,1,1,1,0)',
    });
    document.body.appendChild(div);
    const style = window.getComputedStyle(div);
    expect(style['transform']).toEqual('none');
    // @ts-ignore
    const style_async = await window.getComputedStyle_async(div);
    expect(style['transform']).toEqual('none');
    await snapshot();
  })
})
