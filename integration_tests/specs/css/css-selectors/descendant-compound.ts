describe('css descendant compound selectors', () => {
  it('matches descendant when ancestor is compound (class + attribute)', async () => {
    const style = document.createElement('style');
    style.textContent = `
      h1[_ngcontent-abc] { color: red; margin: 0; }
      .content[_ngcontent-abc] h1[_ngcontent-abc] { color: green; margin-top: 20px; }
    `;

    const root = document.createElement('div');
    root.setAttribute('class', 'content');
    root.setAttribute('_ngcontent-abc', '');
    const left = document.createElement('div');
    left.setAttribute('class', 'left-side');
    left.setAttribute('_ngcontent-abc', '');
    const h1 = document.createElement('h1');
    h1.id = 't';
    h1.setAttribute('_ngcontent-abc', '');
    h1.textContent = 'Hello';
    left.appendChild(h1);
    root.appendChild(left);

    document.head.appendChild(style);
    document.body.appendChild(root);
    await snapshot();
  });

  it('matches descendant with compound ancestor using plain data attributes', async () => {
    const style = document.createElement('style');
    style.textContent = `
      p[data-scope] { color: red; }
      [data-scope] .inner[data-scope] p[data-scope] { color: blue; }
    `;

    const root = document.createElement('div');
    root.setAttribute('data-scope', '');
    const inner = document.createElement('div');
    inner.setAttribute('class', 'inner');
    inner.setAttribute('data-scope', '');
    const pInner = document.createElement('p');
    pInner.id = 'p';
    pInner.setAttribute('data-scope', '');
    pInner.textContent = 'Blue text';
    inner.appendChild(pInner);
    const pShallow = document.createElement('p');
    pShallow.setAttribute('data-scope', '');
    pShallow.textContent = 'Should remain red (shallow)';
    root.appendChild(inner);
    root.appendChild(pShallow);

    document.head.appendChild(style);
    document.body.appendChild(root);
    await snapshot();
  });
});
