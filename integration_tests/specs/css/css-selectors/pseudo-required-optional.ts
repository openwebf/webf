/**
 * CSS Selectors: :required and :optional pseudo-classes
 * Based on WPT patterns
 * https://drafts.csswg.org/selectors-4/#opt-pseudos
 */

describe('css selector :required/:optional', () => {
  it(':required matches elements with required attribute', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .form-group {
        margin: 15px 10px;
      }
      label {
        display: block;
        margin-bottom: 5px;
      }
      input {
        width: 200px;
        padding: 8px;
        border: 2px solid #ccc;
        border-radius: 4px;
      }
      input:required {
        border-left: 4px solid #dc3545;
      }
      input:optional {
        border-left: 4px solid #6c757d;
      }
      label::after {
        content: '';
      }
      input:required + label::after {
        content: ' *';
        color: #dc3545;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="form-group">
        <input type="text" id="name" required placeholder="Enter your name" />
        <label for="name">Name</label>
      </div>
      <div class="form-group">
        <input type="text" id="nickname" placeholder="Enter nickname (optional)" />
        <label for="nickname">Nickname</label>
      </div>
      <div class="form-group">
        <input type="email" id="email" required placeholder="Enter email" />
        <label for="email">Email</label>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();

    const name = document.getElementById('name') as HTMLInputElement;
    const nickname = document.getElementById('nickname') as HTMLInputElement;
    const email = document.getElementById('email') as HTMLInputElement;

    expect(name.matches(':required')).toBe(true);
    expect(name.matches(':optional')).toBe(false);

    expect(nickname.matches(':required')).toBe(false);
    expect(nickname.matches(':optional')).toBe(true);

    expect(email.matches(':required')).toBe(true);
    expect(email.matches(':optional')).toBe(false);
  });

  it(':required/:optional for different input types', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .input-row {
        margin: 10px;
        display: flex;
        align-items: center;
      }
      input, select, textarea {
        padding: 8px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin-right: 10px;
      }
      input:required,
      select:required,
      textarea:required {
        border-color: #ff6b6b;
      }
      input:optional,
      select:optional,
      textarea:optional {
        border-color: #4ecdc4;
      }
      .indicator {
        font-size: 12px;
        padding: 2px 6px;
        border-radius: 3px;
        color: white;
      }
      .required-indicator {
        background-color: #ff6b6b;
      }
      .optional-indicator {
        background-color: #4ecdc4;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="input-row">
        <input type="text" id="text-req" required placeholder="Required text" />
        <span class="indicator required-indicator">Required</span>
      </div>
      <div class="input-row">
        <input type="text" id="text-opt" placeholder="Optional text" />
        <span class="indicator optional-indicator">Optional</span>
      </div>
      <div class="input-row">
        <input type="email" id="email-req" required placeholder="Required email" />
        <span class="indicator required-indicator">Required</span>
      </div>
      <div class="input-row">
        <select id="select-req" required>
          <option value="">Choose...</option>
          <option value="1">Option 1</option>
        </select>
        <span class="indicator required-indicator">Required</span>
      </div>
      <div class="input-row">
        <select id="select-opt">
          <option value="">Choose...</option>
          <option value="1">Option 1</option>
        </select>
        <span class="indicator optional-indicator">Optional</span>
      </div>
      <div class="input-row">
        <textarea id="textarea-req" required placeholder="Required message"></textarea>
        <span class="indicator required-indicator">Required</span>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();

    // Verify all required elements match :required
    const requiredElements = container.querySelectorAll('[required]');
    for (let i = 0; i < requiredElements.length; i++) {
      expect(requiredElements[i].matches(':required')).toBe(true);
      expect(requiredElements[i].matches(':optional')).toBe(false);
    }

    // Verify optional elements
    const textOpt = document.getElementById('text-opt') as HTMLInputElement;
    const selectOpt = document.getElementById('select-opt') as HTMLSelectElement;

    expect(textOpt.matches(':optional')).toBe(true);
    expect(selectOpt.matches(':optional')).toBe(true);
  });

  it(':required combined with :valid/:invalid', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .field {
        margin: 10px;
        padding: 10px;
        border-radius: 4px;
      }
      input {
        width: 200px;
        padding: 8px;
        border: 2px solid #ccc;
        border-radius: 4px;
      }
      /* Required and valid */
      input:required:valid {
        border-color: #28a745;
        background-color: #e8f5e9;
      }
      /* Required and invalid */
      input:required:invalid {
        border-color: #dc3545;
        background-color: #ffebee;
      }
      /* Optional - always has neutral styling */
      input:optional {
        border-color: #6c757d;
      }
      .status {
        font-size: 12px;
        margin-top: 5px;
      }
      input:required:valid ~ .status {
        color: #28a745;
      }
      input:required:invalid ~ .status {
        color: #dc3545;
      }
      input:optional ~ .status {
        color: #6c757d;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="field">
        <input type="text" required value="Filled" placeholder="Required" />
        <div class="status">Required field - filled (valid)</div>
      </div>
      <div class="field">
        <input type="text" required placeholder="Required" />
        <div class="status">Required field - empty (invalid)</div>
      </div>
      <div class="field">
        <input type="text" placeholder="Optional" />
        <div class="status">Optional field</div>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it('querySelectorAll with :required/:optional', async () => {
    const container = document.createElement('div');
    container.id = 'form-container';
    container.innerHTML = `
      <input type="text" id="r1" required />
      <input type="text" id="o1" />
      <input type="email" id="r2" required />
      <input type="email" id="o2" />
      <textarea id="r3" required></textarea>
      <textarea id="o3"></textarea>
    `;
    document.body.appendChild(container);

    const requiredElements = container.querySelectorAll(':required');
    const optionalElements = container.querySelectorAll(':optional');

    expect(requiredElements.length).toBe(3);
    expect(optionalElements.length).toBe(3);

    // Verify required elements have 'r' prefix
    for (let i = 0; i < requiredElements.length; i++) {
      const element = requiredElements[i] as HTMLElement;
      expect(element.id.startsWith('r')).toBe(true);
    }

    // Verify optional elements have 'o' prefix
    for (let i = 0; i < optionalElements.length; i++) {
      const element = optionalElements[i] as HTMLElement;
      expect(element.id.startsWith('o')).toBe(true);
    }
  });

  it(':not(:required) matches optional and non-form elements', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <input type="text" id="required-input" required />
      <input type="text" id="optional-input" />
      <span id="not-form">Not a form element</span>
    `;
    document.body.appendChild(container);

    const matched = container.querySelectorAll(':not(:required)');

    // Should match optional-input and not-form
    const ids = Array.from(matched).map((el: Element) => (el as HTMLElement).id);
    expect(ids).toContain('optional-input');
    expect(ids).toContain('not-form');
    expect(ids).not.toContain('required-input');
  });

  it('dynamic required attribute change', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input {
        width: 200px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 10px;
      }
      input:required {
        border-color: red;
      }
      input:optional {
        border-color: blue;
      }
    `;
    document.head.appendChild(style);

    const input = document.createElement('input');
    input.type = 'text';
    input.id = 'dynamic-required';
    input.placeholder = 'Toggle required';
    document.body.appendChild(input);

    // Initially optional
    await snapshot();
    expect(input.matches(':required')).toBe(false);
    expect(input.matches(':optional')).toBe(true);

    // Add required attribute
    input.required = true;

    await snapshot();
    expect(input.matches(':required')).toBe(true);
    expect(input.matches(':optional')).toBe(false);

    // Remove required attribute
    input.required = false;

    await snapshot();
    expect(input.matches(':required')).toBe(false);
    expect(input.matches(':optional')).toBe(true);
  });
});
