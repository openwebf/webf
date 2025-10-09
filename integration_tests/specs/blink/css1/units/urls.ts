describe('CSS1 URL resolution', () => {
  xit('resolves background URLs relative to stylesheets', async () => {
    const baseLink = document.createElement('link');
    baseLink.rel = 'stylesheet';
    baseLink.type = 'text/css';
    baseLink.media = 'screen';
    baseLink.href = '../resources/base.css';
    document.head.appendChild(baseLink);

    const secondaryLink = document.createElement('link');
    secondaryLink.rel = 'stylesheet';
    secondaryLink.type = 'text/css';
    secondaryLink.media = 'screen';
    secondaryLink.href = '../resources/sec64.css';
    document.head.appendChild(secondaryLink);

    const style = document.createElement('style');
    style.textContent = `
@import url(../resources/sec642.css);
BODY {background: url(../resources/bg.gif);}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>&lt;LINK rel="stylesheet" type="text/css" media="screen" href="../resources/bg.gif"&gt;
@import url(../resources/sec642.css);
BODY {background: url(../resources/bg.gif);}

</pre>
      <hr>
      <p>This page should have a green grid pattern as its background.</p>
      <p class="one"> This paragraph should have a white background, but NO image should appear in the background. If an image, in this case a red square-- or, indeed, any red at all-- is seen there, then the browser has incorrectly interpreted a URL in relation to the document's URL, not the stylesheet's URL. </p>
      <p class="two"> This paragraph should have a white background, but NO image should appear in the background. If an image, in this case a red square-- or, indeed, any red at all-- is seen there, then the browser has incorrectly interpreted a URL in relation to the document's URL, not the stylesheet's URL. </p>
    `;

    try {
      await snapshot();
    } finally {
      document.body.innerHTML = '';
      style.remove();
      secondaryLink.remove();
      baseLink.remove();
    }
  });
});
