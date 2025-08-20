describe('Tag style', () => {
  it('simple usage', async () => {
    const style = document.createElement('style');
    style.appendChild(document.createTextNode(`.foo {
      color: red;
      text-align: center;
    }`));
    document.body.appendChild(style);

    const div = document.createElement('div');
    div.appendChild(document.createTextNode('HelloWorld'));
    div.className = "foo";

    document.body.appendChild(div);
    await snapshot();
  });

  it('dynamic append text child into style', async () => {
    const style = document.createElement('style');
    document.body.appendChild(style);

    const div = document.createElement('div');
    div.appendChild(document.createTextNode('HelloWorld'));
    div.className = "foo";

    document.body.appendChild(div);

    await sleep(0.1);
    // Insert text after all things done.
    style.appendChild(document.createTextNode(`.foo {
      color: red;
      text-align: center;
    }`));

    await snapshot();
  });

  it('the third node position should be fixed', async () => {
      const style = document.createElement('style');
      document.body.appendChild(style);

      style.appendChild(document.createTextNode(`
      .top, .bottom, .left, .right {
         position: relative
      }
      .fixed {
         position: fixed;
         width: 100%;
         top: 0;
         left: 0;
      }
      .content {
         height: 50px;
         background-color: red;
      }`));
      document.body.appendChild(document.createTextNode(`first`));
      document.body.appendChild(document.createTextNode(`second`));
      const div = document.createElement('div');
      div.appendChild(document.createTextNode('third'));
      div.className = "bottom fixed content";
      document.body.appendChild(div);
      await snapshot();
    });

  it('add inline styles should works', async () => {
    const style = document.createElement('style');
    document.head.appendChild(style);

    const div = document.createElement('div');
    div.textContent = 'this text should be red';
    document.body.appendChild(div);

    style.appendChild(document.createTextNode(`
  :root {
    --text-color: red;
  }    
 
  div {
    color: var(--text-color)
  }
  `));

    await snapshot();
  });
});
