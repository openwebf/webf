describe('Accessibility: input[type=button] value behavior', () => {
  it('value getter/setter returns attribute value without recursion', async () => {
    const ib = document.createElement('input');
    ib.setAttribute('type', 'button');
    ib.setAttribute('value', 'Press');
    document.body.appendChild(ib);

    // Property getter should reflect attribute value for type=button
    expect((ib as HTMLInputElement).value).toBe('Press');

    // Update attribute and ensure property follows (allow a microtask for propagation)
    ib.setAttribute('value', 'Run');
    await new Promise(r => setTimeout(r, 0));
    expect((ib as HTMLInputElement).value).toBe('Run');

    await snapshot();
  });
});
