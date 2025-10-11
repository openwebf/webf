describe('CSS1 width', () => {
  it('applies width declarations to elements', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.one {width: 50px;}
.two {width: 50%;}
TABLE {width: 50%;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {width: 50px;}
.two {width: 50%;}
TABLE {width: 50%;}
</pre>
      <hr>
      <img src="assets/resources/oransqr.gif" class="one" alt="[Image]">
      <p>The square above should be fifty pixels wide.</p>
      <img src="assets/resources/oransqr.gif" class="two" alt="[Image]">
      <p>The square above should be half as wide as the image's parent element (either the body or the table cell).</p>
      <p class="two">This paragraph should be half the width of its parent element (either the body or the table, which should itself be half as wide as the body element). This is extra text included to ensure that this will be a fair test of the <code>width</code> property without the need for the user to resize the viewing window.</p>
    `;

    await snapshot();
  });
});
