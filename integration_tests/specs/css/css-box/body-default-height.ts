describe('Body default content height (issue #149)', () => {
  it('body background and content layout with :root CSS variables', async () => {
    const style = document.createElement('style');
    style.textContent = `
      :root {
        --blue: #1e90ff;
        --white: #ffffff;
      }
      body { background-color: var(--blue); }
      h2 { border-bottom: 2px solid var(--blue); margin: 0 0 8px; }
      .container {
        color: var(--blue);
        background-color: var(--white);
        padding: 15px;
        box-sizing: border-box;
      }
      button {
        background-color: var(--white);
        color: var(--blue);
        border: 1px solid var(--blue);
        padding: 5px;
        margin-right: 6px;
      }
    `;
    document.head.appendChild(style);

    const title = document.createElement('h1');
    title.textContent = 'Change CSS Variable With JavaScript';

    const container = document.createElement('div');
    container.className = 'container';

    const h2 = document.createElement('h2');
    h2.textContent = 'Lorem Ipsum';

    const p1 = document.createElement('p');
    p1.textContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam semper diam at erat pulvinar, at pulvinar felis blandit.';

    const p2 = document.createElement('p');
    p2.textContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam semper diam at erat pulvinar, at pulvinar felis blandit.';

    const p3 = document.createElement('p');
    const bYes = document.createElement('button');
    bYes.textContent = 'Yes';
    const bNo = document.createElement('button');
    bNo.textContent = 'No';
    p3.appendChild(bYes);
    p3.appendChild(bNo);

    container.appendChild(h2);
    container.appendChild(p1);
    container.appendChild(p2);
    container.appendChild(p3);

    document.body.appendChild(title);
    document.body.appendChild(container);

    await waitForOnScreen(container);

    // Basic sanity checks for the scenario
    const csBody = getComputedStyle(document.body);
    expect(csBody.backgroundColor).toBe('rgb(30, 144, 255)'); // var(--blue)
    const csH2 = getComputedStyle(h2);
    expect(csH2.borderBottomColor).toBe('rgb(30, 144, 255)');

    // Body should have non-zero height to contain content (regression guard)
    const bodyRect = document.body.getBoundingClientRect();
    expect(bodyRect.height > 0).toBe(true);

    await snapshot();
  });
});

