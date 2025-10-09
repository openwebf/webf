describe('CSS1 canvas', () => {
  xit('applies html and body background colors', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = '../resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
HTML {background-color: aqua;}
BODY {background-color: green; background-image: none; margin: 25px;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>HTML {background-color: aqua;}
BODY {background-color: green; background-image: none; margin: 25px;}
</pre>
      <hr>
      <p>The body of this document should have a green background. It also has a margin of 25 pixels, so the light blue background set for the HTML element should surround the body. If the body content is significantly shorter than the browser's window height, then the bottom border may be larger than 25 pixels.</p>
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
