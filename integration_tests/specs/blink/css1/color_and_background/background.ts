describe('CSS1 background shorthand', () => {
  it('applies shorthand background declarations', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
BODY {background: green url(assets/resources/oransqr.gif) repeat-x center top fixed;}
.one {background: lime url(assets/resources/oransqr.gif) repeat-y 100% 0%;}
.two {background: lime url(assets/resources/oransqr.gif) repeat-y center top;}
.three {background: lime url(assets/resources/oransqr.gif) repeat-x left top;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>BODY {background: green url(assets/resources/oransqr.gif) repeat-x center top fixed;}
.one {background: lime url(assets/resources/oransqr.gif) repeat-y 100% 0%;}
.two {background: lime url(assets/resources/oransqr.gif) repeat-y center top;}
.three {background: lime url(assets/resources/oransqr.gif) repeat-x left top;}
</pre>
      <hr>
      <p>This document should have a green background with an orange strip running across the entire top of the page, since <code>repeat-x</code> indicates tiling in both directions of the x-axis. Furthermore, the strip should be fixed in place. I'll have to add extra text at the end of this page to make it long enough to scroll conveniently.</p>
      <p class="one">This paragraph should have a lime background and an orange strip which starts at the top right and runs to the bottom. Therefore, extra text would be in order, so that we can intelligently evaluate the performance of your browser in handling these declarations. Hey, I didn't say the page would be pretty, did I?</p>
      <p class="two">This paragraph should have a lime background and an orange strip which starts at the center top and runs to the bottom. Therefore, extra text would be in order, so that we can intelligently evaluate the performance of your browser in handling these declarations. Hey, I didn't say the page would be pretty, did I?</p>
      <p class="three">This paragraph should have a lime background and an orange strip which starts at the top left and runs to the top right. Therefore, extra text would be in order, so that we can intelligently evaluate the performance of your browser in handling these declarations. Hey, I didn't say the page would be pretty, did I?</p>
    `;

    await snapshot(0.3);
  });
});
