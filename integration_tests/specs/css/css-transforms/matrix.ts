describe('Transform matrix', () => {
  it('001', async function () {
    const div = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      transform: 'matrix(0,1,1,1,10,10)',
    });
    document.body.appendChild(div);

    // @ts-ignore
    div.ononscreen = async () => {
      const style = window.getComputedStyle(div);
      expect(style['transform']).toEqual('matrix(0, 1, 1, 1, 10, 10)');
      await snapshot();
    }
  })
})
