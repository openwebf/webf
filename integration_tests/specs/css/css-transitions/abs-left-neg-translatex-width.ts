describe('transition: absolute left + translateX(-100%) + width', () => {
  it('stays within container and ends flush left', async () => {
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
        background: orange;
        width: 50px;
        height: 50px;
        left: 100%;
        transform: translateX(-100%);
        transition-property: left, transform, width;
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

    box.style.left = '0px';
    box.style.transform = 'none';
    box.style.width = '80px';

    await new Promise((r) => setTimeout(r, 360));
    await snapshot();
  });
});

