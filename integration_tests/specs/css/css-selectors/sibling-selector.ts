describe('css sibling selector', () => {
  it('001', async () => {
    const style = document.createElement('style');
    style.textContent = `div { color: red; }
    [class=foo] + div { color: green; }
    [class=foo] + div + div { color: green; }
    [class=foo] + div + div + div { color: green; }
    [class=foo] + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div + div + div + div { color: green; }
    [class=foo] + div + div + div + div + div + div + div + div + div + div { color: green; }`;
    const first = document.createElement('div');
    first.id = 'test';
    first.setAttribute('class', 'foo');
    const p1 = document.createElement('div'); p1.textContent = 'This sentence must be green.';
    const p2 = document.createElement('div'); p2.textContent = 'This sentence must be green.';
    const p3 = document.createElement('div'); p3.textContent = 'This sentence must be green.';
    const p4 = document.createElement('div'); p4.textContent = 'This sentence must be green.';
    const p5 = document.createElement('div'); p5.textContent = 'This sentence must be green.';
    const p6 = document.createElement('div'); p6.textContent = 'This sentence must be green.';
    const p7 = document.createElement('div'); p7.textContent = 'This sentence must be green.';
    const p8 = document.createElement('div'); p8.textContent = 'This sentence must be green.';
    const p9 = document.createElement('div'); p9.textContent = 'This sentence must be green.';
    const p10 = document.createElement('div'); p10.textContent = 'This sentence must be green.';
    
    document.head.appendChild(style);
    document.body.appendChild(first);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    document.body.appendChild(p9);
    document.body.appendChild(p10);
    await snapshot();
  });

  it('002', async () => {
    const style = document.createElement('style');
    style.textContent = 'p + div { color: green; }';
    const p = document.createElement('p');
    p.textContent = 'Test passes if the first line of "Filler Text" below is green, but the second line of "Filler Text" below is black.';
    const div1 = document.createElement('div');
    div1.textContent = '002 Filler Text';
    const div2 = document.createElement('div');
    div2.textContent = 'Filler Text';
    
    document.head.appendChild(style);
    document.body.appendChild(p);
    document.body.appendChild(div1);
    document.body.appendChild(div2);
    await snapshot();
  });

  it('003', async () => {
    const style = document.createElement('style');
    style.textContent = 'p + div { color: green; }';
    document.head.appendChild(style);

    const p = document.createElement('p');
    p.textContent = 'Test passes if the first line of "Filler Text" below is green, but the second line of "Filler Text" below is black.';
    const comment = document.createComment(' This is a comment ');
    const div = document.createElement('div');
    div.textContent = ' 003 Filler Text';
    document.body.textContent = '';
    document.body.appendChild(p);
    document.body.appendChild(comment);
    document.body.appendChild(div);
    await snapshot();
  });

  it('004', async () => {
    const style = document.createElement('style');
    style.textContent = 'p + div { color: green; }';
    document.head.appendChild(style);

    const p = document.createElement('p');
    p.textContent = 'Test passes if the first line of "Filler Text" below is green, but the second line of "Filler Text" below is black.';
    const text = document.createTextNode('Filler Text');
    const div = document.createElement('div');
    div.textContent = ' 004 Filler Text';
    document.body.textContent = '';
    document.body.appendChild(p);
    document.body.appendChild(text);
    document.body.appendChild(div);
    await snapshot();
  });
});

