describe('CSS1 background-attachment', () => {
  it('fixes the background relative to the viewport', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = '../resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
BODY {
  background-image: url(../resources/bg.gif);
  background-repeat: repeat-x;
  background-attachment: fixed;
  overflow: hidden;
}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>BODY {background-image: url(../resources/bg.gif); background-repeat: repeat-x; background-attachment: fixed;}

</pre>
      <hr>
      <p>This document should have a green grid-pattern line across the top of the page (or at least a tiled background) which does NOT scroll with the document. It should, instead, appear to be a fixed pattern past which the content scrolls, even when the end of the page is reached. In addition, the default Test Suite background should NOT appear, as it's been overridden by the styles shown above. I'll have to add a lot of extra text to the page in order to make all this something we can actually check. Don't worry, I'll think of something.</p>
      <p>In fact, why not the relevant section from the CSS1 specification? A capital idea.</p>
      <hr>
      <hr>
      <h4><a name="background-attachment">5.3.5 &nbsp;&nbsp; 'background-attachment'</a></h4>
      <p><em>Value:</em> scroll | fixed<br>
<em>Initial:</em> scroll<br>
<em>Applies to:</em> all elements<br>
<em>Inherited:</em> no<br>
<em>Percentage values:</em> N/A</p>
      <p>If a background image is specified, the value of 'background-attachment' determines if it is fixed with regard to the canvas or if it scrolls along with the content.</p>
      <pre>
  BODY { 
    background: red url(pendant.gif);
    background-repeat: repeat-y;
    background-attachment: fixed;
  }
</pre>
      <p><em>CSS1 core:</em> UAs may treat 'fixed' as 'scroll'. However, it is recommended they interpret 'fixed' correctly, at least on the HTML and BODY elements, since there is no way for an author to provide an image only for those browsers that support 'fixed'.</p>
    `;

    try {
      await snapshot();
    } finally {
      document.body.innerHTML = '';
      style.remove();
      link.remove();
    }
  });
});
