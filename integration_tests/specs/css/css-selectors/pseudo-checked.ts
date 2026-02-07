/**
 * CSS Selectors: :checked pseudo-class
 * Based on WPT patterns
 * https://drafts.csswg.org/selectors-4/#checked
 */

describe('css selector :checked', () => {
  it(':checked matches checked checkboxes', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .checkbox-container {
        margin: 10px;
        padding: 10px;
      }
      input[type="checkbox"] {
        margin-right: 8px;
      }
      input[type="checkbox"]:checked + label {
        color: green;
        font-weight: bold;
      }
      input[type="checkbox"]:not(:checked) + label {
        color: gray;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.className = 'checkbox-container';
    container.innerHTML = `
      <div>
        <input type="checkbox" id="cb1" checked />
        <label for="cb1">Checked checkbox</label>
      </div>
      <div>
        <input type="checkbox" id="cb2" />
        <label for="cb2">Unchecked checkbox</label>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();

    // Verify matches() API
    const cb1 = document.getElementById('cb1') as HTMLInputElement;
    const cb2 = document.getElementById('cb2') as HTMLInputElement;

    expect(cb1.matches(':checked')).toBe(true);
    expect(cb2.matches(':checked')).toBe(false);
  });

  it(':checked matches checked radio buttons', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .radio-container {
        margin: 10px;
        padding: 10px;
      }
      input[type="radio"] {
        margin-right: 8px;
      }
      input[type="radio"]:checked + label {
        color: blue;
        font-weight: bold;
      }
      input[type="radio"]:not(:checked) + label {
        color: #666;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.className = 'radio-container';
    container.innerHTML = `
      <div>
        <input type="radio" name="color" id="red" value="red" checked />
        <label for="red">Red</label>
      </div>
      <div>
        <input type="radio" name="color" id="green" value="green" />
        <label for="green">Green</label>
      </div>
      <div>
        <input type="radio" name="color" id="blue" value="blue" />
        <label for="blue">Blue</label>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();

    // Verify matches() API
    const red = document.getElementById('red') as HTMLInputElement;
    const green = document.getElementById('green') as HTMLInputElement;
    const blue = document.getElementById('blue') as HTMLInputElement;

    expect(red.matches(':checked')).toBe(true);
    expect(green.matches(':checked')).toBe(false);
    expect(blue.matches(':checked')).toBe(false);
  });

  it(':checked matches selected option elements', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <select id="myselect">
        <option id="opt1" value="1">First</option>
        <option id="opt2" value="2" selected>Second (Selected)</option>
        <option id="opt3" value="3">Third</option>
      </select>
    `;
    document.body.appendChild(container);

    await snapshot();

    const opt1 = document.getElementById('opt1') as HTMLOptionElement;
    const opt2 = document.getElementById('opt2') as HTMLOptionElement;
    const opt3 = document.getElementById('opt3') as HTMLOptionElement;

    expect(opt1.matches(':checked')).toBe(false);
    expect(opt2.matches(':checked')).toBe(true);
    expect(opt3.matches(':checked')).toBe(false);
  });

  it(':checked custom checkbox styling', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .custom-checkbox {
        display: flex;
        align-items: center;
        margin: 10px;
        cursor: pointer;
      }
      .custom-checkbox input {
        display: none;
      }
      .custom-checkbox .checkmark {
        width: 20px;
        height: 20px;
        border: 2px solid #ccc;
        border-radius: 3px;
        margin-right: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      .custom-checkbox input:checked + .checkmark {
        background-color: #007bff;
        border-color: #007bff;
      }
      .custom-checkbox input:checked + .checkmark::after {
        content: 'X';
        color: white;
        font-weight: bold;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <label class="custom-checkbox">
        <input type="checkbox" checked />
        <span class="checkmark"></span>
        Checked item
      </label>
      <label class="custom-checkbox">
        <input type="checkbox" />
        <span class="checkmark"></span>
        Unchecked item
      </label>
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it(':checked toggles dynamically', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .toggle-container {
        margin: 10px;
      }
      input:checked + span {
        background-color: green;
        color: white;
        padding: 2px 8px;
        border-radius: 3px;
      }
      input:not(:checked) + span {
        background-color: red;
        color: white;
        padding: 2px 8px;
        border-radius: 3px;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.className = 'toggle-container';
    container.innerHTML = `
      <input type="checkbox" id="toggle" />
      <span id="status">OFF</span>
    `;
    document.body.appendChild(container);

    // Initial state - unchecked
    await snapshot();

    const toggle = document.getElementById('toggle') as HTMLInputElement;
    const status = document.getElementById('status') as HTMLSpanElement;

    expect(toggle.matches(':checked')).toBe(false);

    // Check the checkbox
    toggle.checked = true;
    status.textContent = 'ON';

    expect(toggle.matches(':checked')).toBe(true);

    // Checked state
    await snapshot();
  });
});
