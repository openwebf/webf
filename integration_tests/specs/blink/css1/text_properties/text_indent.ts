describe('CSS1 text-indent', () => {
  xit('indents the first line using various units', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
.one {text-indent: 0.5in; background: aqua;}
.two {text-indent: 2cm; background: aqua;}
.three {text-indent: 20mm; background: aqua;}
.four {text-indent: 24pt; background: aqua;}
.five {text-indent: 2pc; background: aqua;}
.six {text-indent: 2em; background: aqua;}
.seven {text-indent: 2ex; background: aqua;}
.eight {text-indent: 50%; background: aqua;}
.nine {text-indent: 25px; background: aqua;}
blockquote {text-indent: 50%; background: aqua;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p>The style declarations which apply to the text below are:</p>
      <pre>.one {text-indent: 0.5in; background: aqua;}
.two {text-indent: 2cm; background: aqua;}
.three {text-indent: 20mm; background: aqua;}
.four {text-indent: 24pt; background: aqua;}
.five {text-indent: 2pc; background: aqua;}
.six {text-indent: 2em; background: aqua;}
.seven {text-indent: 2ex; background: aqua;}
.eight {text-indent: 50%; background: aqua;}
.nine {text-indent: 25px; background: aqua;}
blockquote {text-indent: 50%; background: aqua;}

</pre>
      <hr>
      <p class="one">The first line of this sentence should be indented half an inch.</p>
      <p class="two">The first line of this sentence should be indented two centimeters.</p>
      <p class="three">The first line of this sentence should be indented twenty millimeters.</p>
      <p class="four">The first line of this sentence should be indented twenty-four points.</p>
      <p class="five">The first line of this sentence should be indented two picas.</p>
      <p class="six">The first line of this sentence should be indented two em.</p>
      <p class="seven">The first line of this sentence should be indented two ex.</p>
      <p class="eight">The first line of this sentence should be indented halfway across the page, but the rest of it should be flush with the normal left margin of the page.</p>
      <p class="nine">The first line of this sentence should be indented 25 pixels, but the rest of it should be flush with the normal left margin of the page.</p>
      <p class="one">Only the first line of this sentence should be indented half an inch,<br>
no matter where the lines might start, and<br>
<em>regardless of any other markup</em> which may be present.</p>
      <blockquote>In the first half of the test page, this blockquote element should have a text indent equal to 50% of the body element's width, since blockquote is a child of body; in the second half, it is a child of table.</blockquote>
    `;

      await snapshot();
  });
});
