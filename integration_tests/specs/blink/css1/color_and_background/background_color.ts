describe('CSS1 background-color', () => {
  it('applies background colors and transparency', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P {background-color: green;}
.one {background-color: lime;}
.two {background-color: transparent;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P {background-color: green;}
.one {background-color: lime;}
.two {background-color: transparent;}

</pre>
      <hr>
      <p>This element's background should be green.</p>
      <p class="one">This element's background should be lime (light green).</p>
      <p>This element's background should be green, and the last word in this sentence should also have a green <span class="two">background</span>. This is because the background color of the parent element (the paragraph) should "shine through" the spanned word "sentence," which was set to <code>transparent</code>. If the document background is visible, the browser is in error.</p>
      <p class="two">This element should allow the document background to "shine through." There should be no green backgrounds here!</p>
    `;

      await snapshot(0.3);
  });
});
