describe('CSS1 inline elements', () => {
  xit('handles inline borders, padding, and margins', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P.one {line-height: 200%;}
SPAN.two {border-style: solid; border-width: 10px; border-color: red;
          padding: 2pt; margin: 30pt;}
P.three {font-size: 10pt; line-height: 12pt;}
SPAN.four {border-style: solid; border-width: 12px; border-color: red;
          padding: 2pt;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P.one {line-height: 200%;}
SPAN.two {border-style: solid; border-width: 10px; border-color: red;
          padding: 2pt; margin: 30pt;}
P.three {font-size: 10pt; line-height: 12pt;}
SPAN.four {border-style: solid; border-width: 12px; border-color: red;
          padding: 2pt;}

</pre>
      <hr>
      <p class="one">This is a paragraph that has a <span class="two">very long span in it, and the span has a 10px red border separated from the span by 2pt, and a margin of 30pt. The padding and border should be present on all sides of the span (although vertical lines should appear only at the beginning and the end of the whole span, not on each line). The padding, border, and margin should all be noticeable at the beginning and end of the span. However, the line height should not be changed by any of them, so the margin should be unnoticeable and the border should overlap text on other lines.</span> The line spacing in the whole paragraph should be 200% of the font size.</p>
      <p class="three">This is a paragraph that has a <span class="four">very long span in it, and the span has a 12px red border separated from the span by 2pt of padding (the difference between the line-height and the font-size), which should overlap with the lines of text above and below the span, since the padding and border should not effect the line height. The span's border should have vertical lines only at the beginning and end of the whole span, not on each line.</span> The line spacing in the whole paragraph should be 12pt, with font-size 10pt.</p>
    `;

      await snapshot();
  });
});
