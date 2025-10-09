describe('CSS1 percentage units', () => {
  xit('applies percentage margins relative to containing block', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.zero { background: yellow }
.one { margin-left: 25%; margin-right: 25%; background: white }
.two { margin-left: 50%; margin-right: 0%; background: white }
.three {margin-left: 25%;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.zero { background: yellow }
.one { margin-left: 25%; margin-right: 25%; background: white }
.two { margin-left: 50%; margin-right: 0%; background: white }
.three {margin-left: 25%;}

</pre>
      <hr>
      <div class="zero">
        <div class="one">
          <p>This paragraph should be centered within its yellow containing block and its width should be half of the containing block.</p>
        </div>
        <div class="two">
          <p>This paragraph should be right-aligned within its yellow containing block and its width should be half of the containing block.</p>
        </div>
      </div>
      <p class="three">This paragraph should have a left margin of 25% the width of its parent element, which should require some extra text in order to test effectively.</p>
    `;

      await snapshot();
  });
});
