describe('CSS1 background-image', () => {
  it('applies and removes background images', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P {background-image: url(assets/resources/bg.gif);}
.one {background-image: none;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P {background-image: url(assets/resources/bg.gif);}
.one {background-image: none;}

</pre>
      <hr>
      <p>This sentence should be backed by an image-- a green grid pattern, in this case. The background image should also tile along both axes, because no repeat direction is specified (specific tests for repeating are found elsewhere).</p>
      <p>This sentence should be backed by a repeated green-grid image, as should the last three words <strong><span class="one">in this sentence</span></strong>. If it is not, then <code>none</code> is interpreted incorrectly. (<code>none</code> means that the element has no background image, allowing the parent to "shine through" by default; since the parent of the words "in this sentence" is the paragraph, then the paragraph's image should be visible.)</p>
      <p class="one">This sentence should NOT be backed by a repeated green-grid image, allowing the page's background to "shine through" instead.</p>
    `;

      await snapshot(0.3);
  });
});
