describe('CSS1 first-letter pseudo-element', () => {
  it('styles the first letter of paragraphs', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P:first-letter {color: maroon;}
.two:first-letter {font-size: 200%;}
P.three:first-letter {font-size: 350%;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P:first-letter {color: maroon;}
.two:first-letter {font-size: 200%;}
P.three:first-letter {font-size: 350%;}

</pre>
      <hr>
      <p>The first letter of this paragraph, and only that one, should be maroon. If this precise combination does not occur, then the user agent has failed this test. Remember that in order to ensure a complete test, the paragraph must be displayed on more than one line.</p>
      <p class="two">The first letter of this paragraph, and only that one, should be a larger font size, as well as maroon. If this precise combination does not occur, then the user agent has failed this test. Remember that in order to ensure a complete test, the paragraph must be displayed on more than one line.</p>
      <p class="three">"We should check for quotation support," it was said. The first two characters in this paragraph-- a double-quote mark and a capital 'W'-- should be 350% bigger than the rest of the paragraph, and maroon. Note that this is not required under CSS1, but it is recommended.</p>
    `;

      await snapshot();
  });
});
