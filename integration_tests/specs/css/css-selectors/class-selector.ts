describe('css class selector', () => {
  it('style added', async () => {
    const style = document.createElement('style');
    style.textContent = `.red { color: red; }`;
    const div = document.createElement('div');
    div.setAttribute('class', 'red');
    div.textContent = 'It should red color';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('style removed', async () => {
    const style = document.createElement('style');
    style.textContent = `.red { color: red; }`;
    const div = document.createElement('div');
    div.setAttribute('class', 'red');
    div.textContent = 'It should from red to black color';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
    document.head.removeChild(style);
    await snapshot();
  });

  it('style removed later', async (done) => {
    const style = document.createElement('style');
    style.textContent = `.blue { color: blue; }`;
    const div = document.createElement('div');
    div.setAttribute('class', 'blue');
    div.textContent = 'It should from blue to black color';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
    requestAnimationFrame(async () => {
      document.head.removeChild(style);
      await snapshot();
      done();
    });
  });

  it('two style added', async () => {
    const style1 = document.createElement('style');
    style1.textContent = `.txt { color: red; }`;
    const style2 = document.createElement('style');
    style2.textContent = `.txt { font-size: 20px; }`;
    const div = document.createElement('div');
    div.setAttribute('class', 'txt');
    div.textContent = 'It should red color and 20px';
    document.head.appendChild(style1);
    document.body.appendChild(div);
    document.head.appendChild(style2);

    await snapshot();
  });

  it('one style removed', async () => {
    const style1 = document.createElement('style');
    style1.textContent = `.txt { color: red; }`;
    const style2 = document.createElement('style');
    style2.textContent = `.txt { font-size: 20px; }`;
    const div = document.createElement('div');
    div.setAttribute('class', 'txt');
    div.textContent = 'It should black color and 20px';
    document.head.appendChild(style1);
    document.body.appendChild(div);
    document.head.appendChild(style2);
    document.head.removeChild(style1);

    await snapshot();
  });

  it('one inline style removed', async () => {
    const style1 = document.createElement('style');
    style1.textContent = `.txt { color: red; }`;
    const style2 = document.createElement('style');
    style2.textContent = `.txt { font-size: 20px; }`;
    const div = document.createElement('div');
    div.setAttribute('class', 'txt');
    div.textContent = 'It should from yellow to red and 20px to 16px';
    div.style.color = 'yellow';
    document.head.appendChild(style1);
    document.head.appendChild(style2);
    document.body.appendChild(div);
    await snapshot();
    div.style.removeProperty('color');
    await snapshot();
    document.head.removeChild(style2);
    await snapshot();
  });

  it('001', async () => {
    const style = document.createElement('style');
    style.textContent = 'div.div1 { color: red; }';
    const div = document.createElement('div');
    div.setAttribute('class', 'div11');
    div.textContent = '001 Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('002', async () => {
    const style = document.createElement('style');
    style.textContent = 'div.div1 { color: red; }';
    const div = document.createElement('div');
    div.setAttribute('class', 'div1');
    div.textContent = '002 Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('003', async () => {
    const style = document.createElement('style');
    style.textContent = '.div1 { color: red; }';
    const div = document.createElement('div');
    div.setAttribute('class', 'div1');
    div.textContent = '003 Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('004', async () => {
    const style = document.createElement('style');
    style.textContent = 'div.bar.foo.bat { color: red; }';
    const div = document.createElement('div');
    div.setAttribute('class', 'foo bar bat');
    div.textContent = ' 004 Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();   
  });

  it('005', async () => {
    const style = document.createElement('style');
    style.textContent = '.teST { color: green; } .TEst { background: red; color: yellow; }';
    const p = document.createElement('p');
    p.setAttribute('class', 'teST');
    p.textContent = ' 005 This text should be green.';
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });

  it('006', async () => {
    const style = document.createElement('style');
    style.textContent = 'p { background: green; color: white; } .fail.test { background: red; color: yellow; }';
    const p = document.createElement('p');
    p.setAttribute('class', 'pass test');
    p.textContent = ' 006 This should have a green background.';
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });

  it('007', async () => {
    const style = document.createElement('style');
    style.textContent = 'p { background: red; color: yellow; } .pass.test { background: green; color: white; }';
    const p = document.createElement('p');
    p.setAttribute('class', 'pass test');
    p.textContent = ' 007 This should have a green background.';
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });

  it('008', async () => {
    const style = document.createElement('style');
    style.textContent = 'p { background: red; color: yellow; } .pass { background: green; color: white; }';
    const p = document.createElement('p');
    p.setAttribute('class', 'pass test');
    p.textContent = ' 008 This should have a green background.';
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });

  it('009', async () => {
    const style = document.createElement('style');
    style.textContent = 'p { background: red; color: yellow; } .test { background: green; color: white; }';
    const p1 = document.createElement('p');
    p1.setAttribute('class', 'test line');
    p1.textContent = ' This line should be green.';
    const p2 = document.createElement('p');
    p2.setAttribute('class', 'line test');
    p2.textContent = ' This line should be green.';
    const p3 = document.createElement('p');
    p3.setAttribute('class', ' test line');
    p3.textContent = ' This line should be green.';
    const p4 = document.createElement('p');
    p4.setAttribute('class', ' line test');
    p4.textContent = ' This line should be green.';
    const p5 = document.createElement('p');
    p5.setAttribute('class', 'test line ');
    p5.textContent = ' This line should be green.';
    const p6 = document.createElement('p');
    p6.setAttribute('class', 'line test ');
    p6.textContent = ' This line should be green.';
    const p7 = document.createElement('p');
    p7.setAttribute('class', ' test line ');
    p7.textContent = ' This line should be green.';
    const p8 = document.createElement('p');
    p8.setAttribute('class', ' line test ');
    p8.textContent = ' This line should be green.';
    document.head.appendChild(style);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    await snapshot();
  });

  it('010', async () => {
    const style = document.createElement('style');
    style.textContent = `.rule1 { background: red; color: yellow; } .rule2 { background: green; color: white; }`;
    const p = document.createElement('p');
    p.setAttribute('class', 'rule2 rule1');
    p.textContent = ' 010 This should have a green background.';
    document.head.appendChild(style);
    document.body.appendChild(p);
    await snapshot();   
  });
});
