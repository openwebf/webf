describe('Input checked attribute/property', () => {
  it('checkbox: checked attribute presence toggles checkedness', async () => {
    const checkbox = document.createElement('input');
    checkbox.setAttribute('type', 'checkbox');

    // Boolean attribute presence should make it checked, regardless of the attribute value.
    checkbox.setAttribute('checked', '');
    document.body.appendChild(checkbox);

    expect((checkbox as any).checked).toBe(true);
    await snapshot();

    checkbox.removeAttribute('checked');
    expect((checkbox as any).checked).toBe(false);
    await snapshot();

    checkbox.setAttribute('checked', 'false');
    expect((checkbox as any).checked).toBe(true);
    await snapshot();
  });

  it('checkbox: checked property set before mount is preserved', async () => {
    const checkbox = document.createElement('input');
    checkbox.setAttribute('type', 'checkbox');

    (checkbox as any).checked = true;
    document.body.appendChild(checkbox);

    expect((checkbox as any).checked).toBe(true);
    await snapshot();

    (checkbox as any).checked = false;
    expect((checkbox as any).checked).toBe(false);
    await snapshot();
  });

  it('radio: checked property toggles within the same group', async () => {
    const r1 = document.createElement('input');
    r1.setAttribute('type', 'radio');
    r1.setAttribute('name', 'g');
    r1.setAttribute('value', 'a');

    const r2 = document.createElement('input');
    r2.setAttribute('type', 'radio');
    r2.setAttribute('name', 'g');
    r2.setAttribute('value', 'b');

    document.body.appendChild(r1);
    document.body.appendChild(r2);

    (r1 as any).checked = true;
    expect((r1 as any).checked).toBe(true);
    expect((r2 as any).checked).toBe(false);
    await snapshot();

    (r2 as any).checked = true;
    expect((r1 as any).checked).toBe(false);
    expect((r2 as any).checked).toBe(true);
    await snapshot();
  });

  it('radio: checked attribute presence selects on first layout', async () => {
    const r1 = document.createElement('input');
    r1.setAttribute('type', 'radio');
    r1.setAttribute('name', 'g2');
    r1.setAttribute('value', 'a');
    r1.setAttribute('checked', '');

    const r2 = document.createElement('input');
    r2.setAttribute('type', 'radio');
    r2.setAttribute('name', 'g2');
    r2.setAttribute('value', 'b');

    document.body.appendChild(r1);
    document.body.appendChild(r2);

    expect((r1 as any).checked).toBe(true);
    expect((r2 as any).checked).toBe(false);
    await snapshot();
  });
});

