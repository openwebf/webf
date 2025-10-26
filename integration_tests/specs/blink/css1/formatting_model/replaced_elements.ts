describe('CSS1 replaced elements', () => {
  it('positions replaced images with different display rules', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
IMG.one {display: inline;}
IMG.two {display: block;}
IMG.three {display: block;
           margin-right: auto; margin-left: auto; width: auto;}
IMG.four {display: block;
          margin-right: auto; margin-left: auto; width: 50%;}
IMG.five {display: block;
          margin-right: 0; margin-left: auto; width: 50%;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>IMG.one {display: inline;}
IMG.two {display: block;}
IMG.three {display: block;
           margin-right: auto; margin-left: auto; width: auto;}
IMG.four {display: block;
          margin-right: auto; margin-left: auto; width: 50%;}
IMG.five {display: block;
          margin-right: 0; margin-left: auto; width: 50%;}
</pre>
      <hr>
      <p><img class="one" src="assets/resources/oransqr.gif" alt="[Image]">The image at the beginning of this sentence should be a 15px square.</p>
      <img class="two" src="assets/resources/oransqr.gif" alt="[Image]">
      <p>The above image should be a 15px square with the same left edge as this text.</p>
      <img class="three" src="assets/resources/oransqr.gif" alt="[Image]">
      <p>The above image should be a 15px square aligned at the center.</p>
      <img class="four" src="assets/resources/oransqr.gif" alt="[Image]">
      <p>The above image should be a square resized so its width is 50% of the its parent element, and centered horizontally within the parent element: the document body in the first half, and the table in the second.</p>
      <img class="five" src="assets/resources/oransqr.gif" alt="[Image]">
      <p>The above image should be a square resized so its width is 50% of its parent element, and aligned at the right edge of the parent element: the document body in the first half, and the table in the second.</p>
    `;

      await snapshot(1);
  });
});
