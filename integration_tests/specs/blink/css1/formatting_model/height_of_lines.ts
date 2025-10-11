describe('CSS1 line box height', () => {
  it('expands line boxes to contain replaced content', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P.one {font-size: 14px; line-height: 20px;}
IMG.onea {vertical-align: text-bottom;
     width: 200px; height: 200px;}
IMG.oneb {vertical-align: text-top; width: 200px; height: 200px;}

P.two {font-size: 14px; line-height: 20px;}
IMG.twoa {vertical-align: text-bottom; width: 100px; height: 100px;
     padding: 5px; border-style: solid;
     border-width: 10px; margin: 15px;}
IMG.twob {vertical-align: text-top;
          width: 100px; height: 100px;
     padding: 5px; border-style: solid;
     border-width: 10px; margin: 15px;}

IMG.twoc {vertical-align: middle; width: 50px; height: 50px;
     padding: 5px; border-style: solid;
     border-width: 10px; margin: -10px;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P.one {font-size: 14px; line-height: 20px;}
IMG.onea {vertical-align: text-bottom;
     width: 200px; height: 200px;}
IMG.oneb {vertical-align: text-top; width: 200px; height: 200px;}

P.two {font-size: 14px; line-height: 20px;}
IMG.twoa {vertical-align: text-bottom; width: 100px; height: 100px;
     padding: 5px; border-style: solid;
     border-width: 10px; margin: 15px;}
IMG.twob {vertical-align: text-top;
          width: 100px; height: 100px;
     padding: 5px; border-style: solid;
     border-width: 10px; margin: 15px;}

IMG.twoc {vertical-align: middle; width: 50px; height: 50px;
     padding: 5px; border-style: solid;
     border-width: 10px; margin: -10px;}

</pre>
      <hr>
      <p class="one">This paragraph should have a font size of 14px and a line height of 20px. This means that the lines of text within it should be separated by six pixels, three of which are part of the line-box of each line. Any images within the paragraph should increase the height of the line-box so that they fit within the line box, such as <img src="assets/resources/oransqr.gif" alt="[Image]" class="onea"> and <img src="assets/resources/oransqr.gif" alt="[Image]" class="oneb">. This is additional text to make sure that there is enough room left below the image so that this line does not hit the image that is text-top aligned.</p>
      <p class="two">This paragraph should have a font size of 14px and a line height of 20px. This means that the lines of text within it should be separated by six pixels. Any images within the paragraph should increase the height of the line-box so that they fit, including their padding (5px), border (10px) and margins (15px) within the line box, such as <img src="assets/resources/oransqr.gif" alt="[Image]" class="twoa"> and <img src="assets/resources/oransqr.gif" alt="[Image]" class="twob">. This is additional text to make sure that there is enough room left below the image so that this line does not hit the image that is text-top aligned. It is the outer edge of the margin that should be text-bottom and text-top aligned in this paragraph, so for the first image the bottom border of the image should begin 15px above the bottom of the text, and for the second image the top border should begin 15px below the top of the text <img src="assets/resources/oransqr.gif" alt="[Image]" class="twoc">. The last image in this paragraph has -10px margins set on it, so that should pull the text in toward the image in the vertical direction, and also in the horizontal direction.</p>
    `;

      await snapshot(1);
  });
});
