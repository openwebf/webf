/**
 * CSS Selectors: :valid and :invalid pseudo-classes
 * Based on WPT patterns
 * https://drafts.csswg.org/selectors-4/#validity-pseudos
 */

describe('css selector :valid/:invalid', () => {
  it(':valid matches valid form controls', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input {
        width: 200px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 10px;
      }
      input:valid {
        border-color: green;
      }
      input:invalid {
        border-color: red;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <input type="text" id="optional-empty" placeholder="Optional (empty)" />
      <input type="text" id="optional-filled" placeholder="Optional" value="has value" />
      <input type="text" id="required-empty" placeholder="Required (empty)" required />
      <input type="text" id="required-filled" placeholder="Required" value="has value" required />
    `;
    document.body.appendChild(container);

    await snapshot();

    // Optional empty - valid
    const optionalEmpty = document.getElementById('optional-empty') as HTMLInputElement;
    expect(optionalEmpty.matches(':valid')).toBe(true);
    expect(optionalEmpty.matches(':invalid')).toBe(false);

    // Optional filled - valid
    const optionalFilled = document.getElementById('optional-filled') as HTMLInputElement;
    expect(optionalFilled.matches(':valid')).toBe(true);
    expect(optionalFilled.matches(':invalid')).toBe(false);

    // Required empty - invalid
    const requiredEmpty = document.getElementById('required-empty') as HTMLInputElement;
    expect(requiredEmpty.matches(':valid')).toBe(false);
    expect(requiredEmpty.matches(':invalid')).toBe(true);

    // Required filled - valid
    const requiredFilled = document.getElementById('required-filled') as HTMLInputElement;
    expect(requiredFilled.matches(':valid')).toBe(true);
    expect(requiredFilled.matches(':invalid')).toBe(false);
  });

  it(':valid/:invalid for email type input', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .email-field {
        margin: 10px;
        padding: 10px;
      }
      input[type="email"] {
        width: 200px;
        padding: 8px;
        border: 2px solid #ccc;
        border-radius: 4px;
      }
      input[type="email"]:valid {
        border-color: green;
        background-color: #e8f5e9;
      }
      input[type="email"]:invalid {
        border-color: red;
        background-color: #ffebee;
      }
      .validation-message {
        font-size: 12px;
        margin-top: 5px;
      }
      input:valid + .validation-message {
        color: green;
      }
      input:invalid + .validation-message {
        color: red;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="email-field">
        <input type="email" id="valid-email" value="test@example.com" />
        <div class="validation-message">Valid email format</div>
      </div>
      <div class="email-field">
        <input type="email" id="invalid-email" value="not-an-email" />
        <div class="validation-message">Invalid email format</div>
      </div>
      <div class="email-field">
        <input type="email" id="empty-email" placeholder="Optional email" />
        <div class="validation-message">Empty optional email (valid)</div>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();

    const validEmail = document.getElementById('valid-email') as HTMLInputElement;
    const invalidEmail = document.getElementById('invalid-email') as HTMLInputElement;
    const emptyEmail = document.getElementById('empty-email') as HTMLInputElement;

    expect(validEmail.matches(':valid')).toBe(true);
    expect(invalidEmail.matches(':invalid')).toBe(true);
    expect(emptyEmail.matches(':valid')).toBe(true); // Empty optional is valid
  });

  it(':valid/:invalid for checkbox required', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .checkbox-group {
        margin: 10px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
      }
      .checkbox-group:has(input:invalid) {
        border-color: red;
        background-color: #fff0f0;
      }
      .checkbox-group:has(input:valid) {
        border-color: green;
        background-color: #f0fff0;
      }
      input[type="checkbox"] {
        margin-right: 8px;
      }
      input[type="checkbox"]:valid + label {
        color: green;
      }
      input[type="checkbox"]:invalid + label {
        color: red;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="checkbox-group">
        <input type="checkbox" id="required-unchecked" required />
        <label for="required-unchecked">I agree to terms (required, unchecked)</label>
      </div>
      <div class="checkbox-group">
        <input type="checkbox" id="required-checked" required checked />
        <label for="required-checked">I agree to terms (required, checked)</label>
      </div>
      <div class="checkbox-group">
        <input type="checkbox" id="optional-unchecked" />
        <label for="optional-unchecked">Subscribe to newsletter (optional)</label>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();

    const requiredUnchecked = document.getElementById('required-unchecked') as HTMLInputElement;
    const requiredChecked = document.getElementById('required-checked') as HTMLInputElement;
    const optionalUnchecked = document.getElementById('optional-unchecked') as HTMLInputElement;

    expect(requiredUnchecked.matches(':invalid')).toBe(true);
    expect(requiredChecked.matches(':valid')).toBe(true);
    expect(optionalUnchecked.matches(':valid')).toBe(true);
  });

  it(':valid/:invalid disabled inputs are always valid', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input {
        width: 200px;
        padding: 8px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 10px;
      }
      input:valid {
        border-color: green;
      }
      input:invalid {
        border-color: red;
      }
      input:disabled {
        background-color: #f0f0f0;
        opacity: 0.6;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <input type="text" id="disabled-required" required disabled placeholder="Disabled required" />
      <input type="email" id="disabled-invalid-email" value="invalid" disabled />
    `;
    document.body.appendChild(container);

    await snapshot();

    // Disabled inputs are barred from constraint validation and match neither :valid nor :invalid.
    const disabledRequired = document.getElementById('disabled-required') as HTMLInputElement;
    const disabledInvalidEmail = document.getElementById('disabled-invalid-email') as HTMLInputElement;

    expect(disabledRequired.matches(':valid')).toBe(false);
    expect(disabledRequired.matches(':invalid')).toBe(false);

    expect(disabledInvalidEmail.matches(':valid')).toBe(false);
    expect(disabledInvalidEmail.matches(':invalid')).toBe(false);
  });

  it(':valid/:invalid form validation styling', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .form-field {
        margin: 15px 10px;
      }
      label {
        display: block;
        margin-bottom: 5px;
        font-weight: bold;
      }
      input {
        width: 250px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        font-size: 14px;
      }
      input:focus {
        outline: none;
        border-color: #007bff;
      }
      input:valid {
        border-color: #28a745;
      }
      input:valid:focus {
        box-shadow: 0 0 0 3px rgba(40, 167, 69, 0.25);
      }
      input:invalid {
        border-color: #dc3545;
      }
      input:invalid:focus {
        box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.25);
      }
      .help-text {
        font-size: 12px;
        margin-top: 5px;
        color: #666;
      }
      input:valid ~ .help-text {
        color: #28a745;
      }
      input:invalid ~ .help-text {
        color: #dc3545;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="form-field">
        <label for="username">Username *</label>
        <input type="text" id="username" required placeholder="Enter username" value="johndoe" />
        <div class="help-text">Username is required</div>
      </div>
      <div class="form-field">
        <label for="email">Email *</label>
        <input type="email" id="email" required placeholder="Enter email" />
        <div class="help-text">Please enter a valid email</div>
      </div>
      <div class="form-field">
        <label for="website">Website</label>
        <input type="text" id="website" placeholder="Optional website" />
        <div class="help-text">Optional field</div>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it(':valid/:invalid combined with :required/:optional', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input {
        width: 200px;
        padding: 8px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 5px;
      }
      /* Required and valid */
      input:required:valid {
        border-color: green;
        border-left-width: 5px;
      }
      /* Required and invalid */
      input:required:invalid {
        border-color: red;
        border-left-width: 5px;
      }
      /* Optional and valid */
      input:optional:valid {
        border-color: blue;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div>
        <input type="text" required value="filled" placeholder="Required, filled" />
        <input type="text" required placeholder="Required, empty" />
        <input type="text" placeholder="Optional, empty" />
        <input type="text" value="filled" placeholder="Optional, filled" />
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();
  });
});
