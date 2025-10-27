describe('CSS1 horizontal formatting', () => {
  it('resolves auto margins and widths', async () => {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    const style = document.createElement('style');
    style.textContent = `
body {overflow: hidden;}
.ruler {padding: 0px; margin: 0px; border-width: 0px;}
P#ruled {background-color: aqua; width: 400px;
     border-style: solid; border-color: silver;
     border-top-width: 0px; border-bottom-width: 0px;
     border-left-width: 40px; border-right-width: 40px;
     padding-left: 40px; padding-right: 40px;
     margin-top: 0px; margin-bottom: 0px; margin-left: 40px; margin-right: 40px;}

P.one {margin-left: 10px;}
DIV.two {margin-left: 10px;}
P.three {margin-left: 0; width: 50%; margin-right: auto;
         background-color: gray;}
P.four {margin-left: auto; width: 50%; margin-right: auto;
        background-color: gray;}
P.five {margin-left: auto; width: 50%; margin-right: 0;
        background-color: gray;}
P.six {margin-left: auto; width: auto; margin-right: 0;
       background-color: gray; }
P.seven {margin-left: 0; width: auto; margin-right: auto;
         background-color: gray;}
P.eight {margin-left: auto; width: auto; margin-right: auto;
         background-color: gray;}
P.nine {padding-left: auto; padding-right: auto; margin-left: 0; margin-right: 0;
        width: 50%; background-color: gray;}
P.ten {margin-left: auto; width: 100%; margin-right: auto;
       background-color: gray;}
`;
    document.head.appendChild(style);

    document.body.innerHTML = `
      <p class="one">This paragraph should be indented ten pixels.</p>
      <div class="two">
        <p class="one">This paragraph should be indented twenty pixels, since horizontal margins do not collapse.</p>
      </div>
      <p class="three">This element has a width of 50%, and due to 'auto' values applied to the right margin, the element should be left justified within its parent. The gray rectangle should therefore appear on the left edge of the viewport (e.g. the browser window). The text inside the gray rectangle should not be centered.</p>
      <p class="four">This element has a width of 50%, and due to 'auto' values applied to the left and right margins, the element should be centered within its parent. The gray rectangle should therefore appear in the middle of the viewport (e.g. the browser window). The text inside the gray rectangle should not be centered.</p>
      <p class="five">This element has a width of 50%, and due to 'auto' values applied to the left margin, the element should be right justified within its parent. The gray rectangle should therefore appear on the right edge of the viewport (e.g. the browser window). The text inside the gray rectangle should not be centered.</p>
      <p class="six">Since the width is "auto," the margins that are set to "auto" become zero and this paragraph should have width 100% and the text should be left justified.</p>
      <p class="seven">Since the width is "auto," the margins that are set to "auto" become zero and this paragraph should have width 100% and the text should be left justified.</p>
      <p class="eight">Since the width is "auto," the margins that are set to "auto" become zero and this paragraph should have width 100% and the text should be left justified.</p>
      <p class="nine">Since auto is an invalid value for padding, the right-margin of this paragraph should be reset to <code>auto</code> and thus be expanded to 50% and it should only occupy the left half of the viewport.</p>
      <p class="ten">Because this paragraph has width 100%, the auto margins become zero, so it should not be centered.</p>
    `;

      await snapshot(0.3);
  });
});
