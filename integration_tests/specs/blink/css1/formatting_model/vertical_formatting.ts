describe('CSS1 vertical formatting', () => {
  it('collapses vertical margins and applies padding', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P.one {margin-bottom: 2cm; padding-bottom: 0;}
P.two {margin-top: 2cm; padding-top: 0;}
P.three {margin-top: 0; padding-top: 0;}
P.four {margin-top: -1cm; margin-bottom: 0;
        padding-top: 0; padding-bottom: 0;}
DIV.five {margin-top: 1cm; margin-bottom: 1cm;
          padding-top: 1cm; padding-bottom: 0;}
P.six {margin-top: 1cm; margin-bottom: 1cm;
       padding-top: 0; padding-bottom: 0;}
P.seven {margin-top: 1cm; padding-top: 0;}
P.eight {margin-bottom: -1cm; padding-bottom: 2cm;}
P.nine {margin-top: -1cm; padding-top: 1cm;
        padding-bottom: 0; margin-bottom: 1cm;}
P.eleven {margin-top: 1cm; padding-top: 0; clear: none;}
P.twelve {margin-bottom: 0; padding-bottom: 1cm; clear: both;}
P.thirteen {margin-top: 0; padding-top: 1cm;}
TABLE {clear: both;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P.one {margin-bottom: 2cm; padding-bottom: 0;}
P.two {margin-top: 2cm; padding-top: 0;}
P.three {margin-top: 0; padding-top: 0;}
P.four {margin-top: -1cm; margin-bottom: 0;
        padding-top: 0; padding-bottom: 0;}
DIV.five {margin-top: 1cm; margin-bottom: 1cm;
          padding-top: 1cm; padding-bottom: 0;}
P.six {margin-top: 1cm; margin-bottom: 1cm;
       padding-top: 0; padding-bottom: 0;}
P.seven {margin-top: 1cm; padding-top: 0;}
P.eight {margin-bottom: -1cm; padding-bottom: 2cm;}
P.nine {margin-top: -1cm; padding-top: 1cm;
        padding-bottom: 0; margin-bottom: 1cm;}
P.eleven {margin-top: 1cm; padding-top: 0; clear: none;}
P.twelve {margin-bottom: 0; padding-bottom: 1cm; clear: both;}
P.thirteen {margin-top: 0; padding-top: 1cm;}
TABLE {clear: both;}

</pre>
      <hr>
      <p class="one">There should be a two-centimeter margin between this paragraph and the next, because adjacent vertical margins should collapse to the maximum of the margins.</p>
      <p class="two">This is another paragraph.</p>
      <p class="one">There should be a two-centimeter margin between this paragraph and the next.</p>
      <p class="three">This is another paragraph.</p>
      <p class="one">There should be a one-centimeter margin between this paragraph and the next, because when there is one negative margin, the two margins should be added (the minus sign should be kept).</p>
      <p class="four">This is another paragraph.</p>
      <div class="five">
        <p class="six">There should be three centimeters between this text and the text above, but only one centimeter between this text and the text below, because vertical margins of nested elements should collapse only if there is no border or padding between the margins.</p>
      </div>
      <p class="seven">This is more text.</p>
      <p class="eight">There should be two centimeters between this paragraph and the one below, because negative margins collapse to a negative margin with the largest absolute value of the margins collapsed.</p>
      <p class="nine">This is a paragraph, which I should make very long so that you can easily see how much space there is between it and the one below it and to the right.</p>
      <p class="eleven">There should be one centimeter between this paragraph and the (non-floating) one above it, since the float should not effect the paragraph spacing.</p>
      <p class="twelve">There should be two centimeters of padding between this paragraph and the one below. Padding does not collapse, and there is 1cm of padding on each side.</p>
      <p class="thirteen">This is the next paragraph.</p>
    `;

      await snapshot();
  });
});
