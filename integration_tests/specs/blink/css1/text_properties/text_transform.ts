describe('CSS1 text-transform', () => {
  it('transforms capitalization and casing', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.ttn {text-transform: none;}
.cap {text-transform: capitalize;}
.upp {text-transform: uppercase;}
.low {text-transform: lowercase;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.ttn {text-transform: none;}
.cap {text-transform: capitalize;}
.upp {text-transform: uppercase;}
.low {text-transform: lowercase;}

</pre>
      <hr>
      <p class="ttn">This page tests the 'text-transform' property of CSS1.
This paragraph has no text transformation and should appear normal.</p>
      <p class="cap">This paragraph is capitalized and the first letter in each word should therefore appear in uppercase. Words that are in uppercase in the source (e.g. USA) should remain so. There should be a capital letter after a non-breaking&nbsp;space (&amp;nbsp;). Both those characters appear in the previous sentence.</p>
      <p>Words with inline elements inside them should only capitalize the first letter of the word. Therefore, the last word in this sentence should have one, and only one, capital <span class="cap">le<span>tt</span>er</span>.</p>
      <p class="upp">This paragraph is uppercased and small characters in the source (e.g. a and &aring;) should therefore appear in uppercase. In the last sentence, however, <span class="ttn">the last eight words should not be uppercase</span>.</p>
      <p class="low">This paragraph is lowercased and capital characters in the source (e.g. A and &Aring;) should therefore appear in lowercase.</p>
    `;

      await snapshot(0.3);


      window.scroll(0, 500);

      await waitForFrame();

      await snapshot(0.3);
  });
});
