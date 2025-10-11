describe('CSS1 first-line pseudo-element', () => {
  it('styles only the first line of paragraphs', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P:first-line {color: green;}
.two:first-line {font-size: 200%;}
.three:first-line {font-variant: small-caps;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P:first-line {color: green;}
.two:first-line {font-size: 200%;}
.three:first-line {font-variant: small-caps;}

</pre>
      <hr>
      <p>The first line of this paragraph, and only that one, should be green. If this precise combination does not occur, then the user agent has failed this test. Remember that in order to ensure a complete test, the paragraph must be displayed on more than one line.</p>
      <p class="two">The first line of this paragraph, and only that one, should be a larger font size as well as green. If this precise combination does not occur, then the user agent has failed this test. Remember that in order to ensure a complete test, the paragraph must be displayed on more than one line.</p>
      <p class="three">The first line of this paragraph, and only that one, should be displayed in small-caps style. Thus, if the first line is not in small-caps style, or if the entire paragraph turns out in small-caps, then the user agent has failed this test (although the problem might be that <code>small-caps</code> is not supported by your browser). This is extra text included for the purposes of making the paragraph long enough to have more than one line.</p>
    `;

      await snapshot();
  });
});
