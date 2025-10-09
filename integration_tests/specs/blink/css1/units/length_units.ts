describe('CSS1 length units', () => {
  it('applies various absolute and relative units', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.zero {margin-left: 0;}
.one {margin-left: 3em;}
.two {margin-left: 3ex;}
.three {margin-left: 36px;}
.four {margin-left: 0.5in;}
.five {margin-left: 1.27cm;}
.six {margin-left: 12.7mm;}
.seven {margin-left: 36pt;}
.eight {margin-left: 3pc;}
.nine {margin-left: +3pc;}
.ten {font-size: 40px; border-left: 1ex solid purple; background-color: aqua;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.zero {margin-left: 0;}
.one {margin-left: 3em;}
.two {margin-left: 3ex;}
.three {margin-left: 36px;}
.four {margin-left: 0.5in;}
.five {margin-left: 1.27cm;}
.six {margin-left: 12.7mm;}
.seven {margin-left: 36pt;}
.eight {margin-left: 3pc;}
.nine {margin-left: +3pc;}
.ten {font-size: 40px; border-left: 1ex solid purple; background-color: aqua;}
</pre>
      <hr>
      <p class="zero">This paragraph has no left margin. The following paragraphs have all been given a left margin and their left (outer) edges should therefore be appropriately shifted to the right of <em>this</em> paragraph's left edge.</p>
      <p class="one">This paragraph should have a left margin of 3em.</p>
      <p class="two">This paragraph should have a left margin of 3ex.</p>
      <p class="three">This paragraph should have a left margin of 36 pixels.</p>
      <p class="four">This paragraph should have a left margin of half an inch.</p>
      <p class="five">This paragraph should have a left margin of 1.27cm.</p>
      <p class="six">This paragraph should have a left margin of 12.7mm.</p>
      <p class="seven">This paragraph should have a left margin of 36 points.</p>
      <p class="eight">This paragraph should have a left margin of 3 picas.</p>
      <p class="nine">This paragraph should have a left margin of 3 picas (the plus sign should make no difference).</p>
      <p class="ten">This element has a <code>font-size</code> of <code>40px</code> and a <code>border-left</code> of <code>1ex solid purple</code>. This should make the left border the same number of pixels as the lower-case x in this element's font, as well as solid purple.</p>
    `;

    await snapshot();

    window.scroll(0, 500);

    await waitForFrame();

    await snapshot();
  });
});
