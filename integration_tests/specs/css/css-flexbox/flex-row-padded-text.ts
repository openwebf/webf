describe('flex row with padded text container', () => {
  it('renders container3 with aqua box and container4 span', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .container3 {
        flex-direction: row;
        padding: 15px;
        background-color: red;
        display: flex;
      }

      .container4 {
        padding: 20px;
        margin: 10px;
        background: lightseagreen;
      }
    `;
    document.head.appendChild(style);

    const container3 = document.createElement('div');
    container3.className = 'container3';

    const aquaBox = document.createElement('div');
    aquaBox.setAttribute('style', 'width: 30px; height: 30px; background: aqua;');

    const container4 = document.createElement('div');
    container4.className = 'container4';

    const span = document.createElement('span');
    span.textContent = 'A splash screen was provided to Flutter, but this is deprecated. See flutter.dev.';

    container4.appendChild(span);
    container3.appendChild(aquaBox);
    container3.appendChild(container4);
    document.body.appendChild(container3);

    await snapshot();
  });
});

