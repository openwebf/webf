describe('CSS1 background-position', () => {
  it('positions background images by keyword, percentage, and length', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
BODY {background-image: url(assets/resources/bg.gif); background-position: right top;
      background-repeat: no-repeat;}
.one {background-image: url(assets/resources/bg.gif); background-position: center;
      background-repeat: no-repeat; background-color: aqua;}
.two {background-image: url(assets/resources/bg.gif); background-position: 50% 50%;
      background-repeat: no-repeat; background-color: aqua;}
.three {background-image: url(assets/resources/bg.gif); background-position: bottom right;
        background-repeat: no-repeat; background-color: aqua;}
.four {background-image: url(assets/resources/bg.gif); background-position: 100% 100%;
       background-repeat: no-repeat; background-color: aqua;}
.five {background-image: url(assets/resources/bg.gif); background-position: 0% 50%;
       background-repeat: no-repeat; background-color: aqua;}
.six {background-image: url(assets/resources/bg.gif); background-position: 75% 25%;
       background-repeat: no-repeat; background-color: aqua;}
.seven {background-image: url(assets/resources/bg.gif); background-position: 20px 20px;
       background-repeat: no-repeat; background-color: aqua;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>BODY {background-image: url(assets/resources/bg.gif); background-position: right top;
      background-repeat: no-repeat;}
.one {background-image: url(assets/resources/bg.gif); background-position: center;
      background-repeat: no-repeat; background-color: aqua;}
.two {background-image: url(assets/resources/bg.gif); background-position: 50% 50%;
      background-repeat: no-repeat; background-color: aqua;}
.three {background-image: url(assets/resources/bg.gif); background-position: bottom right;
        background-repeat: no-repeat; background-color: aqua;}
.four {background-image: url(assets/resources/bg.gif); background-position: 100% 100%;
       background-repeat: no-repeat; background-color: aqua;}
.five {background-image: url(assets/resources/bg.gif); background-position: 0% 50%;
       background-repeat: no-repeat; background-color: aqua;}
.six {background-image: url(assets/resources/bg.gif); background-position: 75% 25%;
       background-repeat: no-repeat; background-color: aqua;}
.seven {background-image: url(assets/resources/bg.gif); background-position: 20px 20px;
       background-repeat: no-repeat; background-color: aqua;}

</pre>
      <hr>
      <p>This document should have a single, small green image in its upper right corner.</p>
      <p class="one">This paragraph should have a single, small green image exactly in its center; that is, the center of the image should be fixed at the center of the paragraph. The background color will make it easier to determine the edges of the paragraph, and therefore allow you to calculate its center.</p>
      <p class="two">This paragraph should have a single, small green image exactly in its center; that is, the center of the image should be fixed at the center of the paragraph. The background color will make it easier to determine the edges of the paragraph, and therefore allow you to calculate its center.</p>
      <p class="three">This paragraph should have a single, small green image in its lower-right corner; that is, the lower right corner of the image should be fixed at the lower right corner of the paragraph. The background color will make it easier to determine the edges of the paragraph, and therefore allow you to see its corners.</p>
      <p class="four">This paragraph should have a single, small green image in its lower-right corner; that is, the lower right corner of the image should be fixed at the lower right corner of the paragraph. The background color will make it easier to determine the edges of the paragraph, and therefore allow you to see its corners.</p>
      <p class="five">This paragraph should have a single, small green image exactly at the left center; that is, the left center of the image should be fixed at the left center of the paragraph. The background color will make it easier to determine the edges of the paragraph, and therefore allow you to calculate its center.</p>
      <p class="six">This paragraph should have a single, small green image positioned 75% of the way across the element, and 25% down. The background color will make it easier to determine the edges of the paragraph, which should help in determining if all this is so, and the extra text should make the element long enough for this test to be simpler to evaluate.</p>
      <p class="seven">This paragraph should have a single, small green image positioned 20 pixels down and to the left of the upper left-hand corner; that is, the upper left-hand corner of the image should be 20 pixels down and to the left of the upper-left corner of the element. The background color will make it easier to determine the edges of the paragraph, which should assist in evaluating this test.</p>
    `;

      await snapshot();
  });
});
