describe('Accessibility: button label from value', () => {
  it('input[type=button] displays its value as label', async () => {
    const ib = document.createElement('input');
    ib.setAttribute('type', 'button');
    ib.setAttribute('value', 'Tap Me');
    ib.style.margin = '8px';
    document.body.appendChild(ib);

    // Snapshot should capture the label text visually.
    await snapshot();
  });
});

