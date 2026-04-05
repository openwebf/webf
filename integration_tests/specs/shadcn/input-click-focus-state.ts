describe('shadcn input click focus state', () => {
  it('applies :focus styles after clicking a text input', async () => {
    const style = document.createElement('style');
    style.textContent = `
      body {
        margin: 0;
        padding: 10px;
      }
      input {
        width: 240px;
        height: 36px;
        padding: 4px 12px;
        border: 1px solid rgb(228, 228, 231);
        border-radius: 6px;
        background: white;
        color: rgb(9, 9, 11);
        box-sizing: border-box;
      }
      input:focus {
        outline: none;
        border-color: rgb(212, 212, 216);
        box-shadow: 0 0 0 2px rgb(212, 212, 216);
      }
    `;
    document.head.appendChild(style);

    const input = document.createElement('input');
    input.type = 'text';
    input.placeholder = 'enterprise-canvas';
    document.body.appendChild(input);

    await waitForFrame();
    expect(input.matches(':focus')).toBe(false);
    await snapshot();

    input.click();
    await waitForFrame();
    await snapshot();

    expect(input.matches(':focus')).toBe(true);
  });
});
