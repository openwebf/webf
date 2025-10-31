describe('transition: absolute top + translateY(%) + height', () => {
  it('stays within container and ends flush top', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .host {
        position: relative;
        margin: 0 auto;
        width: 200px;
        height: 200px;
        border: 1px solid #000;
        background: #fff;
      }
      .box {
        position: absolute;
        background: green;
        width: 50px;
        height: 50px;
        top: 100%;
        transform: translateY(-100%);
        transition-property: top, transform, height;
        transition-duration: 300ms;
        transition-timing-function: linear;
      }
    `;
    document.head.appendChild(style);

    const host = document.createElement('div');
    host.className = 'host';
    const box = document.createElement('div');
    box.className = 'box';
    host.appendChild(box);
    document.body.appendChild(host);

    await snapshot();

    box.style.top = '0px';
    box.style.transform = 'none';
    box.style.height = '80px';

    await new Promise((r) => setTimeout(r, 360));
    await snapshot();
  });
});

