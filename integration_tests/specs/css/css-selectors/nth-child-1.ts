describe('css selectors: nth-child-1', () => {
  it('renders nth-child stacking and styles', async () => {
    const style = document.createElement('style');
    style.innerHTML = `
      .demo > * {
        width: 250px;
        height: 200px;
        padding: 1em;
      }

      .demo > * + * {
        margin-top: -150px;
        opacity: 0.75;
      }

      .demo > :first-child {
        background: aliceblue;
        border: 12px solid red;
        z-index: 4;
      }

      .demo > :nth-child(2) {
        background: pink;
        border: 2px solid blue;
        margin-left: 50px;
        z-index: 1;
      }

      .demo > :last-child {
        background: wheat;
        border: 2px solid gold;
        z-index: 4;
        margin-left: 25px;
      }
    `;

    const container = document.createElement('div');
    container.className = 'demo';

    const box1 = document.createElement('div');
    box1.className = 'demo-box';
    const code1 = document.createElement('code');
    code1.textContent = 'z-index: 3;';
    box1.appendChild(code1);

    const box2 = document.createElement('div');
    box2.className = 'demo-box';
    const code2 = document.createElement('code');
    code2.textContent = 'z-index: 1;';
    box2.appendChild(code2);

    const box3 = document.createElement('div');
    box3.className = 'demo-box';
    const code3 = document.createElement('code');
    code3.textContent = 'z-index: 2;';
    box3.appendChild(code3);

    container.appendChild(box1);
    container.appendChild(box2);
    container.appendChild(box3);

    document.head.appendChild(style);
    document.body.appendChild(container);
    await snapshot();
  });
});

