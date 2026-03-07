/**
 * CSS Selectors: :focus and :focus-visible pseudo-classes
 * Based on WPT: css/selectors/focus-visible-*.html
 * https://drafts.csswg.org/selectors-4/#the-focus-pseudo
 * https://drafts.csswg.org/selectors-4/#the-focus-visible-pseudo
 */

describe('css selector :focus', () => {
  it(':focus applies to focused element', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input {
        width: 200px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 10px;
        outline: none;
      }
      input:focus {
        border-color: #007bff;
        box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
      }
    `;
    document.head.appendChild(style);

    const input = document.createElement('input');
    input.type = 'text';
    input.id = 'focusable';
    input.placeholder = 'Click to focus';
    document.body.appendChild(input);

    // Before focus
    await snapshot();
    expect(input.matches(':focus')).toBe(false);

    // Focus the input
    input.focus();

    // After focus
    await snapshot();
    expect(input.matches(':focus')).toBe(true);

    // Blur
    input.blur();
    expect(input.matches(':focus')).toBe(false);
  });

  it(':focus on tabindex elements', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .focusable-div {
        padding: 20px;
        margin: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        cursor: pointer;
      }
      .focusable-div:focus {
        border-color: green;
        background-color: #e8f5e9;
        outline: none;
      }
    `;
    document.head.appendChild(style);

    const div = document.createElement('div');
    div.className = 'focusable-div';
    div.id = 'focusable-div';
    div.tabIndex = 0;
    div.textContent = 'Click to focus this div';
    document.body.appendChild(div);

    await snapshot();
    expect(div.matches(':focus')).toBe(false);

    div.focus();

    await snapshot();
    expect(div.matches(':focus')).toBe(true);
  });

  it(':focus styling for form elements', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .form-control {
        width: 200px;
        padding: 10px;
        border: 1px solid #ced4da;
        border-radius: 4px;
        margin: 10px;
        display: block;
        transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
      }
      .form-control:focus {
        border-color: #80bdff;
        outline: 0;
        box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
      }
      button.form-control:focus {
        background-color: #0056b3;
        color: white;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <input class="form-control" type="text" placeholder="Text input" />
      <textarea class="form-control" placeholder="Textarea"></textarea>
      <select class="form-control">
        <option>Select option</option>
        <option>Option 1</option>
        <option>Option 2</option>
      </select>
      <button class="form-control">Button</button>
    `;
    document.body.appendChild(container);

    await snapshot();
  });
});

describe('css selector :focus-visible', () => {
  it(':focus-visible for keyboard navigation indication', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .btn {
        padding: 10px 20px;
        margin: 10px;
        border: 2px solid #007bff;
        background-color: #007bff;
        color: white;
        border-radius: 4px;
        cursor: pointer;
        outline: none;
      }
      /* Remove default focus ring for mouse users */
      .btn:focus:not(:focus-visible) {
        box-shadow: none;
      }
      /* Show focus ring only for keyboard users */
      .btn:focus-visible {
        box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.5);
        border-color: #0056b3;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <button class="btn" id="btn1">Button 1</button>
      <button class="btn" id="btn2">Button 2</button>
      <button class="btn" id="btn3">Button 3</button>
      <p>Focus ring should only appear for keyboard navigation</p>
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it(':focus-visible matches() API', async () => {
    const div = document.createElement('div');
    div.id = 'test';
    div.tabIndex = 0;
    document.body.appendChild(div);

    expect(div.matches(':focus-visible')).toBe(false);

    // Note: :focus-visible behavior depends on the focus modality
    // In actual browsers, keyboard focus triggers :focus-visible
    // while mouse click focus may not
  });

  it(':focus and :focus-visible combined styling', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .input-field {
        margin: 15px 10px;
      }
      input {
        width: 200px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        font-size: 14px;
        outline: none;
      }
      /* All focus states get border change */
      input:focus {
        border-color: #007bff;
      }
      /* Only keyboard focus gets the ring */
      input:focus-visible {
        box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
      }
      /* Style for :focus but not :focus-visible (mouse click) */
      input:focus:not(:focus-visible) {
        box-shadow: none;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="input-field">
        <label>Click to focus (no ring):</label>
        <input type="text" id="click-focus" placeholder="Click focus" />
      </div>
      <div class="input-field">
        <label>Tab to focus (with ring):</label>
        <input type="text" id="tab-focus" placeholder="Tab focus" />
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it('accessible focus indicator pattern', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .accessible-link {
        color: #007bff;
        text-decoration: underline;
        padding: 2px 4px;
        margin: 5px;
        display: inline-block;
      }
      /* Remove default outline */
      .accessible-link:focus {
        outline: none;
      }
      /* Provide visible focus for keyboard users */
      .accessible-link:focus-visible {
        background-color: #007bff;
        color: white;
        border-radius: 2px;
        text-decoration: none;
      }
      .card {
        padding: 20px;
        margin: 10px;
        border: 1px solid #ddd;
        border-radius: 8px;
        cursor: pointer;
      }
      .card:focus {
        outline: none;
        border-color: #007bff;
      }
      .card:focus-visible {
        box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.5);
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <p>
        <a href="#" class="accessible-link">Link 1</a>
        <a href="#" class="accessible-link">Link 2</a>
        <a href="#" class="accessible-link">Link 3</a>
      </p>
      <div class="card" tabindex="0">
        <h3>Interactive Card</h3>
        <p>This card is focusable and shows focus ring only for keyboard navigation.</p>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();
  });
});

describe('css selector :focus combined with other pseudo-classes', () => {
  it(':focus:hover combined state', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input {
        width: 200px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 10px;
        outline: none;
        transition: all 0.2s;
      }
      input:hover {
        border-color: #999;
      }
      input:focus {
        border-color: #007bff;
      }
      /* When both hover and focus apply */
      input:focus:hover {
        border-color: #0056b3;
        box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
      }
    `;
    document.head.appendChild(style);

    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = 'Hover and focus me';
    document.body.appendChild(input);

    await snapshot();
  });

  it(':focus:not(:disabled) selector', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input {
        width: 200px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 10px;
        outline: none;
      }
      input:focus:not(:disabled) {
        border-color: green;
        box-shadow: 0 0 0 2px rgba(0, 128, 0, 0.25);
      }
      input:disabled {
        background-color: #f0f0f0;
        cursor: not-allowed;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <input type="text" placeholder="Enabled - can focus" />
      <input type="text" placeholder="Disabled - cannot focus" disabled />
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it(':focus:valid and :focus:invalid states', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input {
        width: 200px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 10px;
        outline: none;
      }
      input:focus:valid {
        border-color: #28a745;
        box-shadow: 0 0 0 2px rgba(40, 167, 69, 0.25);
      }
      input:focus:invalid {
        border-color: #dc3545;
        box-shadow: 0 0 0 2px rgba(220, 53, 69, 0.25);
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <input type="email" value="valid@email.com" placeholder="Valid email" />
      <input type="email" value="invalid" placeholder="Invalid email" />
      <input type="text" required placeholder="Required (empty = invalid)" />
      <input type="text" required value="filled" placeholder="Required (filled = valid)" />
    `;
    document.body.appendChild(container);

    await snapshot();

    // Focus the first input (valid email)
    const validEmail = container.querySelector('input[value="valid@email.com"]') as HTMLInputElement;
    console.log("validEmail:", validEmail)
    validEmail.focus();

    await snapshot();
  });
});
