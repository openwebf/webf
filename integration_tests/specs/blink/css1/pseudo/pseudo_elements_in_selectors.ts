describe('CSS1 pseudo-elements in selectors', () => {
  it('treats :first-line placement correctly', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
P:first-line {font-weight: bold;}
P.two:first-line {color: green;}
P:first-line.three {color: red;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>P:first-line {font-weight: bold;}
P.two:first-line {color: green;}
P:first-line.three {color: red;}

</pre>
      <hr>
      <p>The first line of this sentence should be boldfaced. This test is included simply to establish a baseline for the following tests, since if this test fails, then the rest of the tests on this page are expected to fail as well.</p>
      <p class="two">The first line of this sentence should be boldfaced and green, thanks to its selector. If this is not the case, then the user agent may have failed to properly parse the selector, or it may simply not support the <tt>:first-line</tt> pseudo-element.</p>
      <p class="three">The first line of this sentence should be boldfaced. If it is red, then the user agent has violated the specification in allowing pseudo-elements at a point other than the end of a selector. If neither is the case, then the user agent has correctly ignored the incorrect selector, but has suppressed other styles which are valid, and therefore must be considered to have failed the test.</p>
    `;

      await snapshot(0.3);
  });
});
