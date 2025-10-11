describe('CSS1 vertical-align', () => {
  it('aligns inline content in multiple ways', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P {font-size: 12pt;}
.three {vertical-align: top; font-size: 12pt;}
.five {vertical-align: middle; font-size: 12pt;}
.six {vertical-align: bottom; font-size: 12pt;}
.eight {vertical-align: baseline; font-size: 12pt;}
.nine {vertical-align: 50%; font-size: 12px; line-height: 16px;}

P.example {font-size: 14pt;}
BIG {font-size: 16pt;}
SMALL {font-size: 12pt;}
.topalign {vertical-align: top;}
.midalign {vertical-align: middle;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P {font-size: 12pt;}
.three {vertical-align: top; font-size: 12pt;}
.five {vertical-align: middle; font-size: 12pt;}
.six {vertical-align: bottom; font-size: 12pt;}
.eight {vertical-align: baseline; font-size: 12pt;}
.nine {vertical-align: 50%; font-size: 12px; line-height: 16px;}

P.example {font-size: 14pt;}
BIG {font-size: 16pt;}
SMALL {font-size: 12pt;}
.topalign {vertical-align: top;}
.midalign {vertical-align: middle;}

</pre>
      <hr>
      <p>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="50">
        <span class="three">The first four words</span> in this sentence should be top-aligned, which will align their tops with the top of the tallest element in the line (probably the orange rectangle).
      </p>
      <p>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="50" class="five">
        The image at the beginning of this sentence should be middle-aligned, which should align its middle with the point defined as the text baseline plus half the x-height.
      </p>
      <p>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="50" align="top">
        <span style="font-size: 200%;">
          <span class="six">The first four words</span> in this sentence should be 12pt in size and bottom-aligned, which should align their bottom with the bottom of the lowest element in the line.
        </span>
      </p>
      <p>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="50">
        <span style="font-size: 200%;">
          <span class="eight">The first four words</span> in this sentence should be 12pt in size and baseline-aligned, which should align their baseline with the baseline of the rest of the text in the line.
        </span>
      </p>
      <p>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="50">
        <span class="nine">The first four words</span> in this sentence should have a font-size of 12px and a line-height of 16px; they are also 50%-aligned, which should raise them 8px relative to the natural baseline.
      </p>
      <p class="explain">
        In the following paragraph, all images should be aligned with the middle of the default text, whereas any text should be aligned with the text baseline (which is the default value).
      </p>
      <p>
        This paragraph
        <img src="assets/resources/vblank.gif" alt="[Image]" height="30" class="midalign">
        <span style="font-size: 250%;">contains many images</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="50" class="midalign">
        of varying heights
        <img src="assets/resources/vblank.gif" alt="[Image]" height="10" class="midalign">
        <small>and widths</small>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="20" class="midalign">
        all of which
        <img src="assets/resources/vblank.gif" alt="[Image]" height="65" class="midalign">
        should be aligned
        <img src="assets/resources/vblank.gif" alt="[Image]" height="35" class="midalign">
        <span style="font-size: 2em;">with the middle of</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="50" class="midalign">
        <span style="font-size: 150%;">a <span style="font-size: 250%;">14-point</span> text element</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="50" class="midalign">
        <small>regardless of the line in which</small>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="15" class="midalign">
        <big>the images appear.</big>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="90" class="midalign">
      </p>
      <p class="explain">
        In the following paragraph, all elements should be aligned with the top of the tallest element on the line, whether that element is an image or not. Each fragment of text has been spanned appropriately in order to cause this to happen.
      </p>
      <p>
        <span class="topalign">This paragraph</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="10" class="topalign">
        <span style="font-size: 250%;" class="topalign">contains many images</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="10" class="topalign">
        <span class="topalign">and some text</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="10" class="topalign">
        <span class="topalign">of varying heights</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="10" class="topalign">
        <big class="topalign">and widths</big>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="20" class="topalign">
        <span class="topalign">all of which</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="65" class="topalign">
        <span class="topalign">should be aligned</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="35" class="topalign">
        <span style="font-size: 2em;" class="topalign">with the top of</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="50" class="topalign">
        <span class="topalign">the tallest element in</span>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="15" class="topalign">
        <big class="topalign">whichever line the elements appear.</big>
        <img src="assets/resources/vblank.gif" alt="[Image]" height="90" class="topalign">
      </p>
    `;

      await snapshot(2);



      window.scroll(0, 500);

      await waitForFrame();

      await snapshot();



      window.scroll(0, 1000);

      await waitForFrame();

      await snapshot();
  });
});
