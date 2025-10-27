describe('CSS1 line-height', () => {
  it('applies line-height across nested elements', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.one {line-height: 0.5in; font-size: 12px;}
.two {line-height: 2cm; font-size: 12px;}
.three {line-height: 20mm; font-size: 12px;}
.four {line-height: 24pt; font-size: 12px;}
.five {line-height: 2pc; font-size: 12px;}
.six {line-height: 2em; font-size: 12px;}
.seven {line-height: 3ex; font-size: 12px;}
.eight {line-height: 200%; font-size: 12px;}
.nine {line-height: 2; font-size: 12px;}
.ten {line-height: 50px; font-size: 12px;}
.eleven {line-height: -1em; font-size: 12px;}
TABLE .ten {line-height: normal; font-size: 12px;}
DIV {background-color: silver;}
SPAN.color {background-color: silver;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {line-height: 0.5in; font-size: 12px;}
.two {line-height: 2cm; font-size: 12px;}
.three {line-height: 20mm; font-size: 12px;}
.four {line-height: 24pt; font-size: 12px;}
.five {line-height: 2pc; font-size: 12px;}
.six {line-height: 2em; font-size: 12px;}
.seven {line-height: 3ex; font-size: 12px;}
.eight {line-height: 200%; font-size: 12px;}
.nine {line-height: 2; font-size: 12px;}
.ten {line-height: 50px; font-size: 12px;}
.eleven {line-height: -1em; font-size: 12px;}
TABLE .ten {line-height: normal; font-size: 12px;}
DIV {background-color: silver;}
SPAN.color {background-color: silver;}
</pre>
      <hr>
      <p class="one">This sentence should have a line-height of half an inch, which should cause extra spacing between the lines.</p>
      <p class="two">This sentence should have a line-height of two centimeters, which should cause extra spacing between the lines.</p>
      <p class="three">This sentence should have a line-height of twenty millimeters, which should cause extra spacing between the lines.</p>
      <p class="four">This sentence should have a line-height of twenty-four points, which should cause extra spacing between the lines.</p>
      <p class="five">This sentence should have a line-height of two picas, which should cause extra spacing between the lines.</p>
      <p class="six">This sentence should have a line-height of two em, which should cause extra spacing between the lines.</p>
      <p class="seven">This sentence should have a line-height of three ex, which should cause extra spacing between the lines.</p>
      <p class="eight">This sentence should have a line-height of twice the font size, which should cause extra spacing between the lines.</p>
      <div class="eight">
        This first part of the DIV should have a line-height of twice the font size, which should cause extra spacing between the lines.
        <p style="font-size: 200%;">This sentence should have a line-height of twice the DIV's font size, or 28px; this should not cause extra spacing between the lines, since the line-height and font-size should have the same value.</p>
        This second part of the DIV should have a line-height of twice the font size, which should cause extra spacing between the lines.
      </div>
      <p class="nine">This sentence should have a line-height of twice the font size, which should cause extra spacing between the lines.</p>
      <div class="nine">
        This first part of the DIV should have a line-height of twice the font size, which should cause extra spacing between the lines.
        <p style="font-size: 200%;">This sentence should have a line-height of twice the font size, which is 200% normal thanks to an inline style; this should cause extra spacing between the lines, as the font-size will be 28px and the line-height will be 56px.</p>
        This second part of the DIV should have a line-height of twice the font size, which should cause extra spacing between the lines.
      </div>
      <p class="ten">This paragraph should have a line-height of 50 pixels in the first section, which should cause extra spacing between the lines. In the second section (within the table) its line-height should be normal.</p>
      <p class="eleven">This sentence should have a normal line-height, because negative values are not permitted for this property.</p>
      <p class="two"><span class="color">This sentence should have a line-height of two centimeters, which should cause extra spacing between the lines. The text has a background color of silver, but no padding or border. The background color has been set on an inline element and should therefore only cover the text, not the interline spacing.</span></p>
    `;

    await snapshot(0.3);

    window.scroll(0, 500);

    await waitForFrame();

    await snapshot(0.3);
  });
});
