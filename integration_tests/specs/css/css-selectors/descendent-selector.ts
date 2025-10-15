describe('css descendent selector', () => {
  it('001', async () => {
    const style = document.createElement('style');
    style.textContent = 'div em { color: red; }';
    const div = document.createElement('div');
    div.id = 'div1';
    div.textContent = ' 001 Filler Text ';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('002', async () => {
    const style = document.createElement('style');
    style.textContent = 'div em { color: red; }';
    const div = document.createElement('div');
    const em = document.createElement('em');
    em.textContent = '002 Filler Text';
    div.appendChild(em);
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('003', async () => {
    const style = document.createElement('style');
    style.textContent = 'div em { color: red; }';
    const div = document.createElement('div');
    const span = document.createElement('span');
    const em = document.createElement('em');
    em.textContent = '003 Filler Text';
    span.appendChild(em);
    div.appendChild(span);
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('004', async () => {
    const style = document.createElement('style');
    style.textContent = 'p em { color: red; }';
    const div = document.createElement('div');
    const em = document.createElement('em');
    em.textContent = '004 Filler Text';
    div.appendChild(em);
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('005', async () => {
    const style = document.createElement('style');
    style.textContent = 'div * em { color: red; }';
    const div = document.createElement('div');
    div.textContent = '005 Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('006', async () => {
    const style = document.createElement('style');
    style.textContent = 'div * em { color: red; }';
    const div = document.createElement('div');
    const em = document.createElement('em');
    em.textContent = '006 Filler Text';
    div.appendChild(em);
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('007', async () => {
    const style = document.createElement('style');
    style.textContent = 'div * em { color: red; }';
    const div = document.createElement('div');
    const span = document.createElement('span');
    const em = document.createElement('em');
    em.textContent = '007 Filler Text';
    span.appendChild(em);
    div.appendChild(span);
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('008', async () => {
    const style = document.createElement('style');
    style.textContent = 'div em[id] { color: red; }';
    const div = document.createElement('div');
    const span = document.createElement('span');
    const em = document.createElement('em');
    em.id = 'em1';
    em.textContent = ' 008 Filler Text ';
    span.appendChild(em);
    div.appendChild(span);
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('009', async () => {
    const style = document.createElement('style');
    style.textContent = '#div em { color: red; }';
    const div = document.createElement('div');
    div.id = 'div';
    const em = document.createElement('em');
    em.textContent = ' 009 Filler Text ';
    div.appendChild(em);
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });  
  it('010', async () => {
    const style = document.createElement('style');
    style.textContent = `#div
                          em { color: red; }`;
    const div = document.createElement('div');
    div.id = 'div';
    const em = document.createElement('em');
    em.textContent = '010 Filler Text ';
    div.appendChild(em);
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });
  it('011', async () => {
    const style = document.createElement('style');
    style.textContent = `.div.a .text { color: red; }`;
    const root = document.createElement('div');
    root.setAttribute('class', 'div a');
    const inner = document.createElement('div');
    inner.setAttribute('class', 'text');
    inner.textContent = '011 Filler Text ';
    root.appendChild(inner);
    document.head.appendChild(style);
    document.body.appendChild(root);
    await snapshot();
  });
});
