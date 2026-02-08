/**
 * CSS Selectors: :enabled and :disabled pseudo-classes
 * Based on WPT: css/selectors/pseudo-enabled-disabled.html
 * https://drafts.csswg.org/selectors-4/#enableddisabled
 */

describe('css selector :enabled/:disabled', () => {
  it(':enabled should match enabled controls', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <button id="button_enabled"></button>
      <button id="button_disabled" disabled></button>
      <input id="input_enabled">
      <input id="input_disabled" disabled>
      <select id="select_enabled"></select>
      <select id="select_disabled" disabled></select>
      <textarea id="textarea_enabled"></textarea>
      <textarea id="textarea_disabled" disabled></textarea>
      <span id="incapable"></span>
    `;
    document.body.appendChild(container);

    const matched = container.querySelectorAll(':enabled');
    for (let i = 0; i < matched.length; i++) {
      const element = matched[i] as HTMLElement;
      expect(element.id.endsWith('_enabled')).toBe(true);
    }

    await snapshot();
  });

  it(':disabled should match disabled controls', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <button id="button_enabled"></button>
      <button id="button_disabled" disabled></button>
      <input id="input_enabled">
      <input id="input_disabled" disabled>
      <select id="select_enabled"></select>
      <select id="select_disabled" disabled></select>
      <textarea id="textarea_enabled"></textarea>
      <textarea id="textarea_disabled" disabled></textarea>
      <span id="incapable"></span>
    `;
    document.body.appendChild(container);

    const matched = container.querySelectorAll(':disabled');
    for (let i = 0; i < matched.length; i++) {
      const element = matched[i] as HTMLElement;
      expect(element.id.endsWith('_disabled')).toBe(true);
    }

    await snapshot();
  });

  it(':not(:enabled) should match disabled controls and non-controls', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <button id="button_enabled"></button>
      <button id="button_disabled" disabled></button>
      <input id="input_enabled">
      <input id="input_disabled" disabled>
      <span id="incapable"></span>
    `;
    document.body.appendChild(container);

    const matched = container.querySelectorAll(':not(:enabled)');
    for (let i = 0; i < matched.length; i++) {
      const element = matched[i] as HTMLElement;
      expect(
        element.id.endsWith('_disabled') || element.id === 'incapable'
      ).toBe(true);
    }
  });

  it(':not(:disabled) should match enabled controls and non-controls', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <button id="button_enabled"></button>
      <button id="button_disabled" disabled></button>
      <input id="input_enabled">
      <input id="input_disabled" disabled>
      <span id="incapable"></span>
    `;
    document.body.appendChild(container);

    const matched = container.querySelectorAll(':not(:disabled)');
    for (let i = 0; i < matched.length; i++) {
      const element = matched[i] as HTMLElement;
      expect(
        element.id.endsWith('_enabled') || element.id === 'incapable'
      ).toBe(true);
    }
  });

  it('styled :enabled button should have green background', async () => {
    const style = document.createElement('style');
    style.textContent = `
      button:enabled {
        background-color: green;
        color: white;
        padding: 10px 20px;
        border: none;
      }
      button:disabled {
        background-color: gray;
        color: darkgray;
        padding: 10px 20px;
        border: none;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <button id="enabled">Enabled Button</button>
      <button id="disabled" disabled>Disabled Button</button>
    `;
    document.body.appendChild(container);

    await snapshot();
  });

  it('styled :disabled input should have different appearance', async () => {
    const style = document.createElement('style');
    style.textContent = `
      input:enabled {
        border: 2px solid green;
        background-color: white;
        padding: 8px;
      }
      input:disabled {
        border: 2px solid gray;
        background-color: #f0f0f0;
        padding: 8px;
      }
    `;
    document.head.appendChild(style);

    const container = document.createElement('div');
    container.innerHTML = `
      <input type="text" placeholder="Enabled input" /><br/>
      <input type="text" placeholder="Disabled input" disabled />
    `;
    document.body.appendChild(container);

    await snapshot();
  });
});
