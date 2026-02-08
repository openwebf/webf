/**
 * CSS Selectors: :placeholder-shown pseudo-class
 * Based on WPT: css/selectors/placeholder-shown.html
 * https://drafts.csswg.org/selectors-4/#placeholder
 */

describe('css selector :placeholder-shown', () => {
  it(':placeholder-shown matches input with placeholder and empty value', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .result {
        display: inline-block;
        padding: 5px 10px;
        margin-left: 10px;
      }
      :not(:placeholder-shown) + .result,
      :placeholder-shown + .result.should-match {
        background-color: green;
        color: white;
      }
      :placeholder-shown + .result:not(.should-match),
      :not(:placeholder-shown) + .result.should-match {
        background-color: red;
        color: white;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div>
        <input type="text" id="t1" />
        <span class="result">No placeholder - should NOT match</span>
      </div>
      <div>
        <input type="text" id="t2" placeholder />
        <span class="result">Empty placeholder attr - should NOT match</span>
      </div>
      <div>
        <input type="text" id="t3" placeholder="" />
        <span class="result">Empty string placeholder - should NOT match</span>
      </div>
      <div>
        <input type="text" id="t4" placeholder="placeholder" />
        <span class="result should-match">Has placeholder - should match</span>
      </div>
      <div>
        <input type="text" id="t5" placeholder="placeholder" value="value" />
        <span class="result">Has value - should NOT match</span>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();

    // Verify matches() API
    const t1 = document.getElementById('t1') as HTMLInputElement;
    const t2 = document.getElementById('t2') as HTMLInputElement;
    const t3 = document.getElementById('t3') as HTMLInputElement;
    const t4 = document.getElementById('t4') as HTMLInputElement;
    const t5 = document.getElementById('t5') as HTMLInputElement;

    // No placeholder attribute - should not match
    expect(t1.matches(':placeholder-shown')).toBe(false);

    // Placeholder attribute without value (empty) - should not match
    expect(t2.matches(':placeholder-shown')).toBe(false);

    // Placeholder attribute - empty string - should not match
    expect(t3.matches(':placeholder-shown')).toBe(false);

    // Placeholder attribute - non-empty string, no value - should match
    expect(t4.matches(':placeholder-shown')).toBe(true);

    // Placeholder attribute with value - should not match
    expect(t5.matches(':placeholder-shown')).toBe(false);
  });

  it(':placeholder-shown floating label pattern', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .form-group {
        position: relative;
        margin: 20px 10px;
      }
      .form-group input {
        width: 200px;
        padding: 15px 10px 5px 10px;
        border: 1px solid #ccc;
        border-radius: 4px;
        font-size: 16px;
      }
      .form-group label {
        position: absolute;
        left: 10px;
        top: 50%;
        transform: translateY(-50%);
        color: #999;
        transition: all 0.2s;
        pointer-events: none;
      }
      /* When placeholder is shown (input is empty), label is in center */
      .form-group input:placeholder-shown + label {
        top: 50%;
        font-size: 16px;
      }
      /* When input has value (placeholder not shown), label moves up */
      .form-group input:not(:placeholder-shown) + label {
        top: 5px;
        font-size: 12px;
        color: #007bff;
      }
      .form-group input:focus + label {
        color: #007bff;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="form-group">
        <input type="text" id="email" placeholder=" " />
        <label for="email">Email Address</label>
      </div>
      <div class="form-group">
        <input type="text" id="filled" placeholder=" " value="john@example.com" />
        <label for="filled">Email Address</label>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it(':placeholder-shown with textarea', async () => {
    const style = document.createElement('style');
    style.textContent = `
      textarea {
        width: 200px;
        height: 80px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 10px;
        resize: none;
      }
      textarea:placeholder-shown {
        border-color: #999;
        background-color: #f9f9f9;
      }
      textarea:not(:placeholder-shown) {
        border-color: green;
        background-color: white;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <textarea id="empty-textarea" placeholder="Enter your message..."></textarea>
      <textarea id="filled-textarea" placeholder="Enter your message...">This has content</textarea>
    `;
    document.body.appendChild(container);

    await snapshot();

    const emptyTextarea = document.getElementById('empty-textarea') as HTMLTextAreaElement;
    const filledTextarea = document.getElementById('filled-textarea') as HTMLTextAreaElement;

    expect(emptyTextarea.matches(':placeholder-shown')).toBe(true);
    expect(filledTextarea.matches(':placeholder-shown')).toBe(false);
  });

  it(':placeholder-shown updates when value changes', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input {
        width: 200px;
        padding: 10px;
        border: 2px solid #ccc;
        border-radius: 4px;
        margin: 10px;
      }
      input:placeholder-shown {
        border-color: orange;
      }
      input:not(:placeholder-shown) {
        border-color: green;
      }
    `;
    document.head.appendChild(style);

    const input = document.createElement('input');
    input.type = 'text';
    input.id = 'dynamic-input';
    input.placeholder = 'Type something...';
    document.body.appendChild(input);

    // Initially empty - should match :placeholder-shown
    await snapshot();
    expect(input.matches(':placeholder-shown')).toBe(true);

    // Add value
    input.value = 'Hello';

    // Should not match :placeholder-shown anymore
    await snapshot();
    expect(input.matches(':placeholder-shown')).toBe(false);

    // Clear value
    input.value = '';

    // Should match again
    await snapshot();
    expect(input.matches(':placeholder-shown')).toBe(true);
  });

  it(':not(:placeholder-shown) sibling selector styling', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .input-wrapper {
        margin: 10px;
        display: flex;
        align-items: center;
      }
      input {
        padding: 8px;
        border: 1px solid #ccc;
        border-radius: 4px;
        width: 150px;
      }
      .clear-btn {
        margin-left: 10px;
        padding: 8px 12px;
        border: none;
        background-color: #dc3545;
        color: white;
        border-radius: 4px;
        cursor: pointer;
        opacity: 0;
        transition: opacity 0.2s;
      }
      input:not(:placeholder-shown) ~ .clear-btn {
        opacity: 1;
      }
      input:placeholder-shown ~ .clear-btn {
        opacity: 0.3;
        pointer-events: none;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <div class="input-wrapper">
        <input type="text" id="search" placeholder="Search..." />
        <button class="clear-btn">Clear</button>
      </div>
      <div class="input-wrapper">
        <input type="text" id="search-filled" placeholder="Search..." value="query" />
        <button class="clear-btn">Clear</button>
      </div>
    `;
    document.body.appendChild(container);

    await snapshot();
  });
});
