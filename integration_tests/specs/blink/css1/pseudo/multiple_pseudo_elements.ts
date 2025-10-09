describe('CSS1 multiple pseudo-elements', () => {
  xit('applies first-line and first-letter together', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P:first-line {color: green;}
P:first-letter {color: maroon;}
.two:first-line {font-size: 200%;}
.two:first-letter {font-size: 350%;}
P.three:first-letter {font-size: 350%;}
P.three:first-line {font-variant: small-caps;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P:first-line {color: green;}
P:first-letter {color: maroon;}
.two:first-line {font-size: 200%;}
.two:first-letter {font-size: 350%;}
P.three:first-letter {font-size: 350%;}
P.three:first-line {font-variant: small-caps;}

</pre>
      <hr>
      <p>The first letter of this paragraph, and only that one, should be maroon (dark red), while the entire first line should be green. If this precise combination does not occur, then the user agent has failed this test. Remember that in order to ensure a complete test, the paragraph must be displayed on more than one line.</p>
      <p class="two">The first letter of this paragraph, and only that one, should be 350% bigger than the rest of the first line of this paragraph and maroon (dark red), while the entire first line should be 200% bigger than normal and green. If this precise combination does not occur, then the user agent has failed this test. Remember that in order to ensure a complete test, the paragraph must be displayed on more than one line.</p>
      <p class="three">"We should check for quotation support," it was said. The first two characters in this paragraph-- a double-quote mark and a capital 'W'-- should be 350% bigger than the rest of the paragraph, and maroon (dark red). Note that the inclusion of both the quotation mark and the 'W' in the first-letter style is not required under CSS1, but it is recommended. In addition, the entire first line should be in a small-caps font and green.</p>
    `;

      await snapshot();
  });
});
