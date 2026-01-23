describe('flex align-items:center with padding when free-space is 0', () => {
  it('should keep children vertically centered in the content box', async () => {
    document.body.style.margin = '0';
    document.body.style.padding = '0';
    document.body.style.background = '#fff';

    const container = document.createElement('div');
    container.style.cssText = `
      display: flex;
      width: 360px;
      justify-content: center;
      align-items: center;
      border: 1px solid #000;
      padding-top: 16px;
      padding-bottom: 40px;
      margin: 20px;
      box-sizing: border-box;
      font-family: Arial, sans-serif;
    `;

    const left = document.createElement('span');
    left.style.cssText = `
      display: inline-block;
      width: 40px;
      height: 1px;
      border: 1px solid #666;
      background: #666;
      box-sizing: border-box;
    `;

    const middle = document.createElement('div');
    middle.style.cssText = `
      padding: 0 16px;
      font-size: 16px;
      line-height: 24px;
      color: #666;
    `;
    middle.textContent = 'aaa';

    const right = document.createElement('span');
    right.style.cssText = left.style.cssText;

    container.appendChild(left);
    container.appendChild(middle);
    container.appendChild(right);
    document.body.appendChild(container);

    await snapshot();
  });
});

