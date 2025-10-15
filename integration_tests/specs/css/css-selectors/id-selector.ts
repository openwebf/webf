describe('css id selector', () => {
  it('001', async () => {
    const style = document.createElement('style');
    style.textContent = '#div1 { color: green; }';
    const div = document.createElement('div');
    div.id = 'div1';
    div.textContent = '001 green Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('002', async () => {
    const style = document.createElement('style');
    style.textContent = '# div1 { color: green; }';
    const div = document.createElement('div');
    div.id = 'div1';
    div.textContent = '002 black Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('003', async () => {
    const style = document.createElement('style');
    style.textContent = 'div { color: red; } #-div1 { color: green; }';
    const div = document.createElement('div');
    div.id = '-div1';
    div.textContent = '003 green Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('004', async () => {
    const style = document.createElement('style');
    style.textContent = '#1digit { color: red; }';
    const div = document.createElement('div');
    div.id = '1digit';
    div.textContent = '004 black Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('005', async () => {
    const style = document.createElement('style');
    style.textContent = 'div[id=div1] { color: red; } div#div1 { color: green; }';
    const div = document.createElement('div');
    div.id = 'div1';
    div.textContent = '005 green Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('006', async () => {
    const style = document.createElement('style');
    style.textContent = 'div[id=div1] { color: red; } div#div1 { color: green; }';
    const div = document.createElement('div');
    div.id = 'div1';
    div.textContent = '006 green Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });
});
