describe('transition: absolute right + translateX(%) + width', () => {
  it('stays within container and ends flush right', async () => {
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
        background: red;
        width: 50px;
        height: 50px;
        right: 100%;
        transform: translateX(100%);
        transition-property: right, transform, width;
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

    // Initial (box at left edge, fully inside)
    await snapshot();

    // Trigger transition to right:0 / transform:none / width:80px
    box.style.right = '0px';
    box.style.transform = 'none';
    box.style.width = '80px';

    // Wait for transition to complete
    await new Promise((r) => setTimeout(r, 360));
    await snapshot();
  });
});

