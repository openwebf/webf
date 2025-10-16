describe('css tag selector', () => {
  it('001', async () => {
    const style = document.createElement('style');
    style.textContent = 'p { color: green; }';
    const p1 = document.createElement('p'); p1.textContent = '001 This sentence must be green.';
    const p2 = document.createElement('p'); p2.textContent = 'This sentence must be green.';
    const p3 = document.createElement('p'); p3.textContent = 'This sentence must be green.';
    const p4 = document.createElement('p'); p4.textContent = 'This sentence must be green.';
    const p5 = document.createElement('p'); p5.textContent = 'This sentence must be green.';
    
    document.head.appendChild(style);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    await snapshot();
  });

  it('002', async () => {
    const style = document.createElement('style');
    style.textContent = 'div, blockquote, p { color: green; }';
    const p = document.createElement('p'); p.textContent = 'Test passes if the "Filler Text" below is green.';
    const blockquote = document.createElement('blockquote'); blockquote.textContent = 'Filler Text';
    const div = document.createElement('div'); div.textContent = ' 002 Filler Text';
    
    document.head.appendChild(style);
    document.body.appendChild(p);
    document.body.appendChild(blockquote);
    document.body.appendChild(div);
    await snapshot();
  });

  it('003', async () => {
    const style = document.createElement('style');
    style.textContent = 'DIV { color: green; }';
    const div = document.createElement('div'); div.textContent = ' 003 Filler Text';
    
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('004', async () => {
    const style = document.createElement('style');
    style.textContent = 'body * { color: green; }';
    const e1 = document.createElement('p'); e1.textContent = 'This text should be green. (element)';
    const e2 = document.createElement('div'); e2.textContent = 'This text should be green. (class)';
    const e3 = document.createElement('div'); e3.textContent = 'This text should be green. (id)';
    const e4 = document.createElement('div'); e4.textContent = 'This text should be green. (child)';
    const e5 = document.createElement('div'); e5.textContent = 'This text should be green. (descendant)';
    const e6 = document.createElement('blockquote'); e6.textContent = 'This text should be green. (sibling)';
    const e7 = document.createElement('div'); e7.textContent = 'This text should be green. (attribute)';
    
    document.head.appendChild(style);
    document.body.appendChild(e1);
    document.body.appendChild(e2);
    document.body.appendChild(e3);
    document.body.appendChild(e4);
    document.body.appendChild(e5);
    document.body.appendChild(e6);
    document.body.appendChild(e7);
    await snapshot();
  });

  it('005', async () => {
    const style = document.createElement('style');
    style.textContent = ' body { color: green; }';
    const p = document.createElement('p'); p.textContent = 'Test passes if all text on this page is green.';
    const div = document.createElement('div'); div.textContent = '005 Filler Text';
    
    document.head.appendChild(style);
    document.body.appendChild(p);
    document.body.appendChild(div);
    await snapshot();
  });

  it('006', async () => {
    const style = document.createElement('style');
    style.textContent = ' * { color: green; }';
    const p = document.createElement('p'); p.textContent = 'Test passes if all text on this page is green.';
    const div = document.createElement('div'); div.textContent = '006 Filler Text';
    
    document.head.appendChild(style);
    document.body.appendChild(p);
    document.body.appendChild(div);
    await snapshot();
  });

  it('007', async () => {
    const style = document.createElement('style');
    style.textContent = ' html, div { color: green; }';
    const p = document.createElement('p'); p.textContent = 'Test passes if all text on this page is green.';
    const div = document.createElement('div'); div.textContent = '007 Filler Text';
    
    document.head.appendChild(style);
    document.body.appendChild(p);
    document.body.appendChild(div);
    await snapshot();
  });
});
