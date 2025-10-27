describe('CSS1 letter-spacing', () => {
  it('handles absolute, relative, and invalid spacing', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.one {letter-spacing: 0.3in;}
.two {letter-spacing: 0.5cm;}
.three {letter-spacing: 5mm;}
.four {letter-spacing: 3pt;}
.five {letter-spacing: 0.25pc;}
.six {letter-spacing: 1em;}
.seven {letter-spacing: 1ex;}
.eight {letter-spacing: 5px;}
.nine {letter-spacing: normal;}
.ten {letter-spacing: 300%;}
.eleven {letter-spacing: -0.1em;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {letter-spacing: 0.3in;}
.two {letter-spacing: 0.5cm;}
.three {letter-spacing: 5mm;}
.four {letter-spacing: 3pt;}
.five {letter-spacing: 0.25pc;}
.six {letter-spacing: 1em;}
.seven {letter-spacing: 1ex;}
.eight {letter-spacing: 5px;}
.nine {letter-spacing: normal;}
.ten {letter-spacing: 300%;}
.eleven {letter-spacing: -0.1em;}
</pre>
      <hr>
      <p class="one">This letters in this sentence should have extra space between them.</p>
      <p class="two">This letters in this sentence should have extra space between them.</p>
      <p class="three">This letters in this sentence should have extra space between them.</p>
      <p class="four">This letters in this sentence should have extra space between them.</p>
      <p class="five">This letters in this sentence should have extra space between them.</p>
      <p class="six">This letters in this sentence should have extra space between them.</p>
      <p class="seven">This letters in this sentence should have extra space between them.</p>
      <p class="eight">This letters in this sentence should have extra space between them, but the last few words in the sentence <span class="nine">should show normal spacing</span>.</p>
      <p class="ten">This letters in this sentence should have normal space between them, since percentage values are not allowed on this property.</p>
      <p class="eleven">This letters in this sentence should have reduced space between them, since negative values are allowed on this property.</p>
    `;

    await snapshot(0.3);

    window.scroll(0, 500);

    await waitForFrame();

    await snapshot(0.3);
  });
});
