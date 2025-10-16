describe('css child selector', () => {
  it('001', async () => {
    const style = document.createElement('style');
    style.textContent = 'div > h1 { color: green; }';
    const h1 = document.createElement('h1');
    h1.textContent = ' 001 Text should not be green ';

    document.head.appendChild(style);
    document.body.appendChild(h1);
    await snapshot();
  });

  it('002', async () => {
    const style = document.createElement('style');
    style.textContent = 'div > h1 { color: green; }';
    const div = document.createElement('div');
    const h1 = document.createElement('h1');
    h1.textContent = '002 Text should be green ';
    div.appendChild(h1);

    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('003', async () => {
    const style = document.createElement('style');
    style.textContent = 'div > h1 { color: green; }';
    const div = document.createElement('div');
    const blockquote = document.createElement('blockquote');
    const h1 = document.createElement('h1');
    h1.textContent = '003 Text should not be green ';
    blockquote.appendChild(h1);
    div.appendChild(blockquote);

    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('004', async () => {
    const style = document.createElement('style');
    style.textContent = 'div:first-child { color: green; }';
    const div1 = document.createElement('div');
    div1.textContent = '004 Text should be green';
    const div2 = document.createElement('div');
    div2.textContent = 'Text should not be green';
    const p = document.createElement('p');
    p.textContent = 'Text should not be green';

    document.head.appendChild(style);
    document.body.appendChild(div1);
    document.body.appendChild(div2);
    document.body.appendChild(p);
    await snapshot();
  });

  it('005', async () => {
    const style = document.createElement('style');
    style.textContent = 'div:first-child { color: green; }';

    // Reset body contents to match previous JSX structure
    document.body.textContent = '';
    document.body.append('005 ');
    const div1 = document.createElement('div');
    div1.textContent = 'should be green';
    const div2 = document.createElement('div');
    div2.textContent = 'should not be green';
    document.body.appendChild(div1);
    document.body.appendChild(div2);

    document.head.appendChild(style);
    await snapshot();
  });

  it('006', async () => {
    const style = document.createElement('style');
    style.textContent = 'div:fiRsT-cHiLd { color: green; }';
    const div = document.createElement('div');
    div.textContent = '006 should be green';
    document.body.appendChild(div);
    document.head.appendChild(style);
    await snapshot();
  });

  it('007', async () => {
    const style = document.createElement('style');
    style.textContent = 'html { color: red; } :root:first-child { color: green; }';

    // Reset body and add content
    document.body.textContent = '';
    const p = document.createElement('p');
    p.textContent = ' 007 This text should be green.';
    document.body.appendChild(p);

    document.head.appendChild(style);
    await snapshot();
  });

  it('008', async () => {
    const style = document.createElement('style');
    style.textContent = ' :first-child  { color: green; }';
    const div = document.createElement('div');
    div.textContent = '008 Filler Text should be green';
    const p = document.createElement('p');
    p.textContent = 'Filler Text';

    document.head.appendChild(style);
    document.body.appendChild(div);
    document.body.appendChild(p);
    await snapshot();
  });

  it('009', async () => {
    const style = document.createElement('style');
    style.textContent = ':root { color: green; }';
    const p1 = document.createElement('p');
    p1.textContent = '009 Should be green';
    const p2 = document.createElement('p');
    p2.textContent = 'Should be green';
    const p3 = document.createElement('p');
    p3.textContent = 'Should be green';
    const p4 = document.createElement('p');
    p4.textContent = 'Should be green';
    const p5 = document.createElement('p');
    p5.textContent = 'Should be green';

    document.head.appendChild(style);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    await snapshot();
  });

  it('010', async () => {
    const style = document.createElement('style');
    style.textContent = `
        :first-child #a {
            color: green;
          }
          :nth-child(n) #b {
            color: green;
          }
          :first-of-type #c {
            color: green;
          }
          :nth-of-type(1) #d {
            color: green;
          }
          :last-of-type #e {
            color: green;
          }
          :last-child #f {
            color: green;
          }
          :nth-last-child(1) #g {
            color: green;
          }
          :nth-last-of-type(n) #h {
            color: green;
          }
        
          #i {
            color: green;
          }
        
          /* NB: not matching intentionally */
          :nth-last-child(2) #i {
            color: red;
          }
        `;

    document.head.appendChild(style);

    const p1 = document.createElement('p');
    p1.id = 'a';
    p1.textContent = '10 Should be green';
    const p2 = document.createElement('p');
    p2.id = 'b';
    p2.textContent = 'Should be green';
    const p3 = document.createElement('p');
    p3.id = 'c';
    p3.textContent = 'Should be green';
    const p4 = document.createElement('p');
    p4.id = 'd';
    p4.textContent = 'Should be green';
    const p5 = document.createElement('p');
    p5.id = 'e';
    p5.textContent = 'Should be green';
    const p6 = document.createElement('p');
    p6.id = 'f';
    p6.textContent = 'Should be green';
    const p7 = document.createElement('p');
    p7.id = 'g';
    p7.textContent = 'Should be green';
    const p8 = document.createElement('p');
    p8.id = 'h';
    p8.textContent = 'Should be green';
    const p9 = document.createElement('p');
    p9.id = 'i';
    p9.textContent = 'Should be green';
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    document.body.appendChild(p9);
    await snapshot();
  });

  it('011', async () => {
    const style = document.createElement('style');
    style.textContent = `
        :root:first-child #a {
            color: green;
          }
          :root:nth-child(n) #b {
            color: green;
          }
          :root:first-of-type #c {
            color: green;
          }
          :root:nth-of-type(1) #d {
            color: green;
          }
          :root:last-of-type #e {
            color: green;
          }
          :root:last-child #f {
            color: green;
          }
          :root:nth-last-child(1) #g {
            color: green;
          }
          :root:nth-last-of-type(n) #h {
            color: green;
          }
        
          #i {
            color: green;
          }
        
          /* NB: not matching intentionally */
          :root:nth-last-child(2) #i {
            color: red;
          }
        `;

    const p1 = document.createElement('p');
    p1.id = 'a';
    p1.textContent = '11 Should be green';
    const p2 = document.createElement('p');
    p2.id = 'b';
    p2.textContent = 'Should be green';
    const p3 = document.createElement('p');
    p3.id = 'c';
    p3.textContent = 'Should be green';
    const p4 = document.createElement('p');
    p4.id = 'd';
    p4.textContent = 'Should be green';
    const p5 = document.createElement('p');
    p5.id = 'e';
    p5.textContent = 'Should be green';
    const p6 = document.createElement('p');
    p6.id = 'f';
    p6.textContent = 'Should be green';
    const p7 = document.createElement('p');
    p7.id = 'g';
    p7.textContent = 'Should be green';
    const p8 = document.createElement('p');
    p8.id = 'h';
    p8.textContent = 'Should be green';
    const p9 = document.createElement('p');
    p9.id = 'i';
    p9.textContent = 'Should be green';

    document.head.appendChild(style);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    document.body.appendChild(p9);
    await snapshot();
  });

  it('012', async () => {
    const style = document.createElement('style');
    style.textContent = `
        li:only-child {
            color: green;
        }
        `;
    const ul = document.createElement('ul');
    const li = document.createElement('li');
    li.textContent = ' 012 Should be green';
    ul.appendChild(li);

    document.head.appendChild(style);
    document.body.appendChild(ul);
    await snapshot();
  });

  it('013', async () => {
    const style = document.createElement('style');
    style.textContent = `
        li:only-child {
            color: green;
        }
        `;
    const ul = document.createElement('ul');
    const li1 = document.createElement('li');
    li1.textContent = ' 013 Should not be green';
    const li2 = document.createElement('li');
    li2.textContent = ' 013 Should not be green';
    ul.appendChild(li1);
    ul.appendChild(li2);

    document.head.appendChild(style);
    document.body.appendChild(ul);
    await snapshot();
  });

  // error
  it('014', async () => {
    const style = document.createElement('style');
    style.textContent = ':last-child #f { color: green; }';
    const p = document.createElement('p');
    p.textContent = '014';
    const p1 = document.createElement('p');
    p1.id = 'a';
    p1.textContent = 'Should not be green';
    const p2 = document.createElement('p');
    p2.id = 'b';
    p2.textContent = 'Should not be green';
    const p3 = document.createElement('p');
    p3.id = 'c';
    p3.textContent = 'Should not be green';
    const p4 = document.createElement('p');
    p4.id = 'd';
    p4.textContent = 'Should not be green';
    const p5 = document.createElement('p');
    p5.id = 'e';
    p5.textContent = 'Should not be green';
    const p6 = document.createElement('p');
    p6.id = 'f';
    p6.textContent = 'Should be green';
    const p7 = document.createElement('p');
    p7.id = 'g';
    p7.textContent = 'Should not be green';
    const p8 = document.createElement('p');
    p8.id = 'h';
    p8.textContent = 'Should not be green';
    const p9 = document.createElement('p');
    p9.id = 'i';
    p9.textContent = 'Should not be green';

    document.head.appendChild(style);
    document.body.appendChild(p);
    document.body.appendChild(p1);
    document.body.appendChild(p2);
    document.body.appendChild(p3);
    document.body.appendChild(p4);
    document.body.appendChild(p5);
    document.body.appendChild(p6);
    document.body.appendChild(p7);
    document.body.appendChild(p8);
    document.body.appendChild(p9);
    await snapshot();
  });
});
