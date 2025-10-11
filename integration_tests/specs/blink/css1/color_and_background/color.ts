describe('CSS1 color', () => {
  it('applies color from class and inline styles', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.one {color: green;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {color: green;}

</pre>
      <hr>
      <p class="one">This sentence should be green.</p>
      <p style="color: green;">This sentence should be green.</p>
    `;

      await snapshot();
  });
});
