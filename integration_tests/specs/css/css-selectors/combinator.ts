describe('css combinator selector', () => {
  it('001', async () => {
    const style = document.createElement('style');
    style.textContent = '#div1 > p { color: green; }';
    const div = document.createElement('div');
    div.id = 'div1';
    const p = document.createElement('p');
    p.textContent = ' 001 Filler Text ';
    div.appendChild(p);
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('002', async () => {
    const style = document.createElement('style');
    style.textContent = '#div1 + p { color: green; }';
    const div = document.createElement('div');
    div.id = 'div1';
    const p = document.createElement('p');
    p.textContent = '002 Filler Text ';
    document.head.appendChild(style);
    document.body.appendChild(div);
    document.body.appendChild(p);
    await snapshot();
  });  
  it('003', async () => {
    const style = document.createElement('style');
    style.textContent = `
          #div1
          +
          p
      {
          color: green;
      }`;
    const div = document.createElement('div');
    div.id = 'div1';
    const p = document.createElement('p');
    p.textContent = '003 Filler Text ';
    document.head.appendChild(style);
    document.body.appendChild(div);
    document.body.appendChild(p);
    await snapshot();
  });
});  
