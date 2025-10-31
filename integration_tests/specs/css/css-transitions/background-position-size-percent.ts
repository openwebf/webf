describe('transition: background-position(%) with background-size(%)', () => {
  it('keeps background within container during transition', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .box {
        width: 200px;
        height: 120px;
        border: 1px solid #000;
        background-image: linear-gradient(90deg, red, blue);
        background-repeat: no-repeat;
        background-size: 50% 100%;
        background-position: 100% 0%;
        transition: background-position 300ms linear, background-size 300ms linear;
      }
    `;
    document.head.appendChild(style);

    const box = document.createElement('div');
    box.className = 'box';
    document.body.appendChild(box);

    await snapshot();

    box.style.backgroundSize = '80% 100%';
    box.style.backgroundPosition = '0% 0%';

    await new Promise((r) => setTimeout(r, 360));
    await snapshot();
  });
});

