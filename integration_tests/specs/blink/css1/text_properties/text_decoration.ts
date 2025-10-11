describe('CSS1 text-decoration', () => {
  it('draws underlines, overlines, and strikes', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.one {text-decoration: underline;}
.two {text-decoration: overline;}
.three {text-decoration: line-through;}
.four {text-decoration: blink;}
B.five {text-decoration: none;}
.six {text-decoration: underline overline;}
.seven {text-decoration: underline overline line-through;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {text-decoration: underline;}
.two {text-decoration: overline;}
.three {text-decoration: line-through;}
.four {text-decoration: blink;}
B.five {text-decoration: none;}
.six {text-decoration: underline overline;}
.seven {text-decoration: underline overline line-through;}

</pre>
      <hr>
      <p class="one">This sentence should be underlined.</p>
      <p class="two">This sentence should be overlined.</p>
      <p class="three">This sentence should have stricken text (linethrough).</p>
      <p class="four">This element should be blinking. (It is not required, however, that UAs support this behavior.)</p>
      <p class="one">The text in this element should be underlined. The boldfaced text in this element <b class="five">should also be underlined</b>. This is because the parent's underline will 'span' the boldfaced text, even if the inline element has no underline of its own.</p>
      <p class="six">This sentence should be underlined and overlined.</p>
      <p class="seven">This sentence should be underlined, overlined, and stricken.</p>
      <p class="seven"></p>
      <p>There should be nothing visible between this sentence and the one above (there is an empty paragraph element with class of seven).</p>
      <p class="one">Text decorations only apply to the text of an element, so the image at the end of this sentence should <em>not</em> be overlined: <img src="assets/resources/oransqr.gif" class="two" alt="[Image]">. The underline of the parent element should hold true beneath the image, however, since text-decoration 'spans' child elements.</p>
      <p style="color: green;" class="one">The underlining <span style="color: blue;">in this sentence</span> should be green, no matter what the <span style="color: black;">text color may be</span>.</p>
      <p class="one">The colors of the <span style="color: purple;">underlining</span> in <span style="color: blue;">this sentence</span> should be <span style="color: gray;">the same as that of the parent text</span> (that is, the first word in the sentence, which should be black).</p>
    `;

      await snapshot();

      window.scroll(0, 500);

      await waitForFrame();

      await snapshot();
  });
});
