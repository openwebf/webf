describe('css attribute selector', () => {
  it('001', async () => {
    const style = document.createElement('style');
    style.textContent = '[id] { color: green; }';
    const div = document.createElement('div');
    div.id = 'div1';
    div.textContent = '001 should be green';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('002', async () => {
    const style = document.createElement('style');
    style.textContent = '[id=div1] { color: green; }';
    const div = document.createElement('div');
    div.id = 'div1';
    div.textContent = '002 should be green';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('003', async () => {
    const style = document.createElement('style');
    style.textContent = '[class~=est] { color: green; }';
    const div1 = document.createElement('div');
    div1.setAttribute('class', 't estDiv');
    div1.textContent = 'should not be green';
    const div2 = document.createElement('div');
    div2.setAttribute('class', 't est');
    div2.textContent = '003 should be green';
    document.head.appendChild(style);
    document.body.appendChild(div1);
    document.body.appendChild(div2);
    await snapshot();
  });

  it('004', async () => {
    const style = document.createElement('style');
    style.textContent = 'div[CLASS] { color: green; }';
    const div = document.createElement('div');
    div.setAttribute('class', 'div1');
    div.textContent = '004 should be green';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('005', async () => {
    const style = document.createElement('style');
    style.textContent = '[class= "class1"][id = "div1"][class= "class1"][id = "div1"][id = "div1"] { color: green;}';
    const div = document.createElement('div');
    div.setAttribute('class', 'class1');
    div.id = 'div1';
    div.textContent = '005 should be green';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  // error
  it('006', async () => {
    const style = document.createElement('style');
    style.textContent = '[1digit], div { color: green; }';
    const div = document.createElement('div');
    div.textContent = '006 Filler Text';
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('007', async () => {
    const style = document.createElement('style');
    style.textContent = 'div[class^="a"]  { color: green; }';
    const div1 = document.createElement('div');
    div1.setAttribute('class', 'abc');
    div1.textContent = '7 should be green';
    const div2 = document.createElement('div');
    div2.setAttribute('class', 'acb');
    div2.textContent = 'should be green';
    const div3 = document.createElement('div');
    div3.setAttribute('class', 'bac');
    div3.textContent = 'should not be green';
    document.head.appendChild(style);
    document.body.appendChild(div1);
    document.body.appendChild(div2);
    document.body.appendChild(div3);
    await snapshot();
  });

  it('008', async () => {
    const style = document.createElement('style');
    style.textContent = 'div[class^="a"]  { color: green; }';
    const div1 = document.createElement('div');
    div1.setAttribute('class', 'abc');
    div1.textContent = '8 should be green';
    const div2 = document.createElement('div');
    div2.setAttribute('class', 'acb');
    div2.textContent = 'should be green';
    const div3 = document.createElement('div');
    div3.setAttribute('class', 'bac');
    div3.textContent = 'should not be green';
    document.head.appendChild(style);
    document.body.appendChild(div1);
    document.body.appendChild(div2);
    document.body.appendChild(div3);
    await snapshot();
  });

  it('009', async () => {
    const style = document.createElement('style');
    style.textContent = 'div[class$="c"]  { color: green; }';
    const div1 = document.createElement('div');
    div1.setAttribute('class', 'abc');
    div1.textContent = '9 should be green';
    const div2 = document.createElement('div');
    div2.setAttribute('class', 'acb');
    div2.textContent = 'should not be green';
    const div3 = document.createElement('div');
    div3.setAttribute('class', 'bac');
    div3.textContent = 'should be green';
    // Remove existing styles before applying a new one (as in original)
    const existing = Array.from(document.getElementsByTagName('style'));
    for (const oldStyle of existing) {
      if (oldStyle.parentNode === document.head) document.head.removeChild(oldStyle);
    }
    document.head.appendChild(style);
    document.body.appendChild(div1);
    document.body.appendChild(div2);
    document.body.appendChild(div3);
    await snapshot();
  });

  it('010', async () => {
    const style = document.createElement('style');
    style.textContent = 'div[class*="c"] { color: green; }';
    const div1 = document.createElement('div');
    div1.setAttribute('class', 'abc');
    div1.textContent = '10 should be green';
    const div2 = document.createElement('div');
    div2.setAttribute('class', 'acb');
    div2.textContent = 'should be green';
    const div3 = document.createElement('div');
    div3.setAttribute('class', 'bac');
    div3.textContent = 'should be green';
    document.head.appendChild(style);
    document.body.appendChild(div1);
    document.body.appendChild(div2);
    document.body.appendChild(div3);
    await snapshot();
  });

  it('011', async () => {
    const style = document.createElement('style');
    style.textContent = 'div[class|="a"] { color: green; }';
    const div1 = document.createElement('div');
    div1.setAttribute('class', 'a');
    div1.textContent = '11 should be green';
    const div2 = document.createElement('div');
    div2.setAttribute('class', 'a-test');
    div2.textContent = 'should be green';
    const div3 = document.createElement('div');
    div3.setAttribute('class', 'b-test');
    div3.textContent = 'should not be green';
    const div4 = document.createElement('div');
    div4.setAttribute('class', 'c-test');
    div4.textContent = 'should not be green';
    document.head.appendChild(style);
    document.body.appendChild(div1);
    document.body.appendChild(div2);
    document.body.appendChild(div3);
    document.body.appendChild(div4);
    await snapshot();
  });

  it('012', async () => {
    const style = document.createElement('style');
    style.textContent = `
          [d] {
            display: block;
          }
          p {
            display: none;
          }`;
    const p = document.createElement('p');
    p.setAttribute('d', '');
    p.textContent = 'The text should be visible';
    // Note: original test didn't append style to head; preserve that behavior
    document.body.appendChild(p);
    await snapshot();
  });
});
