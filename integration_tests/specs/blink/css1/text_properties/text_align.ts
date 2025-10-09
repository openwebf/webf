describe('CSS1 text-align', () => {
  it('aligns text using keywords', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.one {text-align: left;}
.two {text-align: right;}
.three {text-align: center;}
.four {text-align: justify;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {text-align: left;}
.two {text-align: right;}
.three {text-align: center;}
.four {text-align: justify;}

</pre>
      <hr>
      <p class="one">This sentence should be left-justified.</p>
      <p class="two">This sentence should be right-justified.</p>
      <p class="three">This sentence should be centered.</p>
      <p class="four">This sentence should be fully justified, which means that the right and left margins of this paragraph should line up, no matter how long the paragraph becomes; the exception, of course, is the last line, which should be left-justified in Western languages.</p>
    `;

      await snapshot();
  });
});
