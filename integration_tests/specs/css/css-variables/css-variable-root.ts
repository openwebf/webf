describe('CSS Variables on :root', () => {
  it('should apply CSS variables defined on :root to child elements', async (done) => {
    const style = document.createElement('style');
    style.textContent = `
      :root {
        --primary-color: blue;
        --font-size: 20px;
      }
      .test {
        color: var(--primary-color);
        font-size: var(--font-size);
      }
    `;
    document.head.appendChild(style);

    const div = document.createElement('div');
    div.className = 'test';
    div.textContent = 'This text should be blue and 20px';
    document.body.appendChild(div);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should update CSS variables on :root dynamically', async (done) => {
    const style = document.createElement('style');
    style.textContent = `
      :root {
        --bg-color: red;
      }
      .container {
        background-color: var(--bg-color);
        width: 100px;
        height: 100px;
      }
    `;
    document.head.appendChild(style);

    const div = document.createElement('div');
    div.className = 'container';
    document.body.appendChild(div);

    requestAnimationFrame(async () => {
      // Change the CSS variable on :root
      const root = document.documentElement;
      root.style.setProperty('--bg-color', 'green');

      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });

  xit('should match :root selector correctly', async (done) => {
    const style = document.createElement('style');
    style.textContent = `
      :root {
        background-color: yellow;
      }
      html {
        padding: 20px;
      }
    `;
    document.head.appendChild(style);

    requestAnimationFrame(async () => {
      const root = document.querySelector(':root');
      expect(root).toBe(document.documentElement);
      expect(root.tagName).toBe('HTML');

      const computedStyle = getComputedStyle(root);
      expect(computedStyle.backgroundColor).toBe('rgb(255, 255, 0)'); // yellow

      await snapshot();
      done();
    });
  });

  it('should inherit CSS variables from :root to nested elements', async (done) => {
    const style = document.createElement('style');
    style.textContent = `
      :root {
        --spacing: 10px;
        --text-color: purple;
      }
      .parent {
        padding: var(--spacing);
        color: var(--text-color);
      }
      .child {
        margin: var(--spacing);
        border: 2px solid var(--text-color);
      }
    `;
    document.head.appendChild(style);

    const parent = document.createElement('div');
    parent.className = 'parent';
    parent.textContent = 'Parent element';

    const child = document.createElement('div');
    child.className = 'child';
    child.textContent = 'Child element';

    parent.appendChild(child);
    document.body.appendChild(parent);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });
});
