describe('CSS1 background-repeat', () => {
  it('tiles backgrounds according to repeat values', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = '../resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
body {overflow: hidden;}
.one {background-image: url(../resources/oransqr.gif); background-repeat: repeat-y;}
.two {background-image: url(../resources/oransqr.gif); background-repeat: repeat-x;}
.three {background-image: url(../resources/oransqr.gif); background-repeat: no-repeat;}
.four {background-image: url(../resources/bg.gif); background-position: 50% 50%; background-repeat: repeat-y;}
.five {background-image: url(../resources/crosshair2.gif); background-position: 50% 50%;
       background-color: red;}
.six {background-image: url(../resources/crosshair2.gif); background-position: center top;
      background-color: red;}
.seven {background-image: url(../resources/crosshair2.gif); background-position: top left;
        background-color: red;}
.eight {background-image: url(../resources/crosshair2.gif); background-position: bottom right;
        background-color: red;}
.nine {background-image: url(../resources/crosshair2.gif); background-position: 50% 50%;
       background-color: red;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {background-image: url(../resources/oransqr.gif); background-repeat: repeat-y;}
.two {background-image: url(../resources/oransqr.gif); background-repeat: repeat-x;}
.three {background-image: url(../resources/oransqr.gif); background-repeat: no-repeat;}
.four {background-image: url(../resources/bg.gif); background-position: 50% 50%; background-repeat: repeat-y;}
.five {background-image: url(../resources/crosshair2.gif); background-position: 50% 50%;
       background-color: red;}
.six {background-image: url(../resources/crosshair2.gif); background-position: center top;
      background-color: red;}
.seven {background-image: url(../resources/crosshair2.gif); background-position: top left;
        background-color: red;}
.eight {background-image: url(../resources/crosshair2.gif); background-position: bottom right;
        background-color: red;}
.nine {background-image: url(../resources/crosshair2.gif); background-position: 50% 50%;
       background-color: red;}

</pre>
      <hr>
      <p class="one">This sentence should have an orange stripe repeated in the "y" direction, starting at the upper left corner (since the default for <code>background-position</code> is '0% 0%' and that property is not declared here). This is extra text included for the sole purpose of making the paragraph longer. Thank you for your understanding.</p>
      <p class="two">This sentence should have an orange stripe repeated in the "x" direction, starting at the upper left corner (since the default for <code>background-position</code> is '0% 0%' and that property is not declared here). This is extra text included for the sole purpose of making the paragraph longer. Thank you for your understanding.</p>
      <p class="three">This sentence should have a single orange square behind it, placed at the upper left corner (since the default for <code>background-position</code> is '0% 0%' and that property is not declared here). This is extra text included for the sole purpose of making the paragraph longer. Thank you for your understanding.</p>
      <p class="four">This sentence should have a green-hatch stripe running vertically down the center of the paragraph, with the origin image exactly centered in the paragraph. This is because <code>repeat-y</code> specifies tiling in <em>both</em> directions on the y-axis. Note that this test is only valid if the user agent supports <code>background-position</code> (see <a href="sec536.htm">test 5.3.6</a>). I'll fill the paragraph with extra text to make the conformance (or lack thereof) more obvious.</p>
      <p class="five">This paragraph should have a tiled background, with the origin image exactly centered in the paragraph. This is because <code>background-repeat</code> specifies tiling in <em>all</em> directions, regardless of the position of the origin image. Note that this test is only valid if the user agent supports <code>background-position</code> (see <a href="sec536.htm">test 5.3.6</a>). I'll fill the paragraph with extra text to make the conformance (or lack thereof) more obvious. A background color is present, although if it is visible then the image has not bee correctly tiled.</p>
      <p class="six">This sentence should have a fully tiled background which starts at its center top; that is, the background's origin should be the exact center of the top of the paragraph. I'll fill it with extra text to make the conformance (or lack thereof) more obvious. A background color is present, although if it is visible, then the image may not have been tiled correctly.</p>
      <p class="seven">This sentence should have a fully tiled background which starts at its top left. I'll fill it with extra text to make the conformance (or lack thereof) more obvious. A background color is present, although if it is visible, then the image may not have been tiled correctly.</p>
      <p class="eight">This sentence should have a fully tiled background which starts at its bottom right; in other words, a complete instance of the image should be anchored in the bottom right corner, with the tiled background extending out from there. I'll fill it with extra text to make the conformance (or lack thereof) more obvious. A background color is present, although if it is visible, then the image may not have been tiled correctly.</p>
      <p class="nine">This sentence should have a fully tiled background which starts at its center and is tiled in all directions; that is, the background's origin should be the exact center of the paragraph. I'll fill it with extra text to make the conformance (or lack thereof) more obvious. In fact, a lot of extra text will be necessary to make this at all obvious. This is true because I am not able to increase the text size without resorting to either headings or other CSS properties, neither of which I want to use in this circumstance. This ought to be enough text, though. A background color is present, although if it is visible, then the image may not have been tiled correctly.</p>
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
