describe('CSS1 height', () => {
  it('applies height declarations to images', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.one {height: 50px;}
.two {height: 100px;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {height: 50px;}
.two {height: 100px;}

</pre>
      <hr>
      <img src="assets/resources/oransqr.gif" class="one" alt="[Image]">
      <p>The square above should be fifty pixels tall.</p>
      <img src="assets/resources/oransqr.gif" class="two" alt="[Image]">
      <p>The square above should be 100 pixels tall and wide.</p>
      <img src="assets/resources/vblank.gif" class="two" alt="[Image]">
      <p>The rectangular image above should be 100 pixels tall and 30 pixels wide (the original image is 50x15, and the size has been doubled using the <code>height</code> property).</p>
    `;
    await snapshot();
  });
});
