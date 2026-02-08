/**
 * CSS Selectors: :focus-within pseudo-class
 * Based on WPT: css/selectors/focus-within-*.html
 * https://drafts.csswg.org/selectors-4/#focus-within-pseudo
 */

describe('css selector :focus-within', () => {
  it(':focus-within applies to element when itself has focus', async () => {
    const style = document.createElement('style');
    style.textContent = `
      :focus { outline: none; }
      div {
        border: 15px solid blue;
        padding: 10px;
        margin: 10px;
      }
      div:focus {
        border-color: red;
      }
      div:focus-within {
        border-color: green;
      }
    `;
    document.head.appendChild(style);

    const div = document.createElement('div');
    div.id = 'focusme';
    div.tabIndex = 1;
    div.textContent = 'Focus this element';
    document.body.appendChild(div);

    // Before focus - should be blue
    await snapshot();

    // Focus the element
    div.focus();

    // After focus - should be green (:focus-within takes effect)
    await snapshot();
  });

  it(':focus-within applies to ancestor when descendant is focused', async () => {
    const style = document.createElement('style');
    style.textContent = `
      :focus { outline: none; }
      .container {
        border: 10px solid blue;
        padding: 20px;
        margin: 10px;
      }
      .container:focus-within {
        border-color: green;
        background-color: #e0ffe0;
      }
      input {
        padding: 8px;
        border: 2px solid gray;
      }
      input:focus {
        border-color: green;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.className = 'container';
    container.id = 'parent';

    const input = document.createElement('input');
    input.type = 'text';
    input.id = 'child';
    input.placeholder = 'Focus me';

    container.appendChild(input);
    document.body.appendChild(container);

    // Before focus - container should have blue border
    await snapshot();

    // Focus the input
    input.focus();

    // After focus - container should have green border due to :focus-within
    await snapshot();
  });

  it(':focus-within propagates through nested elements', async () => {
    const style = document.createElement('style');
    style.textContent = `
      :focus { outline: none; }
      .level {
        border: 5px solid blue;
        padding: 10px;
        margin: 5px;
      }
      .level:focus-within {
        border-color: green;
      }
      input {
        padding: 5px;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="level" id="level1">
        Level 1
        <div class="level" id="level2">
          Level 2
          <div class="level" id="level3">
            Level 3
            <input type="text" id="deep-input" placeholder="Deep input" />
          </div>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    // Before focus
    await snapshot();

    // Focus the deep input
    const input = document.getElementById('deep-input') as HTMLInputElement;
    input.focus();

    // All ancestor levels should have green border
    await snapshot();
  });

  it(':focus-within with form validation feedback', async () => {
    const style = document.createElement('style');
    style.textContent = `
      :focus { outline: none; }
      .form-group {
        border: 3px solid #ccc;
        padding: 15px;
        margin: 10px;
        border-radius: 5px;
      }
      .form-group:focus-within {
        border-color: #007bff;
        box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
      }
      label {
        display: block;
        margin-bottom: 5px;
        font-weight: bold;
      }
      input {
        width: 200px;
        padding: 8px;
        border: 1px solid #ccc;
        border-radius: 3px;
      }
    `;
    document.head.appendChild(style);

    const formGroup = document.createElement('div');
    formGroup.className = 'form-group';
    formGroup.innerHTML = `
      <label for="email">Email Address</label>
      <input type="email" id="email" placeholder="Enter your email" />
    `;
    document.body.appendChild(formGroup);

    // Before focus
    await snapshot();

    // Focus the input
    const input = document.getElementById('email') as HTMLInputElement;
    input.focus();

    // Form group should be highlighted
    await snapshot();
  });

  it(':focus-within combined with :hover', async () => {
    const style = document.createElement('style');
    style.textContent = `
      :focus { outline: none; }
      .card {
        border: 3px solid gray;
        padding: 15px;
        margin: 10px;
        transition: border-color 0.2s;
      }
      .card:hover {
        border-color: blue;
      }
      .card:focus-within {
        border-color: green;
      }
      /* :focus-within takes precedence when both apply */
      .card:hover:focus-within {
        border-color: purple;
      }
      input {
        padding: 8px;
        width: 150px;
      }
    `;
    document.head.appendChild(style);

    const card = document.createElement('div');
    card.className = 'card';
    card.id = 'card';
    card.innerHTML = `
      <p>Interactive Card</p>
      <input type="text" id="card-input" placeholder="Type here" />
    `;
    document.body.appendChild(card);

    await snapshot();

    // Focus the input
    const input = document.getElementById('card-input') as HTMLInputElement;
    input.focus();

    await snapshot();
  });

  it('matches() API works with :focus-within', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="parent">
        <input id="child" type="text" />
      </div>
    `;
    document.body.appendChild(container);

    const parent = document.getElementById('parent') as HTMLElement;
    const child = document.getElementById('child') as HTMLInputElement;

    // Before focus
    expect(parent.matches(':focus-within')).toBe(false);
    expect(child.matches(':focus-within')).toBe(false);

    // Focus child
    child.focus();

    // Parent and child should match :focus-within
    expect(parent.matches(':focus-within')).toBe(true);
    expect(child.matches(':focus-within')).toBe(true);

    // Blur
    child.blur();

    // Should no longer match
    expect(parent.matches(':focus-within')).toBe(false);
    expect(child.matches(':focus-within')).toBe(false);
  });
});
