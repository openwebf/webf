describe('CSS1 word-spacing', () => {
  it('handles various word-spacing units', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.one {word-spacing: 0.3in;}
.two {word-spacing: 0.5cm;}
.three {word-spacing: 5mm;}
.four {word-spacing: 3pt;}
.five {word-spacing: 0.25pc;}
.six {word-spacing: 1em;}
.seven {word-spacing: 1ex;}
.eight {word-spacing: 5px;}
.nine {word-spacing: normal;}
.ten {word-spacing: 300%;}
.eleven {word-spacing: -0.2em;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {word-spacing: 0.3in;}
.two {word-spacing: 0.5cm;}
.three {word-spacing: 5mm;}
.four {word-spacing: 3pt;}
.five {word-spacing: 0.25pc;}
.six {word-spacing: 1em;}
.seven {word-spacing: 1ex;}
.eight {word-spacing: 5px;}
.nine {word-spacing: normal;}
.ten {word-spacing: 300%;}
.eleven {word-spacing: -0.2em;}

</pre>
      <hr>
      <p class="one">This words in this sentence should have extra space between them.</p>
      <p class="two">This words in this sentence should have extra space between them.</p>
      <p class="three">This words in this sentence should have extra space between them.</p>
      <p class="four">This words in this sentence should have extra space between them.</p>
      <p class="five">This words in this sentence should have extra space between them.</p>
      <p class="six">This words in this sentence should have extra space between them.</p>
      <p class="seven">This words in this sentence should have extra space between them.</p>
      <p class="eight">This words in this sentence should have extra space between them, but the last few words in the sentence <span class="nine">should have normal spacing</span>.</p>
      <p class="ten">This sentence should have normal word-spacing, since percentage values are not allowed on this property.</p>
      <p class="eleven">This words in this sentence should have reduced space between them, since negative values are allowed on this property.</p>
    `;

    await snapshot(0.3);

    window.scroll(0, 500);

    await waitForFrame();

    await snapshot(0.3);

  });
});
