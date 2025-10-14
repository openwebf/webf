describe('css selectors: html.dark match', () => {
  it('applies styles when html has class', async () => {
    const style = document.createElement('style');
    style.innerHTML = `
      body {
        width: 100%;
        height: 100vh;
        margin: 0;
      }

      html.dark {
        color: aquamarine;
      }
    `;

    document.documentElement.className = 'dark';
    document.documentElement.style.fontSize = '9.25926vw';

    const wrapper = document.createElement('div');
    const span = document.createElement('span');
    span.className = 'content';
    span.textContent = 'content';
    wrapper.appendChild(span);

    document.head.appendChild(style);
    document.body.appendChild(wrapper);
    await snapshot();
  });
});

