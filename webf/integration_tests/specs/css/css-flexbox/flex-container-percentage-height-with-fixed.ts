describe('flex container percentage height with fixed item', () => {
  it('renders layout with text box and fixed square', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .container {
        width: 100px;
        height: 19.55%;
        color: #040b29;
        background-color: #fff;
        justify-content: space-between;
        padding: 10px;
        display: flex;
      }

      .text_box {
        flex: 1;
        background: blue;
      }

      .fixed {
        width: 30px;
        height: 30px;
        background: red;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.className = 'container';

    const textBox = document.createElement('div');
    textBox.className = 'text_box';
    const span = document.createElement('span');
    span.textContent = '你好，你好，你好，你好，你好。';
    textBox.appendChild(span);

    const fixed = document.createElement('div');
    fixed.className = 'fixed';
    fixed.textContent = '1';

    container.appendChild(textBox);
    container.appendChild(fixed);
    document.body.appendChild(container);

    await snapshot();
  });
});

