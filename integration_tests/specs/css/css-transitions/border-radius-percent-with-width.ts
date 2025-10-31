describe('transition: border-radius(%) with width change', () => {
  it('maintains expected rounded shape as size changes', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .box {
        width: 50px;
        height: 50px;
        background: #4aa3ff;
        border-radius: 50%;
        transition: width 300ms linear;
      }
    `;
    document.head.appendChild(style);

    const box = document.createElement('div');
    box.className = 'box';
    document.body.appendChild(box);

    await snapshot();
    box.style.width = '80px';
    await new Promise((r) => setTimeout(r, 360));
    await snapshot();
  });
});

