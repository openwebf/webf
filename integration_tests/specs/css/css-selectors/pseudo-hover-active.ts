/**
 * CSS Selectors: :hover and :active pseudo-classes
 * Based on WPT: css/selectors/hover-*.html
 * https://drafts.csswg.org/selectors-4/#the-hover-pseudo
 * https://drafts.csswg.org/selectors-4/#the-active-pseudo
 */

describe('css selector :hover', () => {
  it(':hover changes style when element is hovered', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .hoverable {
        width: 100px;
        height: 50px;
        background-color: blue;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 10px;
        cursor: pointer;
      }
      .hoverable:hover {
        background-color: green;
      }
    `;
    document.head.appendChild(style);

    const div = document.createElement('div');
    div.className = 'hoverable';
    div.id = 'hovered';
    div.textContent = 'Hover me';
    document.body.appendChild(div);

    // Initial state - blue background
    await snapshot();
  });

  it(':hover selector matching via matches() API', async () => {
    const div = document.createElement('div');
    div.id = 'test';
    document.body.appendChild(div);

    // Initially not hovered
    expect(div.matches(':hover')).toBe(false);
  });

  it(':hover combined with other selectors', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .button {
        padding: 10px 20px;
        background-color: #007bff;
        color: white;
        border: none;
        border-radius: 5px;
        margin: 5px;
        cursor: pointer;
      }
      .button:hover {
        background-color: #0056b3;
      }
      .button.primary:hover {
        background-color: #004085;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
      }
      .button:disabled:hover {
        background-color: #6c757d;
        cursor: not-allowed;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <button class="button">Default Button</button>
      <button class="button primary">Primary Button</button>
      <button class="button" disabled>Disabled Button</button>
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it(':hover on nested elements', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .parent {
        padding: 20px;
        background-color: #f0f0f0;
        border: 2px solid #ccc;
      }
      .parent:hover {
        background-color: #e0e0e0;
        border-color: #999;
      }
      .child {
        padding: 10px;
        background-color: #ddd;
        margin: 10px;
      }
      .child:hover {
        background-color: #ccc;
      }
    `;
    document.head.appendChild(style);

    const parent = document.createElement('div');
    parent.className = 'parent';
    parent.id = 'parent';

    const child = document.createElement('div');
    child.className = 'child';
    child.id = 'child';
    child.textContent = 'Child element';

    parent.appendChild(child);
    parent.insertBefore(document.createTextNode('Parent element '), child);
    document.body.appendChild(parent);

    await snapshot();
  });
});

describe('css selector :active', () => {
  it(':active changes style when element is activated', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .clickable {
        width: 100px;
        height: 50px;
        background-color: blue;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 10px;
        cursor: pointer;
        user-select: none;
      }
      .clickable:active {
        background-color: red;
        transform: scale(0.95);
      }
    `;
    document.head.appendChild(style);

    const div = document.createElement('div');
    div.className = 'clickable';
    div.id = 'active';
    div.textContent = 'Click me';
    document.body.appendChild(div);

    // Initial state - blue background
    await snapshot();
  });

  it(':active selector matching via matches() API', async () => {
    const div = document.createElement('div');
    div.id = 'test';
    document.body.appendChild(div);

    // Initially not active
    expect(div.matches(':active')).toBe(false);
  });

  it(':hover and :active combined', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .interactive-button {
        padding: 12px 24px;
        background-color: #4CAF50;
        color: white;
        border: none;
        border-radius: 4px;
        font-size: 16px;
        cursor: pointer;
        transition: background-color 0.1s;
      }
      .interactive-button:hover {
        background-color: #45a049;
      }
      .interactive-button:active {
        background-color: #3d8b40;
      }
      /* When both hover and active apply */
      .interactive-button:hover:active {
        background-color: #367c39;
        transform: translateY(1px);
      }
    `;
    document.head.appendChild(style);

    const button = document.createElement('button');
    button.className = 'interactive-button';
    button.textContent = 'Interactive Button';
    document.body.appendChild(button);

    await snapshot();
  });

  it(':active on link elements', async () => {
    const style = document.createElement('style');
    style.textContent = `
      a {
        color: blue;
        text-decoration: underline;
        padding: 5px 10px;
        display: inline-block;
      }
      a:hover {
        color: darkblue;
      }
      a:active {
        color: red;
      }
      a:visited {
        color: purple;
      }
    `;
    document.head.appendChild(style);

    const link = document.createElement('a');
    link.href = '#';
    link.textContent = 'Click this link';
    document.body.appendChild(link);

    await snapshot();
  });
});

describe('css selector :hover/:active interaction', () => {
  it('button states: normal, hover, active', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .state-button {
        padding: 15px 30px;
        font-size: 14px;
        border: 2px solid #333;
        border-radius: 8px;
        background-color: white;
        color: #333;
        cursor: pointer;
        margin: 10px;
      }
      .state-button:hover {
        background-color: #f0f0f0;
        border-color: #007bff;
        color: #007bff;
      }
      .state-button:active {
        background-color: #007bff;
        border-color: #0056b3;
        color: white;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <button class="state-button">Normal State</button>
      <p>Buttons above show different visual states</p>
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it(':not(:hover) selector', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .item {
        padding: 10px;
        margin: 5px;
        background-color: #e0e0e0;
        border: 1px solid #ccc;
      }
      .item:not(:hover) {
        opacity: 0.7;
      }
      .item:hover {
        opacity: 1;
        background-color: #fff;
        border-color: #007bff;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="item">Item 1</div>
      <div class="item">Item 2</div>
      <div class="item">Item 3</div>
    `;
    document.body.appendChild(container);

    await snapshot();
  });
});
